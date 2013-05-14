function params = learnParameters(pathNewTrainingFolder, cues, ...
    params, dir_root, skip_precomputed)
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

% params = defaultParams(dir_root, 1);

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
