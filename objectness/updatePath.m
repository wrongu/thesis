function params = updatePath(dirRoot,params)

if nargin < 1
    dirRoot = pwd;
end

if nargin < 2
    params = defaultParams(dirRoot);
end


params.trainingImages = fullfile(dirRoot, 'Training', 'Images');
params.trainingVideos = fullfile(dirRoot, 'Training', 'Videos');
if params.primary_type == params.TYPE_IMAGE
    params.data = fullfile(dirRoot, 'Data', 'Images');
elseif params.primary_type == params.TYPE_VIDEO
    params.data = fullfile(dirRoot, 'Data', 'Videos');
end
params.yourData = fullfile(params.data, 'yourData');
params.tempdir = fullfile(dirRoot, 'tmpdir');
params.SS.soft_dir =fullfile(dirRoot, 'SS', 'segment');