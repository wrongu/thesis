% drawTrackFrameIntensity.m
%
% created on May 6, 2013
% written by Richard Lange
%
% Draw the specified trajectory with points' darnkess corresponding to the
% given array of associated intensities
%
% Inputs:
%   traj_array - the trajectories as a struct array. see structTrajectory.m
%   frame - the frame to extract from traj_array

function new_img = drawTrackFrameIntensity(img, traj_array, frame, intensities)

[h, w, ~] = size(img);
new_img = ones(size(img));
point_size = 1;

% select trajectories with startframe before and endframe after the
% frame.
selection = ([traj_array.startframe] <= frame) & ...
            ([traj_array.endframe] >= frame);
selected_trajectories = traj_array(selection);
% get points from trajectories
points = zeros(2, length(selected_trajectories));
intensities = intensities(selection);
intensities = intensities / max(intensities);
for t=1:length(selected_trajectories)
    traj = selected_trajectories(t);
    points(:,t) = traj.points(:, frame - traj.startframe + 1);
end

for p=1:size(points,2)
    rowrange = max(1, round(points(1,p)-point_size)) : ...
        min(h, round(points(1,p)+point_size));
    colrange = max(1, round(points(2,p)-point_size)) : ...
        min(w, round(points(2,p)+point_size));
    
    new_img(rowrange, colrange, :) = 1 - intensities(p);
end

end