
%% OVERALL DATA ANALYSIS SCRIPT APRIL 2014.
%% Assumes you've already created and run a "_Header" script for any given recording in order to create a basename_BasicMetaData.mat.
%% Assumes matlab is pointed at the homefolder for that recording and step 1 will be to load the _BasicMetaData.mat
%% See below for an example Header
%% USE: Note, if "load" command is at the end of a section then executing that load can subsitute for the entire section (if the data has already been stored to disk)

%% Example Header
% basename = 'BWRat19_032413';
% basepath = ['/mnt/brendon4/BWRat19/' basename '_Supradir/' basename '/'];
% cd (basepath)
% Par = LoadPar([basename '.xml']);
% goodshanks = [2,3,4,5,6];
% goodeegchannel = 26; %For UP State detection
% presleepstartstop = [0 4543];%rough manual entry, in seconds
% postsleepstartstop = [9577 Inf];%rough manual entry, in seconds
% 
% save([basename '_BasicMetaData.mat'],'basename','basepath','Par','goodshanks');

%% Load basic recording info
load([basename '_BasicMetaData.mat']);

%% Load Spikes
%%NOTE ON THIS DATASET:
% shank1 unstable at start of recording, where presleep is.  
% shanks 7-14 from CEA not stable (and not cortical)
[S,shank,cellIx] = LoadSpikeData(basename,goodshanks);
save([basename,'_SAll.mat'],'S','shank','cellIx')

%load([basename,'_SAll.mat'])

%% Look at cellular stability using Mahalanobis distances and total spike energies
% [SpikeEnergiesCell,MahalDistancesCell] = AllCellsEnergyMahalPerSpike(S,shank,cellIx,basename);
[SpikeEnergiesCell,SelfMahalDistancesCell,LRatios,IsoDistances,ISIIndices] = ClusterQualityMetrics(S,shank,cellIx,basename);

% MahalDistances = AllCellsMahalPerSpike(S,shank,cellIx,basename);
for a = 1:size(S,1);
    numspikes = length(S{a});

    SelfMahalDistances{a,1} = tsd(TimePoints(S{a}),SelfMahalDistancesCell{a});
    StartDistances(a) = mean(SelfMahalDistancesCell{a}(1:round(numspikes*.2)));
    EndDistances(a) = mean(SelfMahalDistancesCell{a}((round(numspikes*.8)+1):end));
    SelfMahalDistanceChanges(a) = (EndDistances(a)-StartDistances(a))/StartDistances(a);
    
    SpikeEnergies{a,1} = tsd(TimePoints(S{a}),SpikeEnergiesCell{a});
%     SmoothedSpikeEnergies{a} = smooth(SpikeEnergiesCell{a},500);
    StartEnergies(a) = mean(SpikeEnergiesCell{a}(1:round(numspikes*.2)));
    EndEnergies(a) = mean(SpikeEnergiesCell{a}((round(numspikes*.8)+1):end));
    SpikeEnergyChanges(a) = (EndEnergies(a)-StartEnergies(a))/StartEnergies(a);
end
SelfMahalDistances = tsdArray(SelfMahalDistances);%now have a TSD array of spike distances
SpikeEnergies = tsdArray(SpikeEnergies);

autobadcells = find(abs(SpikeEnergyChanges)>0.3 | abs(SelfMahalDistanceChanges)>0.3);
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
plot_multiperfigure(SelfMahalDistances,5,5,titlestring,fignamestring,evalstring,SelfMahalDistanceChanges,allbadcells)
% Par = LoadPar([basename '.xml']);
evalstring = ['if ismember(a,varargin{2});set(lineh,''color'',''black'');end;'...
    '[xtrend,ytrend] = trend(x,y);hold on;plot(xtrend,ytrend,''r'');',...
    'text(max(x)/10,max(y),[num2str(a),'': '',num2str(varargin{1}(a))])'];
titlestring = 'Spike Energies for each spike for each cell.  Eliminated cells in black';
fignamestring = 'SpikeEnergy';
plot_multiperfigure(SpikeEnergies,5,5,titlestring,fignamestring,evalstring,SpikeEnergyChanges,allbadcells)


titlestring = 'L Ratio for each cell.  First point for whole span, Next 4 points are for each quadrant.  Population mean in red.';
fignamestring = [basename 'LRatios'];
evalstring = ['m = mean(data(1,:));hold on; plot([1 5],[m m],''r'');text(1.25,min([m y(1)])+.5*(max([m y(1)])-min([m y(1)])),num2str(a))'];
plot_multiperfigure(LRatios',5,5,titlestring,fignamestring,evalstring);
% LRatio is the average chance per spike NOT in the cluster that it might
% be in the cluster... as measured by 1-distance from center the cluster (actually from of an
% approximation of the cluster).  <~0.75 is good
% N. SCHMITZER-TORBERT et al 2005

titlestring = 'Isolation Distance for each cell.  First point for whole span, Next 4 points are for each quadrant.  Population mean in red.';
fignamestring = [basename 'IsoDistances'];
evalstring = ['m = mean(data(1,:));hold on; plot([1 5],[m m],''r'');text(1.25,min([m y(1)])+.5*(max([m y(1)])-min([m y(1)])),num2str(a))'];
plot_multiperfigure(IsoDistances',5,5,titlestring,fignamestring,evalstring);
%"Isolation Distance is therefore the radius in Mahalanobis distance
%of the smallest ellipsoid from the cluster center containing a number of
%noise spikes equal to the number of cluster spikes.  ~10+ is good
% N. SCHMITZER-TORBERT et al 2005

titlestring = 'ISIIndex for each cell.  First point for whole span, Next 4 points are for each quadrant.  Population mean in red.';
fignamestring = [basename 'ISIIndices'];
evalstring = ['m = mean(data(1,:));hold on; plot([1 5],[m m],''r'');text(1.25,min([m y(1)])+.5*(max([m y(1)])-min([m y(1)])),num2str(a))'];
plot_multiperfigure(ISIIndices',5,5,titlestring,fignamestring,evalstring);
%ISIIndex measures "clean-ness" of the refractory period (2ms) by measuring spikes
%there over avg spikes overall (ie 0.1 means 90% spike reduction during
%refract period)
%Fee 1996

%save figs
if ~exist(fullfile(basepath,'CellQualityFigs'),'dir')
    mkdir(fullfile(basepath,'CellQualityFigs'))
end
cd(fullfile(basepath,'CellQualityFigs'))
saveallfigsas('fig')
cd(basepath)

%putting quality metrics away neatly
ClusterQualityMeasures = v2struct(SelfMahalDistances,SelfMahalDistancesCell,...
    SelfMahalDistanceChanges,StartDistances,EndDistances,...
    SpikeEnergies,SpikeEnergiesCell,SpikeEnergyChanges,StartEnergies,...
    EndEnergies,...
    LRatios,IsoDistances,ISIIndices,...%putting quality metrics away neatly
    bwbadcells,autobadcells,allbadcells);

%cleaning up
clear MahalDistances SelfDistancesCell MahalDistanceChanges StartDistances...
    EndDistances...
    SpikeEnergies SpikeEnergiesCell SpikeEnergyChanges StartEnergies...
    EndEnergies...
    LRatios IsoDistances ISIIndices...
    bwbadcells autobadcells allbadcells...
    a s2 numspikes titlestring evalstring

save([basename '_ClusterQualityMeasures'],'ClusterQualityMeasures')
% load([basename,'_SStable.mat'])
% load([basename '_ClusterQualityMeasures'])


%% Get connectivity

funcsynapses = FindSynapseWrapper(S,shank,cellIx);

% ccgjitteroutput = CCG_jitter_all(S);%>>> USED 1000 shuffs, 30 halfbins and 3ms jitter
% if exist('ccgjitteroutput.mat','file')
%     movefile('ccgjitteroutput.mat',[basename,'_ccgjitteroutput.mat'])%rename since didn't have basename inside ccgjittera_all when called this way
% end
% 
% CCG_jitter_ReviewPositives(ccgjitteroutput,'ccgjitterreviewed')
% save([basename '_ccgjitterreviewed'],'ccgjitterreviewed')
% clear ccgjitteroutput
%>> or do all cells (ie good or bad) and then go in and toss if in allbadcells?
%    - complex
%    - Use ccgjitteroutput = CCG_jitter_all(basename,maybe:goodshanks)

% load([basename,'_ccgjitterreviewed.mat']);


%save wide/zero lag figs
if ~exist(fullfile(basepath,'ZeroLagAndWideFigs'),'dir')
    mkdir(fullfile(basepath,'ZeroLagAndWideFigs'))
end
cd(fullfile(basepath,'ZeroLagAndWideFigs'))
saveallfigsas('fig')
cd(basepath)

save([basename '_funcsynapses'],'funcsynapses')
% load([basename,'_funcsynapses.mat']);

%% For time: Use another matlab to Get spike waveforms
AllSpkWaveform_BW(basename)
load([basename,'_SpikeWavsAll.mat'])

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

%% Classify cells (get raw waveforms first)
% load([basename '_AllSpikeWavs.mat'])

[CellClassOutput, PyrBoundary] = BWCellClassification (basename, SpkWvform_good, SpkWvform_goodidx, 1:numgoodcells, funcsynapses(1).ECells, funcsynapses(1).ICells);

CellIDs.EDefinite = funcsynapses(1).ECells';
CellIDs.IDefinite = funcsynapses(1).ICells';
CellIDs.ELike = find((CellClassOutput(:,4)==1) & (CellClassOutput(:,5)==0));
CellIDs.ILike = find((CellClassOutput(:,4)==-1) & (CellClassOutput(:,5)==0));
CellIDs.EAll = union(CellIDs.EDefinite,CellIDs.ELike);
CellIDs.IAll = union(CellIDs.IDefinite,CellIDs.ILike);
CellClassificationOutput = v2struct(CellClassOutput,PyrBoundary);
save([basename, '_CellIDs.mat'],'CellIDs')
save([basename,'_CellClassificationOutput.mat'],'CellClassificationOutput')

clear CellClassOutput PyrBoundary SpkWvform_good SpkWvform_goodidx

% load([basename, '_CellIDs.mat'])
% load([basename,'_CellClassificationOutput.mat'])

%% Dividing spikes by cell class (based on S variable above)
Se = S(CellIDs.EAll);
SeDef = S(CellIDs.EDefinite);
SeLike = S(CellIDs.ELike);
Si = S(CellIDs.IAll);
SiDef = S(CellIDs.IDefinite);
SiLike = S(CellIDs.ILike);
SRates = Rate(S);
SeRates = Rate(Se);
SiRates = Rate(Si);

%% Sleep score, get and keep intervals
StateEditor(basename)
statefilename = [basename '-states.mat'];
load(statefilename,'states') %gives states, a vector of the state at each second
intervals = ConvertStatesVectorToIntervalSets;

clear statefilename
save([basename '_Intervals'],'intervals')
% load([basename '_Intervals'])

%% Detect UP and Down states
goodeegchannel = 26;
[UPInts, DNInts] = DetectUPAndDOWNInSWS(S,intervals,Par.nChannels,goodeegchannel,basename);
WriteEventFileFromIntervalSet (UPInts,[basename,'.UPS.evt'])
WriteEventFileFromIntervalSet (DNInts,[basename,'.DNS.evt'])
save ([basename '_UPDOWNIntervals.mat'], 'UPInts', 'DNInts','goodeegchannel')

%load([basename,'_UPDOWNIntervals.mat'])

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
binnedTrains.EAll = sum(binnedEachCellData(:,CellIDs.EAll),2)';
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
load([basename '-states.mat'])
AllSpikesForStateEditor = resample(binnedTrains.All,size(states,2),size(binnedTrains.All,2));
save([basename '_StateEditorOverlay_CombinedAllSpikes'],'AllSpikesForStateEditor')

EAllSpikesForStateEditor = resample(binnedTrains.EAll,size(states,2),size(binnedTrains.EAll,2));
save([basename '_StateEditorOverlay_CombinedEAllSpikes'],'EAllSpikesForStateEditor')
IAllSpikesForStateEditor = resample(binnedTrains.IAll,size(states,2),size(binnedTrains.IAll,2));
save([basename '_StateEditorOverlay_CombinedIAllSpikes'],'IAllSpikesForStateEditor')

AllandEAllandIAllSpikesForStateEditor = cat(1,AllSpikesForStateEditor,EAllSpikesForStateEditor,IAllSpikesForStateEditor);
save([basename '_StateEditorOverlay_CombinedI+E+AllSpikes'],'AllandEAllandIAllSpikesForStateEditor')

SpikesForStateEditor = v2struct(AllSpikesForStateEditor,EAllSpikesForStateEditor,IAllSpikesForStateEditor,AllandEAllandIAllSpikesForStateEditor);
clear AllSpikesForStateEditor EAllSpikesForStateEditor IAllSpikesForStateEditor AllandEAllandIAllSpikesForStateEditor states events transitions

%% defining pre-post sleep epochs
PrePostSleepMetaData = PrePostSleepIntervals(presleepstartstop,postsleepstartstop,intervals,UPInts,DNInts);

save([basename '_PrePostSleepMetaData.mat'],'PrePostSleepMetaData')
%load([basename '_PrePostSleepMetaData.mat'])

%% Plotting basic SWS and UP/DOWN state data and spiking
[SWSMeasures, UPMeasures] =  SpikingAnalysis_SWSAndUPPlotting(basename,S,Se,Si,UPInts,DNInts,intervals,PrePostSleepMetaData);

%save figs
if ~exist(fullfile(basepath,'SWSUPStateBasicFigs'),'dir')
    mkdir(fullfile(basepath,'SWSUPStateBasicFigs'))
end
cd(fullfile(basepath,'SWSUPStateBasicFigs'))
saveallfigsas('fig')
cd(basepath)

save([basename '_SWSAndUPMeasures.mat'],'SWSMeasures','UPMeasures')
% load([basename '_UPStateMetaData.mat'])
% load([basename '_SWSAndUPMeasures.mat'])

%% Plotting cell spike rates, rates by state, invididual cell rate changes and population trends
SpikingAnalysis_IndividalCellRatesAnalysesWithSleep  %note this is a script not a function

%% Looking at rate changes over SWS-REM-SWS episodes detected earlier (SRSEpisodes);
SWSREMSWSEpisode_PopRates = SpikingAnalysis_GetTripletEpisodeSpikeRates(basename,basepath,intervals,PrePostSleepMetaData,Se,Si);

save([basename '_SWSREMSWSEpisode_PopRates.mat'],'SWSREMSWSEpisode_PopRates')
%load([basename '_SWSREMSWSEpisode_PopRates.mat'])

%% SpikeTransfer over sleep epochs... using waking before vs after and first/last third of sleep
% >>Raw Transfer in post spikes per prespike
raw = 1;
byratio = 0;
TransferStrengthsOverSleep_Raw = SpikingAnalysis_TransferRatesOverSleep(PrePostSleepMetaData,S,intervals,funcsynapses,basename,basepath,byratio,raw);
save([basename '_TransferStrengthsOverSleep_Raw.mat'],'TransferStrengthsOverSleep')
%load([basename '_TransferStrengthsOverSleep.mat'])

% >>Normalized by ratio to ccg baseline
raw = 0;
byratio = 1;
TransferStrengthsOverSleep_NormByRatio = SpikingAnalysis_TransferRatesOverSleep(PrePostSleepMetaData,S,intervals,funcsynapses,basename,basepath,byratio,raw);
save([basename '_TransferStrengthsOverSleep_NormByRatio.mat'],'TransferStrengthsOverSleep')
%load([basename '_TransferStrengthsOverSleep.mat'])

% >>Normalized by Hz above/below ccg baseline
raw = 0;
byratio = 0;
TransferStrengthsOverSleep_NormByRateChg = SpikingAnalysis_TransferRatesOverSleep(PrePostSleepMetaData,S,intervals,funcsynapses,basename,basepath,byratio,raw);
save([basename '_TransferStrengthsOverSleep_NormByRateChg.mat'],'TransferStrengthsOverSleep')
%load([basename '_TransferStrengthsOverSleep.mat'])


%% Special case of synapses that were zero at start or at end of Sleep - entirely "created" or "destroyed"
%>>?

%% Looking at SpikeTransfer changes over SWS-REM-SWS episodes detected earlier (SRSEpisodes);
SWSREMSWSEpisode_Transfer = SpikingAnalysis_GetTripletEpisodeSpikeTransfers(basename,basepath,intervals,PrePostSleepMetaData,S,funcsynapses);

save([basename '_SWSREMSWSEpisode_Transfer.mat'],'SWSREMSWSEpisode_Transfer')
%load([basename '_SWSREMSWSEpisode_PopRates.mat'])

%% Looking at SpikeTransfer changes over SWS-REM-SWS episodes - normalized to avg per-synapse sterngth
% percell = 0;
% normalize = 1;
% SWSREMSWSEpisode_Transfer = SpikingAnalysis_GetTripletEpisodeSpikeTransfers(basename,basepath,intervals,PrePostSleepMetaData,S,funcsynapses,percell,normalize);
% 
% save([basename '_SWSREMSWSEpisode_Transfer.mat'],'SWSREMSWSEpisode_Transfer')
% %load([basename '_SWSREMSWSEpisode_PopRates.mat'])

%% SpikeTransfer for each cell, normalized vs unnormalized over SWS-REM-SWS
% 4x4 plot: cells un-norm, all 9 points, cells norm all 9, cells unnorm 3
% times, cells norm 3 times


%% Simple distributions of synaptic strengths
% EE vs EI vs IE vs IE in each plot x2 for gaus or not
% REM vs SWS vs AWAKE figures

%% Mean Syn strength per cell vs mean firing rate per same cell


%%
SpikingAnalysis_REMStartStopLockedSpiking(basename,basepath,SWSREMSWSEpisode_PopRates.PostSleepBWEpisodes,S,Se,Si)


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
plot(toplot,5+ones(size(toplot)),'color','g','LineWidth',5)
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


