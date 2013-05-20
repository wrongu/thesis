function F = getNetFlow(file, start, duration, sampling, reader, debug)

if nargin < 6, debug = false; end
if nargin < 5, reader = VideoReader(file); end

filename = get_save_file(file, start, duration, sampling);

if exist(filename, 'file')
    ld = load(filename);
    F = ld.F;
else
    flows = cell(1,duration);
    if nargin < 4, reader = VideoReader(file); end
    Vdata = get(reader, {'Height', 'Width'});
    h = Vdata{1}; w = Vdata{2};
    
    parfor i=1:duration
        flows{i} = getFlow(file, start+i-1, 'forward', reader);
    end
    
    dx = zeros(h, w);
    dy = zeros(h, w);
    n = w*h;
    rows = 1:sampling:h;
    cols = 1:sampling:w;
    if debug, tic; end
    for r = rows
        for c = cols
            if debug
                progress('tracking point', w*(r-1)+c, n);
            end
            new_p = track_point([r c]', flows, w, h);
            diff = new_p - [r c]';
            dy(r:r+sampling-1, c:c+sampling-1) = diff(1);
            dx(r:r+sampling-1, c:c+sampling-1) = diff(2);
        end
    end
    if debug, toc; end
    
    F = cat(3, dx, dy);
    
    save(filename, 'F');
end

end

function filename = get_save_file(file, start, duration, sampling)

[path, name, ~] = fileparts(file);

if sampling < 2
    sample_str = '';
else
    sample_str = sprintf('_s%d', sampling);
end

if ~exist(fullfile(path, 'net flows'), 'file')
    mkdir(fullfile(path, 'net flows'));
end

filename = fullfile(path, 'net flows', ...
    sprintf('%s_%d-%d%s.mat', name, start, start+duration-1, sample_str));

end
