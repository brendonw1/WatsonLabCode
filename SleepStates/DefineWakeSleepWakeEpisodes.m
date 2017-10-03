function WS = DefineWakeSleepWakeEpisodes(basepath,basename,intervals,GoodSleepInterval)
% maximizes sleep time


if ~exist('basepath','var')
    basepath = cd;
    [~,basename,~] = fileparts(cd);
end
if ~exist('intervals','var')
    t = load(fullfile(basepath,[basename '_Intervals.mat']));
    intervals = t.intervals;
end
if ~exist('GoodSleepInterval','var')
    t = load(fullfile(basepath,[basename '_GoodSleepInterval.mat']));
    GoodSleepInterval = t.GoodSleepInterval;
end



% At least 20min
% No intervening awake greater than 2 min
% At least 7min waking before and 7min waking after...?
%     

%% Setup
% Change to inputs??
MinSleepDurMin = 20;%minutes
MaxInternalWakeInSleepMin = 2;%minutes
MinWake = 7;
MinPreWakeMin = MinWake;%minutes
MinPostWakeMin = MinWake;%minutes
MaxInternalSleepInWakeMin = 2;%minutes

SampFreq = 10000;%Samples per second in intervals variable
FudgeFactor = 20;% # Unlabeled samples allowed between Sleep/Wake states 
                    % that still lets them be considered adjacent
FudgeFactor = FudgeFactor * SampFreq;
% Converted to samples
MinSleepDur = MinSleepDurMin*60*SampFreq;
MaxInternalWakeInSleep =MaxInternalWakeInSleepMin*60*SampFreq;
MinWake = MinWake*60*SampFreq;
MinPreWake = MinPreWakeMin*60*SampFreq;
MinPostWake = MinPostWakeMin*60*SampFreq;
MaxInternalSleepInWake = MaxInternalSleepInWakeMin*60*SampFreq;


%% Get intervals, restrict if necessary\
if length(intervals)==5%if older style
    SleepInts = union(intervals{3},intervals{4},intervals{5});%drowsy scored as sleep by palmer
    WakeInts = union(intervals{1},intervals{2});
elseif length(intervals)==3
    SleepInts = union(intervals{2},intervals{3});%drowsy scored as sleep by palme
    WakeInts = intervals{1};
end

if exist('GoodSleepInterval','var')
    SleepInts = intersect(SleepInts,GoodSleepInterval);
    WakeInts = intersect(WakeInts,GoodSleepInterval);
end

%% Refine by lengths and interruptions    
% Get intervals not interrupted for too long by other intervals
SleepInts = mergeCloseIntervals(SleepInts,MaxInternalWakeInSleep);
MergedWakeInts = mergeCloseIntervals(WakeInts,MaxInternalSleepInWake);

% Keep only those sleeps of the min length
SleepInts = dropShortIntervals(SleepInts,MinSleepDur);
LongEnoughWakeInts = dropShortIntervals(MergedWakeInts,MinWake);
% Predefine some vars
WSWEpisodes = {};
WSWBestIdx = [];
WSEpisodes = {};
WSBestIdx = [];
SWEpisodes = {};
SWBestIdx = [];
WEpisodes = {};
WBestIdx = [];
SEpisodes = {};
SBestIdx = [];

%% Look for contiguous Wake-Sleep-Wake episodes with proper pre-/post- wake durations
for a = 1:length(length(SleepInts))
    okWakesFromStart = [];
    okWakesFromEnd = [];
%     okStartsFromStart = [];
%     okStartsFromEnd = [];
%     okEndsFromStart = [];
%     okEndsFromEnd = [];
%     okIntsFromStart = [];
%     okIntsFromEnd = [];

    thissleep = subset(SleepInts,a);

    %assess which are "accessible" to the outer sleeps by being separated by less than the allowable amount
    rw = intersect(WakeInts,thissleep);%restrict wakes to only wakes inside this sleepint

    previousok = Start(thissleep);
    if length(length(rw))>0
      for b = 1:length(length(rw))%crawl in one minisleep at a time from the start of the sleep
            tw = subset(rw,b);
            %if start of tw is spaced away from end of rw by maxinsidewake
            thisspan = Start(tw) - previousok;
            if thisspan<=MaxInternalSleepInWake
                   previousok = End(tw);
                   okWakesFromStart(end+1) = b;
            else
                break%after first non-close enough interval, stop checking
            end
        end
        okIntsFromStart = subset(rw,okWakesFromStart);%note, may be empty
    end

    previousok = End(thissleep);
    if length(length(rw))>0
        for b = length(length(rw)):-1:1%crawl in one minisleep at a time from the end of the sleep
            tw = subset(rw,b);
            %if start of tw is spaced away from end of rw by maxinsidewake
            thisspan = previousok - End(tw);
            if thisspan<=MaxInternalSleepInWake
                previousok = Start(tw);
                okWakesFromEnd= cat(2,b,okWakesFromEnd);
            else
                break%after first non-close enough interval, stop checking
            end
        end
        okIntsFromEnd = subset(rw,unique(okWakesFromEnd));
    end
    
    
    %make list of prewake possibilities
    %make list of postwake possibilities
    %make list of sleeps based on interval between the pre & post
    prewakepossib = intervalSet([],[]);
    postwakepossib = intervalSet([],[]);
    
    if isempty(okWakesFromStart) %if no qualified encroaching wakes into sleep
        prewakes = Restrict(MergedWakeInts,tsd(Start(thissleep)-FudgeFactor,1));%find any wakes with times including the startpoint of thissleep (will catch if start and end at once)
        overlap = intersect(prewakes,thissleep);%check for overlap of wake and sleep time
        if Data(length(overlap))>0%if there's overlap, we already know the distances between sleep are too great, so...
            prewakepossib = cat(intervalSet(Start(subset(prewakes,1)),Start(thissleep)));%trunkate start of sleep
        else
            prewakepossib = cat(prewakepossib,prewakes);
        end
    else
        prewake = Restrict(WakeInts,tsd(Start(thissleep)-FudgeFactor,1));
        for b = 1:length(okWakesFromStart)
            tp = (1:b);
            tpw = timeSpan(cat(prewake,timeSpan(subset(okIntsFromStart,tp))));
            prewakepossib = cat(prewakepossib,tpw);
        end
    end
    
    if isempty(okWakesFromEnd) %if no qualified encroaching wakes into sleep
        postwakes = Restrict(MergedWakeInts,tsd(End(thissleep)+FudgeFactor,1));%find any wakes with times incluign the startpoint of thissleep (will catch if start and end at once)
        overlap = intersect(postwakes,thissleep);%check for overlap of wake and sleep time
        if Data(length(overlap))>0%if there's overlap, we already know the distances between sleep are too great, so...
            postwakepossib = cat(postwakepossib,intervalSet(End(thissleep),End(subset(postwakes,length(length(postwakes))))));%trunkate start of slep
        else
            postwakepossib = cat(postwakepossib,postwakes);
        end
    else
        postwake = Restrict(WakeInts,tsd(End(thissleep)+FudgeFactor,1));
        for b = 1:length(okWakesFromEnd)
            tp = (b:length(okWakesFromEnd));
            tpw = timeSpan(cat(timeSpan(subset(okIntsFromEnd,tp)),postwake));
            postwakepossib = cat(postwakepossib,tpw);
        end
    end
        %find wakes with time before this sleep
        %find overlap
        %if overlap is mostly sleep > Sleep
        % if overlap is mostly wake > wake
%     numpre = length(length(prewakepossib));
%     numpost = length(length(postwakepossib));
%     okcombos = {};
%     okcombosleepdurs = [];
%     for b = 1:numpre
%         tpre = subset(prewakepossib,b);
%         for c = 1:numpost
%             tpost = subset(postwakepossib,c);
%             tsleep = intervalSet(End(tpre),Start(tpost));
%             if tot_length(tpre)>MinPreWake && tot_length(tsleep)>MinSleepDur && tot_length(tpost)>MinPostWake
%                 okcombos{end+1} = cat(tpre,tsleep,tpost);
%                 okcombosleepdurs(end+1) = tot_length(tsleep);%for later tie-breaking if necessary
%             end
%         end
%     end
    numpre = length(length(prewakepossib));
    numpost = length(length(postwakepossib));

    %% WSW
    WSWokcombos = {};
    WSWokcombosleepdurs = [];
    for b = 1:numpre
        tpre = subset(prewakepossib,b);
        for c = 1:numpost
            tpost = subset(postwakepossib,c);
            tsleep = intervalSet(End(tpre),Start(tpost));
            if tot_length(tpre)>MinPreWake && tot_length(tsleep)>MinSleepDur && tot_length(tpost)>MinPostWake
                WSWokcombos{end+1} = cat(tpre,tsleep,tpost);
                WSWokcombosleepdurs(end+1) = tot_length(tsleep);%for later tie-breaking if necessary
            end
        end
    end
    if ~isempty(WSWokcombosleepdurs)
        if length(WSWokcombosleepdurs)>1
            [~,WSWBestIdx] = max(WSWokcombosleepdurs);
            WSWEpisodes{end+1} = WSWokcombos{WSWBestIdx};
        else
            WSWEpisodes{end+1} = WSWokcombos{1};
        end
    end
    
    %% WS
    WSokcombos = {};
    WSokcombosleepdurs = [];
    for b = 1:numpre
        tpre = subset(prewakepossib,b);
%         for c = 1:numpost
%             tpost = subset(postwakepossib,c);
%             tsleep = intervalSet(End(tpre),Start(tpost));
            tsleep = intervalSet(End(tpre),End(thissleep));
%             if tot_length(tpre)>MinPreWake && tot_length(tsleep)>MinSleepDur && tot_length(tpost)>MinPostWake
            if tot_length(tpre)>MinPreWake && tot_length(tsleep)>MinSleepDur 
%                 okcombos{end+1} = cat(tpre,tsleep,tpost);
                WSokcombos{end+1} = cat(tpre,tsleep);
                WSokcombosleepdurs(end+1) = tot_length(tsleep);%for later tie-breaking if necessary
            end
%         end
    end
    if ~isempty(WSokcombosleepdurs)
        if length(WSokcombosleepdurs)>1
            [~,WSBestIdx] = max(WSokcombosleepdurs);
            WSEpisodes{end+1} = WSokcombos{WSBestIdx};
        else
            WSEpisodes{end+1} = WSokcombos{1};
        end
    end

    %% SW
    SWokcombos = {};
    SWokcombosleepdurs = [];
%     for b = 1:numpre
%         tpre = subset(prewakepossib,b);
        for c = 1:numpost
            tpost = subset(postwakepossib,c);
%             tsleep = intervalSet(End(tpre),Start(tpost));
                tsleep = intervalSet(Start(thissleep),Start(tpost));
%             if tot_length(tpre)>MinPreWake && tot_length(tsleep)>MinSleepDur && tot_length(tpost)>MinPostWake
            if tot_length(tsleep)>MinSleepDur && tot_length(tpost)>MinPostWake
%                 okcombos{end+1} = cat(tpre,tsleep,tpost);
                SWokcombos{end+1} = cat(tsleep,tpost);
                SWokcombosleepdurs(end+1) = tot_length(tsleep);%for later tie-breaking if necessary
            end
        end
%     end
    if ~isempty(SWokcombosleepdurs)
        if length(SWokcombosleepdurs)>1
            [~,SWBestIdx] = max(SWokcombosleepdurs);
            SWEpisodes{end+1} = SWokcombos{SWBestIdx};
        else
            SWEpisodes{end+1} = SWokcombos{1};
        end
    end
    
    %% S
    SEpisodes = SleepInts;
    [~,SBestIdx] = max(Data(length(SEpisodes)));

    %% W
    WEpisodes = LongEnoughWakeInts;
    [~,BestIdx] = max(Data(length(WEpisodes)));
end

WS = v2struct(WSWEpisodes,WSWBestIdx,WSEpisodes,WSBestIdx,...
    SWEpisodes,SWBestIdx,...
    SEpisodes,SBestIdx,WEpisodes,WBestIdx);

% save(fullfile(basepath,[basename '_WSWEpisodes']),'WSWEpisodes','WSWBestIdx','WSEpisodes','WSBestIdx','SWEpisodes','SWBestIdx','SEpisodes','SBestIdx','WEpisodes','WBestIdx','GoodSleepInterval')

