function [in,out] = inOutDegree(M)
for i=1:size(M,2)
    in(1,i) = sum(M(:,i));
    out(1,i) = sum(M(i,:));
end
end