
function [] = checkMotionParams(params)
% checkMotionParams(params) ensure that 'params' is valid for motion cues

assert(isfield(params, 'OFD'), 'params.OF does not exist');
assert(isfield(params, 'OFM'), 'params.OF does not exist');
assert(isfield(params, 'MOS'), 'params.MOS does not exist');
assert(~isempty(dir(fullfile(params.trainingVideos, '*.avi'))), ...
    'no avi files found in training folder');
assert(~isempty(dir(fullfile(params.trainingVideos, 'Annotations', '*.mat'))), ...
    'no mat files found in annotations folder');

end
