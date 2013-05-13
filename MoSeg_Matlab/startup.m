% startup.m
%
% created on April 30, 2013
% written by Richard Lange
%
% Sets up paths for the MoSeg_Matlab workspace

% flag 3 is for mex files
if exist('DGradient', 'file') ~= 3
    addpath('../DGradient');
    need_mex = exist('DGradient.c', 'file') & (exist('DGradient', 'file') ~= 3);
    if need_mex
        root = pwd;
        fprintf('mex DGradient.c');
        cd('../DGradient');
        mex DGradient.c;
        fprintf(' ...finished\n');
        cd(root);
    end
    clear need_mex root;
end

if ~exist('LDOF', 'file')
    fprintf('adding ../LDOF_Matlab to the path\n');
    addpath('../LDOF_Matlab');
    root = pwd;
    cd('../LDOF_Matlab');
    startup;
    cd(root);
    clear root;
end

if ~exist('SpectralClustering', 'file')
    fprintf('adding ../SpectralClustering/files to the path\n');
    addpath('../SpectralClustering/files');
end

mosegParams = structMosegParams('../data/Youtube/10class/penguin/03.avi', 1, 30);