% Spindles_BigScript(basename)
%% Meta info
basepath = cd;
[~,basename,~] = fileparts(cd);
bmd = load([basename '_BasicMetaData.mat']);
numchans = bmd.Par.nChannels;

%% Setup for Detection and Detection
% detectionchan = bmd.Spindlechannel;
% prompt={'Which channel should spindles be detected on?'};
% name='Spindle Channel';
% numlines=1;
% defaultanswer={num2str(detectionchan)};
% detectionchan=inputdlg(prompt,name,numlines,defaultanswer);
% detectionchan = str2num(detectionchan{1});
% 
% clear prompt name numlines defaultanswer
% % Detect
% thresh1 = 2;
% thresh2 = 5;
% 
% [normspindles,SpindleData] = SpindleDetectWrapper(numchans, detectionchan, bmd.voltsperunit, thresh1, thresh2);
% % make interval set from spindles

load(fullfile(basepath,'Spindles','SpindleData.mat'),'SpindleData')
normspindles = SpindleData.normspindles;

%% Get event-wise spiking data
Spindles_DetectAllDatasetSpindles(basepath,basename)

%% Eliminate DOWN state parts from spindles... get event-wise spiking data
FindSpindlesWithDOWNs(basepath,basename);
Spindles_GetNoDOWNSpindleIntervalSpiking(basepath,basename);

%% Extract basic spindle info
sp_starts = normspindles(:,1);
sp_peaks = normspindles(:,2);
sp_stops = normspindles(:,3);
sp_ints = intervalSet(sp_starts,sp_stops);

durs = SpindleData.data.duration;
amps = SpindleData.data.peakAmplitude;
freqs = SpindleData.data.peakFrequency;

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


%% Get spike rates in various states
StateCompressedSpikes = MakeStateCompressedSpikesSet(basename);

%% Plot correlations between spike rates in different states
RWake = Rate(StateCompressedSpikes.S_inWake);
RSWS = Rate(StateCompressedSpikes.S_inSWS);
RREM = Rate(StateCompressedSpikes.S_inREM);
RSpindles = Rate(StateCompressedSpikes.S_inSpindles);
RUPs = Rate(StateCompressedSpikes.S_inUPs);

h=figure;
mcorr_bw_ForCellIDs(StateCompressedSpikes.CellIDs,RWake,RSWS,RREM,RSpindles,RUPs)
saveas(h,[basename '_StateRateSpikingCorrespondences.fig'])

%% Extract spike features of each spindle
filename = fullfile('Spindles',[basename '_SpindleSpikeStats.mat']);
if exist(filename,'file')
    t = load(filename);
    iss = t.iss;
    isse = t.isse;
    issi = t.issi;
    issed = t.issed;
    issid = t.issid;
else
    iss = SpikeStatsInIntervals(S,sp_ints,sp_peaks);
    t = load([basename '_CellIDs.mat']);
    isse = SpikeStatsCellSubset(iss,t.CellIDs.EAll);
    issi = SpikeStatsCellSubset(iss,t.CellIDs.IAll);
    issed = SpikeStatsCellSubset(iss,t.CellIDs.EDefinite);
    issid = SpikeStatsCellSubset(iss,t.CellIDs.IDefinite);
    if ~exist('Spindles','dir')
        mkdir('Spindles')
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
    staidx = find(sp_starts>SleepStartTimes(a),1,'first');
    stoidx = find(sp_stops<SleepStopTimes(a),1,'last');

    SleepStartIdxs(a) = staidx;
    SleepStopIdxs(a) = stoidx;
end

%% Some basic plots
% spindle number vs time
figure;
plot(1:length(normspindles),normspindles(:,2))

%spindle #spikes, duration, spike rate, freq, amp
fa = Spindles_basicSpindlePlots(iss,SpindleData);
set(fa,'Name',[basename '_BasicSpindlePlots_AllCells'])
fe = Spindles_basicSpindlePlots(isse,SpindleData);
set(fe,'Name',[basename '_BasicSpindlePlots_ECells'])
fi = Spindles_basicSpindlePlots(issi,SpindleData);
set(fi,'Name',[basename '_BasicSpindlePlots_ICells'])

fed = Spindles_basicSpindlePlots(issed,SpindleData);
set(fed,'Name',[basename '_BasicSpindlePlots_EDefCells'])
fid = Spindles_basicSpindlePlots(issid,SpindleData);
set(fid,'Name',[basename '_BasicSpindlePlots_IDefCells'])

MakeDirSaveFigsThere(fullfile(basepath,'Spindles','SpindleFigures'),[fa fe fi fed fid])

%% Save StateEditor overlays
Spindles_BasicOverlaysForStateEditor(basename,iss,SpindleData)
Spindles_BasicOverlaysForStateEditor(basename,isse,SpindleData)
Spindles_BasicOverlaysForStateEditor(basename,issi,SpindleData)
Spindles_BasicOverlaysForStateEditor(basename,issed,SpindleData)
Spindles_BasicOverlaysForStateEditor(basename,issid,SpindleData)

%% Overlapping cells per pair of intervals (over union of active cells between pair)
inputStructName = 'iss'; inputFieldName = 'spkbools'; 
metricFcnName = 'SharedOverUnion'; 
outputBaseName = 'ParticipantOverlaps';
h = CalcAndPlotEventMetricsOverAllSs(metricFcnName,inputStructName,inputFieldName,outputBaseName,iss,isse,issi,issed,issid,durs,amps,freqs,SleepStartIdxs,SleepStopIdxs);
MakeDirSaveFigsThere(fullfile('Spindles','OverlapOverUnionFigs'),h)

SimilarityMetricToStateEditorOverlay(ParticipantOverlaps.E,sp_peaks,basename,'ParticipantOverlaps')

%% Dot product of rate vectors... vectors not unitized/normalized at all
inputStructName = 'iss'; inputFieldName = 'spkrates'; 
metricFcnName = 'NonNormRateVectorDots'; 
outputBaseName = 'RateVectorDots';
h = CalcAndPlotEventMetricsOverAllSs(metricFcnName,inputStructName,inputFieldName,outputBaseName,iss,isse,issi,issed,issid,durs,amps,freqs,SleepStartIdxs,SleepStopIdxs);
MakeDirSaveFigsThere(fullfile('Spindles','NonNormRateVectorDotFigs'),h)

SimilarityMetricToStateEditorOverlay(RateVectorDots.E,sp_peaks,basename,'RateVectorDots')

%% Dot product of rate vectors... vectors converted to unit using norm2
% RateVectorOverlapsA = NonNormRateVectorDots(iss.spkrates);
inputStructName = 'iss'; inputFieldName = 'spkrates'; 
metricFcnName = 'NormRateVectorDots'; 
outputBaseName = 'RateNormVectorDots';
h = CalcAndPlotEventMetricsOverAllSs(metricFcnName,inputStructName,inputFieldName,outputBaseName,iss,isse,issi,issed,issid,durs,amps,freqs,SleepStartIdxs,SleepStopIdxs);
MakeDirSaveFigsThere(fullfile('Spindles','NormRateVectorDotFigs'),h)

SimilarityMetricToStateEditorOverlay(RateNormVectorDots.E,sp_peaks,basename,'RateNormVectorDots')

%% Dot product of timing vectors... raw timing
% inputStructName = 'iss'; inputFieldName = 'meanspktsfromstart_capped'; 
% metricFcnName = 'TimingVectorDots'; 
% outputBaseName = 'TimingFromStartCappedDots';
% h = CalcAndPlotEventMetricsOverAllSs(metricFcnName,inputStructName,inputFieldName,outputBaseName,iss,isse,issi,issed,issid,durs,amps,freqs,SleepStartIdxs,SleepStopIdxs);
% MakeDirSaveFigsThere(fullfile('Spindles','TimingFromStartCappedDotFigs',h)

%% Dot product of sorted place vectors... only for shared cells in any pair of events
inputStructName = 'iss'; inputFieldName = 'meanspktsfromstart_capped'; 
metricFcnName = 'TimingRankVectorDots'; 
outputBaseName = 'SortedRankFromStartCappedDots';
h = CalcAndPlotEventMetricsOverAllSs(metricFcnName,inputStructName,inputFieldName,outputBaseName,iss,isse,issi,issed,issid,durs,amps,freqs,SleepStartIdxs,SleepStopIdxs);
MakeDirSaveFigsThere(fullfile('Spindles','TimingFromStartCappedDotFigs',h)

%% 
% Divide cells by quartiles, try same thing


%% Look at similarity of PARTICIPANTS per event
% ... using resampling of # spikes (weighted with replacement) to generate
nshuffs = 100;
[SpindleCountShuffles,SpindleBoolShuffles] = GenerateSurrogateRatesAndBooleansPerEvent(nshuffs,sp_ints,S,iss.spkcounts,iss.spkbools,basename);
[SpindleCountShufflesE,SpindleBoolShufflesE] = GenerateSurrogateRatesAndBooleansPerEvent(nshuffs,sp_ints,Se,isse.spkcounts,isse.spkbools,basename);
[SpindleCountShufflesI,SpindleBoolShufflesI] = GenerateSurrogateRatesAndBooleansPerEvent(nshuffs,sp_ints,Si,issi.spkcounts,issi.spkbools,basename);


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

measured = OrigVsReshuffPairwiseCellSharing(iss.spkbools, SpindleBoolShuffles.surrbools_byOverallRate);
measured = OrigVsReshuffPairwiseCellSharing(isse.spkbools, SpindleBoolShuffles.surrbools_byOverallRate);
measured = OrigVsReshuffPairwiseCellSharing(issi.spkbools, SpindleBoolShuffles.surrbools_byOverallRate);
    

%% Sequences 
    
dists = VectSimilarities(iss.spkbools);


% need a vector similarity metric... even if nans
% ... maybe just # of shared cells... as a % of all cells... or inverse to
% get distance rather than similarity

% RelativeRates per cell
%
% first time
% mean time



