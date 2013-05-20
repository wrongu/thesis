function boxes = scoreOFD(Flow, windows, thetaOF)
% scoreOF(Flow, windows, thetaOF) compute score as 

U = Flow(:,:,1);
V = Flow(:,:,2);

intU = computeIntegralImage(U);
intV = computeIntegralImage(V);

% compute net flow direction inside windows
areas_in = (windows(:,3)-windows(:,1)+1) .* (windows(:,4)-windows(:,2)+1);
sumU_in = computeIntegralImageScores(intU, windows);
sumV_in = computeIntegralImageScores(intV, windows);

% compute net flow direction in outer ring
windows_out = window_offset(windows, thetaOF, 'out', size(U, 2), size(U, 1));
areas_ring = (windows_out(:,3)-windows_out(:,1)+1) .* ...
    (windows_out(:,4)-windows_out(:,2)+1) - areas_in;
sumU_ring = computeIntegralImageScores(intU, windows_out) - sumU_in;
sumV_ring = computeIntegralImageScores(intV, windows_out) - sumV_in;

% take averages for inside and outside
areas_in(areas_in == 0) = eps;
areas_ring(areas_ring == 0) = eps;

meanU_in = sumU_in ./ areas_in;
meanV_in = sumV_in ./ areas_in;
meanU_ring = sumU_ring ./ areas_ring;
meanV_ring = sumV_ring ./ areas_ring;

mean_in = [meanU_in, meanV_in]';
mean_ring = [meanU_ring, meanV_ring]';

norm_in = sqrt(sum(mean_in .* mean_in));
norm_in(norm_in == 0) = eps;
norm_ring = sqrt(sum(mean_ring .* mean_ring));
norm_ring(norm_ring == 0) = eps;

unit_in = mean_in ./ [norm_in; norm_in];
unit_ring = mean_ring ./ [norm_ring; norm_ring];

% similarity defined as cosine of angle between mean inner flow and mean
% surrounding flow. computed using dot product of unit vectors.
similarity = sum(unit_in .* unit_ring)';
% shift values from [-1, 1] to [0, 1] so that 180-degree opposite vectors
% are given similairty 0
similarity = 0.5 + similarity * 0.5;

% higher score goes to windows with low similarity to surrounding area.
scores = 1 - similarity;

boxes = [windows scores];

end
