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

% load or create affinity matrix
[trajectories, W] = getAffinity(mosegParams, debug);

% segment trajectories using spectral clustering on the affinity matrix
clusters = segment_by_affinity(W, trajectories, mosegParams);

end