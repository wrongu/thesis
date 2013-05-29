% test cues and cue combinations

params = defaultParams(pwd, 2);
testdir = fullfile(pwd, 'Tests');

single_cues = {'MS', 'CC', 'ED', 'SS', 'OFM', 'OFD', 'MOS'};

pair_cues = {{'MS', 'CC'}, {'MS', 'ED'}, {'MS', 'SS'}, ...
            {'CC', 'ED'}, {'CC', 'SS'}, {'ED', 'SS'}, ...
            {'OFM', 'OFD'}, {'SS', 'MOS'}};

for i = 1:length(single_cues)
    params.cues = single_cues(i);
    testObjectness(testdir, params);
end

for i = 1:length(pair_cues)
    params.cues = pair_cues{i};
    testObjectness(testdir, params);
end
