file = fullfile(pwd, 'objectness/Training/Videos/penguin03.avi');
annot_file = fullfile(pwd, 'data/Youtube/annot/penguin03.mat');
V = VideoReader(file);
Vdata = get(V, {'Height', 'Width'});
frame = 10;
df = 5;
annot = load(annot_file);
box = [annot.annotations{frame}.xtl, ...
    annot.annotations{frame}.ytl, ...
    annot.annotations{frame}.xbr, ...
    annot.annotations{frame}.ybr];
box = scale_box(V, box, annot.width, annot.height);
h = Vdata{1}; w = Vdata{2};

flows = cell(df,1);

for f = 1:df
    flows{f} = getFlow(file, frame+f-1, 'forward', V);
end

dx = zeros(h, w);
dy = zeros(h, w);

for r = 1:h
    for c = 1:w
        progress('tracking point', (r-1)*w+c, r*c);
        new_p = track_point([r c]', flows);
        diff = new_p - [r c]';
        dy(r, c) = diff(1);
        dx(r, c) = diff(2);
    end
end

displacement = cat(3, dx/df, dy/df);

save('misc/makefigure_OFD.mat', 'file', 'frame', 'displacement', 'df');

% mosegParams = structMosegParams('objectness/Training/Videos/car08.avi', 125, 145);
% [c, t, w] = moseg(mosegParams, true);

im1 = read(V, frame);

figure();
subplot(1,2,1);
imshow(im1);
drawBoxes([box 1]);
subplot(1,2,2);
imshow(flowToColor(displacement));
drawBoxes([box 1]);
drawBoxes([window_offset(box, 30, 'out', w, h) 0.5]);