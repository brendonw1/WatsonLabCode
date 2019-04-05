function SleepDataset_ExecuteOnDatasets(executestring,varstograb,datasets)
% Executes some command over a group of datasets.
% INPUTS
%    executestring = string to execute on each individual dataset (using
%                    eval command)
%    varstograb = variables to load from within each dataset - formatted as
%                    a cell of character strings
%    datasets = family of datasets in dropbox/data/sleepdatasetanalysis/...
%                ie "WSW" or "WSWandSynapses"
% OUTPUT
%    >> Determined by execute string
%
% Brendon Watson 2014

%% Get list of datasets
if exist('datasets','var')
    [names,dirs] = SleepDataset_GetDatasetsDirs(datasets);
else
    datasets = SleepDataset_GetDatasetsDirs_UI;
end
    

%% Cycle through datasets and grab any specified variables in each, to feed into the excute string
for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};
     
    
    
    clear t
    %% Execute
    eval(executestring)
    
end