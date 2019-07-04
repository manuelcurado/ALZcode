function D = Degree (A) 
[n,n] = size(A); 
D = eye(n); 
for i = 1:n
   D(i,i) = 0; 
   for j = 1:n 
      D(i,i) = D(i,i) + A(i,j);
   end
end
      