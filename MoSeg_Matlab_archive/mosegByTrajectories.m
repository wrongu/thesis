function traj_array = mosegByTrajectories(traj_array, flows, mosegParams)

W = createTrajectoryAffinityMatrix(traj_array, flows, mosegParams);

D = diag(sum(W,2));

[V, L] = eig(W-D);

[sort_L, I] = sort(diag(L));

selection = (sort_L > 0) & (sort_L < mosegParams.cluster_threshold);

eigenvectors = V(:, I(selection));

% plot them
m = size(eigenvectors, 2);
spr = floor(sqrt(m));
spc = ceil(m / spr);

midframe = (mosegParams.startframe + mosegParams.endframe) / 2;

Vid = VideoReader(mosegParams.video_file);

img = read(Vid, midframe);

figure();
subplot(spr, spc, 1);
imshow(img);
title('Selected Frame');
for i=2:m
    subplot(spr, spc, i);
    dots = drawTrackFrameIntensity(img, traj_array, midframe, ...
        eigenvectors(:,i-1));
    imshow(dots);
    title(sprintf('eigenvector: value %f', sort_L(i-1)));
end
% end plotting

end