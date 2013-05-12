function traj_array = mosegByTrajectories(traj_array, flows, mosegParams)

W = createTrajectoryAffinityMatrix(traj_array, flows, mosegParams);

D = sum(W,2);
Dsq = diag(D .^ (-1/2));
D = diag(D);
normalized_laplacian = Dsq * (D - W) * Dsq;

[eigenvectors, lambda] = eigs(normalized_laplacian, 20, 'SM');

lambda = diag(lambda);
selection = (lambda > 0) & (lambda < mosegParams.cluster_threshold);
eigenvectors = eigenvectors(:, selection);

km_opts = statset('UseParallel', 'always');

for K=2:mosegParams.max_clusters
    km_clusters = kmeans(eigenvectors, K, 'Start', 'uniform', ...
        'Replicates', mosegParams.repeat_kmeans, ...
        'EmptyAction', 'singleton', ...
        'Options', km_opts);
    hier_clusters = linkage(pdist(eigenvectors));
    for tr=1:length(traj_array)
        traj_array(tr).cluster = km_clusters(tr);
    end
end

end