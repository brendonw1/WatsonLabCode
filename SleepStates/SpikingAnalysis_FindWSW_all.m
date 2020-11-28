function SpikingAnalysis_FindWSW_all

wsw = 0;
synapses = 0;
spindles = 1;
[names,dirs] = SleepAnalysis_GetDatasetNameDirsFromSleepSessionMatrix(wsw,synapses,spindles);

wswlist = {};
wslist = {};

for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};
    cd(basepath)
    
    if exist(fullfile(basepath,[basename '_WSWEpisodes.mat']),'file')
        movefile(fullfile(basepath,[basename '_WSWEpisodes.mat']),fullfile(basepath,[basename '_WSWEpisodes_OLD.mat']))
    end
    if exist(fullfile(basepath,[basename '_WSWEpisodes2.mat']),'file')
        movefile(fullfile(basepath,[basename '_WSWEpisodes2.mat']),fullfile(basepath,[basename '_WSWEpisodes2_OLD.mat']))
    end
    
    %% Get intervals useful for Sleep Analysis... sleep minimum = 20min, wake min = 6min
    GoodSleepInterval = load(fullfile(basepath,[basename '_GoodSleepInterval.mat']));
    GoodSleepInterval = GoodSleepInterval.GoodSleepInterval;

    intervals = load(fullfile(basepath,[basename '_Intervals.mat']));
    intervals = intervals.intervals;
    
    [WSWEpisodes,WSWBestIdx] = DefineWakeSleepWakeEpisodes(intervals,GoodSleepInterval);
    [WSEpisodes,WSBestIdx] = DefineWakeSleepEpisodes(intervals,GoodSleepInterval);
    [SWEpisodes,SWBestIdx] = DefineSleepWakeEpisodes(intervals,GoodSleepInterval);
    [SEpisodes,SBestIdx] = DefineSleepEpisodes(intervals,GoodSleepInterval);
    [WEpisodes,WBestIdx] = DefineWakeEpisodes(intervals,GoodSleepInterval);

    if ~isempty(WSWBestIdx)
        wswlist = cat(1,wswlist,basename);%running list of those meeting criteria
    end
    if ~isempty(WSBestIdx)
        wslist = cat(1,wslist,basename);%running list of those meteing criteria
    end
    save(fullfile(basepath,[basename '_WSWEpisodes']),'WSWEpisodes','WSWBestIdx','WSEpisodes','WSBestIdx','SWEpisodes','SWBestIdx','SEpisodes','SBestIdx','WEpisodes','WBestIdx','GoodSleepInterval')
end