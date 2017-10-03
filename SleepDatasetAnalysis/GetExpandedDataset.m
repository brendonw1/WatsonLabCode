function [names,dirs]=GetExpandedDataset(varargin)
%just enter any of the variable names below to get a dataset restricted to
%criteria where the variable with that name is set to 1
ws = 0;
synapses = 0;
spindles = 0;
new = 0;
sleepdep=0;
upsundone = 0;
hippocampus = 0;

if exist('varargin','var')
    for a = 1:length(varargin);
        if exist(varargin{a},'var')
            eval([varargin{a} '= 1;']);
        else
            error([varargin{a} ' is an Invalid entry'])
        end
    end
end


[names,dirs] = SleepAnalysis_GetDatasetNameDirsFromSleepSessionMatrix(ws,synapses,spindles,new,sleepdep,upsundone,hippocampus);
