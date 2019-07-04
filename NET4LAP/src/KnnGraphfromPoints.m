% Sco 2016
% kNN graph from a set of multidimensional points.
% Input: k and data X (NxD)
% Output: kNN weigthed adjacency matrix 
function [K] = KnnGraphfromPoints(k,X)
% Get the indexes from the second k-th NN one. 
[D,I] = nNNdIndexed(X);
n = size(X,1);
% Prepare memory and build kNN.
K = zeros(n); 
sigma = 2000;
for i=1:n
    for kk=1:k
    % Get the k-th neighbor
        a = X(i,:); 
        b = X(I(i,kk+1),:); 
        d = sum((a-b).^2); % To avoid ambiguities in dimension
        w = exp(-sigma*d); 
        K(i,I(i,kk+1)) =  w; % Not w 
        K(I(i,kk+1),i) =  w; % Not w
        %line([X(i,1),X(I(i,kk+1),1)],[X(i,2),X(I(i,kk+1),2)]);
    end
end
