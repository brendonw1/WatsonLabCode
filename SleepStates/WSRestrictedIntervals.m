function WSRestrictedIntervals(basepath,basename)
% Gets intervalSets of times confined to pre-determined Wake-Sleep Cycles.
% Episodes are states (wake/SWS or REM) at least 20ms long and are confined
% to the Sleep part of Wake Sleep Cycles.  
% - WakeInts = intervalSet of Wake from within WakeSleep
% - SleepInts = intervalSet of Sleep from within WakeSleep
% - SWSEpisodeInts = intervalSet of SWSEpisodes only within SleepInts
% - SWSPacketInts = intervalSet of SWSPackets only within SWSEpisodeInts
% - REMEpisodeInts = intervalSet of REMEpisodes only within SleepInts
% - REMInts = intervalSet of REM only within REMEpisodeInts
%
% Brendon Watson 2015.


if ~exist('basepath','var')
    basepath = cd;
    [~,basename,~] = fileparts(cd);
end

%% Make collections of SWS, REM etc restricted to only WS Cycles (which are already restricted to 

load(fullfile(basepath,[basename '_StateIDM.mat']));

for a = 1:length(WakeSleep);
    if a == 1;
        WakeInts = subset(WakeSleep{a},1);
        SleepInts = subset(WakeSleep{a},2);
    else
        WakeInts = cat(WakeInts,subset(WakeSleep{a},1));
        SleepInts = cat(SleepInts,subset(WakeSleep{a},2));
    end
end

SWSEpisodeInts = intersect(episodeintervals{2},SleepInts);
SWSPacketInts = intersect(packetintervals{1},SWSEpisodeInts);

REMEpisodeInts = intersect(episodeintervals{3},SleepInts);
REMInts = intersect(REMEpisodeInts,stateintervals{end});

save(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']),'WakeSleep','WakeInts','SleepInts','SWSEpisodeInts','SWSPacketInts','REMEpisodeInts','REMInts')
