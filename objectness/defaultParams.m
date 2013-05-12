function params = defaultParams(dirRoot, type)

TYPE_IMAGE = 1;
TYPE_VIDEO = 2;

if nargin < 2
    type = TYPE_IMAGE;
end

if nargin < 1
    dirRoot = pwd;
end

% params in general
params.min_window_height = 10;
params.min_window_width  = 10;
params.distribution_windows = 100000;
params.sampled_windows = 1000;
params.imageType = 'jpg';
params.data = [dirRoot '/Data/'];
params.yourData = [dirRoot '/Data/yourData/'];
params.pobj = 0.0797;
params.tempdir = [dirRoot '/tmpdir/'];
params.pascalThreshold = 0.5;
params.sampling = 'nms';%alternative sampling method - 'multinomial'
params.trainingVideos = fullfile(dirRoot, 'Training', 'Videos');
params.trainingImages = fullfile(dirRoot, 'Training', 'Images');

% type-dependent parameters
if type == TYPE_VIDEO
    params.cues = {'MS','CC','SS', 'OF', 'MO'};%full objectness measure
elseif type == TYPE_IMAGE
    params.cues = {'MS','CC','SS'};%full objectness measure
end

% 'global variables' that distinguish between video and image
params.TYPE_IMAGE = TYPE_IMAGE;
params.TYPE_VIDEO = TYPE_VIDEO;
params.primary_type = type;

% params for MS
params.MS.name = 'Multiscale-Saliency';
params.MS.colortype = 'rgb';
params.MS.filtersize = 3;
params.MS.scale = [16 24 32 48 64];
params.MS.theta = [0.43 0.32 0.34 0.35 0.26];
params.MS.domain = repmat(0.01:0.01:1,5,1);
params.MS.sizeNeighborhood = 7;
params.MS.bincenters = 0:1:500;
params.MS.numberBins = length(params.MS.bincenters) - 1;

% params for CC
params.CC.name = 'Color-Contrast';
params.CC.theta = 100;
params.CC.domain = 100:1:200;
params.CC.quant = [4 8 8];
params.CC.bincenters = 0:0.01:2;
params.CC.numberBins = length(params.CC.bincenters) - 1;

% params for ED
params.ED.name = 'Edge-Density';
params.ED.theta = 17;
params.ED.domain = 1:1:100;
params.ED.crop_size = 200;
params.ED.pixelDistance = 8;
params.ED.imageBorder = 0;
params.ED.bincenters = 0:0.05:5;
params.ED.numberBins = length(params.ED.bincenters) - 1;

% params for SS
params.SS.name = 'Superpixels-Straddling';
params.SS.basis_sigma = 0.5;
params.SS.theta = 450;
params.SS.domain = 200:25:2000;
params.SS.basis_min_area = 200;
params.SS.soft_dir = fullfile(dirRoot, 'SS', 'segment');
params.SS.pixelDistance = 8;
params.SS.imageBorder = 0.05;
params.SS.bincenters = 0:0.01:1;
params.SS.numberBins = length(params.SS.bincenters) - 1;

if type == TYPE_VIDEO
    % params for OF (optic flow)
    % TODO - choose domain, theta, bincenters, pixelDistance, etc more intelligently
    params.OF.name = 'Optic-Flow-Coherence';
    params.OF.theta = 50;
    params.OF.domain = 1:1:100;
    params.OF.pixelDistance = 8;
    params.OF.imageBorder = 0;
    params.OF.bincenters = 0:0.01:1;
    params.OF.numberBins = length(params.OF.bincenters) - 1;
    params.OF.required_path = fullfile(dirRoot, '..', 'LDOF_Matlab');
    
    % params for MO (motion segmentation)
    params.MO.name = 'Motion-Segmentation';
    params.MO.theta = 8;
    params.MO.preframes = 15;
    params.MO.postframes = 0;
    params.MO.sampling = 8;
    params.MO.domain = 2:8;
    params.MO.pixelDistance = 8;
    params.MO.imageBorder = 0;
    params.MO.bincenters = 0:0.01:1;
    params.MO.numberBins = length(params.MO.bincenters) - 1;
    params.MO.required_path = fullfile(dirRoot, '..', 'MoSeg_Matlab');
end