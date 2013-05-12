N = 100;

sym = true;

A = zeros(N,N,3);

if(sym)
    % total number of pairs (including (i,i), the diagonal)
    pairs = N * (N+1) / 2; 
else
    pairs = N*N;
end

colors = [linspace(1,0,pairs)', zeros(1,pairs)', linspace(0,1,pairs)'];

for i=1:pairs
    [r, c] = itorc(i, N, sym);
    A(r,c,:) = reshape(colors(i,:), [1 1 3]);
end

close all;
imshow(A);