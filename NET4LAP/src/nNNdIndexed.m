%n nearest neigbors
%input NxD data
%output NxK (where k = N-1, actually)
function [D,I] = nNNdIndexed(data)
[D,I]=sort(dist(data'),2);
D=D(:,2:end);
I=I(:,2:end);
return
