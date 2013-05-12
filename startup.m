% startup.m
%
% created on April 30, 2013
% written by Richard Lange
%
% Sets up paths for the workspace

root_path = pwd;
addpath(fullfile(pwd, 'objectness'));
addpath(fullfile(pwd, 'LDOF_Matlab'));
addpath(fullfile(pwd, 'MoSeg_Matlab'));
addpath(fullfile(pwd, 'DGradient'));
addpath(fullfile(pwd, 'SpectralClustering'));
addpath(fullfile(pwd, 'SpectralClustering/files'));

disp('-- OBJECTNESS STARTUP --');
cd('objectness');
startup;
cd(root_path);

disp('-- MOSEG STARTUP --');
cd('MoSeg_Matlab');
startup;
cd(root_path);