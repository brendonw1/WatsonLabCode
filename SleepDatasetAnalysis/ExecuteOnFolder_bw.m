function ExecuteOnFolder_bw(executestring,folderpath)
% Executes some command over a group of datasets.
% INPUTS
%    executestring = string to execute on each individual dataset (using
%                    eval command)
% OUTPUT
%    >> Determined by execute string
%
% Brendon Watson 2014


if ~exist('folderpath','var')
    folderpath = cd;
end

%% Get list of datasets
d = getdir(folderpath);
names = {};
dirs = {};
for count = 1:length(d);
    if d(count).isdir
        names{end+1} = d(count).name;
        dirs{end+1} = fullfile(folderpath,d(count).name);
    end
end
% [names,dirs]=GetDefaultDataset('new');

%% Cycle through datasets and grab any specified variables in each, to feed into the excute string
for count = 3:length(dirs);
    disp(['Starting ' names{count}])
    basename = names{count};
    basepath = dirs{count};
     
    eval(executestring)
    
end