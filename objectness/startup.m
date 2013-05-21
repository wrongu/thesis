addpath([pwd '/']);
addpath([pwd '/MEX/']);
addpath([pwd '/CC/']);
addpath([pwd '/MS/']);
addpath([pwd '/SS/']);
addpath([pwd '/ED/']);
addpath([pwd '/OF/']);
addpath([pwd '/MOS/']);
if ~exist('LDOF', 'file')
    root = pwd;
    cd('../LDOF_Matlab'); startup;
    cd(root); clear root;
end
if ~exist('moseg', 'file')
    root = pwd;
    cd('../MoSeg_Matlab'); startup;
    cd(root); clear root;
end

display('Loading the default parameters ...');
params = defaultParams([pwd '/'], 2);
