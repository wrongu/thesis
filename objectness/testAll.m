% test cues and cue combinations

params = defaultParams(pwd, 2);
testdir = fullfile(pwd, 'Tests');

single_cues = {'MS', 'CC', 'ED', 'SS', 'OFM', 'OFD', 'MOS'};

pair_cues = {{'MS', 'ED'}, {'MS', 'SS'}, ...
            {'MS', 'ED', 'SS'}, {'MS', 'OFD'}, {'MS', 'OFM'}...
            {'MS', 'OFM', 'OFD'}, {'MS', 'SS', 'MOS'}, {'MS', 'MOS'}};

for i = 1:length(single_cues)
    params.cues = single_cues(i);
    [t, h] = testObjectness(testdir, params, true);
    tests.(single_cues{i}).data = t;
    tests.(single_cues{i}).plot = h;
end

for i = 1:length(pair_cues)
    params.cues = pair_cues{i};
    fname = horzcat(params.cues{:});
    [t, h] = testObjectness(testdir, params, true);
    tests.(fname).data = t;
    tests.(fname).plot = h;
end
