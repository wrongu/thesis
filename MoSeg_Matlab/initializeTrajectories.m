% initializeTrajectories.m
%
% created on April 30, 2013
% written by Richard Lange
%
% Initialize trajectories based on the texture of the image. See Sundaram
% 2010 for the definition of how this texture thresholding is done.
%
% Inputs
%   img - a 3-channel double image
%   mosegParams - parameters struct. see structMosegParams.m
%   existing_points (optional) - 2xK array of points that already exist and
%                               should be avoided

function trajectory_array = initializeTrajectories(img, ...
    mosegParams, other_points)

if nargin < 3
    other_points = [];
end

[h, w, ~] = size(img);

half_window = floor(mosegParams.init_window/2);
window = -half_window : half_window;

% add border around image to prevent out-of-bounds with window. border
% 'extend' is used in an attempt to preserve textureness near edges
img = addImgBorder(img, half_window, 'extend');

Ix = DGradient(img, 2); % is along columns
Iy = DGradient(img, 1); % y is along rows
% window function is 2D gaussian kernel
Kp = gauss2d(mosegParams.init_window, 1);
% enforce sum to one:
Kp = Kp / sum(Kp(:));

xsamples = floor(mosegParams.sampling/2)+1 : mosegParams.sampling : w;
ysamples = floor(mosegParams.sampling/2)+1 : mosegParams.sampling : h;

% structure-tensor. S(i,j) corresponds to the pixel (ysamples(i), xsamples(j)
% in img, and contains the corresponding image coordinates, and the second
% eigenvalue of the structure tensor at that location
S(1:length(ysamples), 1:length(xsamples)) = ...
    struct('img_pt', [0;0], 'lambda2', 0);

for i = 1:length(ysamples)
    % (r,c) is index into image that is center of window. note offset by
    % half_window to account for the added border
    r = ysamples(i) + half_window;
    for j = 1:length(xsamples)
        c = xsamples(j) + half_window;
        S(i,j).img_pt = [r-half_window c-half_window]';
        % check for nearby points in 'other_points'. Skip this point if
        % there is already one nearby.
        if ~isempty(find_pt_in_range(other_points, S(i,j).img_pt, ...
                mosegParams.sampling / sqrt(2)))
            continue;
        end
        structure = zeros(2,2);
        for depth=1:size(img, 3)
            Ix_patch = Ix(r+window, c+window, depth);
            Iy_patch = Iy(r+window, c+window, depth);
            structure(1,1) = structure(1,1) + sum(sum(Ix_patch .* Ix_patch .* Kp));
            structure(1,2) = structure(1,2) + sum(sum(Ix_patch .* Iy_patch .* Kp));
            structure(2,2) = structure(2,2) + sum(sum(Iy_patch .* Iy_patch .* Kp));
        end
        % symmetry of 2x2 structure matrix:
        structure(2,1) = structure(1,2);
        % texture score is the second eigenvalue
        eigenvalues = eig(structure);
        S(i,j).lambda2 = eigenvalues(2);
    end
end

mean_eigenvalue = mean([S.lambda2]);
textured_points = S([S.lambda2] > mosegParams.init_threshold * mean_eigenvalue);
trajectory_array = structTrajectory(length(textured_points), 1);

for t=1:length(trajectory_array)
    trajectory_array(t).points = textured_points(t).img_pt;
end

end

function gauss_matr = gauss2d(size, sigma)

half_size = floor(size/2);
x = -half_size:half_size;
gauss_vec = exp(-x.^2 / (2*sigma^2)) / (sigma * sqrt(2*pi));
gauss_matr = gauss_vec' * gauss_vec;

end

function nearby_pt = find_pt_in_range(pts, query_pt, within_range)
% find any point in pts that is (euclidean distance) within the given range
% of the query_pt pts is 2xK of [x, y]'
%
% TODO - use quadtree search for nearest points within range. This will
% require 2 functions: build_quadtree and search_quadtree_range

nearby_pt = [];
range_sq = within_range^2;
for p = 1:size(pts,2)
    test_pt = pts(:,p);
    sq_dist = sum((test_pt - query_pt) .* (test_pt - query_pt));
    if (sq_dist < range_sq)
        nearby_pt = test_pt;
        return;
    end
end
end

%{
% unused helper function
function nearest_pt = find_nearest_pt(pts, query_pt, within_range)
% find the nearest point in pts to the given query_pt that is not
% farther than within_range. pts is 2xK of [x, y]'

nearest_pt = [];
range_sq = within_range^2;
nearest_sq_dist = range_sq + 1;
for p = 1:size(pts,2)
    test_pt = pts(:,p);
    sq_dist = sum((test_pt - query_pt) .* (test_pt - query_pt));
    if (sq_dist < range_sq) && (sq_dist < nearest_sq_dist)
        nearest_pt = test_pt;
        nearest_sq_dist = sq_dist;
    end
end
end
%}