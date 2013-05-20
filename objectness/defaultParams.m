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
params.pobj = 0.0797;
params.tempdir = [dirRoot '/tmpdir/'];
params.pascalThreshold = 0.5;
params.sampling = 'nms';%alternative sampling method - 'multinomial'
params.trainingVideos = fullfile(dirRoot, 'Training', 'Videos');
params.trainingImages = fullfile(dirRoot, 'Training', 'Images');

% type-dependent parameters
if type == TYPE_VIDEO
    params.cues = {'MS','CC','SS', 'OFD', 'OFM', 'MOS'};%full objectness measure
params.data = [dirRoot '/Data/Videos/'];
params.yourData = [dirRoot '/Data/Videos/yourData/'];
elseif type == TYPE_IMAGE
    params.cues = {'MS','CC','SS'};%full objectness measure
params.data = [dirRoot '/Data/Images/'];
params.yourData = [dirRoot '/Data/Images/yourData/'];
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
    params.OFD.name = 'Optic-Flow-Direction';
    params.OFD.theta = 50;
    params.OFD.domain = 1:1:100;
    params.OFD.num_frames = 5;
    params.OFD.pixelDistance = 8;
    params.OFD.imageBorder = 0;
    params.OFD.bincenters = 0:0.01:1;
    params.OFD.numberBins = length(params.OFD.bincenters) - 1;
    params.OFD.required_path = fullfile(dirRoot, '..', 'LDOF_Matlab');

    params.OFM.name = 'Optic-Flow-Magnitude';
    params.OFM.theta = 50;
    params.OFM.domain = 1:1:100;
    params.OFM.num_frames = 5;
    params.OFM.pixelDistance = 8;
    params.OFM.imageBorder = 0;
    params.OFM.bincenters = logspace(-3,0,101);%0:0.01:1;
    params.OFM.numberBins = length(params.OFM.bincenters) - 1;
    params.OFM.required_path = fullfile(dirRoot, '..', 'LDOF_Matlab');
    
    % params for MOS (motion segmentation)
    params.MOS.name = 'Motion-Segmentation';
    params.MOS.theta = 8;
    params.MOS.preframes = 15;
    params.MOS.postframes = 0;
    params.MOS.sampling = 8;
    params.MOS.domain = [.005 0.01 0.02 0.05 0.1];
    params.MOS.pixelDistance = 8;
    params.MOS.imageBorder = 0;
    params.MOS.bincenters = 0:0.01:1;
    params.MOS.numberBins = length(params.MOS.bincenters) - 1;
    params.MOS.required_path = fullfile(dirRoot, '..', 'MoSeg_Matlab');
end