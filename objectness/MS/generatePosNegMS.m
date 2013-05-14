

function posneg = generatePosNegMS(params)

if params.primary_type == params.TYPE_IMAGE
    ld = load(fullfile(params.trainingImages, 'structGT.mat'));
elseif params.primary_type == params.TYPE_VIDEO
    ld = load(fullfile(params.trainingVideos, 'structGT.mat'));
end
structGT = ld.structGT;

posneg(1:length(structGT)) = struct( ...
    'examples', [], ...
    'labels', [], ...
    'type', 0, ...
    'scores', [], ...
    'video_file', [], ...
    'frame', 0, ...
    'img', []);

parfor idx = 1:length(structGT)
    posneg(idx).type = structGT(idx).type;
    if structGT(idx).type == params.TYPE_IMAGE
        posneg(idx).img = imread(fullfile(params.trainingImages, structGT(idx).img));
        if isa(posneg(idx).img, 'uint8')
            posneg(idx).img = double(posneg(idx).img) / 255;
        end
    elseif structGT(idx).type == params.TYPE_VIDEO
        posneg(idx).video_file = structGT(idx).video_file;
        posneg(idx).frame = structGT(idx).frame;
    end
    boxes = computeScores(structGT(idx),'MS',params);
    posneg(idx).examples =  boxes(:,1:4);
    labels = -ones(size(boxes,1),1);
    for idx_window = 1:size(boxes,1)
        for bb_id = 1:size(structGT(idx).boxes,1)
            pascalScore = computePascalScore(structGT(idx).boxes(bb_id,:),boxes(idx_window,1:4));
            if (pascalScore >= params.pascalThreshold)
                labels(idx_window) = 1;
                break;
            end
        end
    end
    posneg(idx).labels = labels;
    posneg(idx).scores = boxes(:,5);
end

end
