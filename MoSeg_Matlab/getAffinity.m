% get affinity matrix. If saved, load it. If not, compute and save it. This
% builds up a lot of files on the system but saves a *lot* of time when
% running multiple training runs on the same data.
%
% see ../LDOF_Matlab/getFlow

function [traj_array, W] = getAffinity(mosegParams, debug)

if nargin < 3, debug = false; end

fname = get_save_file(mosegParams);
if exist(fname, 'file')
    struct = load(fname);
    W = struct.W;
    traj_array = struct.traj_array;
else
    % compute trajectories across all specified frames
    [traj_array, ~, ~] = computeTrajectories(mosegParams, debug);
    
    % if debug is on, output about trajectories
    if debug
        %     addpath(fullfile(pwd, '..', 'MoSeg_Matlab', 'debug'));
        fprintf('created %d trajectories..\n', length(traj_array));
        
        %     if ~exist('visualize_trajectories_trail', 'file')
        %         addpath('debug');
        %     end
        %     mov = visualize_trajectories_trail(trajectories, mosegParams);
        %     movie(mov, 5, 3);
    end
    
    if debug, tic; end;
    W = createTrajectoryAffinityMatrix(traj_array, mosegParams);
    if debug, toc; end;
    save(fname, 'W', 'traj_array');
end

end


function filename = get_save_file(mosegParams)
% return filename for .mat save file that is unique to the given
% parameters. Parameters that would generate the same trajectories are
% given the same file name.

[path, vid, ~] = fileparts(mosegParams.video_file);
s = mosegParams.sampling;
st = mosegParams.startframe;
en = mosegParams.endframe;
init = mosegParams.init_threshold;

filename = sprintf('%s_%d-%d_init%d-%f.mat', vid, st, en, s, init);
filename = fullfile(path, 'moseg affinities', filename);

end