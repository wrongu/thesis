function [] = makeVideo(name, frames, transform)

if nargin < 3
    % do-nothing transform
    transform = @(I) I;
end

V = VideoWriter(name);
open(V);
for i=1:length(frames)
    writeVideo(V, transform(imread(frames{i})));
end
close(V);

end