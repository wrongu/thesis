

function [likelihood, pobj, logTotal] = ...
    deriveLikelihood(posneg, theta_value, params, cue, debug)

if nargin < 5, debug = false; end

params.(cue).theta = theta_value;

% *up to* one example per window per training image. note that
% size(params(k).examples,1)==params.distribution_windows; that is, the
% number of randomly generated test windows for each training image is
% params.distribution_windows. Ultimately, examplesPos and examplesNeg will
% contain complementary examples and their union will be all of them. This
% just preallocates enough space for *either* to have all examples.
% [deprecated: this doesn't work well with parallelization]
% examplesPos = zeros(length(posneg) * params.distribution_windows,1);
% examplesNeg = zeros(length(posneg) * params.distribution_windows,1);
% [broken: this was meant to allow parallelization. cryptic errors ensued.]

% loop over training images; compute scores in parallel
parfor idx = 1:length(posneg)
    
    % get a score for all windows on this image according to the given cue
    temp_boxes = computeScores(posneg(idx),cue,params,posneg(idx).examples);
    posneg(idx).scores = temp_boxes(:,end);
end

% count number of positive (object) and negative (background) windows from
% the random set of windows in each training image
pos = 0; 
neg = 0;
examplesPos = zeros(length(posneg) * params.distribution_windows,1);
examplesNeg = zeros(length(posneg) * params.distribution_windows,1);

% concatenate results in a separate loop to make the parallel part happy
for idx = 1:length(posneg)
    
    posInds = find(posneg(idx).labels == 1);
    negInds = find(posneg(idx).labels == -1);
    
    examplesPos(pos+1 : pos+length(posInds)) = posneg(idx).scores(posInds);
    examplesNeg(neg+1 : neg+length(negInds)) = posneg(idx).scores(negInds);
    
    pos = pos + length(posInds);
    neg = neg + length(negInds);
    
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
