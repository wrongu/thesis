function boxes = scoreOF(Flow, windows, thetaOF)
% scoreOF(Flow, windows, thetaOF) compute score as 

U = Flow(:,:,1);
V = Flow(:,:,2);

avgMag = sum(sum(sqrt(U.*U + V.*V)));

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
areas_in(areas_in == 0) = inf;
areas_ring(areas_ring == 0) = inf;

meanU_in = sumU_in ./ areas_in;
meanV_in = sumV_in ./ areas_in;
meanU_ring = sumU_ring ./ areas_ring;
meanV_ring = sumV_ring ./ areas_ring;

diffU = meanU_in - meanU_ring;
diffV = meanV_in - meanV_ring;

dists = diffU.^2 + diffV.^2;

scores = dists / avgMag;

% TODO - normalize, maybe by using inverse cosine instead of distance?
% TODO - check for reasonable ranges

boxes = [windows scores];
end