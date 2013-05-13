function W = createTrajectoryAffinityMatrix(traj_array, flows, mosegParams)

W = pairwiseDist(traj_array, ...
    'DistFun', @(a, b) traj_dist(a, b, flows, mosegParams), ...
    'UseParallel', 'always', ...
    'Symmetric', 'true', ...
    'SparseOutput', 'true');

save('W.mat', 'W');

end

function affinity = traj_dist(TA, TB, flows, mosegParams)
% DEBUG
V = VideoReader(mosegParams.video_file);

common_frames = max(TA.startframe, TB.startframe) : ...
    min(TA.endframe, TB.endframe);

if length(common_frames) > 1
    pointsA = TA.points(:, common_frames-TA.startframe+1);
    pointsB = TB.points(:, common_frames-TB.startframe+1);
    % average squared spatial distance between the points shared
    % between the trajectories
    diff = pointsA - pointsB;
    Dsp = mean(sqrt(sum(diff .* diff, 1)));
    Dmax = 0;
    computed_one = false;
    for k = 1:length(common_frames)
        t = common_frames(k);
        t_ind = t-common_frames(1)+1;
        t5 = min(t+5-1, common_frames(end));
        t5_ind = t5-common_frames(1)+1;
        if ((t5-t+1 == 5) || ~computed_one) && (t ~= mosegParams.endframe)
            % look at total displacement of points across 5 frames (or
            % however many frames are available)
            dispA = pointsA(:,t5_ind) - pointsA(:,t_ind);
            dispB = pointsB(:,t5_ind) - pointsB(:,t_ind);
            % we now have 2 vectors dispA and dispB that define the net
            % motion of the 2 trajectories over 5 frames. These will be
            % considered 'close' based on the two metrics of direction and
            % magnitude similarity..
            mA = norm(dispA);
            mB = norm(dispB);
            % 1) Direction similarity: cosine of angle between vectors,
            if mA ~= 0 && mB ~= 0
                % cosine computed as dot product of unit vectors
                dsim = sum(dispA .* dispB) / (mA * mB);
                % shift from range [-1, 1] to range [0, 1] so that 
                %   180-degree opposition is given 0
                dsim = 0.5 * dsim + 0.5;
            else
                % one vector was zero.. there can be no directional
                % similarity
                dsim = eps;
            end
            % 2) Magnitude similarity
            msim = 1 - abs(mA - mB) / (mA + mB);
            % distance computation: spatial distance divided by direction-
            % and magnitude-similarity. This assumes (maybe asserts) that
            % 'distance' is inversely proportional to 'similarity'
            D = Dsp / (eps + dsim * msim);
            if D > Dmax, Dmax = D; end
            computed_one = true;
        end
    end
    % convert distance to affinity. Using a gaussian ensures that
    % near-0 distance maps to near-1 affinity, and large magnitude distance
    % maps to near-0 affinity
    affinity = exp(-mosegParams.lambda * Dmax);
    
    % DEBUG
    if rand < 0.01
        subplot(1,2,1);
        imshow(read(V, common_frames(1)));
        hold on;
        plot(TA.points(2,:), TA.points(1,:), '-or', ...
            TB.points(2,:), TB.points(1,:), '-ob');
        hold off;
        set(gca, 'YDir', 'reverse');
        axis([0 size(flows{1}, 2) 0 size(flows{1}, 1)]);
        subplot(1,2,2);
        imshow(flowToColor(flows{common_frames(1)}));
        hold on;
        plot(TA.points(2,:), TA.points(1,:), '-or', ...
            TB.points(2,:), TB.points(1,:), '-ob');
        hold off;
        fprintf('Dsp = %f\ndir sim = %g\n mag sim = %g\nDmax = %f\naffinity = %f', ...
            Dsp, dsim, msim, Dmax, affinity);
        pause;
    end
else
    affinity = 0;
end
end

function sigma2 = flow_variation(u, v, center, window)
half_w = floor(window/2);
% get row and col range covered by the window
rrange = max(round(center(1))-half_w, 1) : ...
    min(round(center(1))+half_w, size(u,1));
crange = max(round(center(2))-half_w, 1) : ...
    min(round(center(2))+half_w, size(u,2));
% get flow covered by specified window
flow_u = u(rrange, crange);
flow_v = v(rrange, crange);
% get variance in each dimension
var_u = var(flow_u(:));
var_v = var(flow_v(:));
sigma2 = var_u * var_u + var_v * var_v;
end

