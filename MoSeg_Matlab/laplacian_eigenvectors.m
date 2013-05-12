function [eigenvectors, eigenvalues] = laplacian_eigenvectors(W, mosegParams)
D = sum(W,2);
Dsq = diag(D .^ (-1/2));
D = diag(D);
L = D-W;
L = Dsq * L * Dsq;
L = L + 10*eps*speye(size(L));

[eigenvectors, lambda] = eigs(L, 20, 'SM');
lambda = diag(lambda);

selection = (lambda > 0) & (lambda < mosegParams.cluster_threshold);

eigenvectors = eigenvectors(:, selection);
end