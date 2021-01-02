%% AddHelperPaths.m
% 4/27/2020 - Pho Hale
% This import scripts adds the helper functions to the MATLAB path. 
% Needs to be manually updated when new folders are added.

addpath('Helpers');
helperNamesGenPath = {'General', 'Parsing', 'Filesystem', 'Export', 'MatlabMeta', 'Dual-Cursors', ...
    'UX', 'UserAnnotationsManager', 'ComputerVision', 'Plotting', 'Naming'};
helperNames = {'DateTime', ['DateTime/datestr8601']};

for i=1:length(helperNames)
    currName = fullfile('Helpers',helperNames{i});
    addpath(currName);
end

for i=1:length(helperNamesGenPath)
    currName = fullfile('Helpers',helperNamesGenPath{i});
    addpath(genpath(currName));
end