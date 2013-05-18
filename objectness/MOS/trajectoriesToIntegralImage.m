function [Iint, areas] = trajectoriesToIntegralImage(sz, clusters, trajectories, frame)

selection = ([trajectories.startframe] <= frame) & ...
            ([trajectories.endframe] >= frame);

T = trajectories(selection);
C = clusters(selection);

labels = unique(C);

% "area" is really the number of points in each cluster (on this frame)
areas = arrayfun(@(l) sum(C == l), labels);

n_clusters = length(labels);

I = zeros(sz(1), sz(2), n_clusters);

% loop over trajectories (that cover the given frame). add a pixel to the
% image wherever a trajectory 
for tr = 1:length(T)
    point = round(T(tr).points(:, frame - T(tr).startframe + 1));
    I(point(1), point(2), labels == C(tr)) = ...
        I(point(1), point(2), labels == C(tr)) + 1;
end

% make integral image
Iint = zeros(sz(1)+1, sz(2)+1, n_clusters);
for ch = 1:sz(I,3)
    Iint(:,:,ch) = computeIntegralImage(I(:,:,ch));
end

end