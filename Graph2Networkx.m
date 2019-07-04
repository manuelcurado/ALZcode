function [ edge_list ] = Graph2Networkx(W,type,myzero)
% Graph to Networkx text function. 
% Type: 0-unweighted 1-weighted
% Output: edge_list (write_later) 
% Assumtion: W is SYMMETRIC!

 n = size(W,2);
 edge_list = []; 
 trilW = tril(W); % for creating ordered i<j
 %trilW = trilW(trilW<myzero);
 if type == 0 
     [i,j] = find(trilW==1);
     edge_list = [j i];
 else
      [i,j] = find(trilW>myzero)
     edge_list = [j i trilW(trilW>myzero)];
end

