% Spindles_BigScript(basename)

%% Meta info
[~,basename,~] = fileparts(cd);
basepath = cd;
% basepath = fullfile(basepath,basename);
% bmd = load([basename '_BasicMetaData.mat']);
% numchans = bmd.Par.nChannels;

%% Load UP state data (assuming it was done as part of _BigScript_Sleep
t = load([basename, '_UPDOWNIntervals']);
UPInts = t.UPInts;

%% Extract basic UP info
UPstarts = Start(UPInts);
% UPpeaks = 10000*normspindles(:,2);%... may later redefine this based on moment of max firing
UPstops = End(UPInts);

durs = UPstops - UPstarts;
% amps = SpindleData.data.peakAmplitude;
% freqs = SpindleData.data.peakFrequency;

%% load S (spikes)
t = load([basename '_SStable.mat']);
S = t.S;
shank = t.shank;
cellIx = t.cellIx;

t = load([basename '_CellIDs.mat']);
CellIDs = t.CellIDs;

t = load([basename '_SSubtypes.mat']);
Se = t.Se;
Si = t.Si;
Sed = t.SeDef;
Sid = t.SiDef;

[Sq1, Sq2, Sq3, Sq4] = DivideCellsToQuartilesBySpikeRate(S);
[Seq1, Seq2, Seq3, Seq4] = DivideCellsToQuartilesBySpikeRate(Se);


%%
filename = fullfile('UPstates',[basename '_UPSpikingPeaks.mat']);
if exist(filename,'file')
    t = load(filename);
%     UPSpkMeansFromUPStart = t.UPPeaksFromUPStart;
    UPSpkMeansFromFileStart = t.UPPeaksFromUPStart;
else
    [UPSpkMeansFromUPStart,UPSpkMeansFromFileStart] = DetectIntervalPopSpikePeaks(UPInts,S,1);%times relative to start of up
    if ~exist('UPstates','dir')
        mkdir('UPstates')
    end
    save(fullfile('UPstates',[basename '_UPSpikingMeans']),'UPSpkMeansFromUPStart','UPSpkMeansFromFileStart');
end

%% Extract spike features of each spindle
filenameA = fullfile(basepath,'UPstates',[basename '_UPSpikeStatsAll.mat']);
filenameE = fullfile(basepath,'UPstates',[basename '_UPSpikeStatsE.mat']);
filenameI = fullfile(basepath,'UPstates',[basename '_UPSpikeStatsI.mat']);
if exist(filename,'file')
    load(filenameA,'iss');
    load(filenameE,'isse');
    load(filenameI,'issi');
 else
    iss = SpikeStatsInIntervals(S,UPInts,UPSpkMeansFromFileStart);
    t = load([basename '_CellIDs.mat']);
    isse = SpikeStatsCellSubset(iss,t.CellIDs.EAll);
    issi = SpikeStatsCellSubset(iss,t.CellIDs.IAll);
    issed = SpikeStatsCellSubset(iss,t.CellIDs.EDefinite);
    issid = SpikeStatsCellSubset(iss,t.CellIDs.IDefinite);
    if ~exist('UPstates','dir')
        mkdir('UPstates')
    end
    save(filename,'iss','isse','issi','issed','issid');
end

%% Find times with at least 5min of waking beween SWS Epochs
t = load([basename,'_Intervals.mat']);
intervals = t.intervals;

sleepborders = mergeCloseIntervals(intervals{3},300*10000);
sleepbordertimes = Start(sleepborders);
SleepStartTimes = Start(sleepborders); 
SleepStopTimes = End(sleepborders);

for a = 1:length(SleepStartTimes);
    staidx = find(UPstarts>SleepStartTimes(a),1,'first');
    stoidx = find(UPstops<SleepStopTimes(a),1,'last');

    SleepStartIdxs(a) = staidx;
    SleepStopIdxs(a) = stoidx;
end

%% Some basic plots
% % UP number vs time
% figure;
% plot(1:length(UPstarts),UPstarts)
% 
% %spindle #spikes, duration, spike rate, freq, amp
% fa = Spindles_basicSpindlePlots(iss,SpindleData);
% set(fa,'Name',[basename '_BasicUPPlots_AllCells'])
% fe = Spindles_basicSpindlePlots(isse,SpindleData);
% set(fe,'Name',[basename '_BasicUPPlots_ECells'])
% fi = Spindles_basicSpindlePlots(issi,SpindleData);
% set(fi,'Name',[basename '_BasicUPPlots_ICells'])
% 
% fed = Spindles_basicSpindlePlots(issed,SpindleData);
% set(fed,'Name',[basename '_BasicUPPlots_EDefCells'])
% fid = Spindles_basicSpindlePlots(issid,SpindleData);
% set(fid,'Name',[basename '_BasicUPPlots_IDefCells'])
% 
% MakeDirSaveFigsThere(fullfile(basepath,'UPstates','UPFigures'),[fa fe fi fed fid])

%% Save StateEditor overlays
UPstates_BasicOverlaysForStateEditor(basename,iss,UPstarts/10000)
UPstates_BasicOverlaysForStateEditor(basename,isse,UPstarts/10000)
UPstates_BasicOverlaysForStateEditor(basename,issi,UPstarts/10000)
UPstates_BasicOverlaysForStateEditor(basename,issed,UPstarts/10000)
UPstates_BasicOverlaysForStateEditor(basename,issid,UPstarts/10000)

%% Overlapping cells per pair of intervals (over union of active cells between pair)
inputStructName = 'iss'; inputFieldName = 'spkbools'; 
metricFcnName = 'SharedOverUnion'; 
outputBaseName = 'ParticipantOverlaps';
h = CalcAndPlotEventMetricsOverAllSs_UPs(metricFcnName,inputStructName,inputFieldName,outputBaseName,iss,isse,issi,durs,SleepStartIdxs,SleepStopIdxs);
MakeDirSaveFigsThere(fullfile('UPstates','OverlapOverUnionFigs'),h)

% SimilarityMetricToStateEditorOverlay_UPs(ParticipantOverlaps.E,UPstarts/10000,basename,'ParticipantOverlapsE')

%% Dot product of rate vectors... vectors not unitized/normalized at all
inputStructName = 'isse'; inputFieldName = 'spkrates'; 
metricFcnName = 'NonNormRateVectorDots'; 
outputBaseName = 'RateVectorDots';
h = CalcAndPlotEventMetricsOverAllSs_UPs(metricFcnName,inputStructName,inputFieldName,outputBaseName,iss,isse,issi,durs,SleepStartIdxs,SleepStopIdxs);
MakeDirSaveFigsThere(fullfile('UPstates','NonNormRateVectorDotFigs'),h)


%% Dot product of rate vectors... vectors converted to unit using norm2
inputStructName = 'isse'; inputFieldName = 'spkrates'; 
metricFcnName = 'NormRateVectorDots'; 
outputBaseName = 'RateNormVectorDots';
h = CalcAndPlotEventMetricsOverAllSs_UPs(metricFcnName,inputStructName,inputFieldName,outputBaseName,iss,isse,issi,durs,SleepStartIdxs,SleepStopIdxs);
MakeDirSaveFigsThere(fullfile('UPstates','NormRateVectorDotFigs'),h)

SimilarityMetricToStateEditorOverlay_UPs(RateNormVectorDots.E,UPstarts/10000,basename,'RateNormVectorDotsE')

%% Dot product of timing vectors... raw timing
% RateVectorOverlapsA = NonNormRateVectorDots(iss.spkrates);
TimingFromStartCappedDotsA = TimingVectorDots(iss.meanspktsfromstart_capped);
PlotEventSimilarities(TimingFromStartCappedDotsA,iss.spkrates,durs,amps,freqs,SleepStartIdxs,SleepStopIdxs);

TimingFromStartCappedDotsE = TimingVectorDots(isse.meanspktsfromstart_capped);
PlotEventSimilarities(TimingFromStartCappedDotsE,isse.spkrates,durs,amps,freqs,SleepStartIdxs,SleepStopIdxs);

TimingFromStartCappedDotsI = TimingVectorDots(issi.meanspktsfromstart_capped);
PlotEventSimilarities(TimingFromStartCappedDotsI,issi.spkrates,durs,amps,freqs,SleepStartIdxs,SleepStopIdxs);


%% 
% Divide cells by quartiles, try same thing

% Do all in UP states



%% Look at similarity of PARTICIPANTS per event
% ... using resampling of # spikes (weighted with replacement) to generate
% nshuffs = 100;
% [SpindleCountShuffles,SpindleBoolShuffles] = GenerateSurrogateRatesAndBooleansPerEvent(nshuffs,UPInts,S,iss.spkcounts,iss.spkbools,basename);
% [SpindleCountShufflesE,SpindleBoolShufflesE] = GenerateSurrogateRatesAndBooleansPerEvent(nshuffs,UPInts,Se,isse.spkcounts,isse.spkbools,basename);
% [SpindleCountShufflesI,SpindleBoolShufflesI] = GenerateSurrogateRatesAndBooleansPerEvent(nshuffs,UPInts,Si,issi.spkcounts,issi.spkbools,basename);


%% Look at similarity of PARTICIPANTS per event
% % ... using resampling of participants by using weighted resampling without
% % replacement
% nshuffs = 100;
% 
% surrbools_byFlatDistrib = ShuffleCellOccurrencesByWeights(iss.spkbools,ones(1,size(S,1)),nshuffs);
% 
% surrbools_byOverallRate = ShuffleCellOccurrencesByWeights(iss.spkbools,Rate(S),nshuffs);
% 
% surrbools_bySpindleBinary = ShuffleCellOccurrencesByWeights(iss.spkbools,mean(iss.spkbools,1),nshuffs);
% 
% S_inSpindles =  CompressSpikeTrainsToIntervals(S,sp_ints);
% surrbools_bySpindleRate = ShuffleCellOccurrencesByWeights(iss.spkbools,Rate(S_inSpindles),nshuffs);
% 
% intervals = load([basename,'_Intervals.mat']);
% S_inWake =  CompressSpikeTrainsToIntervals(S,intervals.intervals{1});
% S_inSWS =  CompressSpikeTrainsToIntervals(S,intervals.intervals{3});
% S_inREM =  CompressSpikeTrainsToIntervals(S,intervals.intervals{5});
% surrbools_bySWSRate = ShuffleCellOccurrencesByWeights(iss.spkbools,Rate(S_inSWS),nshuffs);
% 
% UPs = load([basename,'_UPDOWNIntervals.mat']);
% S_inUPs =  CompressSpikeTrainsToIntervals(S,UPs.UPInts);
% surrbools_byUPRate = ShuffleCellOccurrencesByWeights(iss.spkbools,Rate(S_inUPs),nshuffs);
% 
% SpindleBoolShuffles = v2struct(surrbools_byFlatDistrib,surrbools_byOverallRate,...
%     surrbools_bySpindleBinary,surrbools_bySpindleRate,surrbools_bySWSRate,...
%     surrbools_byUPRate);
% save (['Spindles/' basename '_SpindleBoolShuffles_' num2str(nshuffs)],'SpindleBoolShuffles')
% 
% SConfined = v2struct(S_inWake,S_inSWS,S_inREM,S_inUPs,S_inSpindles);
% save ([basename '_SConfined'],'SConfined')
% 
% % !make upstate shuffles, why not
% 
% clear intervals UPs

%% Overlap vs shuffled

% measured = OrigVsReshuffPairwiseCellSharing(iss.spkbools, SpindleBoolShuffles.surrbools_byOverallRate);
% measured = OrigVsReshuffPairwiseCellSharing(isse.spkbools, SpindleBoolShuffles.surrbools_byOverallRate);
% measured = OrigVsReshuffPairwiseCellSharing(issi.spkbools, SpindleBoolShuffles.surrbools_byOverallRate);
    

%% Sequences 
    
% dists = VectSimilarities(iss.spkbools);


% need a vector similarity metric... even if nans
% ... maybe just # of shared cells... as a % of all cells... or inverse to
% get distance rather than similarity

% RelativeRates per cell
%
% first time
% mean time



