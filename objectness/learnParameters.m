function params = learnParameters(pathNewTrainingFolder, cues, ...
    dir_root, skip_precomputed)
% learns the parameters of the objectness function: theta_MS (for 5 scales),
% theta_CC, theta_ED, theta_SS and also the likelihoods corresp to each cue
%
% dir_root - path where the software is installed - see README Setting things up
if nargin < 3
    dir_root = [pwd '/'];
end
if nargin < 4
    skip_precomputed = false;
end

params = defaultParams(dir_root, 1);

if nargin == 1
    % train the parameters from another dataset
    params.trainingImages = pathNewTrainingFolder;
    origDir = pwd;
    cd(params.trainingImages);
    mkdir('Examples');
    cd(origDir);
end

if skip_precomputed && exist(fullfile('Data', 'learnMS.mat'), 'file')
    fprintf('skipping learnThetaMS\n');
    load(fullfile('Data', 'learnMS.mat'));
else
    %learn parameters for MS
    for idx3 = 1: length(params.MS.scale)
        scale = params.MS.scale(idx3);
        params.MS.theta(idx3) = learnThetaMS(params,scale);
    end
end

if skip_precomputed && exist(fullfile(params.yourData, 'MSlikelihood.mat'), 'file')
    fprintf('skipping generatePosNegMS\n');
    load(fullfile(params.yourData, 'MSlikelihood.mat'));
else
    try
        ld2 = load(fullfile(params.trainingImages, 'Examples', 'posnegMS.mat'));
        posnegMS = ld2.posnegMS;
        clear ld2;
    catch
        posnegMS = generatePosNegMS(params);
        save(fullfile(params.trainingImages, 'Examples', 'posnegMS.mat'),'posnegMS');
    end
    
    [likelihood, pObj] = deriveLikelihoodMS(posnegMS,params);
    save(fullfile(params.yourData, 'MSlikelihood.mat'),'likelihood');
    params.pObj = pObj;
    
end

%learn parameters for CC, ED, SS, OF, MO
if nargin < 2
    cues = {'CC','ED','SS', 'OF', 'MO'};
end

for cid = 1:length(cues)
    cue = cues{cid};
    savefile = fullfile(params.yourData, sprintf('%slikelihood.mat', upper(cue)));
    if ~(skip_precomputed && exist(savefile, 'file'))
        [thetaOpt, likelihood, pobj] = learnTheta(cue,params);
        params.(cue).theta = thetaOpt;
        save(savefile,'likelihood');
    else
        fprintf('skipping cue %s\n', cue);
    end
end

save(fullfile(params.yourData, '/params.mat'),'params');

end

function posneg = generatePosNegMS(params)

if params.primary_type == params.TYPE_IMAGE
    ld = load(fullfile(params.trainingImages, 'structGT.mat'));
elseif params.primary_type == params.TYPE_VIDEO
    ld = load(fullfile(params.trainingVideos, 'structGT.mat'));
end
structGT = ld.structGT;

posneg(1:length(structGT)) = struct( ...
    'examples', [], ...
    'labels', [], ...
    'type', 0, ...
    'scores', [], ...
    'video_file', [], ...
    'frame', 0, ...
    'img', []);

parfor idx = 1:length(structGT)
    posneg(idx).type = structGT(idx).type;
    if structGT(idx).type == params.TYPE_IMAGE
        posneg(idx).img = imread(fullfile(params.trainingImages, structGT(idx).img));
        if isa(posneg(idx).img, 'uint8')
            posneg(idx).img = double(posneg(idx).img) / 255;
        end
    elseif structGT(idx).type == params.TYPE_VIDEO
        posneg(idx).video_file = structGT(idx).video_file;
        posneg(idx).frame = structGT(idx).frame;
    end
    boxes = computeScores(structGT(idx),'MS',params);
    posneg(idx).examples =  boxes(:,1:4);
    labels = -ones(size(boxes,1),1);
    for idx_window = 1:size(boxes,1)
        for bb_id = 1:size(structGT(idx).boxes,1)
            pascalScore = computePascalScore(structGT(idx).boxes(bb_id,:),boxes(idx_window,1:4));
            if (pascalScore >= params.pascalThreshold)
                labels(idx_window) = 1;
                break;
            end
        end
    end
    posneg(idx).labels = labels;
    posneg(idx).scores = boxes(:,5);
end

end


function [likelihood, pobj] = deriveLikelihoodMS(posneg,params)

examplesPos = zeros(length(posneg) * params.distribution_windows,1);
examplesNeg = zeros(length(posneg) * params.distribution_windows,1);

pos = 0;
neg = 0;

for idx2 = 1:length(posneg)
    
    indexPositive = find(posneg(idx2).labels == 1);
    examplesPos(pos+1:pos+length(indexPositive)) = posneg(idx2).scores(indexPositive);
    pos = pos + length(indexPositive);
    
    indexNegative = find(posneg(idx2).labels == -1);
    examplesNeg(neg+1:neg+length(indexNegative)) = posneg(idx2).scores(indexNegative);
    neg = neg + length(indexNegative);
    
end

examplesPos(pos+1:end) = [];
examplesNeg(neg+1:end) = [];

pobj = pos/(pos+neg);

posLikelihood = hist(examplesPos,params.MS.bincenters)/length(examplesPos) + eps;
negLikelihood = hist(examplesNeg,params.MS.bincenters)/length(examplesNeg) + eps;

likelihood = [posLikelihood;negLikelihood];
end
