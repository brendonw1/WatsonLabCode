function h = UPstates_UPSpindleSleepHalfSpiking(basepath,basename)

%% Meta info
if ~exist('basepath','var')
    [basepath,basename,~] = fileparts(cd);
    basepath = fullfile(basepath,basename);
end
cd(basepath)
% bmd = load([basename '_BasicMetaData.mat']);
% numchans = bmd.Par.nChannels;

%% Load ups, get starts, stops
t = load([basename, '_UPDOWNIntervals']);
UPints = t.UPInts;
UPstarts = Start(UPints)/10000;
UPstops = End(UPints)/10000;

%% Load Spindles, get starts, stops
load(fullfile(basepath,'Spindles','SpindleData.mat'),'SpindleData')
normspindles = SpindleData.normspindles;
sp_starts = normspindles(:,1);
sp_stops = normspindles(:,3);

%% Find times with at least 5min of waking beween SWS Epochs
t = load([basename,'_Intervals.mat']);
intervals = t.intervals;

sleepborders = mergeCloseIntervals(intervals{3},300*10000);
% sleepbordertimes = Start(sleepborders);
SleepStartTimes = Start(sleepborders); 
SleepStopTimes = End(sleepborders);

for a = 1:length(SleepStartTimes);
    ustaidx = find(UPstarts>SleepStartTimes(a)/10000,1,'first');
    ustoidx = find(UPstops<SleepStopTimes(a)/10000,1,'last');
    sstaidx = find(sp_starts>SleepStartTimes(a)/10000,1,'first');
    sstoidx = find(sp_stops<SleepStopTimes(a)/10000,1,'last');

    if isempty (ustaidx) || isempty(ustoidx) || isempty(sstaidx) || isempty(sstoidx)%if cannot divide into halves, 
        h = [];
        return % skip this recording
    else
        uSleepStartIdxs(a) = ustaidx;
        uSleepStopIdxs(a) = ustoidx;
        sSleepStartIdxs(a) = sstaidx;
        sSleepStopIdxs(a) = sstoidx;
    end
end

% Good sleeps have >100 UPs
GoodSleepNumUpsThresh = 100;
badsleeps = (uSleepStopIdxs-uSleepStartIdxs)<GoodSleepNumUpsThresh;
uSleepStartIdxs(badsleeps) = [];
uSleepStopIdxs(badsleeps) = [];
sSleepStartIdxs(badsleeps) = [];
sSleepStopIdxs(badsleeps) = [];

%% Load SpikeStats
t = load(fullfile('Spindles',[basename '_SpindleSpikeStats.mat']));
%     siss = t.iss;
sisse = t.isse;
%     sissi = t.issi;
% sissed = t.issed;
% sissid = t.issid;

t = load(fullfile('UPstates',[basename '_UPSpikeStatsE.mat']));
%     uiss = t.iss;
uisse = t.isse;
%     uissi = t.issi;
% uissed = t.issed;
% uissid = t.issid;

SpindleUPEvents = FindUPsWithSpindles(basepath,basename);
v2struct(SpindleUPEvents); %extracts [SpindleUps,NoSpindleUps,PartialSpindleUps,EarlyStartUps,LateStartUps,UpPercents,UpSpindleMsCounts] 

% Suiss = SpikeStatsIntervalSubset(uiss,SpindleUps);%spindle ups
Suisse = SpikeStatsIntervalSubset(uisse,SpindleUps);
% Suissi = SpikeStatsIntervalSubset(uissi,SpindleUps);

% Nuiss = SpikeStatsIntervalSubset(uiss,NoSpindleUps);%non-spindle ups
Nuisse = SpikeStatsIntervalSubset(uisse,NoSpindleUps);
% Nuissi = SpikeStatsIntervalSubset(uissi,NoSpindleUps);
% 
% Puiss = SpikeStatsIntervalSubset(uiss,PartialSpindleUps);%partial spindle ups
Puisse = SpikeStatsIntervalSubset(uisse,PartialSpindleUps);
% Puissi = SpikeStatsIntervalSubset(uissi,PartialSpindleUps);
% 
% Euiss = SpikeStatsIntervalSubset(uiss,EarlyStartUps);%early spindle start ups
Euisse = SpikeStatsIntervalSubset(uisse,EarlyStartUps);
% Euissi = SpikeStatsIntervalSubset(uissi,EarlyStartUps);
% 
% Luiss = SpikeStatsIntervalSubset(uiss,LateStartUps);%late spindle start ups
Luisse = SpikeStatsIntervalSubset(uisse,LateStartUps);
% Luissi = SpikeStatsIntervalSubset(uissi,LateStartUps);


h = [];
%% First vs second half spike rate similarity
% All UPs
[r_ue_rate,p_ue_rate,h(end+1)] = PlotHalvesVectorSimilarity(uisse.spkrates,uSleepStartIdxs,uSleepStopIdxs);
AboveTitle('AllUPs: ECellRates')
set(h(end),'name',[basename '_SleepHalfCorr_AllUPsECellRates'])
% Spindle UPs
[r_sue_rate,p_sue_rate,h(end+1)] = PlotHalvesVectorSimilarity(Suisse.spkrates,uSleepStartIdxs,uSleepStopIdxs,Suisse.intervalsubset);
AboveTitle('SpindleUPs: ECellRates')
set(h(end),'name',[basename '_SleepHalfCorr_SpindleUPsECellRates'])
% Non Spindle UPs
[r_nue_rate,p_nue_rate,h(end+1)] = PlotHalvesVectorSimilarity(Nuisse.spkrates,uSleepStartIdxs,uSleepStopIdxs,Nuisse.intervalsubset);
AboveTitle('NonSpindleUPs: ECellRates')
set(h(end),'name',[basename '_SleepHalfCorr_NonSpindleUPsECellRates'])
% Partial Spindle UPs
[r_pue_rate,p_pue_rate,h(end+1)] = PlotHalvesVectorSimilarity(Puisse.spkrates,uSleepStartIdxs,uSleepStopIdxs,Puisse.intervalsubset);
AboveTitle('PartialSpindleUPs: ECellRates')
set(h(end),'name',[basename '_SleepHalfCorr_PartSpindleUPsECellRates'])
% Early Spindle UPs
[r_eue_rate,p_eue_rate,h(end+1)] = PlotHalvesVectorSimilarity(Euisse.spkrates,uSleepStartIdxs,uSleepStopIdxs,Euisse.intervalsubset);
AboveTitle('EarlySpindleUPs: ECellRates')
set(h(end),'name',[basename '_SleepHalfCorr_EarlySpindleUPsECellRates'])
% Late Spindle UPs
[r_lue_rate,p_lue_rate,h(end+1)] = PlotHalvesVectorSimilarity(Luisse.spkrates,uSleepStartIdxs,uSleepStopIdxs,Luisse.intervalsubset);
AboveTitle('LateSpindleUPs: ECellRates')
set(h(end),'name',[basename '_SleepHalfCorr_LateSpindleUPsECellRates'])
% Spindles
[r_se_rate,p_se_rate,h(end+1)] = PlotHalvesVectorSimilarity(sisse.meanspktsfrompeak,sSleepStartIdxs,sSleepStopIdxs);
AboveTitle('AllSpindles: ECellMean vs EventPeak')
set(h(end),'name',[basename '_SleepHalfCorr_SpindleECellRates'])

%% All UPstates: first vs second half spike timing similarity
[r_ue_seq_meanvpeak,p_ue_seq_meanvpeak,h(end+1)] = PlotHalvesVectorSimilarity(uisse.meanspktsfrompeak,uSleepStartIdxs,uSleepStopIdxs);
AboveTitle('AllUPs: ECellMean vs EventPeak')
set(h(end),'name',[basename '_SleepHalfCorr_AllUPsECellMeanVEventPeak'])
[r_ue_seq_meanvstart,p_ue_seq_meanvstart,h(end+1)] = PlotHalvesVectorSimilarity(uisse.meanspktsfromstart,uSleepStartIdxs,uSleepStopIdxs);
AboveTitle('AllUPs: ECellMean vs EventStart')
set(h(end),'name',[basename '_SleepHalfCorr_AllUPsECellMeanVEventStart'])
[r_ue_seq_firstvpeak,p_ue_seq_firstvpeak,h(end+1)] = PlotHalvesVectorSimilarity(uisse.firstspktsfrompeak,uSleepStartIdxs,uSleepStopIdxs);
AboveTitle('AllUPs: ECellFirst vs EventPeak')
set(h(end),'name',[basename '_SleepHalfCorr_AllUPsECellFirstVEventPeak'])
[r_ue_seq_firstvstart,p_ue_seq_firstvstart,h(end+1)] = PlotHalvesVectorSimilarity(uisse.firstspktsfromstart,uSleepStartIdxs,uSleepStopIdxs);
AboveTitle('AllUPs: ECellFirst vs EventStart')
set(h(end),'name',[basename '_SleepHalfCorr_AllUPsECellFirstVEventStart'])

% Icells
% h = PlotHalvesTimingSimilarity(uissi.meanspktsfrompeak,uSleepStartIdxs,uSleepStopIdxs);
% AboveTitle('AllUPs: ICellMean vs EventCoM')
% h = PlotHalvesTimingSimilarity(uissi.meanspktsfromstart,uSleepStartIdxs,uSleepStopIdxs);
% AboveTitle('AllUPs: ICellFirst vs EventStart')

% SpindleUPs
[r_sue_seq_meanvpeak,p_sue_seq_meanvpeak,h(end+1)] = PlotHalvesVectorSimilarity(Suisse.meanspktsfrompeak,uSleepStartIdxs,uSleepStopIdxs,Suisse.intervalsubset);
AboveTitle('SpindleUPs: ECellMean vs EventPeak')
set(h(end),'name',[basename '_SleepHalfCorr_SpindleUPsECellMeanVEventPeak'])
[r_sue_seq_meanvstart,p_sue_seq_meanvstart,h(end+1)] = PlotHalvesVectorSimilarity(Suisse.meanspktsfromstart,uSleepStartIdxs,uSleepStopIdxs,Suisse.intervalsubset);
AboveTitle('SpindleUPs: ECellMean vs EventStart')
set(h(end),'name',[basename '_SleepHalfCorr_SpindleUPsECellMeanVEventStart'])
[r_sue_seq_firstvpeak,p_sue_seq_firstvpeak,h(end+1)] = PlotHalvesVectorSimilarity(Suisse.firstspktsfrompeak,uSleepStartIdxs,uSleepStopIdxs,Suisse.intervalsubset);
AboveTitle('SpindleUPs: ECellFirst vs EventPeak')
set(h(end),'name',[basename '_SleepHalfCorr_SpindleUPsECellFirstVEventPeak'])
[r_sue_seq_firstvstart,p_sue_seq_firstvstart,h(end+1)] = PlotHalvesVectorSimilarity(Suisse.firstspktsfromstart,uSleepStartIdxs,uSleepStopIdxs,Suisse.intervalsubset);
AboveTitle('SpindleUPs: ECellFirst vs EventStart')
set(h(end),'name',[basename '_SleepHalfCorr_SpindleUPsECellFirstVEventStart'])

% NonSpindleUps
[r_nue_seq_meanvpeak,p_nue_seq_meanvpeak,h(end+1)] = PlotHalvesVectorSimilarity(Nuisse.meanspktsfrompeak,uSleepStartIdxs,uSleepStopIdxs,Nuisse.intervalsubset);
AboveTitle('NonSpindleUPs: ECellMean vs EventPeak')
set(h(end),'name',[basename '_SleepHalfCorr_NonSpindleUPsECellMeanVEventPeak'])
[r_nue_seq_meanvstart,p_nue_seq_meanvstart,h(end+1)] = PlotHalvesVectorSimilarity(Nuisse.meanspktsfromstart,uSleepStartIdxs,uSleepStopIdxs,Nuisse.intervalsubset);
AboveTitle('NonSpindleUPs: ECellMean vs EventStart')
set(h(end),'name',[basename '_SleepHalfCorr_NonSpindleUPsECellMeanVEventStart'])
[r_nue_seq_firstvpeak,p_nue_seq_firstvpeak,h(end+1)] = PlotHalvesVectorSimilarity(Nuisse.firstspktsfrompeak,uSleepStartIdxs,uSleepStopIdxs,Nuisse.intervalsubset);
AboveTitle('NonSpindleUPs: ECellFirst vs EventPeak')
set(h(end),'name',[basename '_SleepHalfCorr_NonSpindleUPsECellFirstVEventPeak'])
[r_nue_seq_firstvstart,p_nue_seq_firstvstart,h(end+1)] = PlotHalvesVectorSimilarity(Nuisse.firstspktsfromstart,uSleepStartIdxs,uSleepStopIdxs,Nuisse.intervalsubset);
AboveTitle('NonSpindleUPs: ECellFirst vs EventStart')
set(h(end),'name',[basename '_SleepHalfCorr_NonSpindleUPsECellFirstVEventStart'])

% Partial Spindle UPs
[r_pue_seq_meanvpeak,p_pue_seq_meanvpeak,h(end+1)] = PlotHalvesVectorSimilarity(Puisse.meanspktsfrompeak,uSleepStartIdxs,uSleepStopIdxs,Puisse.intervalsubset);
AboveTitle('PartialSpindleUPs: ECellMean vs EventPeak')
set(h(end),'name',[basename '_SleepHalfCorr_PartSpindleUPsECellMeanVEventPeak'])
[r_pue_seq_meanvstart,p_pue_seq_meanvstart,h(end+1)] = PlotHalvesVectorSimilarity(Puisse.meanspktsfromstart,uSleepStartIdxs,uSleepStopIdxs,Puisse.intervalsubset);
AboveTitle('PartialSpindleUPs: ECellMean vs EventStart')
set(h(end),'name',[basename '_SleepHalfCorr_PartSpindleUPsECellMeanVEventStart'])
[r_pue_seq_firstvpeak,p_pue_seq_firstvpeak,h(end+1)] = PlotHalvesVectorSimilarity(Puisse.firstspktsfrompeak,uSleepStartIdxs,uSleepStopIdxs,Puisse.intervalsubset);
AboveTitle('PartialSpindleUPs: ECellFirst vs EventPeak')
set(h(end),'name',[basename '_SleepHalfCorr_PartSpindleUPsECellFirstVEventPeak'])
[r_pue_seq_firstvstart,p_pue_seq_firstvstart,h(end+1)] = PlotHalvesVectorSimilarity(Puisse.firstspktsfromstart,uSleepStartIdxs,uSleepStopIdxs,Puisse.intervalsubset);
AboveTitle('PartialSpindleUPs: ECellFirst vs EventStart')
set(h(end),'name',[basename '_SleepHalfCorr_PartSpindleUPsECellFirstVEventStart'])

% Early Spindle UPs
[r_eue_seq_meanvpeak,p_eue_seq_meanvpeak,h(end+1)] = PlotHalvesVectorSimilarity(Euisse.meanspktsfrompeak,uSleepStartIdxs,uSleepStopIdxs,Euisse.intervalsubset);
AboveTitle('EarlySpindleUPs: ECellMean vs EventPeak')
set(h(end),'name',[basename '_SleepHalfCorr_EarlySpindleUPsECellMeanVEventPeak'])
[r_eue_seq_meanvstart,p_eue_seq_meanvstart,h(end+1)] = PlotHalvesVectorSimilarity(Euisse.meanspktsfromstart,uSleepStartIdxs,uSleepStopIdxs,Euisse.intervalsubset);
AboveTitle('EarlySpindleUPs: ECellMean vs EventStart')
set(h(end),'name',[basename '_SleepHalfCorr_EarlySpindleUPsECellMeanVEventStart'])
[r_eue_seq_firstvpeak,p_eue_seq_firstvpeak,h(end+1)] = PlotHalvesVectorSimilarity(Euisse.firstspktsfrompeak,uSleepStartIdxs,uSleepStopIdxs,Euisse.intervalsubset);
AboveTitle('EarlySpindleUPs: ECellFirst vs EventPeak')
set(h(end),'name',[basename '_SleepHalfCorr_EarlySpindleUPsECellFirstVEventPeak'])
[r_eue_seq_firstvstart,p_eue_seq_firstvstart,h(end+1)] = PlotHalvesVectorSimilarity(Euisse.firstspktsfromstart,uSleepStartIdxs,uSleepStopIdxs,Euisse.intervalsubset);
AboveTitle('EarlySpindleUPs: ECellFirst vs EventStart')
set(h(end),'name',[basename '_SleepHalfCorr_EarlySpindleUPsECellFirstVEventStart'])

% Late Spindle UPs
[r_lue_seq_meanvpeak,p_lue_seq_meanvpeak,h(end+1)] = PlotHalvesVectorSimilarity(Luisse.meanspktsfrompeak,uSleepStartIdxs,uSleepStopIdxs,Luisse.intervalsubset);
AboveTitle('LateSpindleUPs: ECellMean vs EventPeak')
set(h(end),'name',[basename '_SleepHalfCorr_LateSpindleUPsECellMeanVEventPeak'])
[r_lue_seq_meanvstart,p_lue_seq_meanvstart,h(end+1)] = PlotHalvesVectorSimilarity(Luisse.meanspktsfromstart,uSleepStartIdxs,uSleepStopIdxs,Luisse.intervalsubset);
AboveTitle('LateSpindleUPs: ECellMean vs EventStart')
set(h(end),'name',[basename '_SleepHalfCorr_LateSpindleUPsECellMeanVEventStart'])
[r_lue_seq_firstvpeak,p_lue_seq_firstvpeak,h(end+1)] = PlotHalvesVectorSimilarity(Luisse.firstspktsfrompeak,uSleepStartIdxs,uSleepStopIdxs,Luisse.intervalsubset);
AboveTitle('LateSpindleUPs: ECellFirst vs EventPeak')
set(h(end),'name',[basename '_SleepHalfCorr_LateSpindleUPsECellFirstVEventPeak'])
[r_lue_seq_firstvstart,p_lue_seq_firstvstart,h(end+1)] = PlotHalvesVectorSimilarity(Luisse.firstspktsfromstart,uSleepStartIdxs,uSleepStopIdxs,Luisse.intervalsubset);
AboveTitle('LateSpindleUPs: ECellFirst vs EventStart')
set(h(end),'name',[basename '_SleepHalfCorr_LateSpindleUPsECellFirstVEventStart'])

% Spindles
[r_se_seq_meanvpeak,p_se_seq_meanvpeak,h(end+1)] = PlotHalvesVectorSimilarity(sisse.meanspktsfrompeak,sSleepStartIdxs,sSleepStopIdxs);
AboveTitle('AllSpindles: ECellMean vs EventPeak')
[r_se_seq_meanvstart,p_se_seq_meanvstart,h(end+1)] = PlotHalvesVectorSimilarity(sisse.meanspktsfromstart,sSleepStartIdxs,sSleepStopIdxs);
AboveTitle('AllSpidles: ECellMean vs EventStart')
[r_se_seq_firstvpeak,p_se_seq_firstvpeak,h(end+1)] = PlotHalvesVectorSimilarity(sisse.firstspktsfrompeak,sSleepStartIdxs,sSleepStopIdxs);
AboveTitle('AllSpindles: ECellFirst vs EventPeak')
[r_se_seq_firstvstart,p_se_seq_firstvstart,h(end+1)] = PlotHalvesVectorSimilarity(sisse.firstspktsfromstart,sSleepStartIdxs,sSleepStopIdxs);
AboveTitle('AllSpindles: ECellFirst vs EventStart')

SpindleUPSleepHalfRsAndPs = v2struct(r_ue_rate, p_ue_rate, r_sue_rate, p_sue_rate,...
    r_nue_rate, p_nue_rate, r_pue_rate, p_pue_rate,...
    r_eue_rate, p_eue_rate, r_lue_rate, p_lue_rate,...
    r_se_rate, p_se_rate,...
    r_ue_seq_meanvpeak, p_ue_seq_meanvpeak, r_ue_seq_meanvstart, p_ue_seq_meanvstart,...
    r_ue_seq_firstvpeak, p_ue_seq_firstvpeak, r_ue_seq_firstvstart, p_ue_seq_firstvstart,...
    r_sue_seq_meanvpeak, p_sue_seq_meanvpeak, r_sue_seq_meanvstart, p_sue_seq_meanvstart,...
    r_sue_seq_firstvpeak, p_sue_seq_firstvpeak, r_sue_seq_firstvstart, p_sue_seq_firstvstart,...
    r_nue_seq_meanvpeak, p_nue_seq_meanvpeak, r_nue_seq_meanvstart, p_nue_seq_meanvstart,...
    r_nue_seq_firstvpeak, p_nue_seq_firstvpeak, r_nue_seq_firstvstart, p_nue_seq_firstvstart,...
    r_pue_seq_meanvpeak, p_pue_seq_meanvpeak, r_pue_seq_meanvstart, p_pue_seq_meanvstart,...
    r_pue_seq_firstvpeak, p_pue_seq_firstvpeak, r_pue_seq_firstvstart, p_pue_seq_firstvstart,...
    r_eue_seq_meanvpeak, p_eue_seq_meanvpeak, r_eue_seq_meanvstart, p_eue_seq_meanvstart,...
    r_eue_seq_firstvpeak, p_eue_seq_firstvpeak, r_eue_seq_firstvstart, p_eue_seq_firstvstart,...
    r_lue_seq_meanvpeak, p_lue_seq_meanvpeak, r_lue_seq_meanvstart, p_lue_seq_meanvstart,...
    r_lue_seq_firstvpeak, p_lue_seq_firstvpeak, r_lue_seq_firstvstart, p_lue_seq_firstvstart,...
    r_se_seq_meanvpeak, p_se_seq_meanvpeak, r_se_seq_meanvstart, p_se_seq_meanvstart,...
    r_se_seq_firstvpeak, p_se_seq_firstvpeak, r_se_seq_firstvstart, p_se_seq_firstvstart);
save(fullfile('UPstates',[basename '_SpindleUPSleepHalfRsAndPs.mat']),'SpindleUPSleepHalfRsAndPs')

%% Gather basic metrics
%mean durations per event type
AllUPMeanDur = uisse.intends-uisse.intstarts;
NonSpindleUPMeanDur = Nuisse.intends-Nuisse.intstarts;
PartSpindleUPMeanDur = Puisse.intends-Puisse.intstarts;
SpindleUPMeanDur = Suisse.intends-Suisse.intstarts;
EarlySpindleUPMeanDur = Euisse.intends-Euisse.intstarts;
LateSpindleUPMeanDur = Luisse.intends-Luisse.intstarts;
SpindleMeanDur =  sisse.intends-sisse.intstarts;

%mean spike rates per event type
AllUPMeanRate = mean(uisse.spkcounts,2);
NonSpindleUPMeanRate = mean(Nuisse.spkcounts,2);
PartSpindleUPMeanRate = mean(Puisse.spkcounts,2);
SpindleUPMeanRate = mean(Suisse.spkcounts,2);
EarlySpindleUPMeanRate = mean(Euisse.spkcounts,2);
LateSpindleUPMeanRate = mean(Luisse.spkcounts,2);
SpindleMeanRate = mean(sisse.spkcounts,2);

%mean cell counts per event type
AllUPMeanCellCt = mean(uisse.intcellcounts,2);
NonSpindleUPMeanCellCt = mean(Nuisse.intcellcounts,2);
PartSpindleUPMeanCellCt = mean(Puisse.intcellcounts,2);
SpindleUPMeanCellCt = mean(Suisse.intcellcounts,2);
EarlySpindleUPMeanCellCt = mean(Euisse.intcellcounts,2);
LateSpindleUPMeanCellCt = mean(Luisse.intcellcounts,2);
SpindleMeanCellCt = mean(sisse.intcellcounts,2);

SpindleUPRatesDurations = v2struct(AllUPMeanDur,NonSpindleUPMeanDur,PartSpindleUPMeanDur,...
    SpindleUPMeanDur,EarlySpindleUPMeanDur,LateSpindleUPMeanDur,...
    SpindleMeanDur,...
    AllUPMeanRate,NonSpindleUPMeanRate,PartSpindleUPMeanRate,...
    SpindleUPMeanRate,EarlySpindleUPMeanRate,LateSpindleUPMeanRate,...
    SpindleMeanRate,...
    AllUPMeanCellCt,NonSpindleUPMeanCellCt,PartSpindleUPMeanCellCt,...
    SpindleUPMeanCellCt,EarlySpindleUPMeanCellCt,LateSpindleUPMeanCellCt,...
    SpindleMeanCellCt);
save(fullfile('UPstates',[basename '_SpindleUPRatesDurations.mat']),'SpindleUPRatesDurations')


%% Plot basic metrics
% Plot time dynamics of within-event spiking
h(end+1) = figure;
subplot(2,1,1); 
plot(uisse.intstarts,mean(uisse.spkcounts,2),'.');
hold on
plot(Suisse.intstarts,mean(Suisse.spkcounts,2),'r.');
title('UP state spike rates over session. Red is Spindle-UPs')
subplot(2,1,2); 
plot(sisse.intstarts,mean(sisse.spkcounts,2),'.')
hold on
plot(Suisse.intstarts,mean(Suisse.spkcounts,2),'r.');
title('Spindle spike rates over session. Red is Spindle-UPs')
set(h(end),'name',[basename '_UPandSpindleSpikeratesOverTime'])

% Plot even durations per event type
h(end+1) = figure;
title('Event Duration')
hax = plot_meanSD_bars(AllUPMeanDur,NonSpindleUPMeanDur,SpindleUPMeanDur,...
    PartSpindleUPMeanDur,EarlySpindleUPMeanDur,LateSpindleUPMeanDur,...
    SpindleMeanDur);
set(h(end),'name',[basename '_SpindleUPDurations'])
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{['AllUPs n=' num2str(length(length(UPints)))];...
    ['Non-SU n=' num2str(length(NoSpindleUps))];...
    ['SpindU n=' num2str(length(SpindleUps))];...
    ['Part-SU n=' num2str(length(PartialSpindleUps))];...
    ['EarlySU n=' num2str(length(EarlyStartUps))];...
    ['LateSU n=' num2str(length(LateStartUps))];...
    ['Spinds n=' num2str(length(sp_starts))]})

% Plot Spike Rates per event type
h(end+1) = figure;
hax = plot_meanSD_bars(AllUPMeanRate,NonSpindleUPMeanRate,SpindleUPMeanRate,...
    PartSpindleUPMeanRate,EarlySpindleUPMeanRate,LateSpindleUPMeanRate,...
    SpindleMeanRate);
title(hax,'Event Mean Spike Rate')
set(h(end),'name',[basename '_SpindleUPRates'])
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{['AllUPs n=' num2str(length(length(UPints)))];...
    ['Non-SU n=' num2str(length(NoSpindleUps))];...
    ['SpindU n=' num2str(length(SpindleUps))];...
    ['Part-SU n=' num2str(length(PartialSpindleUps))];...
    ['EarlySU n=' num2str(length(EarlyStartUps))];...
    ['LateSU n=' num2str(length(LateStartUps))];...
    ['Spinds n=' num2str(length(sp_starts))]})

% Plot Cell counts per event type
h(end+1) = figure;
hax = plot_meanSD_bars(AllUPMeanCellCt,NonSpindleUPMeanCellCt,SpindleUPMeanCellCt,...
    PartSpindleUPMeanCellCt,EarlySpindleUPMeanCellCt,LateSpindleUPMeanCellCt,...
    SpindleMeanCellCt);
title(hax,'Event Mean Cell Pariticpant Count')
set(h(end),'name',[basename '_SpindleUPCellCts'])
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{['AllUPs n=' num2str(length(length(UPints)))];...
    ['Non-SU n=' num2str(length(NoSpindleUps))];...
    ['SpindU n=' num2str(length(SpindleUps))];...
    ['Part-SU n=' num2str(length(PartialSpindleUps))];...
    ['EarlySU n=' num2str(length(EarlyStartUps))];...
    ['LateSU n=' num2str(length(LateStartUps))];...
    ['Spinds n=' num2str(length(sp_starts))]})

%Rs for rates
h(end+1) = figure;
hax = plot_meanSD_bars(r_ue_rate,r_nue_rate,r_sue_rate,r_pue_rate,r_eue_rate,r_lue_rate,r_se_rate);
title(hax,'R Values of Rates')
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{['AllUPs n=' num2str(length(length(UPints)))];...
    ['Non-SU n=' num2str(length(NoSpindleUps))];...
    ['SpindU n=' num2str(length(SpindleUps))];...
    ['Part-SU n=' num2str(length(PartialSpindleUps))];...
    ['EarlySU n=' num2str(length(EarlyStartUps))];...
    ['LateSU n=' num2str(length(LateStartUps))];...
    ['Spinds n=' num2str(length(sp_starts))]})
AboveTitle('R values')
set(h(end),'name',[basename '_SpindleUPRateRs'])

%Rs for timing
h(end+1) = figure;
subplot(2,1,1)
hax = plot_meanSD_bars(r_ue_seq_meanvstart,r_nue_seq_meanvstart, r_sue_seq_meanvstart,r_pue_seq_meanvstart,r_eue_seq_meanvstart,r_lue_seq_meanvstart,r_se_seq_meanvstart);
title(hax,'Spike Timing: MeanVsStart')
subplot(2,1,2)
hax = plot_meanSD_bars(r_ue_seq_firstvpeak,r_nue_seq_firstvpeak, r_sue_seq_firstvpeak,r_pue_seq_firstvpeak,r_eue_seq_firstvpeak,r_lue_seq_firstvpeak,r_se_seq_firstvpeak);
title(hax,'Spike Timing: FirstVsPeak')
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{['AllUPs n=' num2str(length(length(UPints)))];...
    ['Non-SU n=' num2str(length(NoSpindleUps))];...
    ['SpindU n=' num2str(length(SpindleUps))];...
    ['Part-SU n=' num2str(length(PartialSpindleUps))];...
    ['EarlySU n=' num2str(length(EarlyStartUps))];...
    ['LateSU n=' num2str(length(LateStartUps))];...
    ['Spinds n=' num2str(length(sp_starts))]})
AboveTitle('R values')
set(h(end),'name',[basename '_SpindleUPTimingRs'])


%% save figs
cd(fullfile(basepath,'UPstates'))
if ~exist('SpindleUPSleepHalfFigs','dir')
    mkdir('SpindleUPSleepHalfFigs')
end
cd('SpindleUPSleepHalfFigs')
savefigsasname(h,'fig');
% close(h)
cd(basepath)



function [r,p,h] = PlotHalvesVectorSimilarity(celleventvectors,SleepStartIdxs,SleepStopIdxs,subset,h,subplotixs)

if ~exist('subset','var')
    subset = 1:size(celleventvectors,1);
end

% if ~exist('h','var')
%     h = figure;
%     subplotixs1 = [];
%     subplotixs2 = [];
% else
%     subplotixs1 = subplotixs(:,1);
%     subplotixs2 = subplotixs(:,2);
% end
h = figure;
r = [];
p = [];

for a = 1:length(SleepStartIdxs)
    thisstartidx = SleepStartIdxs(a);
    thisstopidx = SleepStopIdxs(a);
    half1start = thisstartidx;
    half1stop = thisstartidx+round(thisstopidx-thisstartidx)/2;
    half2start = thisstartidx+round(thisstopidx-thisstartidx)/2+1;
    half2stop = thisstopidx;
    
%     half1start = subset(find(subset>=half1start,1,'first'));
%     half1stop = subset(find(subset<=half1stop,1,'last'));
%     half2start = subset(find(subset>=half2start,1,'first'));
%     half2stop = subset(find(subset<=half2stop,1,'last'));
    half1start = find(subset>=half1start,1,'first');
    half1stop = find(subset<=half1stop,1,'last');
    half2start = find(subset>=half2start,1,'first');
    half2stop = find(subset<=half2stop,1,'last');

    timeshalf1 = celleventvectors(half1start:half1stop,:);
    timeshalf2 = celleventvectors(half2start:half2stop,:);
    
    subplot(length(SleepStartIdxs),1,a)
    x = nanmean(timeshalf1,1);
    y = nanmean(timeshalf2,1);
    plot(x,y,'.');
%     axis equal
    hold on;
    title(['Sleep ' num2str(a) '. n = ' num2str(size(timeshalf1,1)) ' events.'])
    xlabel('First Sleep Half timing (s)')
    ylabel('Second Sleep Half timing (s)')
    xl = get(gca,'xlim');
    yl = get(gca,'ylim');
    plot(xl,yl,'r')
    
    try
        [~,r(end+1),p(end+1)] =  RegressAndFindR(x,y);
        text(.05*(xl(2)-xl(1))+xl(1),.9*(yl(2)-yl(1))+yl(1),['r = ' num2str(r) '. p = ' num2str(p) '.'])
    catch 
        r(end+1) = nan;
        p(end+1) = nan;
    end
end



