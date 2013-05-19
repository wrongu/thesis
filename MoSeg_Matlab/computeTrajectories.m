% computeTrajectories.m
%
% created on April 30, 2013
% written by Richard Lange
%
% computes the trajectories according to all parameters set in mosegParams
%   see structMosegParams.m for definition of these params
%   see structTrajectory.m for definition of trajectory struct

function [traj_array, forward_flows, backward_flows] = ...
    computeTrajectories(mosegParams, debug)

if nargin < 2, debug = false; end

verifyMosegParams(mosegParams, 'computeTrajectories.m');

vid = mosegParams.video_file;
V = VideoReader(vid);
Vdata = get(V, {'Height', 'Width', 'NumberOfFrames'});
nframes = Vdata{3};

traj_array = initializeTrajectories(read(V, mosegParams.startframe), ...
    mosegParams, mosegParams.startframe);
% trajectories before this index are 'closed.' that is, they have been
% fully computed from start frame to end frame.
open_index = 1;

% precompute optic flow since this is a big time bottleneck and can be more
% easily parallelized if done as a separate step
frames = mosegParams.startframe : mosegParams.endframe-1;
forward_flows = cell(1, length(frames));
backward_flows = cell(1, length(frames));
nflows = length(frames);
parfor i=1:nflows
    f = frames(i);
    if f < nframes
        if debug, fprintf('forward flow %d of %d\n', i, nflows); end
        flow = getFlow(vid, f, 'forward', V);
        forward_flows{i} = flow;
    else
        forward_flows{i} = [];
    end
    if f > 1
        if debug, fprintf('backward flow %d of %d\n', i, nflows); end
        back_flow = getFlow(vid, f, 'reverse', V);
        backward_flows{i} = back_flow;
    else
        backward_flows{i} = [];
    end
    %     Icurr = read(V, f);
    %     Inext = read(V, f+1);
    %     [flow, ~, ~] = LDOF(Icurr, Inext, ldof_params, false);
    %     [back_flow, ~, ~] = LDOF(Inext, Icurr, ldof_params, false);
end

% main loop to build trajectories
Inext = read(V, mosegParams.startframe);
for i=1:nflows
    f = frames(i);
    if debug, fprintf('trajectories: frame %d of %d\n', f, mosegParams.endframe-1); end
    % get forward flow from frame f to frame f+1
    flow = forward_flows{i};
    u = flow(:,:,1); % u is flow in x direction
    v = flow(:,:,2); % v is flow in y direction
    % gradient of flow is used for checking motion boundaries
    grad_u_x = DGradient(u);
    grad_u_y = DGradient(u,2);
    grad_v_x = DGradient(v);
    grad_v_y = DGradient(v,2);
    % get backward flow from frame f+1 back to frame f. This is used to
    % check for occlusions. in the no-occlusion case, the fwd and backward
    % flows will agree (since they came from the same object)
    back_flow = backward_flows{i};
    bu = back_flow(:,:,1);
    bv = back_flow(:,:,2);
    % loop over open trajectories. either extend them with new points or
    % close them.
    for t = open_index:length(traj_array)
        % follow the optic flow vector to follow this point to the next
        % frame
        point = traj_array(t).points(:,end);
        % interp2 is used to interpolate the flow at non-integer pixels.
        % The default (and desired) method is bilinear interpolation.
        % note that interp2 takes (x,y) but point is [row; col], so they
        % appear to be reversed
        dx = interp2(u, point(2), point(1));
        dy = interp2(v, point(2), point(1));
        pt_new = point + [dy dx]';
        % two conditions can cause us to stop tracking this point:
        % 1) the point is occluded by some other object. this is measured
        %    by checking the consistency between forward and backward flow.
        % 2) the point is on an ambiguous motion boundary that could cause
        %    it to switch objects later
        % # Occlusion Check
        % this is done as a consistestency check between forward and
        % backward flow.
        bdx = interp2(bu, pt_new(2), pt_new(1));
        bdy = interp2(bv, pt_new(2), pt_new(1));
        % see equation (5) from Sundaram 2010
        consistent = (dx+bdx)^2 + (dy+bdy)^2 < ...
            0.01*(dx^2 + dy^2 + bdx^2 + bdy^2) + 0.5;
        stop_tracking = false;
        if consistent
            gux = interp2(grad_u_x, point(2), point(1));
            guy = interp2(grad_u_y, point(2), point(1));
            gvx = interp2(grad_v_x, point(2), point(1));
            gvy = interp2(grad_v_y, point(2), point(1));
            % # Motion Boundary Check
            % see equation (6) from Sundaram 2010.
            motion_boundary = gux^2 + guy^2 + gvx^2 + gvy^2 > ...
                0.01 * (dx^2 + dy^2) + 0.002;
            if motion_boundary, stop_tracking = true; end
        else
            stop_tracking = true;
        end
        if stop_tracking
            % we aren't tracking to frame f+1, so last frame is f
            traj_array(t).endframe = f;
            traj_array(t).duration = (f - traj_array(t).startframe + 1);
            % transfer this trajectory to the 'closed' part of the array
            % (that is, all indices before 'open index') by swapping it
            % with the first open one.
            temp = traj_array(open_index);
            traj_array(open_index) = traj_array(t);
            traj_array(t) = temp;
            open_index = open_index + 1;
        else
            % this trajectory is still open. add a new point to it.
            traj_array(t).points(:,end+1) = pt_new;
        end
    end
    
    if debug && ~check_durations(traj_array, open_index)
        pause;
    end
    
    % here, all trajectories have been updated for frame f. Some were
    % closed, so we need to re-initialize in textured areas of the image
    % just like for the first frame.
    endpts_cell = cellfun(@(pts) pts(:,end), ...
        {traj_array(open_index:end).points}, 'UniformOutput', false);
    endpts_array = horzcat(endpts_cell{:});
    new_trajectories = initializeTrajectories(Inext, mosegParams, ...
        f+1, endpts_array);
    traj_array = horzcat(traj_array, new_trajectories);
end



% all remaining trajectories' end frame is the final frame
for t = open_index:length(traj_array)
    traj_array(t).endframe = mosegParams.endframe;
    traj_array(t).duration = ...
        traj_array(t).endframe - traj_array(t).startframe + 1;
end

% remove trajectories whose duration is only one frame (these give no
% information to further processing, and only get in the way)
traj_array = traj_array([traj_array.duration] > 1);

end

function ok = check_durations(traj_array, open_index)

ok = true;

for t = 1:open_index - 1;
    if size(traj_array(t).points, 2) ~= traj_array(t).duration
        fprintf('trajectory %d is inconsistent\n', t);
        ok = false;
    end
end

end