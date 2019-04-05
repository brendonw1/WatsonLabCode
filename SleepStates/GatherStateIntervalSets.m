function StateIntervals = GatherStateIntervalSets(basepath,basename,RestrictInterval)
% Returns intervalSets for common states for a given recording.
% Brendon Watson 2015

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

if ~exist('RestrictInterval','var')
    %     RestrictInterval = intervalSet(0,Inf);
    t = load([fullfile(basepath,basename) '_GoodSleepInterval.mat']);
    RestrictInterval = t.GoodSleepInterval;
end

%% Load everything we'll need
load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']),'WakeSleep');
numWSEpisodes = length(WakeSleep);
load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']),'WakeInts');
load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']),'SWSPacketInts');
load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']),'REMInts');
load(fullfile(basepath,[basename '_StateIDM.mat']),'WakeSleep');
% t = load(fullfile(basepath,[basename '_WSWEpisodes.mat']));
% WakeSleep = t.WakeSleep;
% t = load(fullfile(basepath,[basename '_Intervals.mat']));
% intervals = t.intervals;
t = load(fullfile(basepath,'Spindles','SpindleData.mat'));
ns = t.SpindleData.normspindles;
t = load(fullfile(basepath,'Spindles','SpindleDataNoDOWN.mat'));
ndns = t.SpindleData.normspindles;
load(fullfile(basepath,[basename ,'_UPDOWNIntervals.mat']),'UPInts');
load(fullfile(basepath,[basename ,'_UPDOWNIntervals.mat']),'ONInts');
load(fullfile(basepath,[basename ,'_UPDOWNIntervals.mat']),'DNInts');
load(fullfile(basepath,[basename ,'_UPDOWNIntervals.mat']),'OFFInts');
load(fullfile(basepath,[basename ,'_UPDOWNIntervals.mat']),'GammaInts');
% t = load(fullfile(basepath,'UPstates',[basename '_SpindleUPEvents.mat']));
% SpUPIdxs = t.SpindleUPEvents.SpindleUPs;
% NonSpUPIdxs = t.SpindleUPEvents.NoSpindleUPs;
% t = load(fullfile(basepath,[basename '_Motion.mat']));
% ms = t.motiondata.thresholdedsecs;


%% Basics
for a = 1:length(WakeSleep)
    if a == 1
        ws = WakeSleep{a};
        Sleep = subset(WakeSleep{a},2);
    else
        ws = cat(ws, WakeSleep{a});
        Sleep = cat(Sleep,subset(WakeSleep{a},2));
    end
end
WakeSleepCycles = intersect(ws,RestrictInterval);
WSWake = intersect(WakeInts,RestrictInterval);
SWS = intersect(SWSPacketInts,RestrictInterval);
REM = intersect(REMInts,RestrictInterval);
WSSleep = intersect(Sleep,union(SWS,REM));

%% Moving Wake
% wakesecs = [Start(Wake,'s') End(Wake,'s')];%for motion later
% wakesecs = inttobool(wakesecs,length(ms));
% movewake = wakesecs.*ms';
% movewake2 = booltoint(movewake);
% MWake = intervalSet(movewake2(:,1)*10000-9999,movewake2(:,2)*10000);
% % Non-moving Wake
% nonmovewake = ~movewake;
% nonmovewake = nonmovewake .* wakesecs;%Have to take times that are both (notmoving) and (yeswake)
% nonmovewake2 = booltoint(nonmovewake);
% NMWake = intervalSet(nonmovewake2(:,1)*10000-9999,nonmovewake2(:,2)*10000);

%% First/Last SWS of each WSEpisode
for a = 1:length(WakeSleep);
    theseswss = intersect(WakeSleep{a},SWSPacketInts);
    if a == 1;
        FSWS = subset(theseswss,1);
        LSWS = subset(theseswss,length(length(theseswss)));
    else
        FSWS = cat(FSWS,subset(theseswss,1));
        LSWS = cat(LSWS,subset(theseswss,length(length(theseswss))));
    end
end


%% Spindles
Spindles = intervalSet(ns(:,1)*10000,ns(:,3)*10000);
Spindles = intersect(Spindles,RestrictInterval);
% NDSpindles = intervalSet(ndns(:,1),ndns(:,3));
% NDSpindles = intersect(NDSpindles,RestrictInterval);

%% UP states etc
UPstates = UPInts;
UPstates = intersect(UPstates,RestrictInterval);
% SpUPstates = subset(u,SpUPIdxs);
% SpUPstates = intersect(SpUPstates,RestrictInterval);
% NonSpUPstates = subset(u,NonSpUPIdxs);
% NonSpUPstates = intersect(NonSpUPstates,RestrictInterval);
DNstates = DNInts;
DNstates = intersect(DNstates,RestrictInterval);
ONstates = ONInts;
ONstates = intersect(ONstates,RestrictInterval);
OFFstates = OFFInts;
OFFstates = intersect(OFFstates,RestrictInterval);
LowGamma = GammaInts;
LowGamma = intersect(LowGamma,RestrictInterval);

%% Portions of States
load(fullfile(basepath,[basename '_StateIDA.mat']),'stateintervals')
for a = 1:length(stateintervals)%convert to intervalsets
    stateintervals{a} = intervalSet(stateintervals{a}(:,1)*10000,stateintervals{a}(:,2)*10000);
end
% load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']))
% wakestarts = Start(WakeInts,'s');%find official wake episodes
% wakeends = End(WakeInts,'s');

WS = DefineWakeSleepWakeEpisodes(basepath,basename,stateintervals,RestrictInterval);
wakestarts = Start(WS.WEpisodes,'s');%find official wake episodes
wakeends = End(WS.WEpisodes,'s');

% wakeb = intervalSet([],[]); %% unnecessary, have wswake
wakea = intervalSet([],[]);
wakea1quarter = intervalSet([],[]);
wakea2quarter = intervalSet([],[]);
wakea3quarter = intervalSet([],[]);
wakea4quarter = intervalSet([],[]);
wakeb1quarter = intervalSet([],[]);
wakeb2quarter = intervalSet([],[]);
wakeb3quarter = intervalSet([],[]);
wakeb4quarter = intervalSet([],[]);
wssleep1quarter = intervalSet([],[]);
wssleep2quarter = intervalSet([],[]);
wssleep3quarter = intervalSet([],[]);
wssleep4quarter = intervalSet([],[]);
sws1quarter = intervalSet([],[]);
sws2quarter = intervalSet([],[]);
sws3quarter = intervalSet([],[]);
sws4quarter = intervalSet([],[]);
rem1quarter = intervalSet([],[]);
rem2quarter = intervalSet([],[]);
rem3quarter = intervalSet([],[]);
rem4quarter = intervalSet([],[]);


for a = 1:numWSEpisodes;
    sleepend = End(subset(WakeSleep{a},2),'s');    % just look for WSW overlapping with this WS... take the W from there
    good = find((wakestarts-sleepend)<1*60 & wakeends-sleepend>7*60);%find wakes taht start within 1min of sleep and end more than 7 min after
    if ~isempty(good)
        if length(good)>1
            [~,good] = max(Data(length(subset(WS.WEpisodes,good))));
        end
        goodint = intervalSet(sleepend*10000,wakeends(good)*10000);%make sure the candidate starts after sleep ends
        twake = intersect(goodint,stateintervals{1});%find the wake parts in the specified interval    
        wakea = cat(wakea,twake);
        wakeaquarters = regIntervals(twake,4);%in case
        wakea1quarter = cat(wakea1quarter,intersect(wakeaquarters{1},stateintervals{1}));
        wakea2quarter = cat(wakea2quarter,intersect(wakeaquarters{2},stateintervals{1}));
        wakea3quarter = cat(wakea3quarter,intersect(wakeaquarters{3},stateintervals{1}));
        wakea4quarter = cat(wakea4quarter,intersect(wakeaquarters{4},stateintervals{1}));
    end
    
%     wakeb = cat(wakeb,twake);%unncessary, use WSWake
    wakebquarters = regIntervals(subset(WakeSleep{a},1),4);
    wakeb1quarter = cat(wakeb1quarter,intersect(wakebquarters{1},stateintervals{1}));
    wakeb2quarter = cat(wakeb2quarter,intersect(wakebquarters{2},stateintervals{1}));
    wakeb3quarter = cat(wakeb3quarter,intersect(wakebquarters{3},stateintervals{1}));
    wakeb4quarter = cat(wakeb4quarter,intersect(wakebquarters{4},stateintervals{1}));

    wssleepquarters = regIntervals(subset(WakeSleep{a},2),4);
    wssleep1quarter = cat(wssleep1quarter,wssleepquarters{1});
    wssleep2quarter = cat(wssleep2quarter,wssleepquarters{2});
    wssleep3quarter = cat(wssleep3quarter,wssleepquarters{3});
    wssleep4quarter = cat(wssleep4quarter,wssleepquarters{4});
    
    sws1quarter = cat(sws1quarter,intersect(SWSPacketInts,wssleepquarters{1}));
    sws2quarter = cat(sws2quarter,intersect(SWSPacketInts,wssleepquarters{2}));
    sws3quarter = cat(sws3quarter,intersect(SWSPacketInts,wssleepquarters{3}));
    sws4quarter = cat(sws4quarter,intersect(SWSPacketInts,wssleepquarters{4}));

    rem1quarter = cat(rem1quarter,intersect(REMInts,wssleepquarters{1}));
    rem2quarter = cat(rem2quarter,intersect(REMInts,wssleepquarters{2}));
    rem3quarter = cat(rem3quarter,intersect(REMInts,wssleepquarters{3}));
    rem4quarter = cat(rem4quarter,intersect(REMInts,wssleepquarters{4}));
end 



StateIntervals = v2struct(WakeSleepCycles,WSWake,WSSleep,SWS,REM,...
    FSWS,LSWS,Spindles,UPstates,DNstates,ONstates,OFFstates,LowGamma,...
    wakea,...
    wakea1quarter,wakea2quarter,wakea3quarter,wakea4quarter,...
    wakeb1quarter,wakeb2quarter,wakeb3quarter,wakeb4quarter,...
    wssleep1quarter,wssleep2quarter,wssleep3quarter,wssleep4quarter,...
    sws1quarter,sws2quarter,sws3quarter,sws4quarter,...
    rem1quarter,rem2quarter,rem3quarter,rem4quarter);
% StateIntervals = v2struct(Wake,SWS,REM,MWake,NMWake,...
%     UPstates,SpUPstates,NonSpUPstates,Spindles,NDSpindles);

savematname = fullfile(basepath,[basename '_StateIntervals.mat']);
save(savematname,'StateIntervals')