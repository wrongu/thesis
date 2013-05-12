if ~exist('W', 'var')
    load('W.mat');
end

[eigenvectors, lambda] = laplacian_eigenvectors(W, mosegParams);

km_opts = statset('UseParallel', 'always');

for K=2:mosegParams.max_clusters
    colors = hsv(K);
    km_clusters = kmeans(eigenvectors, K, 'Start', 'uniform', ...
        'Replicates', mosegParams.repeat_kmeans, ...
        'EmptyAction', 'singleton', ...
        'Options', km_opts);
    for tr=1:length(traj_array)
        traj_array(tr).cluster = km_clusters(tr);
    end
    
    h = figure();
    movie_frame = 1;
    for f=mosegParams.startframe : mosegParams.endframe
        base_img = read(V, f);
        for cluster = 1:K
            selected_trajectories = traj_array(...
                ([traj_array.startframe] <= f) & ...
                ([traj_array.endframe] >= f) & ...
                ([traj_array.cluster] == cluster));
            base_img = drawTrackFrame(base_img, selected_trajectories, f, ...
                colors(cluster,:));
        end
        imshow(base_img);
        title(sprintf('%d clusters', K));
        mov(movie_frame) = getframe(h);
        movie_frame = movie_frame+1;
    end
    close(h);
    all_movies{K-1} = mov;
end