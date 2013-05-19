% file = fullfile(pwd, 'objectness/Training/Videos/car08.avi');
% annot_file = fullfile(pwd, 'data/Youtube/annot/car08.mat');
% frame = 140;
% annot = load(annot_file);
% box = [annot.annotations{frame}.xtl, ...
%     annot.annotations{frame}.ytl, ...
%     annot.annotations{frame}.xbr, ...
%     annot.annotations{frame}.ybr];
% box = scale_box(V, box, annot.width, annot.height);
% V = VideoReader(file);
% F = getFlow(file, frame, 'forward', V);
% im1 = read(V, frame);

mosegParams = structMosegParams('../objectness/Training/Videos/car08.avi', 125, 145);
[c, t, w] = moseg(mosegParams, true);

% figure();
% subplot(1,2,1);
% imshow(im1);
% drawBoxes([box 1]);
% subplot(1,2,2);
% imshow(flowToColor(F));
% drawBoxes([box 1]);