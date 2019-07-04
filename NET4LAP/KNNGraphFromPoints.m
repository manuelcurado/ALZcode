function [G, sigma] = KNNGraphFromPoints(X,k)
% KNN graph with optimal sigma. 
% Input X: nxd, k 
% Output knn graph and sigma (the inverse to the one used in graph from
% points)

% Firstly compute the distance matrix 
Dis = squareform(pdist(X)); 
Dis = Dis.^2; 

% Sort Distance matrix (ascend because they are not similarities) 
[B,IX] = sort(Dis,2);

% Compute optimal sigma (small sigma for big t,and vicecersa)  
Dmean = mean(Dis(:,2:end)); % Mean of distances x column
Smean = mean(Dmean); 
sigma = (k/100)*Smean; 

n = size(X,1); 
G = zeros(n); 
 

for i=1:n
  % Run through the neighbors 
  % Get the indexes up to the k-th nearest neighbor
  knns=IX(i,1:k+1);
  for l=1:k+1 
    if i~=knns(l) % Dont get the diagonal 
        a = knns(l); 
        G(i,a)=exp(-Dis(i,a)/sigma); 
        if G(a,i)==0 
            G(a,i)=exp(-Dis(i,a)/sigma); 
        end
    end
  end
end 
end

