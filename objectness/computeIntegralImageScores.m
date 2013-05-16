function score = computeIntegralImageScores(integralImage,windows)

windows = round(windows);
%windows = [xmin ymin xmax ymax]
%computes the score of the windows wrt the integralImage
[height, width] = size(integralImage);
index1 = max(1, min(height*width, round(height*windows(:,3) + (windows(:,4) + 1))));
index2 = max(1, min(height*width, round(height*(windows(:,1) - 1) + windows(:,2))));
index3 = max(1, min(height*width, round(height*(windows(:,1) - 1) + (windows(:,4) + 1))));
index4 = max(1, min(height*width, round(height*windows(:,3) + windows(:,2))));
score = integralImage(index1) + integralImage(index2) - integralImage(index3) - integralImage(index4);