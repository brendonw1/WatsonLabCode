function CellRateVariables = SpikingAnalysis_IndividalCellRatesAnalysesWithSleep(basename,basepath,Se,Si,intervals,GoodSleepInterval,WSWEpisodes)
%% Script: SpikingAnalysis_IndividalCellRatesAnalyses
% Variables needed in work space: 
% basename, Se, Si, intervals,PreSleepUPs,UPInts
% PrePostSleepMetaData for presleep


% h = [];

%% Measures of different states from the whole recording
AllESpikeRates = Rate(Se);
AllISpikeRates = Rate(Si);

WakingESpikeRates = Rate(Se,intervals{1});
WakingISpikeRates = Rate(Si,intervals{1});
SWSESpikeRates = Rate(Se,intersect(intervals{3},GoodSleepInterval));
SWSISpikeRates = Rate(Si,intersect(intervals{3},GoodSleepInterval));

REMESpikeRates = Rate(Se,intersect(intervals{5},GoodSleepInterval));
REMISpikeRates = Rate(Si,intersect(intervals{5},GoodSleepInterval));

numWSWEpisodes = size(WSWEpisodes,2);
numUniqueECells = size(Se,1);
numUniqueICells = size(Si,1);

%% get set for concatentation over WSW Episodes
PreWakeMovingSecs = [];
WSWPreMotionBool = [];
PostWakeMovingSecs = [];
WSWPostMotionBool = [];

First5SleepESpikeRates = [];
First5SleepISpikeRates = [];
Last5SleepESpikeRates = [];
Last5SleepISpikeRates = [];
Last5PreWakeESpikeRates = [];
Last5PreWakeISpikeRates = [];
First5PostWakeESpikeRates = [];
First5PostWakeISpikeRates = [];
PrewakeESpikeRates = [];
PrewakeISpikeRates = [];
PostwakeESpikeRates = [];
PostwakeISpikeRates = [];
FirstThirdSleepSWSESpikeRates = [];
LastThirdSleepSWSESpikeRates = [];
FirstThirdSleepSWSISpikeRates = [];
LastThirdSleepSWSISpikeRates = [];
FirstSWSESpikeRates = [];
FirstSWSISpikeRates = [];
LastSWSESpikeRates = [];
LastSWSISpikeRates = [];
% ECellPercentChangesPreWakeVsPostWake = [];
% ICellPercentChangesPreWakeVsPostWake = [];
% ECellAbsoluteChangesPreWakeVsPostWake = [];
% ICellAbsoluteChangesPreWakeVsPostWake = [];
% ECellPercentChangesFirstLastThirdSWS = [];
% ICellPercentChangesFirstLastThirdSWS = [];
% ECellAbsoluteChangesFirstLastThirdSWS = [];
% ICellAbsoluteChangesFirstLastThirdSWS = [];
% ECellPercentChangesFirstVsLastSWS = [];
% ICellPercentChangesFirstVsLastSWS = [];
% ECellAbsoluteChangesFirstVsLastSWS = [];
% ICellAbsoluteChangesFirstVsLastSWS = [];

%% 

for a = 1:numWSWEpisodes;
    %Gather motion data for each wake: pre&post
    pm = fullfile(basepath,[basename '_Motion.mat']);
    tm = load(pm);
    thr = tm.motiondata.thresholdedsecs;
    prw = subset(WSWEpisodes{a},1);%prewake
    prw = [Start(prw) End(prw)]/10000;    
    PreWakeMovingSecs = cat(1,PreWakeMovingSecs,sum(thr(prw(1):prw(2))));
    WSWPreMotionBool = PreWakeMovingSecs>=200;
    pow = subset(WSWEpisodes{a},3);%prewake
    pow = [Start(pow) End(pow)]/10000;    
    PostWakeMovingSecs = cat(1,PostWakeMovingSecs,sum(thr(pow(1):pow(2))));
    WSWPostMotionBool = PostWakeMovingSecs>=200;
    
    %First V Last 5 min of sleep
    First5Sleep = intervalSet(Start(subset(WSWEpisodes{a},2)),Start(subset(WSWEpisodes{a},2))+300*10000);
    First5SleepESpikeRates = cat(1,First5SleepESpikeRates,Rate(Se,First5Sleep));
    First5SleepISpikeRates = cat(1,First5SleepISpikeRates,Rate(Si,First5Sleep));
    Last5Sleep = intervalSet(End(subset(WSWEpisodes{a},2))-300*10000,End(subset(WSWEpisodes{a},2)));
    Last5SleepESpikeRates = cat(1,Last5SleepESpikeRates,Rate(Se,Last5Sleep));
    Last5SleepISpikeRates = cat(1,Last5SleepISpikeRates,Rate(Si,Last5Sleep));
    
    %Last V First 5 min of pre/post wake
    Last5PreWake = intervalSet(End(subset(WSWEpisodes{a},1))-300*10000,End(subset(WSWEpisodes{a},1)));
    Last5PreWakeESpikeRates = cat(1,Last5PreWakeESpikeRates,Rate(Se,Last5PreWake));
    Last5PreWakeISpikeRates = cat(1,Last5PreWakeISpikeRates,Rate(Si,Last5PreWake));
    First5PostWake = intervalSet(Start(subset(WSWEpisodes{a},3)),Start(subset(WSWEpisodes{a},3))+300*10000);
    First5PostWakeESpikeRates = cat(1,First5PostWakeESpikeRates,Rate(Se,First5PostWake));
    First5PostWakeISpikeRates = cat(1,First5PostWakeISpikeRates,Rate(Si,First5PostWake));

    %Pre vs Post Wake
    preSleepWakes = subset(WSWEpisodes{a},1);%prewake
    PrewakeESpikeRates = cat(1,PrewakeESpikeRates,Rate(Se,preSleepWakes));
    PrewakeISpikeRates = cat(1,PrewakeISpikeRates,Rate(Si,preSleepWakes));
    postSleepWakes = subset(WSWEpisodes{a},3);%postwake
    PostwakeESpikeRates = cat(1,PostwakeESpikeRates,Rate(Se,postSleepWakes));
    PostwakeISpikeRates = cat(1,PostwakeISpikeRates,Rate(Si,postSleepWakes));

    % First/Last Thirds of SWS
    sleepthirds = regIntervals(subset(WSWEpisodes{a},2),3);
    FirstThirdSleepSWSESpikeRates = cat(1,FirstThirdSleepSWSESpikeRates,Rate(Se,intersect(sleepthirds{1},intervals{3})));
    LastThirdSleepSWSESpikeRates = cat(1,LastThirdSleepSWSESpikeRates,Rate(Se,intersect(sleepthirds{3},intervals{3})));
    FirstThirdSleepSWSISpikeRates = cat(1,FirstThirdSleepSWSISpikeRates,Rate(Si,intersect(sleepthirds{1},intervals{3})));
    LastThirdSleepSWSISpikeRates = cat(1,LastThirdSleepSWSISpikeRates,Rate(Si,intersect(sleepthirds{3},intervals{3})));

    % FirstSWS vs Last SWS
    thissleep = subset(WSWEpisodes{a},2);
    theseswss = intersect(intervals{3},thissleep);
    thisfirst = subset(theseswss,1);
    thislast = subset(theseswss,length(length(theseswss)));
    FirstSWSESpikeRates = cat(1,FirstSWSESpikeRates,Rate(Se,thisfirst));
    FirstSWSISpikeRates = cat(1,FirstSWSISpikeRates,Rate(Si,thisfirst));
    LastSWSESpikeRates = cat(1,LastSWSESpikeRates,Rate(Se,thislast));
    LastSWSISpikeRates = cat(1,LastSWSISpikeRates,Rate(Si,thislast));

    
%% looking at percent changes per cell
%     ECellPercentChangesPreWakeVsPostWake = (PostwakeESpikeRates-PrewakeESpikeRates)./PrewakeESpikeRates;
%     ICellPercentChangesPreWakeVsPostWake = (PostwakeISpikeRates-PrewakeISpikeRates)./PrewakeISpikeRates;
%     ECellAbsoluteChangesPreWakeVsPostWake = (PostwakeESpikeRates-PrewakeESpikeRates);
%     ICellAbsoluteChangesPreWakeVsPostWake = (PostwakeISpikeRates-PrewakeISpikeRates);
% 
%     ECellPercentChangesFirstLastThirdSWS = (LastThirdSleepSWSESpikeRates-FirstThirdSleepSWSESpikeRates)./FirstThirdSleepSWSESpikeRates;
%     ICellPercentChangesFirstLastThirdSWS = (LastThirdSleepSWSISpikeRates-FirstThirdSleepSWSISpikeRates)./FirstThirdSleepSWSISpikeRates;
%     ECellAbsoluteChangesFirstLastThirdSWS = (LastThirdSleepSWSESpikeRates-FirstThirdSleepSWSESpikeRates);
%     ICellAbsoluteChangesFirstLastThirdSWS = (LastThirdSleepSWSISpikeRates-FirstThirdSleepSWSISpikeRates);
% 
%     ECellPercentChangesFirstVsLastSWS = (LastSWSESpikeRates-FirstSWSESpikeRates)./FirstSWSESpikeRates;
%     ICellPercentChangesFirstVsLastSWS = (LastSWSISpikeRates-FirstSWSISpikeRates)./FirstSWSISpikeRates;
%     ECellAbsoluteChangesFirstVsLastSWS = (LastSWSESpikeRates-FirstSWSESpikeRates);
%     ICellAbsoluteChangesFirstVsLastSWS = (LastSWSISpikeRates-FirstSWSISpikeRates);

end

%saving neatening and arranging data for later
CellRateVariables = v2struct(basename, basepath,...
    numWSWEpisodes,numUniqueECells,numUniqueICells,...
    PreWakeMovingSecs, WSWPreMotionBool, PostWakeMovingSecs, WSWPostMotionBool,...
    AllESpikeRates,AllISpikeRates,...
    WakingESpikeRates, WakingISpikeRates,...
    SWSESpikeRates,SWSISpikeRates,...
    REMESpikeRates,REMISpikeRates,...
    First5SleepESpikeRates,First5SleepISpikeRates,...
    Last5SleepESpikeRates, Last5SleepISpikeRates,...
    Last5PreWakeESpikeRates, Last5PreWakeISpikeRates,...
    First5PostWakeESpikeRates, First5PostWakeISpikeRates,...
    PrewakeESpikeRates,PrewakeISpikeRates,...
    PostwakeESpikeRates,PostwakeISpikeRates,...
    FirstThirdSleepSWSESpikeRates,FirstThirdSleepSWSISpikeRates,...
    LastThirdSleepSWSESpikeRates,LastThirdSleepSWSISpikeRates,...
    FirstSWSESpikeRates,FirstSWSISpikeRates,LastSWSESpikeRates,LastSWSISpikeRates);
%     ECellPercentChangesPreWakeVsPostWake, ICellPercentChangesPreWakeVsPostWake,...
%     ECellAbsoluteChangesPreWakeVsPostWake, ICellAbsoluteChangesPreWakeVsPostWake,...
%     ECellPercentChangesFirstLastThirdSWS, ICellPercentChangesFirstLastThirdSWS,...
%     ECellAbsoluteChangesFirstLastThirdSWS, ICellAbsoluteChangesFirstLastThirdSWS,...
%     ECellPercentChangesFirstVsLastSWS,ICellPercentChangesFirstVsLastSWS,...
%     ECellAbsoluteChangesFirstVsLastSWS,ICellAbsoluteChangesFirstVsLastSWS);
%     UPStateESpikeRates,UPStateISpikeRates,...

save(fullfile(basepath,[basename '_CellRateVariables.mat']),'CellRateVariables')

