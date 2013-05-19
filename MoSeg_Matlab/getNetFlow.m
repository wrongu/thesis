function F = getNetFlow(file, start, duration, reader, debug)

if nargin < 5, debug = false; end

filename = get_save_file(file, start, duration);

if exist(filename, 'file')
    ld = load(filename);
    F = ld.F;
else
    flows = cell(1,duration);
    if nargin < 4, reader = VideoReader(file); end
    Vdata = get(reader, {'Height', 'Width'});
    h = Vdata{1}; w = Vdata{2};
    
    for i=1:duration
        flows{i} = getFlow(file, start+i-1, 'forward', reader);
    end
    
    dx = zeros(h, w);
    dy = zeros(h, w);
    
    
    n = w*h;
    if debug, tic; end
    parfor r = 1:h
        for c = 1:w
            if debug
                progress('tracking point', w*(r-1)+c, n);
            end
            new_p = track_point([r c]', flows);
            diff = new_p - [r c]';
            dy(r, c) = diff(1);
            dx(r, c) = diff(2);
        end
    end
    if debug, toc; end
    
    F = cat(3, dx, dy);
    
    save(filename, 'F');
end

end

function filename = get_save_file(file, start, duration)

[path, name, ~] = fileparts(file);

if ~exist(fullfile(path, 'net flows'), 'file')
    mkdir(fullfile(path, 'net flows'));
end

filename = fullfile(path, 'net flows', ...
    sprintf('%s_%d-%d.mat', name, start, start+duration-1));

end