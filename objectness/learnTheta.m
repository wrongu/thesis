function [thetaOpt, likelihoodOpt, pobj] = learnTheta(cue,params)

fprintf('Learning theta for %s\n',cue);

if nargin < 2 
    params = defaultParams;
end
    
try
    struct = load(fullfile(params.trainingImages, 'Examples', 'posneg.mat'));
    posneg = struct.posneg;
    clear struct;
catch    
    posneg = generatePosNeg(params);
    save(fullfile(params.trainingImages, 'Examples', 'posneg.mat'),'posneg');
end

bestValue = -inf;
thetaOpt = 0;

scores = zeros(3, length(params.(cue).domain));
scores(1,:) = params.(cue).domain;

for idx = 1:length(params.(cue).domain)
    
    theta = params.(cue).domain(idx);
    [likelihood, pobj, logTotal] = deriveLikelihood(posneg,theta,params,cue);
    
    scores(2,idx) = logTotal;
    scores(3,idx) = likelihood;
    
    if bestValue < logTotal
        thetaOpt = theta;
        likelihoodOpt = likelihood;
        bestValue = logTotal;
    end  
    fprintf('Best current theta for %s is %f \n',cue,thetaOpt)   
end

save(sprintf('Data/learn%s.mat', cue), 'scores');

end

% posneg is a struct array parallel to structGT (the training examples).
% So, posneg(k) is a struct corresponding to the kth training image.
% posneg(k).examples is a Wx4 array of randomly generated windows for that
% image. posneg(k).labels is a Wx1 array, {-1, 1}^W, where labels(w)==1
% indicates that the wth window (posneg(k).examples(w,:)) covers* an object
% in the image. posneg(k).img is the kth training image (represented as a
% 3-channel double);
% *cover is defined in terms of pascal score: the ratio of intersected area
% to unioned area must be more than a threshold (default 0.5)
function posneg = generatePosNeg(params)

if params.primary_type == params.TYPE_IMAGE
    struct = load(fullfile(params.trainingImages, 'structGT.mat'));
elseif params.primary_type == params.TYPE_VIDEO
    struct = load(fullfile(params.trainingVideos, 'structGT.mat'));
end
structGT= struct.structGT;

for idx = 1:length(structGT)
    if structGT(idx).type == params.TYPE_IMAGE
        img = imread([params.trainingImages structGT(idx).img]);
    elseif structGT(idx).type == params.TYPE_VIDEO
        V = VideoReader(structGT(idx).video_file);
        img = read(V, structGT(idx).frame);
    end
    % TODO - verify conversion to double here is 'safe' in terms of other
    % algorithms' expected types
    if isa(img, 'uint8')
        img = double(img) / 255;
    end
    windows = generateWindows(img,'uniform',params);
    posneg(idx).examples = windows;
    labels = - ones(size(windows,1),1);
    for idx_window = 1:size(windows,1)        
        for bb_id = 1:size(structGT(idx).boxes,1)
            pascalScore = computePascalScore(structGT(idx).boxes(bb_id,:),windows(idx_window,:));
            if (pascalScore >= params.pascalThreshold)
                labels(idx_window) = 1;
                break;
            end
        end
    end
    posneg(idx).labels = labels;
    posneg(idx).img = img;
end

end

function [likelihood, pobj, logTotal] = deriveLikelihood(posneg,theta_value,params,cue)

params.(cue).theta = theta_value;

% one example per window per training image. note that
% size(params(k).examples,1)==params.distribution_windows; that is, the
% number of randomly generated test windows for each training image is
% params.distribution_windows
examplesPos = zeros(length(posneg) * params.distribution_windows,1);
examplesNeg = zeros(length(posneg) * params.distribution_windows,1);

pos = 0; 
neg = 0;

for idx = 1:length(posneg)
    
    % get a score for all windows 
    temp = computeScores(posneg(idx).img,cue,params,posneg(idx).examples);
    posneg(idx).scores = temp(:,end);
    
    indexPositive = find(posneg(idx).labels == 1);
    examplesPos(pos+1:pos+length(indexPositive)) = posneg(idx).scores(indexPositive);
    pos = pos + length(indexPositive);
    
    indexNegative = find(posneg(idx).labels == -1);
    examplesNeg(neg+1:neg+length(indexNegative)) = posneg(idx).scores(indexNegative);
    neg = neg + length(indexNegative);
    
       
end
examplesPos(pos+1:end) = [];
examplesNeg(neg+1:end) = [];

pobj = pos/(pos+neg);
pbg  = 1 - pobj;

posLikelihood = hist(examplesPos,params.(cue).bincenters)/length(examplesPos) + eps;
negLikelihood = hist(examplesNeg,params.(cue).bincenters)/length(examplesNeg) + eps;

logTotal = 0;

for idx = 1:length(examplesPos)                 
    %see what is the corresponding bin center
    for binc = 2:length(params.(cue).bincenters)
        if (examplesPos(idx) <= params.(cue).bincenters(binc))            
            break;            
        end
    end            
    binc = binc - 1;    
    logTotal = logTotal + log((pobj * posLikelihood(binc))/(pobj * posLikelihood(binc) + pbg * negLikelihood(binc) +eps));            
end

likelihood = [posLikelihood;negLikelihood];
end
