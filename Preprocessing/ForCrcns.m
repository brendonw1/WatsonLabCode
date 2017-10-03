function ForCrcns(obasepath,obasename)
% Copies files and trunkates as necessary based on good sleep recording

if ~exist(['/mnt/brendon4/ForCRCNS/Data/' obasename '/'],'dir')
    eval(['! mkdir /mnt/brendon4/ForCRCNS/Data/' obasename '/'])
end

%% GoodSleepInterval will guide all else
load(fullfile(obasepath,[obasename, '_GoodSleepInterval.mat']))
t.timePairFormat = StartEnd(GoodSleepInterval,'s')/10000;
t.intervalSetFormat = intervalSet(t.timePairFormat(:,1),t.timePairFormat(:,2));
GoodSleepInterval = t;
save(['/mnt/brendon4/ForCRCNS/Data/' obasename '/' obasename '_GoodSleepInterval.mat'],'GoodSleepInterval');
gsi = t.intervalSetFormat;
gend = End(gsi);
clear GoodSleepInterval t

%% Basic metadata
bmd = load(fullfile(obasepath,[obasename '_BasicMetaData.mat']));
bp = bmd.basepath;
s = strfind(bp,'/');
bp = strcat(bp(1:s(2)),'brendon7',bp(s(3):end));
bmd.basepath = bp;
if isfield(bmd,'masterpath');
    mp = bmd.masterpath;
    s = strfind(mp,'/');
    mp = strcat(mp(1:s(2)),'brendon7',mp(s(3):end));
    bmd.masterpath = mp;
end
v2struct(bmd)
SaveBasicMetaData

bmd.RecordingFileIntervals = StartEnd(bmd.RecordingFileIntervals,'s')/10000;
bmd.RecordingFileIntervals = bmd.RecordingFileIntervals(find(bmd.RecordingFilesForSleep),:);
bmd = rmfield(bmd,'RecordingFilesForSleep');
if isfield(bmd,'Ripplechannel')
    bmd = rmfield(bmd,'Ripplechannel');
end
save(['/mnt/brendon4/ForCRCNS/Data/' obasename '/' obasename '_BasicMetaData.mat'],'bmd');

%% XML and EEG/LFP, restricted to GoodSleepInterval
eegpath = findsessioneeglfpfile(obasepath,obasename);
% eval(['! cp ' eegpath ' /mnt/brendon4/ForCRCNS/Data/' basename '/'])
gsibytes = gend*bmd.Par.nChannels*2*1250;
eval(['! head -c ' num2str(gsibytes) ' ' eegpath ' > /mnt/brendon4/ForCRCNS/Data/' obasename '/' obasename '.eeg'])
clear gsibytes bmd 

eval(['! cp ' eegpath(1:end-3) 'xml /mnt/brendon4/ForCRCNS/Data/' obasename '/' obasename '.xml'])


%% .mats that need some conversion

% WSRestrictedIntervals
load(fullfile(obasepath,[obasename, '_WSRestrictedIntervals.mat']))
REMEpisodeTimePairFormat = StartEnd(REMEpisodeInts,'s')/10000;
REMEpisodeIntervalSetFormat = intervalSet(REMEpisodeTimePairFormat(:,1),REMEpisodeTimePairFormat(:,2));
REMTimePairFormat = StartEnd(REMInts,'s')/10000;
REMIntervalSetFormat = intervalSet(REMTimePairFormat(:,1),REMTimePairFormat(:,2));
SWSEpisodeTimePairFormat = StartEnd(SWSEpisodeInts,'s')/10000;
SWSEpisodeIntervalSetFormat = intervalSet(SWSEpisodeTimePairFormat(:,1),SWSEpisodeTimePairFormat(:,2));
SWSPacketTimePairFormat = StartEnd(SWSPacketInts,'s')/10000;
SWSPacketIntervalSetFormat = intervalSet(SWSPacketTimePairFormat(:,1),SWSPacketTimePairFormat(:,2));
MATimePairFormat = StartEnd(MAInts,'s')/10000;
MAIntervalSetFormat = intervalSet(MATimePairFormat(:,1),MATimePairFormat(:,2));
WakeInterruptionTimePairFormat = StartEnd(WakeInterruptionInts,'s')/10000;
WakeInterruptionIntervalSetFormat = intervalSet(WakeInterruptionTimePairFormat(:,1),WakeInterruptionTimePairFormat(:,2));
WakeTimePairFormat = StartEnd(WakeInts,'s')/10000;
WakeIntervalSetFormat = intervalSet(WakeTimePairFormat(:,1),WakeTimePairFormat(:,2));
SleepTimePairFormat = StartEnd(SleepInts,'s')/10000;
SleepIntervalSetFormat = intervalSet(SleepTimePairFormat(:,1),SleepTimePairFormat(:,2));
for a = 1:length(WakeSleep);
    WakeSleepTimePairFormat{a} = StartEnd(WakeSleep{a},'s')/10000;
    WakeSleepIntervalSetFormat{a} = intervalSet(WakeSleepTimePairFormat{a}(:,1),WakeSleepTimePairFormat{a}(:,2));
end
save(['/mnt/brendon4/ForCRCNS/Data/' obasename '/' obasename '_WSRestrictedIntervals.mat'],...
    'REMEpisodeTimePairFormat','REMEpisodeIntervalSetFormat',...
    'REMTimePairFormat','REMIntervalSetFormat',...
    'SWSEpisodeTimePairFormat','SWSEpisodeIntervalSetFormat',...
    'SWSPacketTimePairFormat','SWSPacketIntervalSetFormat',...
    'MATimePairFormat', 'MAIntervalSetFormat',...
    'WakeInterruptionTimePairFormat','WakeInterruptionIntervalSetFormat',...
    'WakeTimePairFormat','WakeIntervalSetFormat',...
    'SleepTimePairFormat','SleepIntervalSetFormat',...
    'WakeSleepTimePairFormat','WakeSleepIntervalSetFormat');

clear REMEpisodeInts REMEpisodeTimePairFormat REMEpisodeIntervalSetFormat REMTimePairFormat REMTimePairFormat...
    REMInts REMTimePairFormat REMIntervalSetFormat SWSEpisodeTimePairFormat SWSEpisodeIntervalSetFormat...
	SWSEpisodeInts SWSPacketInts SWSPacketTimePairFormat SWSPacketIntervalSetFormat ...
    MAInts MATimePairFormat MAIntervalSetFormat WakeInterruptionInts WakeInterruptionTimePairFormat WakeInterruptionIntervalSetFormat...
    WakeTimePairFormat WakeIntervalSetFormat...
    SleepTimePairFormat SleepIntervalSetFormat WakeSleepTimePairFormat WakeSleepIntervalSetFormat WakeInts SleepInts WakeSleep

%SAll
load(fullfile(obasepath,[obasename, '_SAll.mat']))
for a = 1:length(S);
    ttimes = Range(S{a})/10000;%correct for new version of toolbox
    ttimes(ttimes>gend) = [];
    S_CellFormat{a} = ttimes;
    t{a} = tsd(ttimes,ttimes);
end
S_TsdArrayFormat = tsdArray(t);
save(['/mnt/brendon4/ForCRCNS/Data/' obasename '/' obasename '_SAll.mat'],'S_TsdArrayFormat','S_CellFormat','shank','cellIx');
clear S t S_TsdArrayFormat S_CellFormat shank cellIx ttimes

%SBurstFiltered
load(fullfile(obasepath,[obasename, '_SBurstFiltered.mat']))
for a = 1:length(Sbf);
    ttimes = Range(Sbf{a})/10000;%correct for new version of toolbox
    ttimes(ttimes>gend) = [];
    S_CellFormat{a} = ttimes;
    t{a} = tsd(ttimes,ttimes);
end
S_TsdArrayFormat = tsdArray(t);
save(['/mnt/brendon4/ForCRCNS/Data/' obasename '/' obasename '_SBurstFiltered.mat'],'S_TsdArrayFormat','S_CellFormat');
clear Sbf t S_TsdArrayFormat S_CellFormat ttimes

%SStable
load(fullfile(obasepath,[obasename, '_SStable.mat']))
for a = 1:length(S);
    ttimes = Range(S{a})/10000;%correct for new version of toolbox
    ttimes(ttimes>gend) = [];
    S_CellFormat{a} = ttimes;
    t{a} = tsd(ttimes,ttimes);
end
S_TsdArrayFormat = tsdArray(t);
if ~exist('badcells','var');
    badcells = [];
end
if ~exist('numgoodcells','var');
    numgoodcells = length(S);
end
save(['/mnt/brendon4/ForCRCNS/Data/' obasename '/' obasename '_SStable.mat'],'S_TsdArrayFormat','S_CellFormat','shank','cellIx','badcells','numgoodcells');
clear S t S_TsdArrayFormat S_CellFormat shank cellIx badcells numgoodcells ttimes

%SSubtypes
load(fullfile(obasepath,[obasename, '_SSubtypes.mat']))
    % Se
for a = 1:length(Se);
    ttimes = Range(Se{a})/10000;%correct for new version of toolbox
    ttimes(ttimes>gend) = [];
    Se_CellFormat{a} = ttimes;
    t{a} = tsd(ttimes,ttimes);
end
Se_TsdArrayFormat = tsdArray(t);
clear t ttimes
    % SeDef
for a = 1:length(SeDef);
    ttimes = Range(SeDef{a})/10000;%correct for new version of toolbox
    ttimes(ttimes>gend) = [];
    SeDef_CellFormat{a} = ttimes;
    t{a} = tsd(ttimes,ttimes);
end
if exist('t','var')
    SeDef_TsdArrayFormat = tsdArray(t);
else
    SeDef_TsdArrayFormat = [];
end
clear t ttimes
    % SeLike
for a = 1:length(SeLike);
    ttimes = Range(SeLike{a})/10000;%correct for new version of toolbox
    ttimes(ttimes>gend) = [];
    SeLike_CellFormat{a} = ttimes;
    t{a} = tsd(ttimes,ttimes);
end
if exist('t','var')
    SeLike_TsdArrayFormat = tsdArray(t);
else
    SeLike_TsdArrayFormat = [];
end
clear t ttimes
    % Si
for a = 1:length(Si);
    ttimes = Range(Si{a})/10000;%correct for new version of toolbox
    ttimes(ttimes>gend) = [];
    Si_CellFormat{a} = ttimes;
    t{a} = tsd(ttimes,ttimes);
end
if exist('t','var')
    Si_TsdArrayFormat = tsdArray(t);
else
    Si_TsdArrayFormat = [];
end
clear t ttimes
    % SiDef
for a = 1:length(SiDef);
    ttimes = Range(SiDef{a})/10000;%correct for new version of toolbox
    ttimes(ttimes>gend) = [];
    SiDef_CellFormat{a} = ttimes;
    t{a} = tsd(ttimes,ttimes);
end
if exist('t','var')
    SiDef_TsdArrayFormat = tsdArray(t);
else
    SiDef_TsdArrayFormat = [];
end
clear t ttimes
    % SiLike
for a = 1:length(SiLike);
    ttimes = Range(SiLike{a})/10000;%correct for new version of toolbox
    ttimes(ttimes>gend) = [];
    SiLike_CellFormat{a} = ttimes;
    t{a} = tsd(ttimes,ttimes);
end
if exist('t','var')
    SiLike_TsdArrayFormat = tsdArray(t);
else
    SiLike_TsdArrayFormat = [];
end
clear t ttimes

save(['/mnt/brendon4/ForCRCNS/Data/' obasename '/' obasename '_SSubtypes.mat'],...
    'Se_TsdArrayFormat','Se_CellFormat')
try
    save(['/mnt/brendon4/ForCRCNS/Data/' obasename '/' obasename '_SSubtypes.mat'],...
        'SeDef_TsdArrayFormat','SeDef_CellFormat','-append')
end
try
    save(['/mnt/brendon4/ForCRCNS/Data/' obasename '/' obasename '_SSubtypes.mat'],...
        'SeLike_TsdArrayFormat','SeLike_CellFormat','-append')
end
try 
    save(['/mnt/brendon4/ForCRCNS/Data/' obasename '/' obasename '_SSubtypes.mat'],...
        'Si_TsdArrayFormat','Si_CellFormat','-append')
end
try
    save(['/mnt/brendon4/ForCRCNS/Data/' obasename '/' obasename '_SSubtypes.mat'],...
        'SiDef_TsdArrayFormat','SiDef_CellFormat','-append')
end
try
    save(['/mnt/brendon4/ForCRCNS/Data/' obasename '/' obasename '_SSubtypes.mat'],...
        'SiLike_TsdArrayFormat','SiLike_CellFormat','-append')
end

clear S t Se_TsdArrayFormat Se_CellFormat Si_TsdArrayFormat Si_CellFormat ...
    SeDef_TsdArrayFormat SeDef_CellFormat SiDef_TsdArrayFormat SiDef_CellFormat ...
    SeLike_TsdArrayFormat SeLike_CellFormat SiLike_TsdArrayFormat SiLike_CellFormat ttimes...
    Se Si SeDef SiDef SeLike SiLike SeRates SiRates

% EMGCorr
load(fullfile(obasepath,[obasename, '_EMGCorr.mat']))
i = EMGCorr(:,1)<=gend;
EMGCorr = EMGCorr(i,:);
save(['/mnt/brendon4/ForCRCNS/Data/' obasename '/' obasename '_EMGCorr.mat'],'EMGCorr')
clear EMGCorr i

% Motion
load(fullfile(obasepath,[obasename, '_Motion.mat']))
i = 1:length(motiondata.motion);
i = i<=gend;
motiondata.motion = motiondata.motion(i);
motiondata.thresholdedsecs = motiondata.thresholdedsecs(i);
save(['/mnt/brendon4/ForCRCNS/Data/' obasename '/' obasename '_Motion.mat'],'motiondata')
clear motiondata

%% Detected Events
%UP/DOWN states - these are already restricted
load(fullfile(obasepath,[obasename, '_UPDOWNIntervals.mat']))
UPIntsTimePairFormat = StartEnd(UPInts)/10000;
UPIntsIntervalSetFormat = intervalSet(UPIntsTimePairFormat(:,1),UPIntsTimePairFormat(:,2));
DNIntsTimePairFormat = StartEnd(DNInts)/10000;
DNIntsIntervalSetFormat = intervalSet(DNIntsTimePairFormat(:,1),DNIntsTimePairFormat(:,2));
ONIntsTimePairFormat = StartEnd(ONInts)/10000;
ONIntsIntervalSetFormat = intervalSet(ONIntsTimePairFormat(:,1),ONIntsTimePairFormat(:,2));
OFFIntsTimePairFormat = StartEnd(OFFInts)/10000;
OFFIntsIntervalSetFormat = intervalSet(OFFIntsTimePairFormat(:,1),OFFIntsTimePairFormat(:,2));
GammaIntsTimePairFormat = StartEnd(GammaInts)/10000;
GammaIntsIntervalSetFormat = intervalSet(GammaIntsTimePairFormat(:,1),GammaIntsTimePairFormat(:,2));
save(['/mnt/brendon4/ForCRCNS/Data/' obasename '/' obasename '_UPDOWNINtervals.mat'],...
    'UPIntsTimePairFormat', 'UPIntsIntervalSetFormat',...
    'DNIntsTimePairFormat', 'DNIntsIntervalSetFormat',...
    'ONIntsTimePairFormat', 'ONIntsIntervalSetFormat',...
    'OFFIntsTimePairFormat', 'OFFIntsIntervalSetFormat',...
    'GammaIntsTimePairFormat', 'GammaIntsIntervalSetFormat', 'UPchannel');
clear UPInts DNInts ONInts OFFInts GammaInts UPIntsTimePairFormat ...
    UPIntsIntervalSetFormat DNIntsTimePairFormat DNIntsIntervalSetFormat...
    ONIntsTimePairFormat ONIntsIntervalSetFormat ...
    OFFIntsTimePairFormat OFFIntsIntervalSetFormat...
    GammaIntsTimePairFormat GammaIntsIntervalSetFormat UPchannel

%Spindles - already restricted
eval(['! cp ' fullfile(obasepath,[obasename '_SpindleData.mat']) ' /mnt/brendon4/ForCRCNS/Data/' obasename '/' [obasename, '_Spindles.mat']])


%% other .mats
eval(['! cp ' fullfile(obasepath,[obasename '_CellClassificationOutput.mat']) ' /mnt/brendon4/ForCRCNS/Data/' obasename '/'])
eval(['! cp ' fullfile(obasepath,[obasename '_CellIDs.mat']) ' /mnt/brendon4/ForCRCNS/Data/' obasename '/'])
eval(['! cp ' fullfile(obasepath,[obasename '_ChannelAnatomy.csv']) ' /mnt/brendon4/ForCRCNS/Data/' obasename '/'])
eval(['! cp ' fullfile(obasepath,[obasename '_ClusteringNotes.csv']) ' /mnt/brendon4/ForCRCNS/Data/' obasename '/'])
eval(['! cp ' fullfile(obasepath,[obasename '_ClusterQualityMeasures.mat']) ' /mnt/brendon4/ForCRCNS/Data/' obasename '/'])
eval(['! cp ' fullfile(obasepath,[obasename '_funcsynapsesMoreStringent.mat']) ' /mnt/brendon4/ForCRCNS/Data/' obasename '/'])
eval(['! cp ' fullfile(obasepath,[obasename '_MeanWaveforms.mat']) ' /mnt/brendon4/ForCRCNS/Data/' obasename '/'])



function temp2(basepath,basename)
% res, fet, spk, clu
eval(['! mkdir /mnt/brendon4/ForCRCNS2/' basename '/'])
eval(['! cp -a ' basepath '/' basename '.clu.* /mnt/brendon4/ForCRCNS2/' basename '/'])
eval(['! cp -a ' basepath '/' basename '.res.* /mnt/brendon4/ForCRCNS2/' basename '/'])
eval(['! cp -a ' basepath '/' basename '.fet.* /mnt/brendon4/ForCRCNS2/' basename '/'])
eval(['! cp -a ' basepath '/' basename '.spk.* /mnt/brendon4/ForCRCNS2/' basename '/'])

% 
% TO DO
%  - Copy dataset to somewhere - exclude c3po
% 
%  - Data conversion
% 	BasicMetaData
% 		- RecordingFileIntervals = StartStop(RecordingFileIntervals,’s’);
% 		- Remove RecordingFilesForSleep, Ripplechannel
% 	Remove .nrs, _GoodSleepInterval.mat
%        Convert any .lfp to .eeg
%        Add _EMGCorr, _WSRestrictedIntervals ClusterQualityMeasures, SecondsFromLightsOn (Zeitgetber Time)
% 	Add SAll, SBurstFiltered, SStable - change fields to be .XXX_tsdA and .XXX in cellArray format
%        Review _Motion - if nonsense replace with NaNs
%    Mean Waveform
% 
% Code: - Cluster quality
%       - Cell classification - make so doesn’t need funcsyn
%       - Detect spindles
%       - Dan’s code for state scoring?
%       - Binning code: burst, CV, HighLow
%       - 
%    