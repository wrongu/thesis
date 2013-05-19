% visualize_trajectories_trail
%
% visualize trajectories in a movie where each frame draws the points with
% a 'trail' coming from the previous frame
function mov = visualize_trajectories_trail(traj_array, mosegParams)

h = figure();
movie_frame = 1;
V = VideoReader(mosegParams.video_file);
for f = int32(mosegParams.startframe) : int32(mosegParams.endframe)
    base_img = read(V, f);
    % draw dots on this frame
    selected_trajectories = traj_array(...
        ([traj_array.startframe] <= f) & ...
        ([traj_array.endframe] >= f));
    base_img = drawTrackFrame(base_img, selected_trajectories, f, ...
        [1 0 0 ]);
    imshow(base_img);
    % draw tails
    selected_trajectories = traj_array(...
        ([traj_array.startframe] <= f-1) & ...
        ([traj_array.endframe] >= f));
    fprintf('%d trajs can have tails\n', length(selected_trajectories));
    hold on;
    for tr = 1:length(selected_trajectories)
        T = selected_trajectories(tr);
        prevPt = T.points(:, f-T.startframe);
        curPt = T.points(:, f-T.startframe+1);
        plot([prevPt(2) curPt(2)],[prevPt(1) curPt(1)], 'g');
    end
    hold off;
    mov(movie_frame) = getframe(h);
    movie_frame = movie_frame+1;
end

disp('done');
end