function FindInjectionComparisonIntervals(basepath)
% For injection-based recordings, find a series of time intervals of
% interest, such as hour after injection, 24hours after, baseline prior
% to, etc, save as intervals.  Many of these are in pairs, maybe shouldn't
% have done that.
% Brendon Watson 2016

if ~exist('basepath','var')
    basepath = cd;
end
basename = bz_BasenameFromBasepath(basepath);

load(fullfile(basepath,[basename '_RecordingSecondVectors.mat']))
load(fullfile(basepath,[basename '_BasicMetaData.mat']),'InjectionTimestamp')
rs=RecordingSecondVectors.RecordingSeconds;
rcs=RecordingSecondVectors.FromRecordingOn_ByClockSeconds;


%% Baseline vs 24 hours later... start to injection
BaselineStartIdx = 1;%define interest as starting with first second, find index of that...
BaselineEndIdx = find(rcs < InjectionTimestamp.InClockSecondsFromStart,1,'last');% and spanning to Injection Time

BaselineStartRecordingSeconds = rs(BaselineStartIdx);%get the actual seconds of the start in .dat time
BaselineEndRecordingSeconds = rs(BaselineEndIdx);%seconds of the end

BaselineStartRecordingClockSeconds = rcs(BaselineStartIdx);%find the clock times (vs recoridng start) corresponding with those seconds
BaselineEndRecordingClockSeconds = rcs(BaselineEndIdx);%... and end

BaselineP24StartRecordingClockSeconds = 24*3600+BaselineStartRecordingClockSeconds;
BaselineP24EndRecordingClockSeconds = 24*3600+BaselineEndRecordingClockSeconds;

BaselineP24StartIdx = find(rcs>=BaselineP24StartRecordingClockSeconds,1,'first');
BaselineP24EndIdx = find(rcs<=BaselineP24EndRecordingClockSeconds,1,'last');

BaselineP24StartRecordingSeconds = rs(BaselineP24StartIdx);
BaselineP24EndRecordingSeconds = rs(BaselineP24EndIdx);

%% Injection-1hr to Injection+1hr
InjMinusHourStartIdx = find(rcs < InjectionTimestamp.InClockSecondsFromStart-3600,1,'last');% and spanning to Injection Time
InjMinusHourEndIdx = BaselineEndIdx;
InjPlusHourStartIdx = BaselineEndIdx + 2;
InjPlusHourEndIdx = find(rcs < InjectionTimestamp.InClockSecondsFromStart+3600,1,'last');% and spanning to Injection Time

InjMinusHourStartRecordingSeconds = rs(InjMinusHourStartIdx);
InjMinusHourEndRecordingSeconds = rs(InjMinusHourEndIdx);
InjMinusHourStartRecordingClockSeconds = rcs(InjMinusHourStartIdx);
InjMinusHourEndRecordingClockSeconds = rcs(InjMinusHourStartIdx);

InjPlusHourStartRecordingSeconds = rs(InjPlusHourStartIdx);
InjPlusHourEndRecordingSeconds = rs(InjPlusHourEndIdx);
InjPlusHourStartRecordingClockSeconds = rcs(InjPlusHourStartIdx);
InjPlusHourEndRecordingClockSeconds = rcs(InjPlusHourStartIdx);

%% Inj+2hr to capture all states
InjPlus2HourStartIdx = BaselineEndIdx + 2;
InjPlus2HourEndIdx = find(rcs < InjectionTimestamp.InClockSecondsFromStart+2*3600,1,'last');% and spanning to Injection Time
InjPlus2HourStartRecordingSeconds = rs(InjPlus2HourStartIdx);
InjPlus2HourEndRecordingSeconds = rs(InjPlus2HourEndIdx);
InjPlus2HourStartRecordingClockSeconds = rcs(InjPlus2HourStartIdx);
InjPlus2HourEndRecordingClockSeconds = rcs(InjPlus2HourStartIdx);

%% Save a range of timepoints: Inj+2 Inj+4 Inj+6 Inj+12 Inj+18 Inj+24
InjPlus2HourIdx = find(rcs < InjectionTimestamp.InClockSecondsFromStart+2*3600,1,'last');% and spanning to Injection Time
InjPlus2HourRecordingSeconds = rs(InjPlus2HourIdx);
InjPlus2HourRecordingClockSeconds = rcs(InjPlus2HourIdx);

InjPlus4HourIdx = find(rcs < InjectionTimestamp.InClockSecondsFromStart+4*3600,1,'last');% and spanning to Injection Time
InjPlus4HourRecordingSeconds = rs(InjPlus4HourIdx);
InjPlus4HourRecordingClockSeconds = rcs(InjPlus4HourIdx);

InjPlus6HourIdx = find(rcs < InjectionTimestamp.InClockSecondsFromStart+6*3600,1,'last');% and spanning to Injection Time
InjPlus6HourRecordingSeconds = rs(InjPlus6HourIdx);
InjPlus6HourRecordingClockSeconds = rcs(InjPlus6HourIdx);

InjPlus12HourIdx = find(rcs < InjectionTimestamp.InClockSecondsFromStart+12*3600,1,'last');% and spanning to Injection Time
InjPlus12HourRecordingSeconds = rs(InjPlus12HourIdx);
InjPlus12HourRecordingClockSeconds = rcs(InjPlus12HourIdx);

InjPlus18HourIdx = find(rcs < InjectionTimestamp.InClockSecondsFromStart+18*3600,1,'last');% and spanning to Injection Time
InjPlus18HourRecordingSeconds = rs(InjPlus18HourIdx);
InjPlus18HourRecordingClockSeconds = rcs(InjPlus18HourIdx);

InjPlus24HourIdx = find(rcs < InjectionTimestamp.InClockSecondsFromStart+24*3600,1,'last');% and spanning to Injection Time
InjPlus24HourRecordingSeconds = rs(InjPlus24HourIdx);
InjPlus24HourRecordingClockSeconds = rcs(InjPlus24HourIdx);



%% Can do baseline vs injection+1hr using above
%% Can add others later

%%
InjectionComparisionIntervals = v2struct(...
    BaselineStartRecordingSeconds,BaselineEndRecordingSeconds,...
    BaselineP24StartRecordingSeconds,BaselineP24EndRecordingSeconds,...
    BaselineStartRecordingClockSeconds,BaselineEndRecordingClockSeconds,...
    BaselineP24StartRecordingClockSeconds,BaselineP24EndRecordingClockSeconds,...
    BaselineStartIdx,BaselineEndIdx,BaselineP24StartIdx,BaselineP24EndIdx,...
    InjMinusHourStartRecordingSeconds,InjMinusHourEndRecordingSeconds,...
    InjPlusHourStartRecordingSeconds,InjPlusHourEndRecordingSeconds,...
    InjMinusHourStartRecordingClockSeconds,InjMinusHourEndRecordingClockSeconds,...
    InjPlusHourStartRecordingClockSeconds,InjPlusHourEndRecordingClockSeconds,...
    InjPlus2HourStartRecordingSeconds,InjPlus2HourEndRecordingSeconds,...
    InjPlus2HourStartRecordingClockSeconds,InjPlus2HourEndRecordingClockSeconds,...
    InjPlus2HourRecordingSeconds,InjPlus2HourRecordingClockSeconds,...
    InjPlus4HourRecordingSeconds,InjPlus4HourRecordingClockSeconds,...
    InjPlus6HourRecordingSeconds,InjPlus6HourRecordingClockSeconds,...
    InjPlus12HourRecordingSeconds,InjPlus12HourRecordingClockSeconds,...
    InjPlus18HourRecordingSeconds,InjPlus18HourRecordingClockSeconds,...
    InjPlus24HourRecordingSeconds,InjPlus24HourRecordingClockSeconds,...
    InjMinusHourStartIdx,InjMinusHourEndIdx,InjPlusHourStartIdx,InjPlusHourEndIdx);

save(fullfile(basepath,[basename '_InjectionComparisionIntervals.mat']),'InjectionComparisionIntervals')
