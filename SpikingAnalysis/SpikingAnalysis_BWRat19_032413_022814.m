%% USE: Note, if "load" command is at the end of a section then executing that load can subsitute for the entire section (if the data has already been stored to disk)

basename = 'BWRat19_032413';
basepath = ['/mnt/brendon4/BWRat19/' basename '_Supradir/' basename '/'];
cd (basepath)
Par = LoadPar([basename '.xml']);
goodshanks = [2,3,4,5,6];

save([basename '_basicMetaData.mat'],'basename','basepath','Par','goodshanks');
% load([basename '_basicMetaData.mat']);

%% Load Spikes
%%NOTE ON THIS DATASET:
% shank1 unstable at start of recording, where presleep is.  
% shanks 7-14 from CEA not stable (and not cortical)
[S,shank,cellIx] = LoadSpikeData(basename,goodshanks);
save([basename,'_SAll.mat'],'S','shank','cellIx')

%load([basename,'_SAll.mat'])

%% Look at cellular stability using Mahalanobis distances and total spike energies
[SpikeEnergiesCell,MahalDistancesCell] = AllCellsEnergyMahalPerSpike(S,shank,cellIx,basename);

% MahalDistances = AllCellsMahalPerSpike(S,shank,cellIx,basename);
for a = 1:size(S,1);
    numspikes = length(S{a});

    MahalDistances{a,1} = tsd(TimePoints(S{a}),MahalDistancesCell{a});
    StartDistances(a) = mean(MahalDistancesCell{a}(1:round(numspikes*.2)));
    EndDistances(a) = mean(MahalDistancesCell{a}((round(numspikes*.8)+1):end));
    MahalDistanceChanges(a) = (EndDistances(a)-StartDistances(a))/StartDistances(a);
    
    SpikeEnergies{a,1} = tsd(TimePoints(S{a}),SpikeEnergiesCell{a});
%     SmoothedSpikeEnergies{a} = smooth(SpikeEnergiesCell{a},500);
    StartEnergies(a) = mean(SpikeEnergiesCell{a}(1:round(numspikes*.2)));
    EndEnergies(a) = mean(SpikeEnergiesCell{a}((round(numspikes*.8)+1):end));
    SpikeEnergyChanges(a) = (EndEnergies(a)-StartEnergies(a))/StartEnergies(a);
end
MahalDistances = tsdArray(MahalDistances);%now have a TSD array of spike distances
SpikeEnergies = tsdArray(SpikeEnergies);

autobadcells = find(abs(SpikeEnergyChanges)>0.3 | abs(MahalDistanceChanges)>0.3);
bwbadcells = [];
% bwbadcells = find(shank == 4 & [cellIx == 3 | cellIx == 8]);
allbadcells = union(autobadcells,bwbadcells);

% SpikeEnergies = AllCellsEnergyPerSpike(S,shank,cellIx,basename);
% for a = 1:size(S,1);
%     SpikeEnergies{a,1} = tsd(TimePoints(S{a}),SpikeEnergiesCell{a});
% end

%store original datastructs for ?
UnselectedSpikeTsds = v2struct(S, cellIx, shank);

%keep only good cells in S, cellIx, shank
s2 = cellArray(S);
s2(allbadcells)=[];
S = tsdArray(s2);
cellIx(allbadcells) = [];
shank(allbadcells) = [];
numgoodcells = size(S,1);
badcells = v2struct(allbadcells,autobadcells,bwbadcells);
save([basename,'_SStable.mat'],'S','shank','cellIx','numgoodcells','badcells')

%plotting cluster/cell stability for visualization
evalstring = ['if ismember(a,varargin{2});set(lineh,''color'',''black'');end;'...
    '[xtrend,ytrend] = trend(x,y);hold on;plot(xtrend,ytrend,''r'');',...
    'text(max(x)/10,max(y),[num2str(a),'': '',num2str(varargin{1}(a))])'];
titlestring = 'Mahal Distances for each spike for each cell.  Eliminated cells in black';
fignamestring = 'MahalDist';
plot_multiperfigure(MahalDistances,5,5,titlestring,fignamestring,evalstring,MahalDistanceChanges,allbadcells)
% Par = LoadPar([basename '.xml']);
evalstring = ['if ismember(a,varargin{2});set(lineh,''color'',''black'');end;'...
    '[xtrend,ytrend] = trend(x,y);hold on;plot(xtrend,ytrend,''r'');',...
    'text(max(x)/10,max(y),[num2str(a),'': '',num2str(varargin{1}(a))])'];
titlestring = 'Spike Energies for each spike for each cell.  Eliminated cells in black';
fignamestring = 'SpikeEnergy';
plot_multiperfigure(SpikeEnergies,5,5,titlestring,fignamestring,evalstring,SpikeEnergyChanges,allbadcells)

%save figs
if ~exist(fullfile(basepath,'CellQualityFigs'),'dir')
    mkdir(fullfile(basepath,'CellQualityFigs'))
end
cd(fullfile(basepath,'CellQualityFigs'))
saveallfigsas('fig')
cd(basepath)

%putting quality metrics away neatly
ClusterQualityMeasures = v2struct(MahalDistances,MahalDistancesCell,...
    MahalDistanceChanges,StartDistances,EndDistances,...
    SpikeEnergies,SpikeEnergiesCell,SpikeEnergyChanges,StartEnergies,...
    EndEnergies,...
    bwbadcells,autobadcells,allbadcells);

%cleaning up
clear MahalDistances MahalDistancesCell MahalDistanceChanges StartDistances...
    EndDistances...
    SpikeEnergies SpikeEnergiesCell SpikeEnergyChanges StartEnergies...
    EndEnergies...
    bwbadcells autobadcells allbadcells...
    a s2 numspikes titlestring evalstring


% load([basename,'_SStable.mat'])

%% Get connectivity
ccgjitteroutput = CCG_jitter_all(S);%>>> USED 1000 shuffs, 30 halfbins and 3ms jitter
if exist('ccgjitteroutput.mat','file')
    movefile('ccgjitteroutput.mat',[basename,'_ccgjitteroutput.mat'])%rename since didn't have basename inside ccgjittera_all when called this way
end

%>> or do all cells (ie good or bad) and then go in and toss if in allbadcells?
%    - complex
%    - Use ccgjitteroutput = CCG_jitter_all(basename,maybe:goodshanks)
% load([basename,'_ccgjitteroutput.mat']);

%% For time: Use another matlab to Get spike waveforms
AllSpkWaveform_BW(basename)
%load([basename,'_SpikeWavsAll.mat'])

good = [];
for a = 1:length(goodshanks);
   good = cat(1,good,find(SpkWvform_idx(:,2)==goodshanks(a))); 
end
good(ClusterQualityMeasures.allbadcells) = [];

SpkWvform_good = SpkWvform_all(good,:,:);
SpkWvform_goodidx = SpkWvform_idx(good,:);
SpkWvform_goodidx(:,1)=1:numgoodcells;

save([basename '_SpikeWavsGood.mat'],'SpkWvform_good', 'SpkEWvform_goodidx');

clear SpkWvform_all SpkWvform_idx good a
% load([basename '_SpikeWavsGood.mat'])

%% For time: Use a third matlab to Sleep score
StateEditor(basename)

%% Classify cells (get raw waveforms first)
% load([basename '_AllSpikeWavs.mat'])

[CellsQuality, PyrBoundary, CellSpikeMeasures] = WaveShapeClassification (basename, SpkWvform_good, SpkWvform_goodidx, 1:numgoodcells, 0, ccgjitteroutput(1).ECells, ccgjitteroutput(1).ICells);
CellIDs.EDefinite = ccgjitteroutput(1).ECells;
CellIDs.IDefinite = ccgjitteroutput(1).ICells;
CellIDs.ELike = find((CellsQuality(:,4)==1) .* (CellsQuality(:,5)==0));
CellIDs.ILike = find((CellsQuality(:,4)==-1) .* (CellsQuality(:,5)==0));
CellIDs.EAll = find(CellsQuality(:,4)==1);
CellIDs.IAll = find(CellsQuality(:,4)==-1);
CellClassificationOutput = v2struct(CellsQuality,PyrBoundary,CellSpikeMeasures);
save([basename, '_CellIDs.mat'],'CellIDs')
save([basename,'_CellClassificationOutput.mat'],'CellClassificationOutput')

clear CellsQuality PyrBoundary CellSpikeMeasures SpkWvform_good SpkWvform_goodidx

% load([basename, '_CellIDs.mat'])
% load([basename,'_CellClassificationOutput.mat'])

%% Dividing spikes by cell class (based on S variable above)
Se = S(CellIDs.EAll);
SeDef = S(CellIDs.EDefinite);
SeLike = S(CellIDs.ELike);
Si = S(CellIDs.IAll);
SiDef = S(CellIDs.IDefinite);
SiLike = S(CellIDs.ILike);

%% Get and keep intervals
statefilename = [basename '-states.mat'];E
load(statefilename,'states') %gives states, a vector of the state at each second
intervals = ConvertStatesVectorToIntervalSets;

clear statefilename

%% Detect UP and Down states

goodeegchannel = 26;
[UPInts, DNInts] = DetectUPAndDOWNInSWS(S,intervals,Par.nChannels,goodeegchannel,basename);
WriteEventFileFromIntervalSet (UPInts,[basename,'.UPs.evt'])
WriteEventFileFromIntervalSet (DNInts,[basename,'.DNs.evt'])
save ([basename '_UPDOWNIntervals.mat'], 'UPInts', 'DNInts','goodeegchannel')

%load([basename,'_UPDOWNIntervals.mat'])

%% Subdivide UP state spikes
UPSpikes = Restrict(S,UPInts);
DNSpikes = Restrict(S,DNInts);

UPSpikesI = Restrict(Si,UPInts);
DNSpikesI = Restrict(Si,DNInts);
UPSpikesE = Restrict(Se,UPInts);
DNSpikesE = Restrict(Se,DNInts);

%% Getting binned spike times for all cells combined & for cell types... 10sec bins

AllAllCellSpikes = oneSeries(S);
AllESpikes = oneSeries(Se);
AllISpikes = oneSeries(Si);

binnedEachCell = MakeQfromS(S,100000);%bin every 100000pts, which is 10sec (10000 pts per sec)
binnedEachCellData = Data(binnedEachCell);
binnedTrains.All = sum(Data(binnedEachCell),2)';
% figure;plot(binnedTrains.All)

binnedTrains.EDefinite = sum(binnedEachCellData(:,CellIDs.EDefinite),2)';
binnedTrains.ELike = sum(binnedEachCellData(:,CellIDs.ELike),2)';
binnedTrains.EAll = sum(binnedEachCellData(:,CellIDs.EAll),2)';E
binnedTrains.IDefinite = sum(binnedEachCellData(:,CellIDs.IDefinite),2)';
binnedTrains.ILike = sum(binnedEachCellData(:,CellIDs.ILike),2)';
binnedTrains.IAll = sum(binnedEachCellData(:,CellIDs.IAll),2)';

h=figure;
subplot(2,1,1);
title('Spikes from All cells (black), all ECells (green) and all ICells (red)')
hold on;
plot(binnedTrains.All,'k')
plot(binnedTrains.EAll,'g')
plot(binnedTrains.IAll,'r')
subplot(2,1,2);
title('All cells (black), DefinteE:BoldGrn, DefiniteI:BoldRed, E-Like:PaleGrn, I-Like:PaleRed')
hold on;
plot(binnedTrains.All,'k')
plot(binnedTrains.EDefinite+500,'color',[.3 1 .3])
plot(binnedTrains.IDefinite+500,'color',[1 .3 .3])
plot(binnedTrains.ELike,'color',[.6 1 .6])
plot(binnedTrains.ILike,'color',[1 .6 .6])
set(h,'name','RawSpikeRatesOverFullRecordingByCellType')
% ? ADD STATES to plotintervals = ConvertStatesVectorToIntervalSets

%save fig
if ~exist(fullfile(basepath,'RawSpikeRateFigs'),'dir')
    mkdir(fullfile(basepath,'RawSpikeRateFigs'))
end
cd(fullfile(basepath,'RawSpikeRateFigs'))
saveas(h,'RawSpikeRatesOverFullRecordingByCellType')
cd(basepath)


%% Save binned trains out for StateEditor
AllSpikesForStateEditor = resample(binnedTrains.All,size(states,2),size(binnedTrains.All,2));
save([basename '_StateEditorOverlay_CombinedAllSpikes'],'AllSpikesForStateEditor')

EAllSpikesForStateEditor = resample(binnedTrains.EAll,size(states,2),size(binnedTrains.EAll,2));
save([basename '_StateEditorOverlay_CombinedEAllSpikes'],'EAllSpikesForStateEditor')
IAllSpikesForStateEditor = resample(binnedTrains.IAll,size(states,2),size(binnedTrains.IAll,2));
save([basename '_StateEditorOverlay_CombinedIAllSpikes'],'IAllSpikesForStateEditor')

AllandEAllandIAllSpikesForStateEditor = cat(1,AllSpikesForStateEditor,EAllSpikesForStateEditor,IAllSpikesForStateEditor);
save([basename '_StateEditorOverlay_CombinedI+E+AllSpikes'],'AllandEAllandIAllSpikesForStateEditor')

SpikesForStateEditor = v2struct(AllSpikesForStateEditor,EAllSpikesForStateEditor,IAllSpikesForStateEditor,AllandEAllandIAllSpikesForStateEditor);
clear AllSpikesForStateEditor EAllSpikesForStateEditor IAllSpikesForStateEditor AllandEAllandIAllSpikesForStateEditor

%% defining pre-post sleep epochs
presleepSWSlist = 1:12;
presleepREMlist = 1:8;
prestart = min(FirstTime(subset(intervals{3},presleepSWSlist)),FirstTime(subset(intervals{5},presleepREMlist)));
prestop = max(LastTime(subset(intervals{3},presleepSWSlist)),LastTime(subset(intervals{5},presleepREMlist)));
presleepInt = intervalSet(prestart,prestop);

postsleepSWSlist = 18:39;
postsleepREMlist = 8:20;
poststart = min(FirstTime(subset(intervals{3},postsleepSWSlist)),FirstTime(subset(intervals{5},postsleepREMlist)));
poststop = max(LastTime(subset(intervals{3},postsleepSWSlist)),LastTime(subset(intervals{5},postsleepREMlist)));
postsleepInt = intervalSet(poststart,poststop);

% presleepUPlist = 
% postsleepUPlist = 

clear prestart prestop poststart poststop

%% Gather and plot basic UP state rate effects over time
numSWSeps = length(length(intervals{3}));

for a = 1:size(Se,1) %overall spike rates for each cell in SWS, NOT just during UPs
    SWSRatesE(:,a) = Data(intervalRate(Se{a},intervals{3}));
end
for a = 1:size(Si,1)
    SWSRatesI(:,a) = Data(intervalRate(Si{a},intervals{3}));
end
SWSRatesE = SWSRatesE';
SWSRatesI = SWSRatesI';

MeanSWSRatesE = mean(SWSRatesE,2);%...average over all cells
MeanSWSRatesI = mean(SWSRatesI,2);

for a=1:numSWSeps %overall spike rates for each cell during UPs
    thisSWS = subset(intervals{3},a);
    temp = RatesDuringSpanofUps(Se,UPInts,thisSWS);
    SWSRatesEDuringUP(:,a) = mean(temp,1);E
end
for a=1:numSWSeps 
    thisSWS = subset(intervals{3},a);
    temp = RatesDuringSpanofUps(Si,UPInts,thisSWS);
    SWSRatesIDuringUP(:,a) = mean(temp,1);
end
MeanSWSRatesEDuringUP = mean(SWSRatesEDuringUP,1);%...average over all cells
MeanSWSRatesIDuringUP = mean(SWSRatesIDuringUP,1);

numUPs = length(length(UPInts));
CellUPRates = zeros(numUPs,numgoodcells);
for a = 1:numgoodcells;
    CellUPRates(:,a) = Data(intervalRate(S{a},UPInts));
end

%get and store counts of spikes per up state
for a = 1:numUPs
    UPSpikeCounts(a) = length(Restrict(AllAllCellSpikes,subset(UPInts,a)));
end
UPDurations = Data(length(UPInts));

%plotting
%function should be in same folder... to save space on this script
SpikingAnalysis_SWSAndUPPlotting(basename,intervals,...
    SWSRatesE,SWSRatesI,MeanSWSRatesE,MeanSWSRatesI,...
    SWSRatesEDuringUP,SWSRatesIDuringUP,MeanSWSRatesEDuringUP,MeanSWSRatesIDuringUP,...
    CellUPRates, AllAllCellUPRates, AllECellUPRates, AllICellUPRates, CellIDs,... 
    UPInts,numUPs,AllAllCellSpikes,UPSpikeCounts,...
    presleepSWSlist,postsleepSWSlist)

%save figs
if ~exist(fullfile(basepath,'SWSUPStateBasicFigs'),'dir')
    mkdir(fullfile(basepath,'SWSUPStateBasicFigs'))
end
cd(fullfile(basepath,'SWSUPStateBasicFigs'))
saveallfigsas('fig')
cd(basepath)

%cleaning up
PrePostSleepMetaData = v2struct(presleepSWSlist,presleepREMlist,presleepInt,...
    postsleepSWSlist,postsleepREMlist,postsleepInt);E
clear presleepSWSlist presleepREMlist presleepInt postsleepSWSlist postsleepREMlist postsleepInt

UPStateMetaData = v2struct(UPInts,DNInts,numUPs,UPSpikeCounts,UPDurations);
clear UPInts DNInts numUPs UPSpikeCounts UPDurations

SWSAndUPRates = v2struct(numSWSeps,...
    SWSRatesE,SWSRatesI,MeanSWSRatesE,MeanSWSRatesI,...
    SWSRatesEDuringUP,SWSRatesIDuringUP,MeanSWSRatesEDuringUP,MeanSWSRatesIDuringUP);
clear numSWSeps...
    SWSRatesE SWSRatesI MeanSWSRatesE MeanSWSRatesI...
    SWSRatesEDuringUP SWSRatesIDuringUP MeanSWSRatesEDuringUP MeanSWSRatesIDuringUP

clear a temp thisSWS

save([basename '_PrePostSleepMetaData.mat'],'PrePostSleepMetaData')
save([basename '_UPStateMetaData.mat'],'UPStateMetaData')
save([basename '_SWSAndUPRates.mat'],'SWSAndUPRates')

% load([basename '_PrePostSleepMetaData.mat'])
% load([basename '_UPStateMetaData.mat'])
% load([basename '_SWSAndUPRates.mat'])

%% Spike rates during first vs last SWS (or REM) SRSEpisodes in presleep
SWSERawRatesPresleepFirst = Rate(Restrict(UPSpikesE,subset(intervals{3},PrePostSleepMetaData.presleepSWSlist(1))));
SWSERawRatesPresleepLast = Rate(Restrict(UPSpikesE,subset(intervals{3},PrePostSleepMetaData.presleepSWSlist(end))));
SWSIRawRatesPresleepFirst = Rate(Restrict(UPSpikesI,subset(intervals{3},PrePostSleepMetaData.presleepSWSlist(1))));
SWSIRawRatesPresleepLast = Rate(Restrict(UPSpikesI,subset(intervals{3},PrePostSleepMetaData.presleepSWSlist(end))));
h=figure;plot_meanSEM(SWSERawRatesPresleepFirst,SWSERawRatesPresleepLast,0,SWSIRawRatesPresleepFirst,SWSIRawRatesPresleepLast);
title(['Raw Spike Rates during first vs last SWS Periods in presleep',...
    'E First Ep, E Last Ep, I First Ep, I Last Ep'])
set(h,'name','FirstVsLastSWSRawRates')

SWSEUPsRatesPresleepFirst = SWSAndUPRates.SWSRatesEDuringUP(:,PrePostSleepMetaData.presleepSWSlist(1));
SWSEUPsRatesPresleepLast = SWSAndUPRates.SWSRatesEDuringUP(:,PrePostSleepMetaData.presleepSWSlist(end));
SWSIUPsRatesPresleepFirst = SWSAndUPRates.SWSRatesIDuringUP(:,PrePostSleepMetaData.presleepSWSlist(1));
SWSIUPsRatesPresleepLast = SWSAndUPRates.SWSRatesIDuringUP(:,PrePostSleepMetaData.presleepSWSlist(end));
h=figure;plot_meanSEM(SWSEUPsRatesPresleepFirst,SWSEUPsRatesPresleepLast,0,SWSIUPsRatesPresleepFirst,SWSIUPsRatesPresleepLast);
title(['UP state Spike Rates during first vs last SWS Periods in presleep',...
    'E First Ep, E Last Ep, I First Ep, I Last Ep'])
set(h,'name','FirstVsLastSWSUPRates')

REMERatesPresleepFirst = Rate(Restrict(Se,subset(intervals{5},PrePostSleepMetaData.presleepREMlist(1))));
REMERatesPresleepLast = Rate(Restrict(Se,subset(intervals{5},PrePostSleepMetaData.presleepREMlist(end))));
REMIRatesPresleepFirst = Rate(Restrict(Si,subset(intervals{5},PrePostSleepMetaData.presleepREMlist(1))));
REMIRatesPresleepLast = Rate(Restrict(Si,subset(intervals{5},PrePostSleepMetaData.presleepREMlist(end))));
h=figure;plot_meanSEM(REMERatesPresleepFirst,REMERatesPresleepLast,0,REMIRatesPresleepFirst,REMIRatesPresleepLast);
title(['Spike Rates during first vs last REM Periods in presleep',...
    'E First Ep, E Last Ep, I First Ep, I Last Ep'])
set(h,'name','FirstVsLastREMRates')

%save figs
if ~exist(fullfile(basepath,'SWSUPStateBasicFigs'),'dir')
    mkdir(fullfile(basepath,'SWSUPStateBasicFigs'))
end
cd(fullfile(basepath,'SWSUPStateBasicFigs'))
saveallfigsas('fig')
cd(basepath)

%% Plot distribution of E cell spike rates
% all global spike rates for all E cells
AllESpikeRates = Rate(Se);
AllISpikeRates = Rate(Si);
h = SpikingAnalysis_PlotRateDistributionsLinearAndLog(AllESpikeRates);
    subplot(2,1,1)
    title('Distribution of spike rates for E cells for entire recording: Linear scale')
    subplot(2,1,2)
    title('Distribution of spike rates for E cells for entire recording: Semilog Scale')
    set(h,'name',[basename,'_ECellSpikeHisto-WholeRecording'])
h = SpikingAnalysis_PlotRateDistributionsLinearAndLog(AllISpikeRates);
    subplot(2,1,1)
    title('Distribution of spike rates for I cells for entire recording: Linear scale')
    subplot(2,1,2)
    title('Distribution of spike rates for I cells for entire recording: Semilog Scale')
    set(h,'name',[basename,'_ICellSpikeHisto-WholeRecording'])

%State-specific rate distributions
WakingESpikeRates = Rate(Se,intervals{1});
WakingISpikeRates = Rate(Si,intervals{1});
PreSleepUPs = intersect(UPStateMetaData.UPInts,PrePostSleepMetaData.presleepInt);
UPStateESpikeRates = Rate(Se,PreSleepUPs);
UPStateISpikeRates = Rate(Si,PreSleepUPs);
REMESpikeRates = Rate(Se,subset(intervals{5},PrePostSleepMetaData.presleepREMlist));
REMISpikeRates = Rate(Si,subset(intervals{5},PrePostSleepMetaData.presleepREMlist));

h = SpikingAnalysis_PlotRateDistributionsLinearAndLog(WakingESpikeRates);
    subplot(2,1,1)
    title('Distribution of spike rates for E cells for All Waking: Linear scale')
    subplot(2,1,2)
    title('Distribution of spike rates for E cells for All Waking: Semilog Scale')
    set(h,'name',[basename,'_ECellSpikeHisto-AllWaking'])
h = SpikingAnalysis_PlotRateDistributionsLinearAndLog(WakingISpikeRates);
    subplot(2,1,1)
    title('Distribution of spike rates for I cells for All Waking: Linear scale')
    subplot(2,1,2)
    title('Distribution of spike rates for I cells for All Waking: Semilog Scale')
    set(h,'name',[basename,'_ICellSpikeHisto-AllWaking'])
    
h = SpikingAnalysis_PlotRateDistributionsLinearAndLog(UPStateESpikeRates);
    subplot(2,1,1)
    title('Distribution of spike rates for E cells for Presleep SWS-UPStates: Linear scale')
    subplot(2,1,2)
    title('Distribution of spike rates for E cells for Presleep SWS-UPStates: Semilog Scale')
    set(h,'name',[basename,'_ECellSpikeHisto-AllPresleepUPStates'])
h = SpikingAnalysis_PlotRateDistributionsLinearAndLog(UPStateISpikeRates);
    subplot(2,1,1)
    title('Distribution of spike rates for I cells for Presleep SWS-UPStates: Linear scale')
    subplot(2,1,2)
    title('Distribution of spike rates for I cells for Presleep SWS-UPStates: Semilog Scale')
    set(h,'name',[basename,'_ICellSpikeHisto-AllPresleepUPStates'])

h = SpikingAnalysis_PlotRateDistributionsLinearAndLog(REMESpikeRates);
    subplot(2,1,1)
    title('Distribution of spike rates for E cells for Presleep REM: Linear scale')
    subplot(2,1,2)
    title('Distribution of spike rates for E cells for Presleep REM: Semilog Scale')
    set(h,'name',[basename,'_ECellSpikeHisto-AllPresleepREM'])
h = SpikingAnalysis_PlotRateDistributionsLinearAndLog(REMISpikeRates);
    subplot(2,1,1)
    title('Distribution of spike rates for I cells for Presleep REM: Linear scale')
    subplot(2,1,2)
    title('Distribution of spike rates for I cells for Presleep REM: Semilog Scale')
    set(h,'name',[basename,'_ICellSpikeHisto-AllPresleepREM'])

% Comparisons of before/early vs after/late sleep epochs, all related to
% presleep
prepresleepWakes = find(End(intervals{1})<FirstTime(PrePostSleepMetaData.presleepInt));
PrePresleepWakingESpikeRates = Rate(Se,subset(intervals{1},prepresleepWakes(end)));
PrePresleepWakingISpikeRates = Rate(Si,subset(intervals{1},prepresleepWakes(end)));
postpresleepWakes = find(Start(intervals{1})>LastTime(PrePostSleepMetaData.presleepInt));
PostPresleepWakingESpikeRates = Rate(Se,subset(intervals{1},postpresleepWakes(1)));
PostPresleepWakingISpikeRates = Rate(Si,subset(intervals{1},postpresleepWakes(1)));

% EndFirstThirdPresleep = (Start(PrePostSleepMetaData.presleepInt))+Data(length(PrePostSleepMetaData.presleepInt))/3;
% StartLastThirdPresleep = (Start(PrePostSleepMetaData.presleepInt))+(Data(length(PrePostSleepMetaData.presleepInt))*2/3);
% 
% FirstThirdPresleepREM = intersect(PrePostSleepMetaData.presleepREMlist, ...
%     find(End(intervals{5})<=EndFirstThirdPresleep));
% FirstPresleepREMESpikeRates = Rate(Se,subset(intervals{5},FirstThirdPresleepREM));
% LastThirdPresleepREM = intersect(PrePostSleepMetaData.presleepREMlist, ...
%     find(Start(intervals{5})>=StartLastThirdPresleep));
% LastPresleepREMESpikeRates = Rate(Se,subset(intervals{5},LastThirdPresleepREM));

PresleepFirstThirdUPsList = find(Start(UPStateMetaData.UPInts)>=Start(PrePostSleepMetaData.presleepInt) & End(UPStateMetaData.UPInts)<=EndFirstThirdPresleep);
% PresleepFirstSWSUPs = intersect(UPStateMetaData.UPInts,subset(intervals{3},PrePostSleepMetaData.presleepSWSlist(1:3)));
FirstThirdPresleepSWSUPStateESpikeRates = Rate(Se,subset(UPStateMetaData.UPInts,PresleepFirstThirdUPsList));
FirstThirdPresleepSWSUPStateISpikeRates = Rate(Si,subset(UPStateMetaData.UPInts,PresleepFirstThirdUPsList));
PresleepLastThirdUPsList = find(Start(UPStateMetaData.UPInts)>=StartLastThirdPresleep & End(UPStateMetaData.UPInts)<=End(PrePostSleepMetaData.presleepInt));
% PresleepLastSWSUPs = intersect(UPStateMetaData.UPInts,subset(intervals{3},PrePostSleepMetaData.presleepSWSlist(end-3:end)));
LastThirdPresleepSWSUPStateESpikeRates = Rate(Se,subset(UPStateMetaData.UPInts,PresleepLastThirdUPsList));
LastThirdPresleepSWSUPStateISpikeRates = Rate(Si,subset(UPStateMetaData.UPInts,PresleepLastThirdUPsList));

h = SpikingAnalysis_PlotRateDistributionsLinearAndLog(PrePresleepWakingESpikeRates,PostPresleepWakingESpikeRates);
    subplot(2,2,1)
    title('E:PPre-Presleep Waking')
    subplot(2,2,2)
    title('E:Post-Presleep Waking')
    set(h,'name',[basename,'_ECellSpikeHisto-PreVsPostPresleepWaking'])
h = SpikingAnalysis_PlotRateDistributionsLinearAndLog(PrePresleepWakingISpikeRates,PostPresleepWakingISpikeRates);
    subplot(2,2,1)
    title('I:PPre-Presleep Waking')
    subplot(2,2,2)
    title('I:Post-Presleep Waking')
    set(h,'name',[basename,'_ICellSpikeHisto-PreVsPostPresleepWaking'])
% h = SpikingAnalysis_PlotRateDistributionsLinearAndLog(FirstPresleepREMESpikeRates,LastPresleepREMESpikeRates);
%     subplot(2,1,1)
%     title('Pre-Presleep Waking')
%     subplot(2,1,2)
%     title('Post-Presleep Waking')
%     set(h,'name',[basename,'_CellSpikeHisto-PreVsPostPresleepWaking'])
h = SpikingAnalysis_PlotRateDistributionsLinearAndLog(FirstThirdPresleepSWSUPStateESpikeRates,LastThirdPresleepSWSUPStateESpikeRates);
    subplot(2,2,1)
    title('E:Presleep 1st 1/3 SWS UP Rates')
    subplot(2,2,2)
    title('E:Presleep 1st 1/3 SWS UP Rates')
    set(h,'name',[basename,'_ECellSpikeHisto-FirstVsLastThirdPresleepSWS'])
h = SpikingAnalysis_PlotRateDistributionsLinearAndLog(FirstThirdPresleepSWSUPStateISpikeRates,LastThirdPresleepSWSUPStateISpikeRates);
    subplot(2,2,1)
    title('I:Presleep 1st 1/3 SWS UP Rates')
    subplot(2,2,2)
    title('I:Presleep 1st 1/3 SWS UP Rates')
    set(h,'name',[basename,'_ICellSpikeHisto-FirstVsLastThirdPresleepSWS'])

%save figs
if ~exist(fullfile(basepath,'CellRateDistributionFigs'),'dir')
    mkdir(fullfile(basepath,'CellRateDistributionFigs'))
end
cd(fullfile(basepath,'CellRateDistributionFigs'))
saveallfigsas('fig')
cd(basepath)
    

%% Cell-by-cell changes in rates over various intervals in various states 
%>(see BWRat20 analysis)
% use above to do simple 2 point plots for each comparison

h = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(PrePresleepWakingESpikeRates,PostPresleepWakingESpikeRates);CellRateVariables
subplot(1,2,1)
title('E:Pre-Presleep Waking vs Post-Presleep Waking Per cell')
subplot(1,2,2)
title('Log scale')
set(h,'name',[basename,'_ECellByCellRateChanges-PreVsPostPresleepWaking'])
h = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(PrePresleepWakingISpikeRates,PostPresleepWakingISpikeRates);
subplot(1,2,1)
title('I:Pre-Presleep Waking vs Post-Presleep Waking Per cell')
subplot(1,2,2)
title('Log scale')http://klusters.sourceforge.net/howto.html

set(h,'name',[basename,'_ICellByCellRateChanges-PreVsPostPresleepWaking'])

h = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(FirstThirdPresleepSWSUPStateESpikeRates,LastThirdPresleepSWSUPStateESpikeRates);
subplot(1,2,1)
title('E:First 1/3 SWS UP Rates vs Last 1/3 SWS UP Rates')
subplot(1,2,2)
title('Log scale')
set(h,'name',[basename,'_ECellByCellRateChanges-FirstVsLastThirdPresleepSWS'])
h = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(FirstThirdPresleepSWSUPStateISpikeRates,LastThirdPresleepSWSUPStateISpikeRates);
subplot(1,2,1)
title('I:First 1/3 SWS UP Rates vs Last 1/3 SWS UP Rates')
subplot(1,2,2)
title('Log scale')
set(h,'name',[basename,'_ICellByCellRateChanges-FirstVsLastThirdPresleepSWS'])
http://klusters.sourceforge.net/howto.html

%looking at percent changes per cell
ECellPercentChangesPreWakeVsPostWake = (PostPresleepWakingESpikeRates-PrePresleepWakingESpikeRates)./PrePreCellRateVariablessleepWakingESpikeRates;
ICellPercentChangesPreWakeVsPostWake = (PostPresleepWakingISpikeRates-PrePresleepWakingISpikeRates)./PrePresleepWakingISpikeRates;
ECellAbsoluteChangesPreWakeVsPostWake = (PostPresleepWakingESpikeRates-PrePresleepWakingESpikeRates);
ICellAbsoluteChangesPreWakeVsPostWake = (PostPresleepWakingISpikeRates-PrePresleepWakingISpikeRates);

ECellPercentChangesFirstLastThirdSWS = (LastThirdPresleepSWSUPStateESpikeRates-FirstThirdPresleepSWSUPStateESpikeRates)./FirstThirdPresleepSWSUPStateESpikeRates;
ICellPercentChangesFirstLastThirdSWS = (LastThirdPresleepSWSUPStateISpikeRates-FirstThirdPresleepSWSUPStateISpikeRates)./FirstThirdPresleepSWSUPStateISpikeRates;
ECellAbsoluteChangesFirstLastThirdSWS = (LastThirdPresleepSWSUPStateESpikeRates-FirstThirdPresleepSWSUPStateESpikeRates);
ICellAbsoluteChangesFirstLastThirdSWS = (LastThirdPresleepSWSUPStateISpikeRates-FirstThirdPresleepSWSUPStateISpikeRates);

%histograms of those percent changes
h=figure;
hist(ECellPercentChangesPreWakeVsPostWake,50)
title('Histogram of E cell Percent Rate changes from: Wake before to After presleep')
set(h,'name',[basename,'_HistoOfECellRateChanges-PreVsPostPresleepWaking'])
h=figure;
hist(ICellPercentChangesPreWakeVsPostWake,50)
title('Histogram of I cell Percent Rate changes from: Wake before to After presleep')
set(h,'name',[basename,'_HistoOfICellRateChanges-PreVsPostPresleepWaking'])

h=figure;
hist(ECellPercentChangesFirstLastThirdSWS,50)
title('Histogram of E cell Percent Rate changes from: First 1/3 sleep  to Last 1/3 sleep')
set(h,'name',[basename,'_HistoOfECellRateChanges-FirstVsLastThirdPresleepSWS'])
h=figure;
hist(ICellPercentChangesFirstLastThirdSWS,50)
title('Histogram of I cell Percent Rate changes from: First 1/3 sleep  to Last 1/3 sleep')CellRateVariables
set(h,'name',[basename,'_HistoOfICellRateChanges-FirstVsLastThirdPresleepSWS'])

%percent change in relation to intial spike ratehttp://klusters.sourceforge.net/howto.html

h=figure;
subplot(2,1,1);
x = PrePresleepWakingESpikeRates;
y = ECellPercentChangesPreWakeVsPostWake;
plot(x,y,'marker','.','Line','none');
[yfit,r2] =  RegressAndFindR2(x,y,1)
hold on;plot(x,yfit,'r')
text(0.8*max(x),0.8*max(y),['r2=',num2str(r2)])
title('ECells Percent change in spike rate in pre vs post wake VS initial spike rate')
subplot(2,1,2);
x = FirstThirdPresleepSWSUPStateESpikeRates;
y = ECellPercentChangesFirstLastThirdSWS;
plot(x,y,'marker','.','Line','none');
[yfit,r2] =  RegressAndFindR2(x,y,1)
hold on;plot(x,yfit,'r')
text(0.8*max(x),0.8*max(y),['r2=',num2str(r2)])
title('Ecells: Change in spike rate in early vs late SWS in presleep VS initial spike rate')
set(h,'name',[basename,'_ChangeVsInitialRate-Ecells'])CellRateVariables

h=figure;
subplot(2,1,1);
x = PrePresleepWakingISpikeRates;
y = ICellPercentChangesPreWakeVsPostWake;
plot(x,y,'marker','.','Line','none');
[yfit,r2] =  RegressAndFindR2(x,y,1)
hold on;plot(x,yfit,'r')
text(0.8*max(x),0.8*max(y),['r2=',num2str(r2)])
title('ICells Percent change in spike rate in pre vs post wake VS initial spike rate')
subplot(2,1,2);
x = FirstThirdPresleepSWSUPStateISpikeRates;
y = ICellPercentChangesFirstLastThirdSWS;
plot(x,y,'marker','.','Line','none');
[yfit,r2] =  RegressAndFindR2(x,y,1)http://klusters.sourceforge.net/howto.html

hold on;plot(x,yfit,'r')
text(0.8*max(x),0.8*max(y),['r2=',num2str(r2)])
title('Icells: Change in spike rate in early vs late SWS in presleep VS initial spike rate')
set(h,'name',[basename,'_ChangeVsInitialRate-Icells'])

%save figs
if ~exist(fullfile(basepath,'CellRateDistributionFigs'),'dir')
    mkdir(fullfile(basepath,'CellRateDistributionFigs'))
end
cd(fullfile(basepath,'CellRateDistributionFigs'))
saveallfigsas('fig')
cd(basepath)

%saving neatening and arranging data for later
CellRateVariables = v2struct(AllESpikeRates,AllISpikeRates,...
    WakingESpikeRates, WakingISpikeRates,...
    UPStateESpikeRates,UPStateISpikeRates,...
    REMESpikeRates,REMISpikeRates,...
    PrePresleepWakingESpikeRates,PrePresleepWakingISpikeRates,...
    PostPresleepWakingESpikeRates,PostPresleepWakingISpikeRates,...
    FirstThirdPresleepSWSUPStateESpikeRates,FirstThirdPresleepSWSUPStateISpikeRates,...
    LastThirdPresleepSWSUPStateESpikeRates,LastThirdPresleepSWSUPStateISpikeRates,...
    ECellPercentChangesPreWakeVsPostWake, ICellPercentChangesPreWakeVsPostWake,...
    ECellAbsoluteChangesPreWakeVsPostWake, ICellAbsoluteChangesPreWakeVsPostWake,...
    ECellPercentChangesFirstLastThirdSWS, ICellPercentChangesFirstLastThirdSWS,...
    ECellAbsoluteChangesFirstLastThirdSWS, ICellAbsoluteChangesFirstLastThirdSWS);

PrePostSleepMetaData.PreSleepUPs = PreSleepUPs;
PrePostSleepMetaData.PresleepFirstThirdUPsList = PresleepFirstThirdUPsList;
PrePostSleepMetaData.PresleepLastThirdUPsList = PresleepLastThirdUPsList;
PrePostSleepMetaData.PrepresleepWakes = prepresleepWakes;
PrePostSleepMetaData.PostpresleepWakes = postpresleepWakes;

save([basename '_CellRateVariables.mat'],'CellRateVariables')
save([basename '_PrePostSleepMetaData.mat'],'PrePostSleepMetaData')

clear AllESpikeRates AllISpikeRates ...
    WakingESpikeRates WakingISpikeRates ...
    UPStateESpikeRates UPStateISpikeRates ...http://klusters.sourceforge.net/howto.html

    REMESpikeRates REMISpikeRates ...
    PrePresleepWakingESpikeRates PrePresleepWakingISpikeRates ...
    PostPresleepWakingESpikeRates PostPresleepWakingISpikeRates ...
    FirstThirdPresleepSWSUPStateESpikeRates irstThirdPresleepSWSUPStateISpikeRates ...
    LastThirdPresleepSWSUPStateESpikeRates LastThirdPresleepSWSUPStateISpikeRates ...
    ECellPercentChangesPreWakeVsPostWake ICellPercentChangesPreWakeVsPostWake ...
    ECellAbsoluteChangesPreWakeVsPostWake ICellAbsoluteChangesPreWakeVsPostWake ...
    ECellPercentChangesFirstLastThirdSWS ICellPercentChangesFirstLastThirdSWS ...
    ECellAbsoluteChangesFirstLastThirdSWS ICellAbsoluteChangesFirstLastThirdSWS ...
    PreSleepUPs PresleepFirstThirdUPsList PresleepFirstThirdUPsList ...
    prepresleepWakes postpresleepWakes


% load([basename '_CellRateVariables.mat'])
% load([basename '_PrePostSleepMetaData.mat'])

%% Looking at rate changes over SWS-REM-SWS episodes deteced earlier (SRSEpisodes);
% Get necessary triplet episodes... see function below for details
SRSEpisodesPreSleepAndres = GetTripletSleepEpisodes(intervals,50,100,30,30,PrePostSleepMetaData.presleepInt);
SRSEpisodesPreSleepBW = GetTripletSleepEpisodes(intervals,30,50,30,30,PrePostSleepMetaData.presleepInt);

SRSEpisodesPostSleepAndres = GetTripletSleepEpisodes(intervals,50,100,30,30,PrePostSleepMetaData.postsleepInt);
SRSEpisodesPostSleepBW = GetTripletSleepEpisodes(intervals,30,50,30,30,PrePostSleepMetaData.postsleepInt);

%assess E in pre-sleep using BW detection of S-R-S episodes
h = figure;
SRSEpisodePreleepERatesBW = SpikingAnalysis_TripletEpisodePlotting(SRSEpisodesPreSleepBW,Se);
title({[basename '-SWSREMSWS-PreSleep-ERateChanges-BWLenientDetection'];...
    ['n=' num2str(size(SRSEpisodesPreSleepBW,2)) ' Episodes']})
set(h,'name',[basename '-SWSREMSWSPresleep-ERateChanges-BWLenientDetection'])
%assess I in pre-sleep using BW detection of S-R-S episodes
h = figure;
SRSEpisodePreleepIRatesBW = SpikingAnalysis_TripletEpisodePlotting(SRSEpisodesPreSleepBW,Si);
title({[basename '-SWSREMSWS-PreSleep-IRateChanges-BWLenientDetection'];...
    ['n=' num2str(size(SRSEpisodesPreSleepBW,2)) ' Episodes']})
set(h,'name',[basename '-SWSREMSWSPresleep-IRateChanges-BWLenientDetection'])

%assess E in pre-sleep using Andres detection
h = figure;
SRSEpisodePresleepERatesAndres = SpikingAnalysis_TripletEpisodePlotting(SRSEpisodesPreSleepAndres,Se);
title({[basename '-SWSREMSWS-Preleep-ERateChanges-AndresDetection'];...
    ['n=' num2str(size(SRSEpisodesPreSleepAndres,2)) ' Episodes']})
set(h,'name',[basename '-SWSREMSWSPresleep-ERateChanges-AndresDetection'])
%assess I in pre-sleep using Andres detection
h = figure;
SRSEpisodePresleepIRatesAndres = SpikingAnalysis_TripletEpisodePlotting(SRSEpisodesPreSleepAndres,Si);
title({[basename '-SWSREMSWS-Preleep-IRateChanges-AndresDetection'];...
    ['n=' num2str(size(SRSEpisodesPreSleepAndres,2)) ' Episodes']})
set(h,'name',[basename '-SWSREMSWSPresleep-IRateChanges-AndresDetection'])

%assess E in post-sleep using BW detection of S-R-S episodes
h = figure;
SRSEpisodePostsleepERatesBW = SpikingAnalysis_TripletEpisodePlotting(SRSEpisodesPostSleepBW,Se);
title({[basename '-SWSREMSWS-PostSleep-ERateChanges-BWLenientDetection'];...
    ['n=' num2str(size(SRSEpisodesPostSleepBW,2)) ' Episodes']})
set(h,'name',[basename '-SWSREMSWSPostsleep-ERateChanges-BWLenientDetection'])
%assess I in post-sleep using BW detection of S-R-S episodes
h = figure;
SRSEpisodePostsleepIRatesBW = SpikingAnalysis_TripletEpisodePlotting(SRSEpisodesPostSleepBW,Si);
title({[basename '-SWSREMSWS-PostSleep-IRateChanges-BWLenientDetection'];...
    ['n=' num2str(size(SRSEpisodesPostSleepBW,2)) ' Episodes']})
set(h,'name',[basename '-SWSREMSWSPostsleep-IRateChanges-BWLenientDetection'])

%assess E in post-sleep using Andres detection
h = figure;
SRSEpisodePostsleepERatesAndres = SpikingAnalysis_TripletEpisodePlotting(SRSEpisodesPostSleepAndres,Se);
title({[basename '-SWSREMSWS-PostSleep-ERateChanges-AndresDetection'];...
    ['n=' num2str(size(SRSEpisodesPostSleepAndres,2)) ' Episodes']})
set(h,'name',[basename '-SWSREMSWSPostsleep-ERateChanges-AndresDetection'])
%assess I in post-sleep using Andres detection
h = figure;
SRSEpisodePostsleepIRatesAndres = SpikingAnalysis_TripletEpisodePlotting(SRSEpisodesPostSleepAndres,Si);
title({[basename '-SWSREMSWS-PostSleep-IRateChanges-AndresDetection'];...
    ['n=' num2str(size(SRSEpisodesPostSleepAndres,2)) ' Episodes']})
set(h,'name',[basename '-SWSREMSWSPostsleep-IRateChanges-AndresDetection'])


%save figs
if ~exist(fullfile(basepath,'SWSREMSWSFigs'),'dir')
    mkdir(fullfile(basepath,'SWSREMSWSFigs'))
end
cd(fullfile(basepath,'SWSREMSWSFigs'))
saveallfigsas('fig')
cd(basepath)


SWSREMSWSRates = v2struct(SRSEpisodesPreSleepAndres,SRSEpisodesPreSleepBW,...
    SRSEpisodesPostSleepAndres, SRSEpisodesPostSleepBW,...
    

PrePostSleepMetaData.PreSleepUPs = PreSleepUPs;
PrePostSleepMetaData.PresleepFirstThirdUPsList = PresleepFirstThirdUPsList;
PrePostSleepMetaData.PresleepLastThirdUPsList = PresleepLastThirdUPsList;
PrePostSleepMetaData.PrepresleepWakes = prepresleepWakes;
PrePostSleepMetaData.PostpresleepWakes = postpresleepWakes;

save([basename '_CellRateVariables.mat'],'CellRateVariables')
save([basename '_PrePostSleepMetaData.mat'],'PrePostSleepMetaData')




clear preSWSints REMints postSWSints preSWSrates REMrates postSWSrates smax smin


%% Stability Metrics over UP states (?NECESSARY)
% % UPSpikesMDists = Restrict(MahalDistances,UPInts);
% UPMahalDistances = zeros(numUPs,numgoodcells); 
% for a = 1:numUPs
%     thisupdistances = Restrict(MahalDistances,subset(UPInts,a));
%     disp(a)
%     for b = 1:numgoodcells
%         UPMahalDistances(a,b) = mean(Data(thisupdistances{b}));
%     end
% end
% 
% %
% UPSpikeEnergies = zeros(numUPs,numgoodcells); 
% for a = 1:numUPs
%     thisupdistances = Restrict(SpikeEnergies,subset(UPInts,a));
%     disp(a)
%     for b = 1:numgoodcells
%         UPSpikeEnergies(a,b) = mean(Data(thisupdistances{b}));
%     end
% end
%     
%% plot each cell spike rates over upstates,
% '[xtrend,ytrend] = trend(x,y);hold on;plot(xtrend,ytrend,''r'')'];
% titlestring = 'Spike Energy for UP State spikes for each cell, Interneurons in Black';
% ates
% % plot_multiperfigure(CellUPRates,5,5);
% 
% % plot spike by spike energies, with trends
% evalstring = ['if ~ismember(a,varargin{1});set(lineh,''color'',''black'');end;'...,
% '[xtrend,ytrend] = trend(x,y);hold on;plot(xtrend,ytrend,''r'')'];
% titlestring = 'Spike Energy for UP State spikes for each cell, Interneurons in Black';
% plot_multiperfigure(UPSpikeEnergies,6,8,titlestring,evalstring,CellIDs.EAll)
% 
% %plot spike by spike mahal distances, with trends
% titlestring = 'Mahalonobis Distances for UP State spikes for each cell, Interneurons in Black';
% plot_multiperfigure(UPMahalDistances,6,8,titlestring,evalstring,CellIDs.EAll)
% 
% %plot cell spike rates
% titlestring = 'UP State spike rates for each cell, Interneurons in Black';
% evalstring = ['if ~ismember(a,varargin{1});set(lineh,''color'',''black'');end;'];
% % ,...
% %     'y2 = varargin{2}(:,a);x2 = (1:length(y2))'';[xtrend,ytrend] = trend(x2,y2);hold on;plot(xtrend,ytrend,''c'');'...
% %     'y2 = varargin{3}(:,a);x2 = (1:length(y2))'';[xtrend,ytrend] = trend(x2,y2);hold on;plot(xtrend,ytrend,''g'');'...
% %     ];
% plot_multiperfigure(CellUPRates,6,8,titlestring,evalstring,CellIDs.EAll,UPMahalDistances,UPSpikeEnergies);
% 
% % !>>> New plots of Distances/Energies for ALL spikes per cell with UPs spikes highlighted in a color
% % !>>> Plot with Energies and Mahal distance trendlines (min of trendline at 0) 
% 
% %plot each E cell putting regressions on each
% titlestring = 'Individual excitatory cells spike rates over all UP states';
% evalstring = '[yfit,r2]=RegressAndFindR2(x,y,1);hold on;plot(x,yfit,''r'');text(1000,max(y),num2str(varargin{1}(a)))';%evals on each figure
% 
% plot_multiperfigure(CellUPRates(:,CellIDs.EAll),5,8,titlestring,evalstring,CellIDs.EAll);
% 
% %plot each I cell
% plot_multiperfigure(CellUPRates(:,CellIDs.IAll),5,5,titlestring,evalstring,CellIDs.IAll);
% 
% 
% 
% clear titlestring evalstring
% 
% 

% %% Pull out spike rates in chunks of 1/3 of each session... may not work yet
% 
% for a=1:length(StateIntervals);%for each state type (ie waking, rem, SWS etc)
%     numintervals = size(length(StateIntervals{a}));
%     if prod(numintervals>0) %if there are any of that state
%         numintervals = numintervals(1);
%         for b = 1:numintervals%go through each invididual instance of that state class
%             thirds = regIntervals(subset(StateIntervals{a},b),3);%divide intervals into thirds for analysis
%             FirstThirdIntervals{a}{b} = thirds{1};%store thirds
%             MiddleThirdIntervals{a}{b} = thirds{2};
%             LastThirdIntervals{a}{b} = thirds{3};
% 
%             FirstThirdSpiking{a,b} = Restrict(S,thirds{1});%tsdarrays for all cells
%             FirstThirdRates{a}(:,b) = Rate(FirstThirdSpiking{a,b});%spike rates over each cell
%             
%             MiddleThirdSpiking{a,b} = Restrict(S,thirds{2});%tsdarrays for all cells
%             MiddleThirdRates{a}(:,b) = Rate(MiddleThirdSpiking{a,b});%spike rates over each cell
%             
%             LastThirdSpiking{a,b} = Restrict(S,thirds{2});%tsdarrays for all cells
%             LastThirdRates{a}(:,b) = Rate(LastThirdSpiking{a,b});%spike rates over each cell
%         end
%     end
% end
% 
% SWSEpisodePercentChanges = LastThirdRates{3}./FirstThirdRates{3};
% 
% SWSMeanFirstThirdRates = mean(FirstThirdRates{3},2);
% SWSMeanLastThirdRates = mean(LastThirdRates{3},2);
% SWSPercentMeanChanges = SWSMeanLastThirdRates./SWSMeanFirstThirdRates;
% 
% 
% 
% REMMeanFirstThirdRates = mean(FirstThirdRates{5},2);
% REMMeanLastThirdRates = mean(LastThirdRates{5},2);
% REMPercentChanges = REMMeanLastThirdRates./REMMeanFirstThirdRates;
% 

%% When CCGjitter completes, plot results
CCG_jitter_plotpositives(ccgjitteroutput,0)
CCG_jitter_plotzerolag(ccgjitteroutput)

%save figs
if ~exist(fullfile(basepath,'CCGJitterFigs'),'dir')
    mkdir(fullfile(basepath,'CCGJitterFigs'))
end
cd(fullfile(basepath,'CCGJitterFigs'))
saveallfigsas('fig')
cd(basepath)


%% Find assemblies
%bin at 100ms

% binnedEachCell = MakeQfromS(S,1000);%bin every 1000pts, which is 100msec (10000 pts per sec)
% binnedTrains.All = sum(Data(binnedEachCell),2)';
numgoodcells = size(binnedEachCellData,1);
%figure; imagesc(binnedEachCellData)%% When CCGjitter completes, plot results
CCG_jitter_plotpositives(ccgjitteroutput,individualplot)
CCG_jitter_plotzerolag(ccgjitteroutput)

%save figs
if ~exist(fullfile(basepath,'CCGJitterFigs'),'dir')
    mkdir(fullfile(basepath,'CCGJitterFigs'))
end
cd(fullfile(basepath,'CCGJitterFigs'))
saveallfigsas('fig')
cd(basepath)
 %view basic binned spiking like this


% Find assembly patterns
opts.threshold.method = 'MarcenkoPastur';
opts.Patterns.method = 'ICA'
opts.Patterns.number_of_iterations = 1000;
[Patterns,Threshold] = assembly_patterns_bw(binnedEachCellData,opts)

% Find and label neurons with significant contributions on to assemblies
[cellnum,assemblynum]=find(abs(Patterns)>Threshold);%find cell,assembly ID's of contributions with abs>Threshold
% shigecellnum = cellinds(cellnum,2);%convert back to shige's number system


% Plot Assembly PatternsPrep for all but final analysis BWRat19... anticipate  

maxproj = max(Patterns(:));%get the max projection of any initial variable onto any PC
minproj = min(Patterns(:));%get the min
numassemblies = size(Patterns,2);

[v,h]=determinenumsubplots(numassemblies);

%Stem plots of assemblies
figure;
for a = 1:numassemblies
    subplot(v,h,a);
    hold on
        stem(Patterns(:,a));
        plot([1 numgoodcells],[Threshold Threshold],'r')
        plot([1 numgoodcells],[-Threshold -Threshold],'r')
        xlim([1 numgoodcells])
        ylim([minproj maxproj])
        title(['Assembly ',num2str(a)])
        signifassemblycellinds = find(assemblynum==a);
        for b = 1:length(signifassemblycellinds)
            x = cellnum(signifassembl%% When CCGjitter completes, plot results
CCG_jitter_plotpositives(ccgjitteroutput,individualplot)
CCG_jitter_plotzerolag(ccgjitteroutput)

%save figs
if ~exist(fullfile(basepath,'CCGJitterFigs'),'dir')
    mkdir(fullfile(basepath,'CCGJitterFigs'))
end
cd(fullfile(basepath,'CCGJitterFigs'))
saveallfigsas('fig')
cd(basepath)
ycellinds(b));
            y = Patterns(cellnum(signifassemblycellinds(b)),a);
            textstr = num2str(signifassemblycellinds(b));Prep for all but final analysis BWRat19... anticipate  

            text(x+1,y,textstr)
        end
end
% >> highlight connected cells in green or red


% Get activity of each assembly
AssemblyActivities = assembly_activity(Patterns,binnedEachCellData);
SumAssemblyActivities = sum(abs(AssemblyActivities),1);

% Plot activity of each assembly
figure 
subplot(3,1,1) 
imagesc(binnedEachCellData)
xlim([1 size(AssemblyActivities,2)])

subplot(3,1,2) 
hold on;
plot(SumAssemblyActivities,'k')
plot(AssemblyActivities')
xlim([1 size(AssemblyActivities,2)])
title('Activities of assemblies found by PCA: Erepmat(sum(ccg,1),size(ccg,1),1)ach color is 1 assembly, Black is sum of all others')

subplot(3,1,3)
hold on
plot(binnedTrains.All,'k')
plot(binnedTrains.EAll,'g')
plot(binnedTrains.IAll,'r')
toplot = [Start(StateIntervals{5}) End(StateIntervals{5})]'/100000;%scale down based on binning
plot(toplot,5+ones(size(toplot)),'color','m','LineWidth',5)
toplot = [Start(StateIntervals{3}) End(StateIntervals{3})]'/100000;%scale down based on binning
plot(toplot,5+ones(size(toplot)),'color','c','LineWidth',5)
toplot = [Start(StateIntervals{1}) End(StateIntervals{1})]'/100000;%scale down based on binning
plot(toplot,5+ones(size(toplot)),'col%% When CCGjitter completes, plot results
CCG_jitter_plotpositives(ccgjitteroutput,individualplot)
CCG_jitter_plotzerolag(ccgjitteroutput)

%save figs
if ~exist(fullfile(basepath,'CCGJitterFigs'),'dir')
    mkdir(fullfile(basepath,'CCGJitterFigs'))
end
cd(fullfile(basepath,'CCGJitterFigs'))
saveallfigsas('fig')
cd(basepath)
or','k','LineWidth',5)

xlim([1 size(binnedTrains.All,2)])
title({['Spikes from All cells (black), all ECells (green) and all ICells (red)'];['Bottom state indicator: Dark blue-wake, Cyan-SWS, Magenta-REM']})


% for a = 1:numassemblies;
%     legendstr{a} = num2str(a);
% end
% legend(legendstr,'Location','NorthEastOutside')
%>>> Find a way to separate these, plot them with spiking
%normalize by spiking
%plot states color coded with spikes


%% Synaptic strength analysis
% for a = 1:size(S,1); 
%     individCellsSpikes{a} = Data(S{a})';%get spike times, concat into a vector with times of all other spikes from other clusters/cells
% end

oldpath = addpath('/home/brendon/Dropbox/MATLABwork/BuzLabOthersWork/FMAToolbox/Analyses/');

%% make sure the reference cell is presynaptic if normalizing by reference
[ccg,x,y] = ShortTimeCCG_bw(Data(S{34})/10000,Data(S{32})/10000,'binsize',0.001,'duration',0.060,'window',60,'overlap',0.5);
figure;
PlotShortTimeCCG(ccg,'x',x,'y',y)
title('Not normalized')
hold on;
toplot = [Start(StateIntervals{5}) End(StateIntervals{5})]'/10000;%scale down based on binning
plot(toplot,5+ones(size(toplot)),'color','m','LineWidth',5)
toplot = [Start(StateIntervals{3}) End(StateIntervals{3})]'/10000;%scale down based on binning
plot(toplot,5+ones(size(toplot)),'color','c','LineWidth',5)
toplot = [Start(StateIntervals{1}) End(StateIntervals{1})]'/10000;%scale down based on binning
plot(toplot,5+ones(size(toplot)),'color','k','LineWidth',5)

[ccg,x,y] = ShortTimeCCG_bw(Data(S{34})/10000,Data(S{32})/10000,'binsize',0.001,'duration',0.060,'window',60,'overlap',0.5,'mode','norm');
figure;
PlotShortTimeCCG(ccg,'x',x,'y',y)
title('Normalization by Total CCG count per time bin')
hold on;
toplot = [Start(StateIntervals{5}) End(StateIntervals{5})]'/10000;%scale down based on binning
plot(toplot,5+ones(size(toplot)),'color','m','LineWidth',5)
toplot = [Start(StateIntervals{3}) End(StateIntervals{3})]'/10000;%scale down based on binning
plot(toplot,5+ones(size(toplot)),'color','c','LineWidth',5)
toplot = [Start(StateIntervals{1}) End(StateIntervals{1})]'/10000;%scale down based on binning
plot(toplot,5+ones(size(toplot)),'color','k','LineWidth',5)

[ccg,x,y] = ShortTimeCCG_bw(Data(S{34})/10000,Data(S{32})/10000,'binsize',0.001,'duration',0.060,'window',60,'overlap',0.5,'mode','normbyreferencecell');
figure;
PlotShortTimeCCG(ccg,'x',x,'y',y)
title('Normalization by Reference Cell spikes per time bin')
hold on;
toplot = [Start(StateIntervals{5}) End(StateIntervals{5})]'/10000;%scale down based on binning
plot(toplot,5+ones(size(toplot)),'color','m','LineWidth',5)
toplot = [Start(StateIntervals{3}) End(StateIntervals{3})]'/10000;%scale down based on binning
plot(toplot,5+ones(size(toplot)),'color','c','LineWidth',5)
toplot = [Start(StateIntervals{1}) End(StateIntervals{1})]'/10000;%scale down based on binning
plot(toplot,5+ones(size(toplot)),'color','k','LineWidth',5)

path(oldpath);


