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

displacement = getNetFlow(file, frame, df, V, true);

im1 = read(V, frame);

figure();
subplot(1,2,1);
imshow(im1);
drawBoxes([box 1]);
subplot(1,2,2);
imshow(flowToColor(displacement));
drawBoxes([box 1]);
drawBoxes([window_offset(box, 30, 'out', w, h) 0.5]);