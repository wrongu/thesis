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
            F = flows{t}; u = F(:,:,1); v = F(:,:,2);
            % look at total displacement of points across 5 frames (or
            % however many frames are available)
            dispA = pointsA(:,t5_ind) - pointsA(:,t_ind);
            dispB = pointsB(:,t5_ind) - pointsB(:,t_ind);
            sq_diff = sum((dispA - dispB) .* (dispA - dispB));
            % normalization based on flow fields
            sigmaA = 0; sigmaB = 0;
            for tsub = t_ind:t5_ind
                sigmaA = sigmaA + sum(arrayfun(@(f) flow_variation(u, v, ...
                    pointsA(:,tsub), ...
                    mosegParams.flow_variation_window), ...
                    t:t5));
                sigmaB = sigmaB + sum(arrayfun(@(f) flow_variation(u, v, ...
                    pointsB(:,tsub), ...
                    mosegParams.flow_variation_window), ...
                    t:t5));
            end
            sigma2 = min(sigmaA, sigmaB);
            % distance computation
            D = Dsp * sq_diff / (5 * sigma2);
            if D > Dmax, Dmax = D; end
            computed_one = true;
        end
    end
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
        fprintf('Dsp = %f\nsigma2 = %f\ndiff displacement = %g\naffinity = %g', ...
            Dsp, sigma2, sq_diff, affinity);
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

