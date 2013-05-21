function [thetaOpt, likelihoodOpt, pobj] = learnTheta(cue,params,debug)

if nargin < 3, debug = false; end

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
    if params.primary_type == params.TYPE_IMAGE
        save(fullfile(params.trainingImages, 'Examples', 'posneg.mat'), 'posneg');
    elseif params.primary_type == params.TYPE_VIDEO
        save(fullfile(params.trainingVideos, 'Examples', 'posneg.mat'), 'posneg');
    end
end

scores = zeros(3, length(params.(cue).domain));
all_likelihoods = cell(1, length(params.(cue).domain));

% note: if this is loop is done as a parfor, it results in many instances of 
% duplicate image or video processing.
for idx = 1:length(params.(cue).domain)
    
    fprintf('learning %s: %d of %d\n', cue, idx, length(params.(cue).domain));
    
    theta = params.(cue).domain(idx);
    [likelihood, p, logTotal] = deriveLikelihood(posneg,theta,params,cue,debug);
    
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
