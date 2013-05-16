function [C, traj_array] = segment_by_affinity(W, traj_array, mosegParams)

[eigenvectors, lambda] = laplacian_eigenvectors(W, 12);

selection = (lambda > 0) & (lambda < mosegParams.cluster_threshold);
eigenvectors = eigenvectors(:, selection);

km_opts = statset('UseParallel', 'always');

C = kmeans(eigenvectors, mosegParams.num_clusters, ...
    'Start', 'uniform', ...
    'Replicates', mosegParams.repeat_kmeans, ...
    'EmptyAction', 'singleton', ...
    'Options', km_opts);

for tr=1:length(traj_array)
    traj_array(tr).cluster = find(C(tr,:));
end

end