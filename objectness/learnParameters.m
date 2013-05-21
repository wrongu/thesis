function params = learnParameters(cues, params, skip_precomputed )
% learns the parameters of the objectness function: theta_MS (for 5 scales),
% theta_CC, theta_ED, theta_SS and also the likelihoods corresp to each cue
%
% dir_root - path where the software is installed - see README Setting things up
% if nargin < 3
%     dir_root = [pwd '/'];
% end
if nargin < 3
    skip_precomputed = false;
end

% if nargin == 1
%     % train the parameters from another dataset
%     params = defaultParams(dir_root, 1);
%     params.trainingImages = pathNewTrainingFolder;
%     origDir = pwd;
%     cd(params.trainingImages);
%     mkdir('Examples');
%     cd(origDir);
% end

%learn parameters for MS
for idx = 1: length(params.MS.scale)
    scale = params.MS.scale(idx);
    if skip_precomputed && exist(fullfile(params.data, ...
            sprintf('learnMS_%d.mat', scale)), 'file')
        fprintf('skipping learnThetaMS @ %d\n', scale);
        ld = load(fullfile(params.data, sprintf('learnMS_%d.mat', scale)));
        [~, ind] = max(ld.scores(2,:));
        params.MS.theta(idx) = ld.scores(1,ind);
    else
        params.MS.theta(idx) = learnThetaMS(params,scale);
    end
end

if skip_precomputed && exist(fullfile(params.yourData, 'MSlikelihood.mat'), 'file')
    fprintf('skipping generatePosNegMS\n');
    load(fullfile(params.yourData, 'MSlikelihood.mat'));
else
    try
        if params.primary_type == params.TYPE_IMAGE
            ld2 = load(fullfile(params.trainingImages, 'Examples', 'posnegMS.mat'));
        elseif params.primary_type == params.TYPE_VIDEO
            ld2 = load(fullfile(params.trainingVideos, 'Examples', 'posnegMS.mat'));
        end
        posnegMS = ld2.posnegMS;
        clear ld2;
    catch
        posnegMS = generatePosNegMS(params);
        
        if params.primary_type == params.TYPE_IMAGE
            save(fullfile(params.trainingImages, 'Examples', 'posnegMS.mat'),'posnegMS');
        elseif params.primary_type == params.TYPE_VIDEO
            save(fullfile(params.trainingVideos, 'Examples', 'posnegMS.mat'),'posnegMS');
        end
    end
    
    [likelihood, pObj] = deriveLikelihoodMS(posnegMS,params);
    save(fullfile(params.yourData, 'MSlikelihood.mat'),'likelihood');
    params.pObj = pObj;
    
end

%learn parameters for CC, ED, SS, OF, MOS
if nargin < 1
    cues = {'CC','ED','SS', 'OFD', 'OFM', 'MOS'};
end

for cid = 1:length(cues)
    cue = cues{cid};
    savefile = fullfile(params.yourData, sprintf('%slikelihood.mat', upper(cue)));
    if ~(skip_precomputed && exist(savefile, 'file'))
        [thetaOpt, likelihood, pobj] = learnTheta(cue,params,true);
        params.(cue).theta = thetaOpt;
        save(savefile,'likelihood');
    else
        fprintf('skipping cue %s\n', cue);
        ld = load(fullfile(params.data, sprintf('learn%s.mat', upper(cue))));
        [~, ind] = max(ld.scores(2,:));
        params.(cue).theta = ld.scores(1,ind);
    end
end

save(fullfile(params.yourData, '/params.mat'),'params');

end
