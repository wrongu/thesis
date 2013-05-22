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
        ld = load(savefile);
        tests(w,:) = ld.slice;
    else
        for ex = 1:size(tests,2)
            fprintf('Test: W = %d\tExample = %d\n', tests(t).W, mod((t-1), length(structGT))+1);
            tests(t).boxes = runObjectness(tests(t).descGT, tests(t).W, params);
            
            count_valid = 0;
            for box = 1:size(tests(t).boxes, 1)
                for annot = 1:size(tests(t).descGT.boxes, 1)
                    if computePascalScore(tests(t).boxes(box,:), ...
                            tests(t).descGT.boxes(annot,:) >= params.pascalThreshold)
                        count_valid = count_valid + 1;
                        break;
                    end
                end
            end
            
            tests(t).percent = count_valid / size(tests(t).boxes, 1);
        end
        slice = tests(w, :);
        save(savefile, 'slice');
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