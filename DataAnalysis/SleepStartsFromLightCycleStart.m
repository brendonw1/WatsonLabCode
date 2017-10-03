function SleepStartsFromLightCycleStart
% Gather meta file start times clock 
%    GetDefaultDataset...
%     ('TimeFromLightsOn(basepath,basename);')
%    Save seconds
%    Save Seconds per WS as well, by just adding time of each
%    Plot by session, by WS Episode

plotting = 1;

[names,dirs]=GetDefaultDataset;

SecondsAfterLightCycleStart = [];
WSSleepStarts = [];
WSSleepEnds = [];

for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};
%     disp(['Starting ' basename])
    load(fullfile(basepath,[basename '_WSWEpisodes.mat']))
    load(fullfile(basepath,[basename '_GoodSleepInterval.mat']))
    se = load(fullfile(basepath,[basename '_SecondsFromLightsOn.mat']));

    SecondsAfterLightCycleStart(end+1) = se.SecondsAfterLightCycleStart;

    for a = 1:length(WSEpisodes)
        ts = Start(intersect(WSEpisodes{a},GoodSleepInterval),'s');
        te = End(intersect(WSEpisodes{a},GoodSleepInterval),'s');
        WSSleepStarts(end+1) = ts(2) + SecondsAfterLightCycleStart(end);
        WSSleepEnds(end+1) = te(2) + SecondsAfterLightCycleStart(end);
    end
end


if plotting
   h = figure('position',[100 0 500 800],'Name','SleepStartsVsLightCycle');
   subplot(2,1,1)
   hist(SecondsAfterLightCycleStart/3600,20)
   title('Hours Past Light Cycle Start that Recordings Start.  Lights on at 6am')
   
   subplot(2,1,2)
   hist(WSSleepStarts/3600,40)
   title('Hours Past Light Cycle Start that Sleeps (within WS Cycles) Start')

   MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/OverallStats',h)
end