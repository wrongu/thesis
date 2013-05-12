function params = updatePath(dirRoot,params)

if nargin < 1
    dirRoot = pwd;
end

if nargin < 2
    params = defaultParams(dirRoot);
end


params.trainingImages = fullfile(dirRoot, 'Training', 'Images');
params.trainingVideos = fullfile(dirRoot, 'Training', 'Videos');
params.data = fullfile(dirRoot, 'Data');
params.yourData = fullfile(dirRoot, 'Data', 'yourData');
params.tempdir = fullfile(dirRoot, 'tmpdir');
params.SS.soft_dir =fullfile(dirRoot, 'SS', 'segment');