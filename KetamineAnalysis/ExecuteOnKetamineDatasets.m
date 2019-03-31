function ExecuteOnKetamineDatasets(executestring,varargin)
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
% determine whether want to require only sessions with below > 1 means
% require each condition be met, 0 means don't worry (all zeros means just 
% acquire sleep and spikes recordings)
[names,dirs]=GetKetamineDataset;

varstograb = varargin;

%% Cycle through datasets and excute string
for a = 1:length(dirs)
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};

    eval(executestring)
end