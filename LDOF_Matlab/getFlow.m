function flow = getFlow(file, frame, fo_rev, reader)
% getFlow(file, frame, fo_rev, reader) gets optic flow for given video, or load it if
% it's been computed before. If the flow is computed for the first time
% here, it is saved for future use so that flow only ever needs to be
% computed once per frame
%
% INPUTS
%   file - path to the video
%   frame - frame of the video to compute flow of
%   fo_rev - either 'forward' or 'reverse'.
%       'forward': compute flow from frame to frame+1
%       'reverse': compute flow from frame to frame-1
%   reader (optional) - a VideoReader object. if none is given, it will be
%   created. Creating a VideoReader multiple times is expensive, so it
%   should be provided if possible.

[path, name, ~] = fileparts(file);

matname = fullfile(path, 'flows', get_flow_file(name, frame, fo_rev));

if exist(matname, 'file')
    % it exists - load it!
    struct = load(matname);
    flow = struct.flow;
else
    % doesn't exist - compute and save
    if nargin < 4
        reader = VideoReader(file);
    end
    Vdata = get(reader, {'Height', 'Width'});
    para = get_para_flow(Vdata{1}, Vdata{2});
    im1 = read(reader, frame);
    switch fo_rev
        case 'forward'
            im2 = read(reader, frame+1);
        case 'reverse'
            im2 = read(reader, frame-1);
    end
    [flow, ~, ~] = LDOF(im1, im2, para);
    save(matname, 'flow');
end

end

function filename = get_flow_file(vid, frame, fo_rev)

switch fo_rev
    case 'forward'
        suffix = 'for';
    case 'reverse'
        suffix = 'rev';
end

filename = sprintf('%s_%d%s.mat', vid, frame, suffix);

end
