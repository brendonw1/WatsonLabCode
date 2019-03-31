function SleepDataset_SingleCellSleepChanges

%% get dataset info from directory
[names,dirs] = SleepDataset_GetDatasetsDirs_WSWCellsSynapses;

 for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};

    t = load([fullfile(dirs{a},names{a}) '_SSubtypes.mat']);
    Se = t.Se;
    Si = t.Si;
    t = load([fullfile(dirs{a},names{a}) '_WSWEpisodes.mat']);
    WSWEpisodes = t.WSWEpisodes;
    WSWBestIdx = t.WSWBestIdx;

    Wint1 = subset(WSWEpisodes{WSWBestIdx},1);%prewake
    Wint2 = subset(WSWEpisodes{WSWBestIdx},3);%postwake
    t = regIntervals(subset(WSWEpisodes{WSWBestIdx},2),3);
    Sint1 = t{1};%first third SWS
    Sint2 = t{3};%last third SWS
    
    [Echangingcells,Echangedir,Eps] = SpikeRateDistribChangeOverIntervals(Se,Wint1,Wint2,5);
    [Ichangingcells,Ichangedir,Ips] = SpikeRateDistribChangeOverIntervals(Si,Wint1,Wint2,5);
    
    %calc proportion of Se and Si Cells
    
    1;
    
    % once have the cells... what?  save their trains
    % plot
    
 end