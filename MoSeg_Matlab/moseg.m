function [clusters, trajectories, W] = moseg(mosegParams, debug)
% moseg(mosegParams) execute motion segmentation algorithm according to the
% given parameters
%
% Inputs:
%   mosegParams - see structMosegParams
%
% Outputs:
%   clusters - T x K indicator matrix. Each of the T rows corresponds to a
%   trajectory. clusters(t, k) == 1 indicates that trajectory t belongs to
%   cluster k. clusters contains exactly one 1 in each row, all else is
%   zeros
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
clusters = SpectralClustering(W, mosegParams.num_clusters, 2);

for k = 1:size(clusters,2)
    for tr = find(clusters(:,k))'
        trajectories(tr).cluster = k;
    end
end

end