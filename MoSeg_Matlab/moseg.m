function [clusters, trajectories, W] = moseg(mosegParams)
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

[trajectories, fflows, ~] = computeTrajectories(mosegParams);

fprintf('correlating %d trajectories..\n', length(trajectories));

W = createTrajectoryAffinityMatrix(trajectories, fflows, mosegParams);

clusters = SpectralClustering(W, mosegParams.num_clusters, 2);

for k = 1:size(clusters,2)
    trajectories(clusters(:,k)).cluster = k;
end

end