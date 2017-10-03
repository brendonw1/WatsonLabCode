function h = UPstates_UPSpindleEvenOddSpikingNotBySleepEp_Restricted(basepath,basename)

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
% t = load([basename,'_Intervals.mat']);
% intervals = t.intervals;
% 
% sleepborders = mergeCloseIntervals(intervals{3},300*10000);
% % sleepbordertimes = Start(sleepborders);
% SleepStartTimes = Start(sleepborders); 
% SleepStopTimes = End(sleepborders);
% 
% for a = 1:length(SleepStartTimes);
%     ustaidx = find(UPstarts>SleepStartTimes(a)/10000,1,'first');
%     ustoidx = find(UPstops<SleepStopTimes(a)/10000,1,'last');
%     sstaidx = find(sp_starts>SleepStartTimes(a)/10000,1,'first');
%     sstoidx = find(sp_stops<SleepStopTimes(a)/10000,1,'last');
% 
%     if isempty (ustaidx) || isempty(ustoidx) || isempty(sstaidx) || isempty(sstoidx)%if cannot divide into halves, 
%         h = [];
%         return % skip this recording
%     else
%         uSleepStartIdxs(a) = ustaidx;
%         uSleepStopIdxs(a) = ustoidx;
%         sSleepStartIdxs(a) = sstaidx;
%         sSleepStopIdxs(a) = sstoidx;
%     end
% end
% 
% % Good sleeps have >100 UPs
% GoodSleepNumUpsThresh = 100;
% badsleeps = (uSleepStopIdxs-uSleepStartIdxs)<GoodSleepNumUpsThresh;
% uSleepStartIdxs(badsleeps) = [];
% uSleepStopIdxs(badsleeps) = [];
% sSleepStartIdxs(badsleeps) = [];
% sSleepStopIdxs(badsleeps) = [];

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
v2struct(SpindleUPEvents); %extracts [SpindleUPs,NoSpindleUPs,PartialSpindleUPs,EarlyStartUPs,LateStartUPs,UpPercents,UpSpindleMsCounts] 

% Suiss = SpikeStatsIntervalSubset(uiss,SpindleUPs);%spindle ups
Suisse = SpikeStatsIntervalSubset(uisse,SpindleUPs);
% Suissi = SpikeStatsIntervalSubset(uissi,SpindleUPs);

% Nuiss = SpikeStatsIntervalSubset(uiss,NoSpindleUPs);%non-spindle ups
Nuisse = SpikeStatsIntervalSubset(uisse,NoSpindleUPs);
% Nuissi = SpikeStatsIntervalSubset(uissi,NoSpindleUPs);
% 
% Puiss = SpikeStatsIntervalSubset(uiss,PartialSpindleUPs);%partial spindle ups
Puisse = SpikeStatsIntervalSubset(uisse,PartialSpindleUPs);
% Puissi = SpikeStatsIntervalSubset(uissi,PartialSpindleUPs);
% 
% Euiss = SpikeStatsIntervalSubset(uiss,EarlyStartUPs);%early spindle start ups
Euisse = SpikeStatsIntervalSubset(uisse,EarlyStartUPs);
% Euissi = SpikeStatsIntervalSubset(uissi,EarlyStartUPs);
% 
% Luiss = SpikeStatsIntervalSubset(uiss,LateStartUPs);%late spindle start ups
Luisse = SpikeStatsIntervalSubset(uisse,LateStartUPs);
% Luissi = SpikeStatsIntervalSubset(uissi,LateStartUPs);


%% To normalize by number of events per sleephalf to be equal to the event type with the fewest
% Assume minimum is spindleups
numevts = [length(uisse.intstarts),length(SpindleUPs),length(NoSpindleUPs),length(PartialSpindleUPs),length(sisse.intstarts)];
minevts = min(numevts);

h = [];
%% First vs second half spike rate similarity
% All UPs
[r_ue_rate,p_ue_rate,h(end+1)] = PlotEvenOddVectorSimilarity(uisse.spkrates,minevts);
AboveTitle('AllUPs: ECellRates')
set(h(end),'name',[basename '_SleepHalfCorr_AllUPsECellRates'])
% Spindle UPs
[r_sue_rate,p_sue_rate,h(end+1)] = PlotEvenOddVectorSimilarity(Suisse.spkrates,minevts,Suisse.intervalsubset);
AboveTitle('SpindleUPs: ECellRates')
set(h(end),'name',[basename '_SleepHalfCorr_SpindleUPsECellRates'])
% Non Spindle UPs
[r_nue_rate,p_nue_rate,h(end+1)] = PlotEvenOddVectorSimilarity(Nuisse.spkrates,minevts,Nuisse.intervalsubset);
AboveTitle('NonSpindleUPs: ECellRates')
set(h(end),'name',[basename '_SleepHalfCorr_NonSpindleUPsECellRates'])
% Partial Spindle UPs
[r_pue_rate,p_pue_rate,h(end+1)] = PlotEvenOddVectorSimilarity(Puisse.spkrates,minevts,Puisse.intervalsubset);
AboveTitle('PartialSpindleUPs: ECellRates')
set(h(end),'name',[basename '_SleepHalfCorr_PartSpindleUPsECellRates'])
% Early Spindle UPs
[r_eue_rate,p_eue_rate,h(end+1)] = PlotEvenOddVectorSimilarity(Euisse.spkrates,minevts,Euisse.intervalsubset);
AboveTitle('EarlySpindleUPs: ECellRates')
set(h(end),'name',[basename '_SleepHalfCorr_EarlySpindleUPsECellRates'])
% Late Spindle UPs
[r_lue_rate,p_lue_rate,h(end+1)] = PlotEvenOddVectorSimilarity(Luisse.spkrates,minevts,Luisse.intervalsubset);
AboveTitle('LateSpindleUPs: ECellRates')
set(h(end),'name',[basename '_SleepHalfCorr_LateSpindleUPsECellRates'])
% Spindles
[r_se_rate,p_se_rate,h(end+1)] = PlotEvenOddVectorSimilarity(sisse.spkrates,minevts);
AboveTitle('AllSpindles: ECellMean vs EventPeak')
set(h(end),'name',[basename '_SleepHalfCorr_SpindleECellRates'])

%% All UPstates: first vs second half spike timing similarity
[r_ue_seq_meanvpeak,p_ue_seq_meanvpeak,h(end+1)] = PlotEvenOddVectorSimilarity(uisse.meanspktsfrompeak,minevts);
AboveTitle('AllUPs: ECellMean vs EventPeak')
set(h(end),'name',[basename '_SleepHalfCorr_AllUPsECellMeanVEventPeak'])
[r_ue_seq_meanvstart,p_ue_seq_meanvstart,h(end+1)] = PlotEvenOddVectorSimilarity(uisse.meanspktsfromstart,minevts);
AboveTitle('AllUPs: ECellMean vs EventStart')
set(h(end),'name',[basename '_SleepHalfCorr_AllUPsECellMeanVEventStart'])
[r_ue_seq_firstvpeak,p_ue_seq_firstvpeak,h(end+1)] = PlotEvenOddVectorSimilarity(uisse.firstspktsfrompeak,minevts);
AboveTitle('AllUPs: ECellFirst vs EventPeak')
set(h(end),'name',[basename '_SleepHalfCorr_AllUPsECellFirstVEventPeak'])
[r_ue_seq_firstvstart,p_ue_seq_firstvstart,h(end+1)] = PlotEvenOddVectorSimilarity(uisse.firstspktsfromstart,minevts);
AboveTitle('AllUPs: ECellFirst vs EventStart')
set(h(end),'name',[basename '_SleepHalfCorr_AllUPsECellFirstVEventStart'])

% Icells
% h = PlotHalvesTimingSimilarity(uissi.meanspktsfrompeak);
% AboveTitle('AllUPs: ICellMean vs EventCoM')
% h = PlotHalvesTimingSimilarity(uissi.meanspktsfromstart);
% AboveTitle('AllUPs: ICellFirst vs EventStart')

% SpindleUPs
[r_sue_seq_meanvpeak,p_sue_seq_meanvpeak,h(end+1)] = PlotEvenOddVectorSimilarity(Suisse.meanspktsfrompeak,minevts,Suisse.intervalsubset);
AboveTitle('SpindleUPs: ECellMean vs EventPeak')
set(h(end),'name',[basename '_SleepHalfCorr_SpindleUPsECellMeanVEventPeak'])
[r_sue_seq_meanvstart,p_sue_seq_meanvstart,h(end+1)] = PlotEvenOddVectorSimilarity(Suisse.meanspktsfromstart,minevts,Suisse.intervalsubset);
AboveTitle('SpindleUPs: ECellMean vs EventStart')
set(h(end),'name',[basename '_SleepHalfCorr_SpindleUPsECellMeanVEventStart'])
[r_sue_seq_firstvpeak,p_sue_seq_firstvpeak,h(end+1)] = PlotEvenOddVectorSimilarity(Suisse.firstspktsfrompeak,minevts,Suisse.intervalsubset);
AboveTitle('SpindleUPs: ECellFirst vs EventPeak')
set(h(end),'name',[basename '_SleepHalfCorr_SpindleUPsECellFirstVEventPeak'])
[r_sue_seq_firstvstart,p_sue_seq_firstvstart,h(end+1)] = PlotEvenOddVectorSimilarity(Suisse.firstspktsfromstart,minevts,Suisse.intervalsubset);
AboveTitle('SpindleUPs: ECellFirst vs EventStart')
set(h(end),'name',[basename '_SleepHalfCorr_SpindleUPsECellFirstVEventStart'])

% NonSpindleUPs
[r_nue_seq_meanvpeak,p_nue_seq_meanvpeak,h(end+1)] = PlotEvenOddVectorSimilarity(Nuisse.meanspktsfrompeak,minevts,Nuisse.intervalsubset);
AboveTitle('NonSpindleUPs: ECellMean vs EventPeak')
set(h(end),'name',[basename '_SleepHalfCorr_NonSpindleUPsECellMeanVEventPeak'])
[r_nue_seq_meanvstart,p_nue_seq_meanvstart,h(end+1)] = PlotEvenOddVectorSimilarity(Nuisse.meanspktsfromstart,minevts,Nuisse.intervalsubset);
AboveTitle('NonSpindleUPs: ECellMean vs EventStart')
set(h(end),'name',[basename '_SleepHalfCorr_NonSpindleUPsECellMeanVEventStart'])
[r_nue_seq_firstvpeak,p_nue_seq_firstvpeak,h(end+1)] = PlotEvenOddVectorSimilarity(Nuisse.firstspktsfrompeak,minevts,Nuisse.intervalsubset);
AboveTitle('NonSpindleUPs: ECellFirst vs EventPeak')
set(h(end),'name',[basename '_SleepHalfCorr_NonSpindleUPsECellFirstVEventPeak'])
[r_nue_seq_firstvstart,p_nue_seq_firstvstart,h(end+1)] = PlotEvenOddVectorSimilarity(Nuisse.firstspktsfromstart,minevts,Nuisse.intervalsubset);
AboveTitle('NonSpindleUPs: ECellFirst vs EventStart')
set(h(end),'name',[basename '_SleepHalfCorr_NonSpindleUPsECellFirstVEventStart'])

% Partial Spindle UPs
[r_pue_seq_meanvpeak,p_pue_seq_meanvpeak,h(end+1)] = PlotEvenOddVectorSimilarity(Puisse.meanspktsfrompeak,minevts,Puisse.intervalsubset);
AboveTitle('PartialSpindleUPs: ECellMean vs EventPeak')
set(h(end),'name',[basename '_SleepHalfCorr_PartSpindleUPsECellMeanVEventPeak'])
[r_pue_seq_meanvstart,p_pue_seq_meanvstart,h(end+1)] = PlotEvenOddVectorSimilarity(Puisse.meanspktsfromstart,minevts,Puisse.intervalsubset);
AboveTitle('PartialSpindleUPs: ECellMean vs EventStart')
set(h(end),'name',[basename '_SleepHalfCorr_PartSpindleUPsECellMeanVEventStart'])
[r_pue_seq_firstvpeak,p_pue_seq_firstvpeak,h(end+1)] = PlotEvenOddVectorSimilarity(Puisse.firstspktsfrompeak,minevts,Puisse.intervalsubset);
AboveTitle('PartialSpindleUPs: ECellFirst vs EventPeak')
set(h(end),'name',[basename '_SleepHalfCorr_PartSpindleUPsECellFirstVEventPeak'])
[r_pue_seq_firstvstart,p_pue_seq_firstvstart,h(end+1)] = PlotEvenOddVectorSimilarity(Puisse.firstspktsfromstart,minevts,Puisse.intervalsubset);
AboveTitle('PartialSpindleUPs: ECellFirst vs EventStart')
set(h(end),'name',[basename '_SleepHalfCorr_PartSpindleUPsECellFirstVEventStart'])

% Early Spindle UPs
[r_eue_seq_meanvpeak,p_eue_seq_meanvpeak,h(end+1)] = PlotEvenOddVectorSimilarity(Euisse.meanspktsfrompeak,minevts,Euisse.intervalsubset);
AboveTitle('EarlySpindleUPs: ECellMean vs EventPeak')
set(h(end),'name',[basename '_SleepHalfCorr_EarlySpindleUPsECellMeanVEventPeak'])
[r_eue_seq_meanvstart,p_eue_seq_meanvstart,h(end+1)] = PlotEvenOddVectorSimilarity(Euisse.meanspktsfromstart,minevts,Euisse.intervalsubset);
AboveTitle('EarlySpindleUPs: ECellMean vs EventStart')
set(h(end),'name',[basename '_SleepHalfCorr_EarlySpindleUPsECellMeanVEventStart'])
[r_eue_seq_firstvpeak,p_eue_seq_firstvpeak,h(end+1)] = PlotEvenOddVectorSimilarity(Euisse.firstspktsfrompeak,minevts,Euisse.intervalsubset);
AboveTitle('EarlySpindleUPs: ECellFirst vs EventPeak')
set(h(end),'name',[basename '_SleepHalfCorr_EarlySpindleUPsECellFirstVEventPeak'])
[r_eue_seq_firstvstart,p_eue_seq_firstvstart,h(end+1)] = PlotEvenOddVectorSimilarity(Euisse.firstspktsfromstart,minevts,Euisse.intervalsubset);
AboveTitle('EarlySpindleUPs: ECellFirst vs EventStart')
set(h(end),'name',[basename '_SleepHalfCorr_EarlySpindleUPsECellFirstVEventStart'])

% Late Spindle UPs
[r_lue_seq_meanvpeak,p_lue_seq_meanvpeak,h(end+1)] = PlotEvenOddVectorSimilarity(Luisse.meanspktsfrompeak,minevts,Luisse.intervalsubset);
AboveTitle('LateSpindleUPs: ECellMean vs EventPeak')
set(h(end),'name',[basename '_SleepHalfCorr_LateSpindleUPsECellMeanVEventPeak'])
[r_lue_seq_meanvstart,p_lue_seq_meanvstart,h(end+1)] = PlotEvenOddVectorSimilarity(Luisse.meanspktsfromstart,minevts,Luisse.intervalsubset);
AboveTitle('LateSpindleUPs: ECellMean vs EventStart')
set(h(end),'name',[basename '_SleepHalfCorr_LateSpindleUPsECellMeanVEventStart'])
[r_lue_seq_firstvpeak,p_lue_seq_firstvpeak,h(end+1)] = PlotEvenOddVectorSimilarity(Luisse.firstspktsfrompeak,minevts,Luisse.intervalsubset);
AboveTitle('LateSpindleUPs: ECellFirst vs EventPeak')
set(h(end),'name',[basename '_SleepHalfCorr_LateSpindleUPsECellFirstVEventPeak'])
[r_lue_seq_firstvstart,p_lue_seq_firstvstart,h(end+1)] = PlotEvenOddVectorSimilarity(Luisse.firstspktsfromstart,minevts,Luisse.intervalsubset);
AboveTitle('LateSpindleUPs: ECellFirst vs EventStart')
set(h(end),'name',[basename '_SleepHalfCorr_LateSpindleUPsECellFirstVEventStart'])

% Spindles
[r_se_seq_meanvpeak,p_se_seq_meanvpeak,h(end+1)] = PlotEvenOddVectorSimilarity(sisse.meanspktsfrompeak,minevts);
AboveTitle('AllSpindles: ECellMean vs EventPeak')
[r_se_seq_meanvstart,p_se_seq_meanvstart,h(end+1)] = PlotEvenOddVectorSimilarity(sisse.meanspktsfromstart,minevts);
AboveTitle('AllSpidles: ECellMean vs EventStart')
[r_se_seq_firstvpeak,p_se_seq_firstvpeak,h(end+1)] = PlotEvenOddVectorSimilarity(sisse.firstspktsfrompeak,minevts);
AboveTitle('AllSpindles: ECellFirst vs EventPeak')
[r_se_seq_firstvstart,p_se_seq_firstvstart,h(end+1)] = PlotEvenOddVectorSimilarity(sisse.firstspktsfromstart,minevts);
AboveTitle('AllSpindles: ECellFirst vs EventStart')

SpindleUPEvenOddRsAndPs = v2struct(r_ue_rate, p_ue_rate, r_sue_rate, p_sue_rate,...
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
save(fullfile('UPstates',[basename '_SpindleUPEvenOddRsAndPs_Restricted.mat']),'SpindleUPEvenOddRsAndPs')

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
% save(fullfile('UPstates',[basename '_SpindleUPRatesDurations.mat']),'SpindleUPRatesDurations')


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
    ['Non-SU n=' num2str(length(NoSpindleUPs))];...
    ['SpindU n=' num2str(length(SpindleUPs))];...
    ['Part-SU n=' num2str(length(PartialSpindleUPs))];...
    ['EarlySU n=' num2str(length(EarlyStartUPs))];...
    ['LateSU n=' num2str(length(LateStartUPs))];...
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
    ['Non-SU n=' num2str(length(NoSpindleUPs))];...
    ['SpindU n=' num2str(length(SpindleUPs))];...
    ['Part-SU n=' num2str(length(PartialSpindleUPs))];...
    ['EarlySU n=' num2str(length(EarlyStartUPs))];...
    ['LateSU n=' num2str(length(LateStartUPs))];...
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
    ['Non-SU n=' num2str(length(NoSpindleUPs))];...
    ['SpindU n=' num2str(length(SpindleUPs))];...
    ['Part-SU n=' num2str(length(PartialSpindleUPs))];...
    ['EarlySU n=' num2str(length(EarlyStartUPs))];...
    ['LateSU n=' num2str(length(LateStartUPs))];...
    ['Spinds n=' num2str(length(sp_starts))]})

%Rs for rates
h(end+1) = figure;
hax = plot_meanSD_bars(r_ue_rate,r_nue_rate,r_sue_rate,r_pue_rate,r_eue_rate,r_lue_rate,r_se_rate);
title(hax,'R Values  E Cell Rate(by Event Type)')
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{['AllUPs n=' num2str(length(length(UPints)))];...
    ['Non-SU n=' num2str(length(NoSpindleUPs))];...
    ['SpindU n=' num2str(length(SpindleUPs))];...
    ['Part-SU n=' num2str(length(PartialSpindleUPs))];...
    ['EarlySU n=' num2str(length(EarlyStartUPs))];...
    ['LateSU n=' num2str(length(LateStartUPs))];...
    ['Spinds n=' num2str(length(sp_starts))]})
AboveTitle('R values')
set(h(end),'name',[basename '_SpindleUPRateRs'])

%Rs for timing
h(end+1) = figure;
subplot(2,2,1)
hax = plot_meanSD_bars(r_ue_seq_firstvstart,r_nue_seq_firstvstart, r_sue_seq_firstvstart,r_pue_seq_firstvstart,r_eue_seq_firstvstart,r_lue_seq_firstvstart,r_se_seq_firstvstart);
title(hax,'SpikeTiming: FirstVsStart')
subplot(2,2,2)
hax = plot_meanSD_bars(r_ue_seq_firstvpeak,r_nue_seq_firstvpeak, r_sue_seq_firstvpeak,r_pue_seq_firstvpeak,r_eue_seq_firstvpeak,r_lue_seq_firstvpeak,r_se_seq_firstvpeak);
title(hax,'SpikeTiming: FirstVsPeak')
subplot(2,2,3)
hax = plot_meanSD_bars(r_ue_seq_meanvstart,r_nue_seq_meanvstart, r_sue_seq_meanvstart,r_pue_seq_meanvstart,r_eue_seq_meanvstart,r_lue_seq_meanvstart,r_se_seq_meanvstart);
title(hax,'SpikeTiming: MeanVsStart')
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{['AllUPs n=' num2str(length(length(UPints)))];...
    ['Non-SU n=' num2str(length(NoSpindleUPs))];...
    ['SpindU n=' num2str(length(SpindleUPs))];...
    ['Part-SU n=' num2str(length(PartialSpindleUPs))];...
    ['EarlySU n=' num2str(length(EarlyStartUPs))];...
    ['LateSU n=' num2str(length(LateStartUPs))];...
    ['Spinds n=' num2str(length(sp_starts))]})
subplot(2,2,4)
hax = plot_meanSD_bars(r_ue_seq_meanvpeak,r_nue_seq_meanvpeak, r_sue_seq_meanvpeak,r_pue_seq_meanvpeak,r_eue_seq_meanvpeak,r_lue_seq_meanvpeak,r_se_seq_meanvpeak);
title(hax,'SpikeTiming: MeanVsPeak')
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{['AllUPs n=' num2str(length(length(UPints)))];...
    ['Non-SU n=' num2str(length(NoSpindleUPs))];...
    ['SpindU n=' num2str(length(SpindleUPs))];...
    ['Part-SU n=' num2str(length(PartialSpindleUPs))];...
    ['EarlySU n=' num2str(length(EarlyStartUPs))];...
    ['LateSU n=' num2str(length(LateStartUPs))];...
    ['Spinds n=' num2str(length(sp_starts))]})
AboveTitle('R values')
set(h(end),'name',[basename '_SpindleUPTimingRs'])


%% save figs
cd(fullfile(basepath,'UPstates'))
if ~exist('SpindleUPEvenOddRestrictedFigs','dir')
    mkdir('SpindleUPEvenOddRestrictedFigs')
end
cd('SpindleUPEvenOddRestrictedFigs')
savefigsasname(h,'fig');
% close(h)
cd(basepath)



function [r,p,h] = PlotEvenOddVectorSimilarity(celleventvectors,minevts,subset)

if ~exist('subset','var')
    subset = 1:size(celleventvectors,1);
end

r = [];
p = [];

oddidxs = 1:2:length(subset);
evenidxs = 2:2:length(subset);
%     oddidxs = subset(oddidxs);
%     evenidxs = subset(evenidxs);
timesodd = celleventvectors(oddidxs,:);
timeseven = celleventvectors(evenidxs,:);

randixs1 = randperm(size(timesodd,1));
randixs1 = randixs1(1:min([floor(minevts/2) size(timesodd,1)]));
randixs2 = randperm(size(timeseven,1));
randixs2 = randixs2(1:min([floor(minevts/2) size(timeseven,1)]));
x = nanmean(timesodd(randixs1,:),1);
y = nanmean(timeseven(randixs2,:),1);

%     x = nanmean(timesodd,1);
%     y = nanmean(timeseven,1);

% h = 0;
h = figure;
% subplot(length(SleepStartIdxs),1,a)
plot(x,y,'.');
%     axis equal
hold on;
title(['N = ' num2str(size(subset,2)) ' events.'])
xlabel('Odd Event Mean timing (s)')
ylabel('Even Event (s)')
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


% function [r,p,h] = PlotEvenOddVectorSimilarityResample(celleventvectors,minevts,subset)
% 
% if ~exist('subset','var')
%     subset = 1:size(celleventvectors,1);
% end
% 
% r = [];
% p = [];
% 
% oddidxs = 1:2:length(subset);
% evenidxs = 2:2:length(subset);
% %     oddidxs = subset(oddidxs);
% %     evenidxs = subset(evenidxs);
% timesodd = celleventvectors(oddidxs,:);
% timeseven = celleventvectors(evenidxs,:);
% 
% for a = 1:100;
%     randixs1 = randperm(size(timesodd,1));
%     randixs1 = randixs1(1:min([floor(minevts/2-2) size(timesodd,1)]));
%     randixs2 = randperm(size(timeseven,1));
%     randixs2 = randixs2(1:min([floor(minevts/2-2) size(timeseven,1)]));
%     x = nanmean(timesodd(randixs1,:),1);
%     y = nanmean(timeseven(randixs2,:),1);
%     try
%         [~,r(end+1),p(end+1)] =  RegressAndFindR(x,y);
%     catch 
%         r(end+1) = nan;
%         p(end+1) = nan;
%     end
% end
% 
% 
% %     x = nanmean(timesodd,1);
% %     y = nanmean(timeseven,1);
% 
% % h = 0;
% h = figure;
% % subplot(length(SleepStartIdxs),1,a)
% plot(x,y,'.');
% %     axis equal
% hold on;
% title(['N = ' num2str(size(subset,2)) ' events.'])
% xlabel('Odd Event Mean timing (s)')
% ylabel('Even Event (s)')
% xl = get(gca,'xlim');
% yl = get(gca,'ylim');
% plot(xl,yl,'r')
% text(.05*(xl(2)-xl(1))+xl(1),.9*(yl(2)-yl(1))+yl(1),['r = ' num2str(nanmean(r)) '. p = ' num2str(nanmean(p)) '.'])



function numevts = GetHalvesNumEvts(celleventvectors,SleepStartIdxs,SleepStopIdxs,subset)

if ~exist('subset','var')
    subset = 1:size(celleventvectors,1);
end

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
    numevts(a,1) = size(timeshalf1,1);
    numevts(a,2) = size(timeshalf2,1);
end





