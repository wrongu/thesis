

% posneg is a struct array parallel to structGT (the training examples).
% So, posneg(k) is a struct corresponding to the kth training image.
% posneg(k).examples is a Wx4 array of randomly generated windows for that
% image. posneg(k).labels is a Wx1 array, {-1, 1}^W, where labels(w)==1
% indicates that the wth window (posneg(k).examples(w,:)) covers* an object
% in the image. posneg(k).img is the kth training image (represented as a
% 3-channel double);
% *cover is defined in terms of pascal score: the ratio of intersected area
% to unioned area must be more than a threshold (default 0.5)
function posneg = generatePosNeg(params)

if params.primary_type == params.TYPE_IMAGE
    fprintf('gpn: load images structGT\n');
    ld = load(fullfile(params.trainingImages, 'structGT.mat'));
elseif params.primary_type == params.TYPE_VIDEO
    fprintf('gpn: load videos structGT\n');
    ld = load(fullfile(params.trainingVideos, 'structGT.mat'));
end
structGT= ld.structGT;

for idx = length(structGT):-1:1
    if structGT(idx).type == params.TYPE_IMAGE
        posneg(idx).type = structGT(idx).type;
        posneg(idx).img = imread(fullfile(params.trainingImages, structGT(idx).img));
        % TODO - verify conversion to double here is 'safe' in terms of other
        % algorithms' expected types
        if isa(posneg(idx).img, 'uint8')
            posneg(idx).img = double(posneg(idx).img) / 255;
        end
        s = size(posneg(idx).img);
    elseif structGT(idx).type == params.TYPE_VIDEO
        posneg(idx).type = structGT(idx).type;
        posneg(idx).video_file = structGT(idx).video_file;
        posneg(idx).frame = structGT(idx).frame;
        V = VideoReader(fullfile(params.trainingVideos, ...
            posneg(idx).video_file));
        Vdata = get(V, {'Width', 'Height'});
        s = [Vdata{2} Vdata{1}];
    end
    windows = generateWindows(s,'uniform',params);
    posneg(idx).examples = windows;
    labels = - ones(size(windows,1),1);
    for idx_window = 1:size(windows,1)        
        for bb_id = 1:size(structGT(idx).boxes,1)
            pascalScore = computePascalScore(structGT(idx).boxes(bb_id,:),windows(idx_window,:));
            if (pascalScore >= params.pascalThreshold)
                labels(idx_window) = 1;
                break;
            end
        end
    end
    posneg(idx).labels = labels;
end

end