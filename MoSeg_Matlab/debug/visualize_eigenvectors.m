[eigenvectors, lambda] = laplacian_eigenvectors(W, mosegParams);

% plot them
m = sum(selection);
spr = floor(sqrt(m+1));
spc = ceil((m+1) / spr);

midframe = floor((mosegParams.startframe + mosegParams.endframe) / 2);

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
    title(sprintf('eigenvector: value %g', lambda(i-1)));
end