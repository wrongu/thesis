% this function creates a new set of random training examples (video)

function structGT = newRandomStructGT(num_examples, params)

checkMotionParams(params);

structGT(1:num_examples) = struct(...
    'type', params.TYPE_VIDEO, ...
    'video_file', '', ...
    'frame', 0, ...
    'boxes', []);

all_vids = dir(fullfile(params.trainingVideos, '/*.avi'));
all_vids = {all_vids.name};
for idx = 1:num_examples
    range = [];
    while isempty(range)
        % choose random video
        r = floor(rand*length(all_vids))+1;
        structGT(idx).video_file = all_vids{r};
        % load annotation (.mat) file for this video
        datname = [structGT(idx).video_file(1:end-3) 'mat'];
        annot = load(fullfile(params.trainingVideos, 'Annotations', datname));
        % choose random frame within allowable bounds from params
        range = params.MOS.preframes+1 : annot.num_frames - params.MOS.postframes;
        if ~isempty(range)
            f = range(randi(length(range)));
            structGT(idx).frame = f;
            % save box annotations for this frame
            a = annot.annotations{f};
            structGT(idx).boxes = scale_box(...
                VideoReader(structGT(idx).video_file), ...
                [a.xtl a.ytl a.xbr a.ybr] + 1, ...
                annot.width, annot.height);
        end
    end
end
end

% return box coordinates that fit on the video V, taken from annotations
% that have width a_width and height a_height (w and h from 'annotation')
% box and a_box should be [xtl ytl xbr ybr]
function box = scale_box(V, a_box, a_width, a_height)
vdata = get(V, {'Width', 'Height'});
w = vdata{1};
h = vdata{2};
box = a_box;
box([1 3]) = round(box([1 3]) * w / a_width);
box([2 4]) = round(box([2 4]) * h / a_height);

end
