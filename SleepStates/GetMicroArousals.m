function [MAInts,WakeInterruptionInts,AnyWakish,REM] = GetMicroArousals(basepath,basename)
% finds microarousals and other elements based on WSRestrictedIntervals
% MAs are defined as <= 40sec and adjacent to only Packets, not adjacent to
% REM

% set max length
MAMaxDur = 40;

% load up
if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end
wpath = fullfile(basepath,[basename,'_WSRestrictedIntervals.mat']);

%get some intervals
%% Dan's way(?)
spath = fullfile(basepath,[basename,'_StateIDM.mat']);
load(spath,'stateintervals');
AnyWakish = stateintervals{1};
MAs = dropLongIntervals(AnyWakish,MAMaxDur*10000);

%% OLD WAY
% load(wpath)
% IPIs = minus(SleepInts,SWSPacketInts);
% REM = intersect(REMEpisodeInts,IPIs);
% AnyWakish = minus(IPIs,REM);
% MAs = dropLongIntervals(AnyWakish,MAMaxDur*10000);


%% find MAs within 2sec of REM, get rid of them
mase = StartEnd(MAs,'s');
mase(:,1) = mase(:,1)-2;%if gap less than 1 second separation from neighboring REM, toss it 
mase(:,2) = mase(:,2)+2;% ...(+-2 and look for overlap leads to search for start/ends within 1sec)
bad = InIntervalsBW(mase(:,1),StartEnd(stateintervals{3},'s')) + InIntervalsBW(mase(:,2),StartEnd(stateintervals{3},'s'));
maidxs = 1:length(length(MAs));
MAInts = subset(MAs,maidxs(~bad));

% classify all other wake
WakeInterruptionInts = minus(AnyWakish,MAInts);
WakeInterruptionInts = dropLongIntervals(WakeInterruptionInts,120*10000);
WakeInterruptionInts = dropShortIntervals(WakeInterruptionInts,1*10000);

% Write extra variable into _WSRestrictedIntervals
copyfile(wpath,fullfile(basepath,[basename,'_WSRestrictedIntervals_NoMAs.mat']));
save(wpath,'MAInts','-append')
save(wpath,'WakeInterruptionInts','-append')
% names = MatVariableList(fpath);
% namestr = '';
% for a = 1:length(names);namestr = strcat(namestr,'''',names{a},''',');end
% namestr = strcat(namestr,'''MAInts'',''WakeInterruptionInts''');
% eval(['save(fpath,' namestr ');'])
% % eval(['save(''test.mat'',' namestr ');'])
