h = figure();
for i=1:length(fflows)
    f = fflows{i};
    maxframe = max(max(max(abs(f))));
    if maxframe > maxval, maxval = maxframe; end
end

V = VideoReader(mosegParams.video_file);

for i=1:length(fflows)
    img = read(V, mosegParams.startframe+i-1);
    subplot(1,3,1);
    imshow(img);
    f = fflows{i};
    subplot(1,3,2);
    imshow(0.5 * f(:,:,1) / maxval + 0.5);
    title('u component');
    subplot(1,3,3);
    imshow(0.5 * f(:,:,2) / maxval + 0.5);
    title('v component');
    mov(i) = getframe(h);
end