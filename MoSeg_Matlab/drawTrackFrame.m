% drawTrackFrame.m
%
% created on April , 2013
% written by Richard Lange
%
% overlay points on the image according to the position of the trajectories
% at the given frame. The type of overlay can be specified in the
% (optional) fourth through sixth parameters
%
% Inputs:
%   img - the image to draw the overlay onto
%   traj_array - the trajectories as a struct array. see structTrajectory.m
%   frame - the frame to extract from traj_array
%   color (optional) - [r g b] color of marker. default is red [1 0 0]
%   marker (optional) - one of {'o', '+', '.'}. specifies the type of
%                       overlay to draw
%   marker_size (optional) - width, in pixels, of the marker. even sizes
%                            incremented to next odd number

function new_img = drawTrackFrame(img, traj_array, frame, color, marker, marker_size)

if nargin < 4
    color = [1 0 0];
end
if nargin < 5
    marker = '.';
end
if nargin < 6
    marker_size = 3;
end
half_size = floor(marker_size/2);

% make 3-channel so color will work
if size(img, 3) == 1
    img = repmat(img, [1 1 3]);
end

[h w ~] = size(img);

% add border to prevent out-of-bounds problems
new_img = addImgBorder(img, half_size);

% select trajectories with startframe before and endframe after the
% frame.
selected_trajectories = traj_array(...
    ([traj_array.startframe] <= frame) & ...
    ([traj_array.endframe] >= frame));
%     fprintf('%d trajectories selected\n', length(selected_trajectories));
% get points from trajectories
points = zeros(2, length(selected_trajectories));
for t=1:length(selected_trajectories)
    traj = selected_trajectories(t);
    points(:,t) = traj.points(:, frame - traj.startframe + 1);
end

% draw points on the image
marker_matrix = get_marker_matrix(marker, marker_size, color);
for p=1:size(points,2)
    % use half_size to shift from original image coordinates to
    % image-with-border coordinates
    rowrange = half_size + round((points(1,p)-half_size : points(1,p)+half_size));
    colrange = half_size + round((points(2,p)-half_size : points(2,p)+half_size));
    img_chunk = new_img(rowrange, colrange, :);
    img_chunk(marker_matrix ~= -1) = marker_matrix(marker_matrix ~= -1);
    new_img(rowrange, colrange, :) = img_chunk;
end

% remove border
new_img = new_img(half_size + (1:h), half_size + (1:w), :);

end

function matrix = get_marker_matrix(marker, size, color)

% ensure size is odd
size = floor(size/2)*2 + 1;

% initialize matrix. unused pixels are -1 (since 0 is used for black)
matrix = -ones(size,size,3);

switch marker
    case 'o'
        matrix(1,:,1) = color(1);
        matrix(1,:,2) = color(2);
        matrix(1,:,3) = color(3);
        matrix(end,:,1) = color(1);
        matrix(end,:,2) = color(2);
        matrix(end,:,3) = color(3);
        matrix(:,1,1) = color(1);
        matrix(:,1,2) = color(2);
        matrix(:,1,3) = color(3);
        matrix(:,end,1) = color(1);
        matrix(:,end,2) = color(2);
        matrix(:,end,3) = color(3);
    case '+'
        matrix(ceil(size/2),:,1) = color(1);
        matrix(ceil(size/2),:,2) = color(2);
        matrix(ceil(size/2),:,3) = color(3);
        matrix(:,ceil(size/2),1) = color(1);
        matrix(:,ceil(size/2),2) = color(2);
        matrix(:,ceil(size/2),3) = color(3);
    case '.'
        matrix(:,:,1) = color(1);
        matrix(:,:,2) = color(2);
        matrix(:,:,3) = color(3);
end
end