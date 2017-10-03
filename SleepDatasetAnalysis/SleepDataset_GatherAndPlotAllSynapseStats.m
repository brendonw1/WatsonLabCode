function SleepDataset_GatherAndPlotAllSynapseStats
%% Get list of datasets
if exist('datasets','var')
    [names,dirs] = SleepDataset_GetDatasetsDirs(datasets);
else
    [names,dirs] = SleepDataset_GetDatasetsDirs_UI;
end
    

%% Cycle through datasets and grab any specified variables in each, to feed into the excute string
for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};
     
    t = load([fullfile(dirs{a},names{a}) '_CellIDs.mat']);
    CellIDs = t.CellIDs;
    t = load([fullfile(dirs{a},names{a}) '_funcsynapses.mat']);
    funcsynapses = t.funcsynapses;
    clear t
    % Execute
    if a == 1; 
        SynCounts = CountFuncsynapses(funcsynapses,CellIDs);
    else
        SynCounts = CountFuncsynapses(funcsynapses,CellIDs,SynCounts);
    end
end


%% Plot

PlotSynapseCounts(SynCounts)
