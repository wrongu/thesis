% verifyMosegParams.m
%
% created on April 30, 2013
% written by Richard Lange
%
% if mosegParams passes this test, it is valid to use, though there are no
% checks for how "smart" it is to use certain values

function [] = verifyMosegParams(mosegParams, callername)

assert(exist(mosegParams.video_file, 'file') > 0, ...
    sprintf('%s: cannot find video specified in params: %s', ...
    callername, mosegParams.video_file));

V = VideoReader(mosegParams.video_file);
Vdata = get(V, {'NumberOfFrames'});
nframes = Vdata{1};

assert(mosegParams.startframe > 0, ...
    sprintf('%s: params startframe must be positive', callername));
assert(nframes >= mosegParams.endframe, ...
    sprintf('%s: params specify end-frame %d, but the video %s only has %d frames', ...
    callername, mosegParams.endframe, mosegParams.video_file, nframes));
assert(mosegParams.startframe < mosegParams.endframe, ...
    sprintf('%s: computeTrajectories: params startframe must be before the endframe', callername));
assert(mosegParams.sampling > 0, ...
    sprintf('%s: params sampling must be positive', callername));
assert(mosegParams.init_threshold > 0, ...
    sprintf('%s: params init_threshold must be positive', callername));
if mod(mosegParams.init_window, 2) == 0
    warning('params init_window will be changed from %d to %d in the code to ensure that it is odd', ...
        mosegParams.init_window, mosegParams.init_window+1);
end

end