function [eigenvectors, lambda] = laplacian_eigenvectors(W, n)

Dsum = sum(W,2);
D = spdiags(Dsum, 0, size(W,1), size(W,2));
% avoid dividing by zero
Dsum(Dsum == 0) = eps;
% calculate D^(-1/2)
Dsq = spdiags(1./(Dsum .^ 0.5), 0, size(W, 1), size(W, 2));

% calculate normalized Laplacian
L = D - W;
L = Dsq * L * Dsq;

try
    [eigenvectors, lambda] = eigs(L, n, 'SM');
catch
    fprintf('eigs failed. trying with +eps\n');
    [eigenvectors, lambda] = eigs(L + eps*speye(size(W)), n, 'SM');
end
lambda = diag(lambda);
lambda(1) = 0; % in case it was altered by the +eps hack, it should always be 0
end
