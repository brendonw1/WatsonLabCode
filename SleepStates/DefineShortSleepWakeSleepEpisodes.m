function WS = DefineShortSleepWakeSleepEpisodes(basepath,basename,GoodSleepInterval)
% maximizes wake time

if ~exist('basepath','var')
    basepath = cd;
    [~,basename,~] = fileparts(cd);
end
if ~exist('intervals','var')
    load(fullfile(basepath,[basename '_StateIDM.mat']),'stateintervals');
    intervals = stateintervals;
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
MinSleepDurMin = 2;%minutes
MinPreSleepMin = MinSleepDurMin;%minutes
MinPostSleepMin = MinSleepDurMin;%minutes
MaxInternalWakeInSleepMin = 0;%minutes
MinWake = 7;
% MinPreWakeMin = MinWake;%minutes
% MinPostWakeMin = MinWake;%minutes
MaxInternalSleepInWakeMin = 2;%minutes

SampFreq = 10000;%Samples per second in intervals variable
FudgeFactor = 20;% # Unlabeled samples allowed between Sleep/Wake states 
                    % that still lets them be considered adjacent
FudgeFactor = FudgeFactor * SampFreq;
% Converted to samples
MinSleepDur = MinSleepDurMin*60*SampFreq;
MaxInternalWakeInSleep =MaxInternalWakeInSleepMin*60*SampFreq;
MinWake = MinWake*60*SampFreq;
MinPreSleep = MinPreSleepMin*60*SampFreq;
MinPostSleep = MinPostSleepMin*60*SampFreq;
% MinPreWake = MinPreWakeMin*60*SampFreq;
% MinPostWake = MinPostWakeMin*60*SampFreq;
MaxInternalSleepInWake = MaxInternalSleepInWakeMin*60*SampFreq;


%% Get intervals, restrict if necessary\
if length(intervals)==5%if older style
    MergedSleepInts = union(intervals{3},intervals{4},intervals{5});%drowsy scored as sleep by palmer
    WakeInts = union(intervals{1},intervals{2});
elseif length(intervals)==3
    MergedSleepInts = union(intervals{2},intervals{3});
    WakeInts = intervals{1};
end

if exist('GoodSleepInterval','var')
    MergedSleepInts = intersect(MergedSleepInts,GoodSleepInterval);
    WakeInts = intersect(WakeInts,GoodSleepInterval);
end

%% Refine by lengths and interruptions    
% deal with wakes chunks each at least 2min in length
% WakeInts = dropShortIntervals(WakeInts,2*60*SampFreq);

% Get intervals not interrupted for too long by other intervals
MergedSleepInts = mergeCloseIntervals(MergedSleepInts,MaxInternalWakeInSleep);
MergedWakeInts = mergeCloseIntervals(WakeInts,MaxInternalSleepInWake);

% Keep only those sleeps of the min length
LongEnoughSleepInts = dropShortIntervals(MergedSleepInts,MinSleepDur);
LongEnoughWakeInts = dropShortIntervals(MergedWakeInts,MinWake);
% Predefine some vars
SWSEpisodes = {};

%% Look for contiguous Wake-Sleep-Wake episodes with proper pre-/post- wake durations
for a = 1:length(length(LongEnoughWakeInts))
    %% start with basic sleep intervals, then maximize
    okSleepsFromStart = [];
    okSleepsFromEnd = [];

    thiswake = subset(LongEnoughWakeInts,a);

    %assess which are "accessible" to the outer sleeps by being separated by less than the allowable amount
    rs = intersect(LongEnoughSleepInts,thiswake);%restrict wakes to only wakes inside this sleepint

    previousok = Start(thiswake);
    if length(length(rs))>0
      for b = 1:length(length(rs))%crawl in one minisleep at a time from the start of the sleep
            ts = subset(rs,b);
            %if start of ts is spaced away from end of rs by maxinsidewake
            thisspan = Start(ts) - previousok;
            if thisspan<=MaxInternalWakeInSleep
                   previousok = End(ts);
                   okSleepsFromStart(end+1) = b;
            else
                break%after first non-close enough interval, stop checking
            end
        end
        okIntsFromStart = subset(rs,okSleepsFromStart);%note, may be empty
    end

    previousok = End(thiswake);
    if length(length(rs))>0
        for b = length(length(rs)):-1:1%crawl in one minisleep at a time from the end of the sleep
            ts = subset(rs,b);
            %if start of ts is spaced away from end of rs by maxinsidewake
            thisspan = previousok - End(ts);
            if thisspan<=MaxInternalWakeInSleep
                previousok = Start(ts);
                okSleepsFromEnd= cat(2,b,okSleepsFromEnd);
            else
                break%after first non-close enough interval, stop checking
            end
        end
        okIntsFromEnd = subset(rs,unique(okSleepsFromEnd));
    end
    
    
    %make list of presleep possibilities
    %make list of postsleep possibilities
    %make list of sleeps based on interval between the pre & post
    presleeppossib = intervalSet([],[]);
    postsleeppossib = intervalSet([],[]);
    
    if isempty(okSleepsFromStart) %if no qualified encroaching sleeps into wake
        presleeps = Restrict(MergedSleepInts,tsd(Start(thiswake)-FudgeFactor,1));%find any wakes with times including the startpoint of thissleep (will catch if start and end at once)
        overlap = intersect(presleeps,thiswake);%check for overlap of wake and sleep time
        if Data(length(overlap))>0%if there's overlap, we already know the distances between sleep are too great, so...
            presleeppossib = cat(intervalSet(Start(subset(presleeps,1)),Start(thiswake)));%trunkate start of sleep
        else
            presleeppossib = cat(presleeppossib,presleeps);
        end
    else%if wake encrouaching into sleep
        presleep= Restrict(SleepInts,tsd(Start(thiswake)-FudgeFactor,1));
        for b = 1:length(okSleepsFromStart)
            tp = (1:b);
            tpw = timeSpan(cat(presleep,timeSpan(subset(okIntsFromStart,tp))));
            presleeppossib = cat(presleeppossib,tpw);%store away possibilities of varying levels of encroachment
        end
    end
    
    if isempty(okSleepsFromEnd) %if no qualified encroaching wakes into sleep
        postsleeps = Restrict(MergedSleepInts,tsd(End(thiswake)+FudgeFactor,1));%find any wakes with times incluign the startpoint of thissleep (will catch if start and end at once)
        overlap = intersect(postsleeps,thiswake);%check for overlap of wake and sleep time
        if Data(length(overlap))>0%if there's overlap, we already know the distances between sleep are too great, so...
            postsleeppossib = cat(postsleeppossib,intervalSet(End(thiswake),End(subset(postsleeps,length(length(postsleeps))))));%trunkate start of slep
        else
            postsleeppossib = cat(postsleeppossib,postsleeps);
        end
    else%if wake encrouaching into sleep
        postsleep = Restrict(SleepInts,tsd(End(thiswake)+FudgeFactor,1));
        for b = 1:length(okSleepsFromEnd)
            tp = (b:length(okSleepsFromEnd));
            tpw = timeSpan(cat(timeSpan(subset(okIntsFromEnd,tp)),postsleep));
            postsleeppossib = cat(postsleeppossib,tpw);%store away possibilities of varying levels of encroachment
        end
    end
    
    numpre = length(length(presleeppossib));
    numpost = length(length(postsleeppossib));

    %% SWS
    SWSokcombos = {};
    SWSokcombosleepdurs = [];
    for b = 1:numpre
        tpre = subset(presleeppossib,b);
        for c = 1:numpost
            tpost = subset(postsleeppossib,c);
            twake = intervalSet(End(tpre),Start(tpost));%find the first solution that satisfies all minima and then store that one.
            if tot_length(tpre)>MinPreSleep && tot_length(twake)>MinSleepDur && tot_length(tpost)>MinPostSleep
                SWSokcombos{end+1} = cat(tpre,twake,tpost);
                SWSokcombosleepdurs(end+1) = tot_length(twake);%for later tie-breaking if necessary
            end
        end
    end
    if ~isempty(SWSokcombosleepdurs)
        if length(SWSokcombosleepdurs)>1
            [~,SWSBestIdx] = max(SWSokcombosleepdurs);%keep the solution with max total sleep length
            SWSEpisodes{end+1} = SWSokcombos{SWSBestIdx};
        else
            SWSEpisodes{end+1} = SWSokcombos{1};
        end
    end
    
%     %% WS
%     WSokcombos = {};
%     WSokcombosleepdurs = [];
%     for b = 1:numpre
%         tpre = subset(prewakepossib,b);
% %         for c = 1:numpost
% %             tpost = subset(postwakepossib,c);
% %             tsleep = intervalSet(End(tpre),Start(tpost));
%             tsleep = intervalSet(End(tpre),End(thissleep));
% %             if tot_length(tpre)>MinPreWake && tot_length(tsleep)>MinSleepDur && tot_length(tpost)>MinPostWake
%             if tot_length(tpre)>MinPreWake && tot_length(tsleep)>MinSleepDur 
% %                 okcombos{end+1} = cat(tpre,tsleep,tpost);
%                 WSokcombos{end+1} = cat(tpre,tsleep);
%                 WSokcombosleepdurs(end+1) = tot_length(tsleep);%for later tie-breaking if necessary
%             end
% %         end
%     end
%     if ~isempty(WSokcombosleepdurs)
%         if length(WSokcombosleepdurs)>1
%             [~,WSBestIdx] = max(WSokcombosleepdurs);
%             WSEpisodes{end+1} = WSokcombos{WSBestIdx};
%         else
%             WSEpisodes{end+1} = WSokcombos{1};
%         end
%     end
% 
%     %% SW
%     SWokcombos = {};
%     SWokcombosleepdurs = [];
% %     for b = 1:numpre
% %         tpre = subset(prewakepossib,b);
%         for c = 1:numpost
%             tpost = subset(postwakepossib,c);
% %             tsleep = intervalSet(End(tpre),Start(tpost));
%                 tsleep = intervalSet(Start(thissleep),Start(tpost));
% %             if tot_length(tpre)>MinPreWake && tot_length(tsleep)>MinSleepDur && tot_length(tpost)>MinPostWake
%             if tot_length(tsleep)>MinSleepDur && tot_length(tpost)>MinPostWake
% %                 okcombos{end+1} = cat(tpre,tsleep,tpost);
%                 SWokcombos{end+1} = cat(tsleep,tpost);
%                 SWokcombosleepdurs(end+1) = tot_length(tsleep);%for later tie-breaking if necessary
%             end
%         end
% %     end
%     if ~isempty(SWokcombosleepdurs)
%         if length(SWokcombosleepdurs)>1
%             [~,SWBestIdx] = max(SWokcombosleepdurs);
%             SWEpisodes{end+1} = SWokcombos{SWBestIdx};
%         else
%             SWEpisodes{end+1} = SWokcombos{1};
%         end
%     end
%     
%     %% S
%     SEpisodes = SleepInts;
%     [~,SBestIdx] = max(Data(length(SEpisodes)));
% 
%     %% W
%     WEpisodes = LongEnoughWakeInts;
%     [~,BestIdx] = max(Data(length(WEpisodes)));
end

disp(size(SWSEpisodes))
save(fullfile(basepath,[basename '_ShortSWSEpisodes']),'SWSEpisodes','GoodSleepInterval')

