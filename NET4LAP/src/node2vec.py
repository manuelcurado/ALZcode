import numpy as np
import networkx as nx
import random


class Graph():
	def __init__(self, nx_G, is_directed, p, q):
		self.G = nx_G
		self.is_directed = is_directed
		self.p = p
		self.q = q


	def node2vec_walk(self, walk_length, start_node):
		'''
		Simulate a random walk starting from start node.
		'''
		G = self.G
		alias_nodes = self.alias_nodes
		alias_edges = self.alias_edges

		walk = [start_node]

		while len(walk) < walk_length:
			cur = walk[-1]
			cur_nbrs = sorted(G.neighbors(cur))
			# Add current node as neighbor
			cur_nbrs.append(cur)
			if len(cur_nbrs) > 0:
				if len(walk) == 1:
					walk.append(cur_nbrs[alias_draw(alias_nodes[cur][0], alias_nodes[cur][1])])
				else:
					prev = walk[-2]
					next = cur_nbrs[alias_draw(alias_edges[(prev, cur)][0],
						alias_edges[(prev, cur)][1])]
					#print('Next')
					#print(next)
					walk.append(next)
			else:
				break

		return walk

	def simulate_walks(self, num_walks, walk_length):
		'''
		Repeatedly simulate random walks from each node.
		'''
		G = self.G
		walks = []
		nodes = list(G.nodes())
		print('Walk iteration:')
		for walk_iter in range(num_walks):
			print (str(walk_iter+1), '/', str(num_walks))
			random.shuffle(nodes)
			for node in nodes:
				walks.append(self.node2vec_walk(walk_length=walk_length, start_node=node))

		return walks

	def get_alias_edge(self, src, dst, centrality, perron):
		'''
		Get the alias edge setup lists for a given edge.
		'''
		G = self.G
		p = self.p
		q = self.q

		unnormalized_probs = []
		# MaxEnt random walk
		#for dst_nbr in sorted(G.neighbors(dst)):
			#unnormalized_probs.append(np.exp(-G[dst][dst_nbr]['weight'])*(centrality[dst_nbr] / centrality[dst])/perron)
			#unnormalized_probs.append(G[dst][dst_nbr]['weight'] * (centrality[dst_nbr] / centrality[dst]) / perron)
		    #unnormalized_probs.append((centrality[dst_nbr] / centrality[dst]) / perron)

		# Original random walk
		for dst_nbr in sorted(G.neighbors(dst)):
			if dst_nbr == src:
		    		unnormalized_probs.append(G[dst][dst_nbr]['weight']/p)
			elif G.has_edge(dst_nbr, src):
				unnormalized_probs.append(G[dst][dst_nbr]['weight'])
			else:
				unnormalized_probs.append(G[dst][dst_nbr]['weight']/q)
                    #print(G.degree(dst_nbr,'weight'))
		# Absortion random walk with Lambda = Identity
        #for dst_nbr in sorted(G.neighbors(dst)):
		    #unnormalized_probs.append(G[dst][dst_nbr]['weight'])
		#	if dst_nbr == src:
		#		unnormalized_probs.append((1.0 + G[dst][dst_nbr]['weight']) / (1.0 + G.degree(src,'weight')))
		#	else:
		#		unnormalized_probs.append(G[dst][dst_nbr]['weight']/(1.0 + G.degree(src,'weight')))
		norm_const = sum(unnormalized_probs)
		#print(unnormalized_probs)
		normalized_probs =  [float(u_prob)/norm_const for u_prob in unnormalized_probs]

		return alias_setup(normalized_probs)

	def preprocess_transition_probs(self):
		'''
		Preprocessing of transition probabilities for guiding the random walks.
		'''
		G = self.G
		is_directed = self.is_directed

	    # Compute eigenvector centrality
		#centrality = nx.eigenvector_centrality_numpy(G, weight='weight')
		#perron = max(nx.adjacency_spectrum(G, 'weight'))
		centrality = nx.eigenvector_centrality_numpy(G)
		perron = max(nx.adjacency_spectrum(G))
		#nx.draw(G)

		alias_nodes = {}
		for node in G.nodes():
			#(centrality[nbr] / centrality[node])
			#unnormalized_probs = [np.exp(-G[node][nbr]['weight'])*(centrality[nbr] / centrality[node])/perron for nbr in sorted(G.neighbors(node))]
			#unnormalized_probs = [G[node][nbr]['weight']*(centrality[nbr] / centrality[node])/perron for nbr in sorted(G.neighbors(node))]
			#unnormalized_probs = [(centrality[nbr] / centrality[node]) / perron for nbr in sorted(G.neighbors(node))]
			unnormalized_probs = [G[node][nbr]['weight'] for nbr in sorted(G.neighbors(node))]
			norm_const = sum(unnormalized_probs)
			normalized_probs =  [float(u_prob)/norm_const for u_prob in unnormalized_probs]
			alias_nodes[node] = alias_setup(normalized_probs)

		alias_edges = {}
		triads = {}

		# Add self-loops as edges
		#for node in G.nodes():
		#	G.add_edge(node,node, weight=1.0)


		if is_directed:
			for edge in G.edges():
				alias_edges[edge] = self.get_alias_edge(edge[0], edge[1], centrality, perron)
		else:
			for edge in G.edges():
				alias_edges[edge] = self.get_alias_edge(edge[0], edge[1], centrality, perron)
				alias_edges[(edge[1], edge[0])] = self.get_alias_edge(edge[1], edge[0], centrality, perron)

		self.alias_nodes = alias_nodes
		self.alias_edges = alias_edges

		return


def alias_setup(probs):
	'''
	Compute utility lists for non-uniform sampling from discrete distributions.
	Refer to https://hips.seas.harvard.edu/blog/2013/03/03/the-alias-method-efficient-sampling-with-many-discrete-outcomes/
	for details
	'''
	K = len(probs)
	q = np.zeros(K)
	J = np.zeros(K, dtype=np.int)

	smaller = []
	larger = []
	for kk, prob in enumerate(probs):
	    q[kk] = K*prob
	    if q[kk] < 1.0:
	        smaller.append(kk)
	    else:
	        larger.append(kk)

	while len(smaller) > 0 and len(larger) > 0:
	    small = smaller.pop()
	    large = larger.pop()

	    J[small] = large
	    q[large] = q[large] + q[small] - 1.0
	    if q[large] < 1.0:
	        smaller.append(large)
	    else:
	        larger.append(large)

	return J, q

def alias_draw(J, q):
	'''
	Draw sample from a non-uniform discrete distribution using alias sampling.
	'''
	K = len(J)

	kk = int(np.floor(np.random.rand()*K))
	if np.random.rand() < q[kk]:
	    return kk
	else:
	    return J[kk]