function H = vonNeumannEntropy(G)
D = Degree(G);
V = size(G,2);
aux = 0;
for i=1:V
    for j=1:V
        if G(i,j) > 0
            aux = aux + 1/(4*D(i,i)*D(j,j));
        end
    end
end
H = V/4 - aux;
end