function W = createTrajectoryAffinityMatrix(traj_array, flows, mosegParams)

N = length(traj_array);

% TODO - consider using 'sparse(N,N);'
W = sparse(N,N);

% loop over trajectory pairs (TA,TB)
time_per = 0; iter = 1; total = N*(N-1)/2;
count_nonzero = 0;
for i=1:N
    TA = traj_array(i);
    for j=i+1:N
        tstart = tic;
        TB = traj_array(j);
        common_frames = max(TA.startframe, TB.startframe) : ...
            min(TA.endframe, TB.endframe);
        
        if ~isempty(common_frames)
            count_nonzero = count_nonzero+1;
            
            pointsA = TA.points(:, common_frames-TA.startframe+1);
            pointsB = TB.points(:, common_frames-TB.startframe+1);
            % average squared spatial distance between the points shared
            % between the trajectories
            diff = pointsA - pointsB;
            Dsp = mean(sum(diff .* diff, 1));
            Dmax = 0;
            computed_one = false;
            for k = 1:length(common_frames)
                t = common_frames(k);
                t_ind = t-common_frames(1)+1;
                t5 = min(t+5, common_frames(end));
                t5_ind = t5-common_frames(1)+1;
                if ((t5-t+1 == 5) || ~computed_one) && (t ~= mosegParams.endframe)
                    F = flows{t}; u = F(:,:,1); v = F(:,:,2);
                    % look at total displacement of points across 5 frames (or
                    % however many frames are available)
                    dispA = pointsA(:,t5_ind) - pointsA(:,t_ind);
                    dispB = pointsB(:,t5_ind) - pointsB(:,t_ind);
                    sq_diff = sum((dispA - dispB) .* (dispA - dispB));
                    % normalization based on flow fields
                    sigmaA = sum(arrayfun(@(f) flow_variation(u, v, ...
                        pointsA(:, t_ind), ...
                        mosegParams.flow_variation_window), ...
                        t:t5));
                    sigmaB = sum(arrayfun(@(f) flow_variation(u, v, ...
                        pointsB(:, t_ind), ...
                        mosegParams.flow_variation_window), ...
                        t:t5));
                    sigma2 = min(sigmaA, sigmaB);
                    % distance computation
                    D = Dsp * sq_diff / (5 * sigma2);
                    if D > Dmax, Dmax = D; end
                    computed_one = true;
                end
            end
            W(i,j) = exp(-mosegParams.lambda * Dmax);
            W(j,i) = W(i,j);
            
        end
            
	telapse = toc(tstart);
	if(time_per == 0), time_per = telapse*2; fprintf('              '); end
	time_per = time_per + (telapse - time_per) / 10000;
	iter_remain = total - iter;
	iter = iter+1;
	tremain = iter_remain * time_per;
	fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\bETR: %.5d min', floor(tremain / 60));
            
    end
end

save('W.mat', 'W');

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
