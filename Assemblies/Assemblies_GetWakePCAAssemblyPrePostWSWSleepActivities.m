function Assemblies_GetWakePCAAssemblyPrePostWSWSleepActivities(basepath,basename)


if ~exist('basepath','var')
    basepath = cd;
    [~,basename,~] = fileparts(cd);
end

%% Loading things in
t = load(fullfile(basepath,'Assemblies','WakeBasedPCA','AssemblyBasicDataWakeDetect'));
aa = t.AssemblyBasicDataWakeDetect.AssemblyActivities;

t = load(fullfile(basepath,[basename '_WSWEpisodes']));
WSWEpisodes = t.WSWEpisodes;
numWSWEpisodes = size(WSWEpisodes,2);
GoodSleepInterval = t.GoodSleepInterval;

t = load(fullfile(basepath,[basename '_Intervals']));
intervals = t.intervals;

%% get set for concatentation over WSW Episodes
PreWakeMovingSecs = [];
WSWPreMotionBool = [];
PostWakeMovingSecs = [];
WSWPostMotionBool = [];

First5SleepEAas = [];
Last5SleepEAas = [];
Last5PreWakeEAas = [];
First5PostWakeEAas = [];
PrewakeEAas = [];
PostwakeEAas = [];
FirstThirdSleepSWSEAas = [];
LastThirdSleepSWSEAas = [];
FirstSWSEAas = [];
LastSWSEAas = [];

numUniqueEAssemblies = size(aa,1);


for a = 1:numWSWEpisodes;
    %Gather motion data for each wake: pre&post
    pm = fullfile(basepath,[basename '_Motion.mat']);
    tm = load(pm);
    thr = tm.motiondata.thresholdedsecs;
    prw = subset(WSWEpisodes{a},1);%prewake
    prw = [Start(prw) End(prw)]/10000;    
    PreWakeMovingSecs = cat(1,PreWakeMovingSecs,sum(thr(prw(1):prw(2))));
    WSWPreMotionBool = PreWakeMovingSecs>=200;

    pow = subset(WSWEpisodes{a},3);%postwake
    pow = [Start(pow) End(pow)]/10000;    
    PostWakeMovingSecs = cat(1,PostWakeMovingSecs,sum(thr(pow(1):pow(2))));
    WSWPostMotionBool = PostWakeMovingSecs>=200;
    
    %First V Last 5 min of sleep
    tinterval = intervalSet(Start(subset(WSWEpisodes{a},2)),Start(subset(WSWEpisodes{a},2))+300*10000);    
    tmeans = mean(aa(:,FirstTime(tinterval,'s'):LastTime(tinterval,'s')),2);
    First5SleepEAas = cat(1,First5SleepEAas,tmeans);
    
    tinterval = intervalSet(End(subset(WSWEpisodes{a},2))-300*10000,End(subset(WSWEpisodes{a},2)));
    tmeans = mean(aa(:,FirstTime(tinterval,'s'):LastTime(tinterval,'s')),2);
    Last5SleepEAas = cat(1,Last5SleepEAas,tmeans);
    
      %Last V First 5 min of pre/post wake
    tinterval = intervalSet(End(subset(WSWEpisodes{a},1))-300*10000,End(subset(WSWEpisodes{a},1)));
    tmeans = mean(aa(:,FirstTime(tinterval,'s'):LastTime(tinterval,'s')),2);
    Last5PreWakeEAas = cat(1,Last5PreWakeEAas,tmeans);

    tinterval = intervalSet(Start(subset(WSWEpisodes{a},3)),Start(subset(WSWEpisodes{a},3))+300*10000);
    tmeans = mean(aa(:,FirstTime(tinterval,'s'):LastTime(tinterval,'s')),2);
    First5PostWakeEAas = cat(1,First5PostWakeEAas,tmeans);

    %Pre vs Post Wake
    tinterval = subset(WSWEpisodes{a},1);%prewake
    tmeans = mean(aa(:,FirstTime(tinterval,'s'):LastTime(tinterval,'s')),2);
    PrewakeEAas = cat(1,PrewakeEAas,tmeans);

    tinterval = subset(WSWEpisodes{a},3);%postwake
    tmeans = mean(aa(:,FirstTime(tinterval,'s'):LastTime(tinterval,'s')),2);
    PostwakeEAas = cat(1,PostwakeEAas,tmeans);

    % First/Last Thirds of SWS
    sleepthirds = regIntervals(subset(WSWEpisodes{a},2),3);
    
    tinterval = intersect(sleepthirds{1},intervals{3});
    tmeans = mean(aa(:,FirstTime(tinterval,'s'):LastTime(tinterval,'s')),2);
    FirstThirdSleepSWSEAas = cat(1,FirstThirdSleepSWSEAas,tmeans);
    
    tinterval = intersect(sleepthirds{3},intervals{3});
    tmeans = mean(aa(:,FirstTime(tinterval,'s'):LastTime(tinterval,'s')),2);
    LastThirdSleepSWSEAas = cat(1,LastThirdSleepSWSEAas,tmeans);

    % FirstSWS vs Last SWS
    thissleep = subset(WSWEpisodes{a},2);
    theseswss = intersect(intervals{3},thissleep);
    
    tinterval = subset(theseswss,1);
    tmeans = mean(aa(:,FirstTime(tinterval,'s'):LastTime(tinterval,'s')),2);
    FirstSWSEAas = cat(1,FirstSWSEAas,tmeans);

    tinterval = subset(theseswss,length(length(theseswss)));
    tmeans = mean(aa(:,FirstTime(tinterval,'s'):LastTime(tinterval,'s')),2);
    LastSWSEAas = cat(1,LastSWSEAas,tmeans);
end

%saving neatening and arranging data for later
WakePCAEAssembliesPrePostSleep = v2struct(basename, basepath,...
    WSWEpisodes,GoodSleepInterval,...
    numWSWEpisodes,numUniqueEAssemblies,...
    PreWakeMovingSecs, WSWPreMotionBool, PostWakeMovingSecs, WSWPostMotionBool,...
    First5SleepEAas,...
    Last5SleepEAas,...
    Last5PreWakeEAas,...
    First5PostWakeEAas,...
    PrewakeEAas,...
    PostwakeEAas,...
    FirstThirdSleepSWSEAas,...
    LastThirdSleepSWSEAas,...
    FirstSWSEAas,LastSWSEAas);

save(fullfile(basepath,'Assemblies',[basename '_WakePCAEAssembliesPrePostSleep.mat']),'WakePCAEAssembliesPrePostSleep')

