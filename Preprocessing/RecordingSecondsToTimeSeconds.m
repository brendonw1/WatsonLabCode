function RecordingSecondsToTimeSeconds(basepath,basename)
% Store correspondences between recoring (ie dat file) second timestamps
% and clock time.  0.1sec resolution. 
% Brendon Watson 2016

if ~exist('basepath','var')
    [~,basename] = fileparts(cd);
    basepath = cd;
end
if ~exist(basepath,'dir')
    basepath = fullfile(getdropbox,'Data','KetamineDataset',basename);
end


load(fullfile(basepath,[basename '_DatInfo.mat']))
load(fullfile(basepath,[basename '_SecondsFromLightsOn.mat']))

RecordingSeconds = .1:.1:sum(recordingseconds);

% Clock seconds since light on (on day 1)
LightOn_ClockSeconds = [];
RecordingStartsFromLightOnByClock = SecondsAfterLightCycleStart_PerFile;
RecordingEndsFromLightOnByClock = SecondsAfterLightCycleStart_PerFile+recordingseconds;
for a = 1:length(RecordingStartsFromLightOnByClock)
    LightOn_ClockSeconds = cat(2,LightOn_ClockSeconds,RecordingStartsFromLightOnByClock(a)+.1:.1:RecordingEndsFromLightOnByClock(a));
end

% Clock seconds since start of file
RecordingOn_ClockSeconds = LightOn_ClockSeconds-SecondsAfterLightCycleStart_PerFile(1);
RecordingStartsFromRecordingOnByClock = RecordingStartsFromLightOnByClock-SecondsAfterLightCycleStart_PerFile(1);
RecordingEndsFromRecordingOnByClock = RecordingEndsFromLightOnByClock-SecondsAfterLightCycleStart_PerFile(1);


RecordingSecondVectors = v2struct(RecordingSeconds,LightOn_ClockSeconds,...
    RecordingOn_ClockSeconds,...
    RecordingStartsFromLightOnByClock,RecordingEndsFromLightOnByClock,...
    RecordingStartsFromRecordingOnByClock,RecordingEndsFromRecordingOnByClock);

save(fullfile(basepath,[basename '_RecordingSecondVectors.mat']),'RecordingSecondVectors')

