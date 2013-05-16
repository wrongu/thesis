function [clusters, trajectories, W] = moseg(mosegParams, debug)
% moseg(mosegParams) execute motion segmentation algorithm according to the
% given parameters
%
% Inputs:
%   mosegParams - see structMosegParams
%
% Outputs:
%   clusters - T x 1 cluster matrix. Each of the T rows corresponds to a
%   trajectory. clusters(t) == k indicates that trajectory t belongs to
%   cluster k.
%   trajectories - the struct array of trajectories. see structTrajectories
%   W - the affinity matrix from which clusters were computed

if nargin < 2, debug = false; end

% compute trajectories across all specified frames
[trajectories, fflows, ~] = computeTrajectories(mosegParams);

% if debug is on, visualize trajectories
if debug
    fprintf('created %d trajectories..\n', length(trajectories));
    
    if ~exist('visualize_trajectories_trail', 'file')
        addpath('debug');
    end
    mov = visualize_trajectories_trail(trajectories, mosegParams);
    movie(mov, 5, 3);
end

% create affinity matrix
W = createTrajectoryAffinityMatrix(trajectories, fflows, mosegParams);

% segment trajectories using spectral clustering on the affinity matrix
clusters = segment_by_affinity(W, trajectories, mosegParams);

end