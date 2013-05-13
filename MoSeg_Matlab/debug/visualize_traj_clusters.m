function mov = visualize_traj_clusters(C, traj_array, mosegParams)
h = figure();
movie_frame = 1;
V = VideoReader(mosegParams.video_file);
colors = hsv(size(C,2));
for f=mosegParams.startframe : mosegParams.endframe
    base_img = read(V, f);
    for cluster = 1:size(C,2)
        selected_trajectories = traj_array(...
            ([traj_array.startframe] <= f) & ...
            ([traj_array.endframe] >= f) & ...
            (C(:,cluster)'));
        base_img = drawTrackFrame(base_img, selected_trajectories, f, ...
            colors(cluster,:));
    end
    imshow(base_img);
    title(sprintf('%d clusters', 2));
    mov(movie_frame) = getframe(h);
    movie_frame = movie_frame+1;
end
end