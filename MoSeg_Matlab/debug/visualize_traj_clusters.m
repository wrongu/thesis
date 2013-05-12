if ~exist('C', 'var')
    if ~exist('W', 'var')
        load('W3.mat');
    end
    C = SpectralClustering(W, 3, 2);
end

h = figure();
movie_frame = 1;
V = VideoReader(mosegParams.video_file);
colors = hsv(3);
for f=mosegParams.startframe : mosegParams.endframe
    base_img = read(V, f);
    for cluster = 1:3
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