% generate plots from learnParameters
function plots = createPlots(params)

% LEARN THETA MS SCORES
ms16 = load(fullfile(params.data, 'learnMS_16.mat'));
ms24 = load(fullfile(params.data, 'learnMS_24.mat'));
ms32 = load(fullfile(params.data, 'learnMS_32.mat'));
ms48 = load(fullfile(params.data, 'learnMS_48.mat'));
ms64 = load(fullfile(params.data, 'learnMS_64.mat'));

msdomain = ms16.scores(1,:);

plots.learnTheta.MS = figure();
plot(msdomain, ms16.scores(2,:), msdomain, ms24.scores(2,:), ...
    msdomain, ms32.scores(2,:), msdomain, ms48.scores(2,:), ...
    msdomain, ms64.scores(2,:));
xlabel('thetaMS');
ylabel('sum pascal score');
legend('S = 16', 'S = 24', 'S = 32', 'S = 48', 'S = 64');

% LEARN THETA {OTHER CUES}
if params.primary_type == params.TYPE_IMAGE
    cues = {'CC', 'ED', 'SS'};
elseif params.primary_type == params.TYPE_VIDEO
    cues = {'CC', 'ED', 'SS', 'OFM', 'OFD'};
end

for i=1:length(cues)
    cue = cues{i};
    ld = load(fullfile(params.data, ['learn' cue '.mat']));
    plots.learnTheta.(cue) = figure();
    plot(ld.scores(1,:), ld.scores(2,:));
    xlabel(['theta' cue]);
    ylabel('sum likelihood');
    
end

% ==================
%  LIKELIHOOD PLOTS
% ==================

if params.primary_type == params.TYPE_IMAGE
    cues = {'MS', 'CC', 'ED', 'SS'};
elseif params.primary_type == params.TYPE_VIDEO
    cues = {'MS', 'CC', 'ED', 'SS', 'OFD', 'OFM'};
end

for i=1:length(cues)
    cue = cues{i};
    file = fullfile(params.yourData, [cue 'likelihood.mat']);
    if exist(file, 'file')
        plots.likelihood.(cue) = figure();
        ld = load(file);
        domain = params.(cue).bincenters;
        plot(domain, ld.likelihood(1,:), domain, ld.likelihood(2,:));
        legend(['p(' cue ' | obj)'], ['p(' cue ' | bg)']);
        xlabel(['score ' cue]);
        ylabel('probability');
    else
        fprintf('no data for cue %s\n', cue);
    end
end

if params.primary_type == params.TYPE_VIDEO
    % ================
    %  COMBINED PLOTS
    % ================
    cues = {'CC', 'ED', 'SS'};
    for i=1:length(cues)
        cue = cues{i};
        ld_vid = load(fullfile(params.data, ['learn' cue '.mat']));
        ld_img = load(fullfile(params.data, '..', 'Images', ['learn' cue '.mat']));
        plots.combined.(cue) = figure();
        plot(ld_vid.scores(1,:), ld_vid.scores(2,:), ...
            ld_img.scores(1,:), ld_img.scores(2,:));
        xlabel(['theta' cue]);
        ylabel('sum likelihood');
        legend('videos', 'images');
        
    end
end
end