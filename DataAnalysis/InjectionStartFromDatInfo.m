function InjectionTimestamp = InjectionStartFromDatInfo(basepath,basename,InjectionStartFile)

if ~exist('basepath','var')
    [~,basename] = fileparts(cd);
    basepath = cd;
end

if ~exist(basepath,'dir')
    basepath = fullfile(getdropbox,'Data','KetamineDataset',basename);
end

load(fullfile(basepath,[basename '_DatInfo.mat']));
load(fullfile(basepath,[basename '_SecondsFromLightsOn.mat']));
Par = LoadPar(fullfile(basepath,[basename '.xml']));

InClockSecondsFromZeitgeber = SecondsAfterLightCycleStart_PerFile(InjectionStartFile);

th = floor(InClockSecondsFromZeitgeber/3600);
tm = floor((InClockSecondsFromZeitgeber-(3600*th))/60);
ts = InClockSecondsFromZeitgeber - tm*60 - th*3600;
InClockTime.h = 6+th;
InClockTime.m = tm;
InClockTime.s = ts;

InClockSecondsFromStart = InClockSecondsFromZeitgeber - SecondsAfterLightCycleStart_PerFile(1);

InRecordingSeconds = cumsum(recordingbytes(1:InjectionStartFile-1));
InRecordingSeconds = InRecordingSeconds(end)/Par.nChannels/2/Par.SampleRate;

InjectionTimestamp = v2struct(InClockSecondsFromZeitgeber,...
    InClockSecondsFromStart,InClockTime,InRecordingSeconds);