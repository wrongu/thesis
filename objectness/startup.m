addpath([pwd '/']);
addpath([pwd '/MEX/']);
addpath([pwd '/CC/']);
addpath([pwd '/MS/']);
addpath([pwd '/SS/']);
addpath([pwd '/ED/']);
addpath([pwd '/OF/']);
addpath([pwd '/MO/']);
if ~exist('LDOF', 'file')
    addpath([pwd '/../LDOF_Matlab']);
end
display('Loading the default parameters ...');
params = defaultParams([pwd '/']);