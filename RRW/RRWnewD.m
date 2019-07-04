 function [RWe,We2,We1] = RRWnewD(W)
 %2019 Manuel Curado

n = size(W,2); 
RWe = zeros(n);
We1 = zeros(n);
b = zeros(n);
%%%%
D = Degree(W);
Meye = (1-eye(n));
%Adjacency Matrix
Adj = sparse(W);
[idxAdj] = find(Adj>0);
Adj(idxAdj) = 1;
Wsparse = sparse(W);

for i=1:n
    Di = D(i,i); %Degree i

    Wida = W(i,:);
    for j=1:n
           %GO and return by diferent ways
           P = Wida.*W(j,:);
           P = (P*Di^(-1))*D(j,j)^(-1);

           %Shortest Path
           [dist, path, ~] = graphshortestpath(Wsparse, i, j,'Directed', false);
           %RRW path
           %*********************************
           if(isempty(path)==false)
           
           paths = (P'*P).*Meye;
           
           [We,idx] = max(max(paths));
            We1(i,j) = We; 
           if(We==0)
               idx1 = 1;
               idx2 = 1;
           else
               [I,J] = find(paths==We);
               idx1 = I(1);
               idx2 = J(1);
           end

           path1RRW = W(i,idx1) + W(idx1,j);
           path2RRW = W(j,idx2) + W(idx2,i);

           diffShortestPathRRW = (dist*2)/(path1RRW+path2RRW);
           RWe(i,j) = We*exp(-diffShortestPathRRW);
           %balanced matrix b
           Wi = W(i,idx1) + W(idx2,i);
           Wj = W(idx1,j) + W(j,idx2);
           b(i,j) = abs(1-Wi/Wj); 
           else
               b(i,j) = 0;
               RWe(i,j) = 0;
           end
           %*********************************
    end 
    toc
end

    We2 = RWe;
    RWe = RWe./b;
    for i=1:size(RWe,2)
        RWe(i,i) = 0;
    end
    
    RWe = removeNan(RWe);

    for i=1:size(RWe,2)
        for j=1:size(RWe,2)
            if isinf(RWe(i,j))
                RWe(i,j) = 0;
            end
        end
    end
end
  