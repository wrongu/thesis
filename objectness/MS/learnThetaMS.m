function thresholdOpt = learnThetaMS(params,scale)

fprintf('Learning theta_MS for scale = %d \n',scale);
level = find(params.MS.scale == scale);
scores = zeros(2, size(params.MS.domain, 2));
if params.primary_type == params.TYPE_IMAGE
    struct = load(fullfile(params.trainingImages, 'structGT.mat'));
elseif params.primary_type == params.TYPE_VIDEO
    struct = load(fullfile(params.trainingVideos, 'structGT.mat'));
end
structGT= struct.structGT;%training GT

for idxThr = 1:length(params.MS.domain(level,:)) %loop over the possible threshold values
    
    threshold = params.MS.domain(level,idxThr);
    
    scoreThreshold = 0;
    
    for idxImgGT = 1:length(structGT) %for every img in GT
        
        if structGT(idxImgGT).type == params.TYPE_IMAGE
            img = imread(fullfile(params.trainingImages, ...
                structGT(idxImgGT).img));
        else
            V = VideoReader(fullfile(params.trainingVideos, ...
                structGT(idxImgGT).video_file));
            img = read(V, structGT(idxImgGT).frame);
        end
        
        saliencyMAP = saliencyMap(img,params.MS.filtersize,scale);%compute the saliency map - for the current scale            
        thrmap = saliencyMAP >= threshold;                    
        salmap = saliencyMAP .* thrmap;                         
        thrmapIntegralImage = computeIntegralImage(thrmap);                         
        salmapIntegralImage =  computeIntegralImage(salmap);                                             
        scoreScale = slidingWindowComputeScore(double(saliencyMAP), scale, 1, 1, threshold, salmapIntegralImage, thrmapIntegralImage);     
        
        [xmin, ymin, xmax, ymax, score] = nms4d(double(scoreScale),scale,scale,params.MS.sizeNeighborhood);%non maximum supression
       
        indexPositive = find(score > 0);
        xmin = xmin(indexPositive);
        ymin = ymin(indexPositive);
        xmax = xmax(indexPositive);
        ymax = ymax(indexPositive);
        score = score(indexPositive);
        
        for idxObject = 1:size(structGT(idxImgGT).boxes,1) %for every annotated object
            
            gtBox = structGT(idxImgGT).boxes(idxObject,:);
            [height, width, ~] = size(img);
            gtBox(1) = gtBox(1)*scale/width;
            gtBox(3) = gtBox(3)*scale/width;
            gtBox(2) = gtBox(2)*scale/height;
            gtBox(4) = gtBox(4)*scale/height;
            
            maxPascalScore = 0;
            for w = 1:length(score)
                nmsBox = [xmin(w) ymin(w) xmax(w) ymax(w)];
                pascalScore = computePascalScore(gtBox,nmsBox);
                if maxPascalScore < pascalScore
                    maxPascalScore = pascalScore;
                end
            end
            scoreThreshold = scoreThreshold + maxPascalScore;
        end
        
    end
    
    scores(:, idxThr) = [threshold scoreThreshold]';
    
%     scores(2, idxThr) = scoreThreshold;
%     scores(3, idxThr) = threshold;
    
%     if bestScoreThreshold < scoreThreshold
%         bestScoreThreshold = scoreThreshold;
%         thresholdOpt = threshold;
%     end
%     fprintf('Best current theta_MS for scale = %d is %f \n',scale,thresholdOpt)    
end

[~, iBest] = max(scores(2,:));
thresholdOpt = scores(1, iBest);

save(fullfile(params.data, sprintf('learnMS_%d.mat', scale)), 'scores');

end

function saliencyMAP = saliencyMap(inImg,filtersize,scale)

inImg = im2double(rgb2gray(inImg));
inImg = imresize(inImg,[scale,scale],'bilinear');

%Spectral Residual
myFFT = fft2(inImg);
myLogAmplitude = log(abs(myFFT));
myPhase = angle(myFFT);
mySmooth = imfilter(myLogAmplitude,fspecial('average',filtersize),'replicate');
mySpectralResidual = myLogAmplitude-mySmooth;
saliencyMAP = abs(ifft2(exp(mySpectralResidual+1i*myPhase))).^2;

%After Effect
saliencyMAP = imfilter(saliencyMAP,fspecial('disk',filtersize));
saliencyMAP = mat2gray(saliencyMAP);
end
