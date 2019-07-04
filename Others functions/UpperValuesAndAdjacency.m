function [Wa,A] = UpperValuesAndAdjacency(We,percent)
n = size(We,2); 
%Thresholding k max elements of We (Myzero by percent)
%Select the thresholding u
values = reshape(We,n*n,1);
values = sort(nonzeros(values),'Descend');
myzero = values(floor(length(values)*percent),1);
%Select all elements We(i,j) higher than u
[rows, cols] = find(We > myzero);


Wa = zeros(n,n);
Wa(We>myzero) = We(We>myzero);
A = zeros(n,n);
A(We>myzero) = 1;

end