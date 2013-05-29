function tests = testObjectness(testDirectory, params)
% testObjectness(testDirectory) test the objectness measure according to
% params.cues
%
% testDirectory must contain a file 'testDirectory/testStructGT.mat' which
% contains a struct array 'structGT': the descriptors of test cases.

testfile = fullfile(testDirectory, 'testStructGT.mat');

if ~exist(testfile, 'file')
    error(['testObjectness: no testStructGT.mat found in ' testDirectory]);
else
    ld = load(testfile);
    structGT = ld.structGT;
end

if ~exist(fullfile(testDirectory, 'saves'), 'file')
    mkdir(fullfile(testDirectory, 'saves'));
end

tests(1:4, length(structGT)) = struct('W', 0, 'boxes', [], 'percent', 0);
for t = 1:size(tests,1)
    for s = 1:length(structGT)
        tests(t,s).W = 10^(t-1);
        tests(t,s).descGT = structGT(s);
    end
end

if length(params.cues) > 1
    fprintf('BEGINNING TEST WITH CUES ');
    for i=1:length(params.cues)-1
        fprintf('%s, ', params.cues{i});
    end
    fprintf('AND %s\n', params.cues{end});
else
    fprintf('BEGINNING TEST WITH CUE %s\n', params.cues{1});
end
for w = 1:size(tests,1)
    W = tests(w,1).W;
    savefile = fullfile(testDirectory, 'saves', get_save_file(params, W));
    if exist(savefile, 'file')
        fprintf('loading %s\n', savefile);
        ld = load(savefile);
        tests(w,:) = ld.slice;
    else
        slice = tests(w,:);
        parfor ex = 1:size(tests,2)
            fprintf('Test: W = %d\tExample = %d\n', W, ex);
            slice(ex).boxes = runObjectness(slice(ex).descGT, slice(ex).W, params);
            
            count_valid = 0;
            for box = 1:size(slice(ex).boxes, 1)
                for annot = 1:size(slice(ex).descGT.boxes, 1)
                    if computePascalScore(slice(ex).boxes(box,:), ...
                            slice(ex).descGT.boxes(annot,:) >= params.pascalThreshold)
                        count_valid = count_valid + 1;
                        break;
                    end
                end
            end
            
            slice(ex).percent = count_valid / size(slice(ex).boxes, 1);
        end
        save(savefile, 'slice');
        tests(w,:) = slice;
    end
end

end

% TODO - ONE SAVE FILE PER ROW (i.e. per windows)

function filename = get_save_file(params, W)

cues = sort(params.cues);

cue_str = '';
for i=1:length(cues)
    cue_str = [cue_str cues{i}];
end

filename = sprintf('testresult_%s_W%d.mat', cue_str, W);

end
