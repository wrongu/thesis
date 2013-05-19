function testObjectness(testDirectory, params)
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

for i=1:length(structGT)
    
end

end