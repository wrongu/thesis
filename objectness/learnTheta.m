function [thetaOpt, likelihoodOpt, pobj] = learnTheta(cue,params)

fprintf('Learning theta for %s\n',cue);

if nargin < 2 
    params = defaultParams;
end
    
try
    if params.primary_type == params.TYPE_IMAGE
        ld = load(fullfile(params.trainingImages, 'Examples', 'posneg.mat'));
    elseif params.primary_type == params.TYPE_VIDEO
        ld = load(fullfile(params.trainingVideos, 'Examples', 'posneg.mat'));
    end
    posneg = ld.posneg;
    clear struct;
catch    
    posneg = generatePosNeg(params);
    save(fullfile(params.trainingImages, 'Examples', 'posneg.mat'),'posneg');
end

scores = zeros(3, length(params.(cue).domain));
all_likelihoods = cell(1, length(params.(cue).domain));

parfor idx = 1:length(params.(cue).domain)
    
    theta = params.(cue).domain(idx);
    [likelihood, p, logTotal] = deriveLikelihood(posneg,theta,params,cue);
    
    scores(:, idx) = [params.(cue).domain(idx) logTotal p]';
    all_likelihoods{idx} = likelihood;
    
%     if bestValue < logTotal
%         thetaOpt = theta;
%         likelihoodOpt = likelihood;
%         bestValue = logTotal;
%     end  
%     fprintf('Best current theta for %s is %f \n',cue,thetaOpt)   
end

[bestValue, iBest] = max(scores(2,:));
thetaOpt = params.(cue).domain(iBest);
likelihoodOpt = all_likelihoods{iBest};
pobj = scores(3, iBest);

save(fullfile(params.data, sprintf('learn%s.mat', cue)), 'scores');

end

function [likelihood, pobj, logTotal] = deriveLikelihood(posneg,theta_value,params,cue)

params.(cue).theta = theta_value;

% *up to* one example per window per training image. note that
% size(params(k).examples,1)==params.distribution_windows; that is, the
% number of randomly generated test windows for each training image is
% params.distribution_windows. Ultimately, examplesPos and examplesNeg will
% contain complementary examples and their union will be all of them. This
% just preallocates enough space for *either* to have all examples.
examplesPos = zeros(length(posneg) * params.distribution_windows,1);
examplesNeg = zeros(length(posneg) * params.distribution_windows,1);

% count number of positive (object) and negative (background) windows from
% the random set of windows in each training image
pos = 0; 
neg = 0;

% loop over training images
for idx = 1:length(posneg)
    
    % get a score for all windows on this image according to the given cue
    temp_boxes = computeScores(posneg(idx),cue,params,posneg(idx).examples);
    posneg(idx).scores = temp_boxes(:,end);
    
    % get all windows and scores that are considered positive (object)
    % examples
    indexPositive = find(posneg(idx).labels == 1);
    examplesPos(pos+1:pos+length(indexPositive)) = posneg(idx).scores(indexPositive);
    pos = pos + length(indexPositive);
    
    indexNegative = find(posneg(idx).labels == -1);
    examplesNeg(neg+1:neg+length(indexNegative)) = posneg(idx).scores(indexNegative);
    neg = neg + length(indexNegative);
end
examplesPos(pos+1:end) = [];
examplesNeg(neg+1:end) = [];

% at this point, examplesPos contains all the *scores* of this cue that are
% associated with objects. examplesNeg is, likewise, the scores of this cue
% associated with background.

pobj = pos/(pos+neg);
pbg  = 1 - pobj;

% p(obj|score) = p(score|obj)*pobj / (p(score|obj)*pobj + p(score|bg)*pbg)
% 
% WHERE
%
% p(score|obj) and p(score|bg) are done with histogram that counts the 
% positive and negative examples *at each bin of scores*
% 
% we've found a good value for theta when the peak for posLikelihood and
% the peak for negLikelihood have minimum overlap (that is, the scores that
% say 'object' are clearly distinct from the scores that say 'background')
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
    % to reiterate:
    % p(obj|score) = p(score|obj)*pobj / (p(score|obj)*pobj + p(score|bg)*pbg)
    % 
    % ..and likelihood = log(p(obj|score))
    logTotal = logTotal + log((pobj * posLikelihood(binc))/(pobj * posLikelihood(binc) + pbg * negLikelihood(binc) +eps));            
end

likelihood = [posLikelihood;negLikelihood];
end
