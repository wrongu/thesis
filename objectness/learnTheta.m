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

scores = zeros(4, length(params.(cue).domain));

parfor idx = 1:length(params.(cue).domain)
    
    theta = params.(cue).domain(idx);
    [likelihood, p, logTotal] = deriveLikelihood(posneg,theta,params,cue);
    
    scores(:, idx) = [params.(cue).domain(idx) logTotal likelihood p]';
    
%     if bestValue < logTotal
%         thetaOpt = theta;
%         likelihoodOpt = likelihood;
%         bestValue = logTotal;
%     end  
%     fprintf('Best current theta for %s is %f \n',cue,thetaOpt)   
end

[bestValue, iBest] = max(scores(2,:));
thetaOpt = params.(cue).domain(iBest);
likelihoodOpt = scores(3, iBest);
pobj = scores(4, iBest);

save(sprintf('Data/learn%s.mat', cue), 'scores');

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
    temp = computeScores(posneg(idx),cue,params,posneg(idx).examples);
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
