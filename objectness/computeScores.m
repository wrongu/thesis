function boxes = computeScores(descGT,cue,params,windows)
% computeScores(descCT, cue, params, windows)
%   compute the score for the given test image or video and the given cue.
%
%   if no windows are given, windows are generated automatically.
%
%   given W windows (in a Wx4 matrix), this function returns a Wx5 matrix
%   where the first 4 columns are unchanged and the 5th contains the score
%   for the windows computed by the given cue.
%
%   descGT is a struct. it is one of the array of structGT, and can have
%   one of two forms depending on whether it describes an image example or
%   a video example.
%   Image case:
%       descGT.type = 1; % the constant for images
%       descGT.img  = filename or image matrix; % name of an image in params.trainingImages
%       descGT.boxes = bx4 matrix; % ground truth boxes on this image
%   Video case:
%       descGT.type = 2; % the constant for videos
%       descGT.video_file  = filename; % a video in params.trainingVideos
%       descGT.frame = f; % the frame from the video to process
%       descGT.boxes = bx4 matrix; % ground truth boxes on this frame

img = [];
if descGT.type == params.TYPE_IMAGE
    if isa(descGT.img, 'char')
        img = imread(fullfile(params.trainingImages, descGT.img));
    else
        img = descGT.img;
    end
elseif descGT.type == params.TYPE_VIDEO
    V = VideoReader(descGT.video_file);
    img = read(V, descGT.frame);
end

if nargin<4
    %no windows provided - so generate them -> single cues
    
    switch cue
        
        case 'MS' %Multi-scale Saliency
            
            nscores = length(params.MS.scale) * 3;
            xmin = zeros(nscores,1);
            ymin = zeros(nscores,1);
            xmax = zeros(nscores,1);
            ymax = zeros(nscores,1);
            score = zeros(nscores,1);
            img = gray2rgb(img); %always have 3 channels
            [height, width, ~] = size(img);
            
            for sid = 1:length(params.MS.scale) %looping over the scales
                
                scale = params.MS.scale(sid);
                threshold = params.MS.theta(sid);
                min_width = max(2,round(params.min_window_width * scale/width));
                min_height = max(2,round(params.min_window_height * scale/height));
                
                samples = round(params.distribution_windows/(length(params.MS.scale)*3)); %number of samples per channel to be generated
                
                for channel = 1:3 %looping over the channels
                    
                    saliencyMAP = saliencyMapChannel(img,channel,params.MS.filtersize,scale);%compute the saliency map - for the current scale & channel
                    
                    thrmap = saliencyMAP >= threshold;
                    salmap = saliencyMAP .* thrmap;
                    thrmapIntegralImage = computeIntegralImage(thrmap);
                    salmapIntegralImage =  computeIntegralImage(salmap);
                    
                    scoreScale = slidingWindowComputeScore(double(saliencyMAP), scale, min_width, min_height, threshold, salmapIntegralImage, thrmapIntegralImage);%compute all the windows score
                    %keyboard;
                    indexPositives = find(scoreScale>0); %find the index of the windows with positive(>0) score
                    scoreScale = scoreScale(indexPositives);
                    
                    indexSamples = scoreSampling(scoreScale, samples, 1);%sample from the distribution of the scores
                    scoreScale = scoreScale(indexSamples);
                    
                    [xminScale, yminScale, xmaxScale, ymaxScale] = retrieveCoordinates(indexPositives(indexSamples) - 1,scale);%
                    xminScale = xminScale*width/scale;
                    xmaxScale = xmaxScale*width/scale;
                    yminScale = yminScale*height/scale;
                    ymaxScale = ymaxScale*height/scale;
                    
                    score = [score;scoreScale];
                    xmin = [xmin ;xminScale];
                    ymin = [ymin ;yminScale];
                    xmax = [xmax ;xmaxScale];
                    ymax = [ymax ;ymaxScale];
                    
                end%loop channel
                
            end%loop sid
            
            boxes = [xmin ymin xmax ymax score];
            boxes = boxes(1:params.distribution_windows,:);%might be more than 100000
            
        case 'CC'
            
            windows = generateWindows(img, 'uniform', params);%generate windows
            boxes = computeScores(descGT, cue, params, windows);
            
        case 'ED'
            
            windows = generateWindows(img, 'dense', params, cue);%generate windows
            boxes = computeScores(descGT, cue, params, windows);
            
        case 'SS'
            windows = generateWindows(img,'dense', params, cue);
            boxes = computeScores(descGT, cue, params, windows);
            
        case 'OF'
            
            windows = generateWindows(img, 'dense', params, cue);%generate windows
            boxes = computeScores(descGT, cue, params, windows);
            
        case 'MO'
            
            windows = generateWindows(img, 'dense', params, cue);%generate windows
            boxes = computeScores(descGT, cue, params, windows);
    end
    
else
    %windows are provided so score them
    switch cue
        
        case 'CC'
            
            [height, width, ~] = size(img);
            
            imgLAB = rgb2lab(img);%get the img in LAB space
            Q = computeQuantMatrix(imgLAB,params.CC.quant);
            integralHistogram = computeIntegralHistogramMex(double(Q), height, width, prod(params.CC.quant));
            
            xmin = round(windows(:,1));
            ymin = round(windows(:,2));
            xmax = round(windows(:,3));
            ymax = round(windows(:,4));
            
            score = computeScoreContrast(double(integralHistogram), height, width, xmin, ymin, xmax, ymax, params.CC.theta, prod(params.CC.quant), size(windows,1));%compute the CC score for the windows
            boxes = [windows score];
            
        case 'ED'
            
            [~, ~, temp] = size(img);
            if temp==3
                edgeMap = edge(rgb2gray(img),'canny');%compute the canny map for 3 channel images
            else
                edgeMap = edge(img,'canny');%compute the canny map for grey images
            end
            
            h = computeIntegralImage(edgeMap);
            
            xmin = round(windows(:,1));
            ymin = round(windows(:,2));
            xmax = round(windows(:,3));
            ymax = round(windows(:,4));
            
            [xminInner, yminInner, xmaxInner, ymaxInner] = ...
                window_offset([xmin ymin xmax ymax], params.ED.theta, ...
                'in', size(img,2), size(img,1));
            
            scoreWindows = computeIntegralImageScores(h,[xmin ymin xmax ymax]);
            scoreInnerWindows = computeIntegralImageScores(h,[xminInner yminInner xmaxInner ymaxInner]);
            areaWindows = (xmax - xmin + 1) .* (ymax - ymin +1);
            areaInnerWindows = (xmaxInner - xminInner + 1) .* (ymaxInner - yminInner + 1);
            areaDiff = areaWindows - areaInnerWindows;
            areaDiff(areaDiff == 0) = inf;
            
            score = ((xmax - xmaxInner + ymax - ymaxInner)/2) .* (scoreWindows - scoreInnerWindows) ./ areaDiff;
            boxes = [windows score];
            
        case 'SS'
            
            currentDir = pwd;
            soft_dir = params.SS.soft_dir;
            basis_sigma = params.SS.basis_sigma;
            basis_k = params.SS.theta;
            basis_min_area = params.SS.basis_min_area;
            imgType = params.imageType;
            imgBase = tempname(params.tempdir);%find a unique name for a file in params.tempdir
            imgBase = imgBase(length(params.tempdir)+1:end);
            imgName = [imgBase '.' imgType];
            cd(params.tempdir);
            imwrite(img,imgName,imgType);
            segmFileName = [imgBase '_segm.ppm'];
            
            if not(exist(segmFileName,'file'))
                % convert image to ppm
                if not(strcmp(imgType, 'ppm'))
                    cmd = [ 'convert "' imgName '" "' imgBase '.ppm"' ];
                    system(cmd);
                end
                % setting segmentation params
                I = imread([imgBase '.ppm']);
                Iarea = size(I,1)*size(I,2);
                sf = sqrt(Iarea/(300*200));
                sigma = basis_sigma*sf;
                min_area = basis_min_area*sf;
                k = basis_k;
                % segment image
                cmd = [soft_dir '/segment ' num2str(sigma) ' ' num2str(k) ' ' num2str(min_area) ' "' imgBase '.ppm' '" "' segmFileName '"' ];
                system(cmd);
                % delete image ppm
                if not(strcmp(imgType, 'ppm'))
                    delete([imgBase '.ppm']);
                    delete(imgName);
                end
                S = imread(segmFileName);
                delete(segmFileName);
            else    % segmentation file found
                S = imread(segmFileName);
            end
            
            cd(currentDir);
            
            N = numerizeLabels(S);
            superpixels = segmentArea(N);
            
            integralHist = integralHistSuperpixels(N);
            
            xmin = round(windows(:,1));
            ymin = round(windows(:,2));
            xmax = round(windows(:,3));
            ymax = round(windows(:,4));
            
            areaSuperpixels = [superpixels(:).area];
            areaWindows = (xmax - xmin + 1) .* (ymax - ymin + 1);
            
            intersectionSuperpixels = zeros(length(xmin),size(integralHist,3));
            
            for dim = 1:size(integralHist,3)
                intersectionSuperpixels(:,dim) = computeIntegralImageScores(integralHist(:,:,dim),windows);
            end
            
            score = ones(size(windows,1),1) - (sum(min(intersectionSuperpixels,repmat(areaSuperpixels,size(windows,1),1) - intersectionSuperpixels),2)./areaWindows);
            boxes = [windows score];
            
        case 'OF'
            % checkMotionParams(params);
            [h, w, ~] = size(img);
            ldof_params = get_para_flow(h, w);
            assert(descGT.type == 2, 'cue OF is undefined for images');
            im2 = read(V, descGT.frame+1);
            % compute flow
            [F, ~, ~] = LDOF(img, im2, ldof_params);
            % TODO - some sort of integral image
            % compute surrounding windows as offsets from given windows
            [xminSurr, yminSurr, xmaxSurr, ymaxSurr] = ...
                window_offset(round(windows), params.OF.theta, ...
                'out', size(img,2), size(img,1));
            
            
        case 'MO'
            assert(descGT.type == 2, 'cue MO is undefined for images');
            % checkMotionParams(params);
            
            
        otherwise
            error('Option not known: check the cue names');
    end
end

end

function offset = window_offset(w, theta, direction, imwidth, imheight)

offset = w;
xmin = w(:,1);
ymin = w(:,2);
xmax = w(:,3);
ymax = w(:,4);

switch(direction)
    case 'in'
        % shrink window by factor of theta. if w had dimensions (x,y),
        % offset will have dimensions (x*theta, y*theta), centered at the
        % same point
        xmaxInner = round((xmax*(200+theta)/(theta+100) + xmin*theta/(theta+100)+100/(theta+100)-1)/2);
        xminInner  = round(xmax + xmin - xmaxInner);
        ymaxInner = round((ymax*(200+theta)/(theta+100) + ymin*theta/(theta+100)+100/(theta+100)-1) /2);
        yminInner  = round(ymax + ymin - ymaxInner);
        offset = [xminInner, yminInner, xmaxInner, ymaxInner];
    case 'out'
        % expand window by factor of theta. if w had dimensions (x,y),
        % offset will have dimensions (x/theta, y/theta), centered at the
        % same point
        offsetWidth  = (w(:,3)-w(:,1)+1) * theta / 200;
        offsetHeight = (w(:,4)-w(:,2)+1) * theta / 200;
        xminSurr=round(max(xmin-offsetWidth,1));
        xmaxSurr=round(min(xmax+offsetWidth,imwidth));
        yminSurr=round(max(ymin-offsetHeight,1));
        ymaxSurr=round(min(ymax+offsetHeight,imheight));
        offset = [xminSurr, yminSurr, xmaxSurr, ymaxSurr];
end
end