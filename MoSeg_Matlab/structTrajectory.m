% structTrajectory.m
%
% created on April 30, 2013
% written by Richard Lange
%
% this file defines the architecture of the 'trajectory' struct. A single
% trajectory is a pixel location [row; col] tracked over multiple frames.
% A set of trajectories are defined as a structure array of tracks sorted
% by end frame.
%
% trajectory struct:
%   traj.startframe = integer frame number
%   traj.endframe = integer frame number
%   traj.duration = number of frames
%   traj.points = 2 x duration matrix of [row; col] points in the image
%   traj.cluster = integer id of this trajectory's cluster
%
% Note that there is a lot of redundancy. This allows for trajectories to
% be subselected by any of their properties. For example to select all
% trajectories that end before a given frame F, we could do:
%
% |selection = traj_array([traj_array.endframe] < F);|
%
% this is much cleaner than using a combination of startframe and duration,
% for example

function traj_array = structTrajectory(n_trajectories, frame, point)

if nargin < 2
    frame = 1;
end

if nargin < 3
    point = [0 0]';
else
    % ensure proper point dimensions: 2x1
    point = [point(1) point(2)]';
end

traj_array(1:n_trajectories) = struct( ...
    'startframe', frame, ...
    'endframe', frame, ...
    'duration', 1, ...
    'points', point, ...
    'cluster', 1);
end