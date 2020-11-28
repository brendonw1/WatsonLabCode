%% OVERALL DATA ANALYSIS SCRIPT APRIL 2014.
% Assumes you've already created and run a "_Header" script for any given recording in order to create a basename_BasicMetaData.mat.
% Assumes matlab is pointed at the homefolder for that recording and step 1 will be to load the _BasicMetaData.mat
% See below for an example Header
% USE: Note, if "load" command is at the end of a section then executing that load can subsitute for the entire section (if the data has already been stored to disk)

%% get basename and basepath from CD
clear
[basepath,basename,~] = fileparts(cd);
basepath = fullfile(basepath,basename);

%% Review/Create Header
headername = [basename,'_Header.m'];
if ~exist(headername,'file')
    w = which('SpikingAnalysis_Header_ForKetamine.m');% copy an example header here to edit
    copyfile(w,headername);
end
edit(headername)

clear dummy headername w naught

%% Create basic recording info from human-entered header file info
run([basename '_Header.m']);
% load([basename '_BasicMetaData.mat']);

%% Make a file of which anatomical site each channel was in (based on a csv made in gdrive by hand)
ChannelAnatomyFileFromSpikeGroupAnatomy(basename)

% Make subdirectory for each anatomical region
tx = read_mixed_csv([basename '_SpikeGroupAnatomy.csv'],',');
for a = 2:size(tx,1);
    txx{a-1} = tx{a,2};
end
anatregions = unique(txx);
for a = 1:length(anatregions)
    if ~exist([basename,'_',anatregions{a}],'dir')
        mkdir([basename,'_',anatregions{a}])
    end
end

%% Store an interval with start/stop of time with acceptable sleep
% gf = find(RecordingFilesForAnalysis);
% if length(gf) == 1;
%     GoodSleepInterval = subset(RecordingFileIntervals,gf);
% else
%     GoodSleepInterval = subset(RecordingFileIntervals,gf(1));
%     for a = 2:length(gf);
%         GoodSleepInterval = timeSpan(cat(GoodSleepInterval, subset(RecordingFileIntervals,gf(a))));
%     end
% end
% save([basename '_GoodSleepInterval'],'GoodSleepInterval')
% % load([basename '_GoodSleepInterval'])
%% START HERE IF REDUNDANT UNITS HAVE ALREADY BEEN REMOVED
%% Copy Clus from KlustaViewaFiles to Superdirectory
CopySortedClusToSuperdirectory

%% Load Spikes
%%NOTE ON THIS DATASET:
% shank1 unstable at start of recording, where presleep is.  
% shanks 7-14 from CEA not stable (and not cortical)
[S,shank,cellIx] = LoadSpikeData(basename,goodshanks);
save([basename,'_SAll.mat'],'S','shank','cellIx')

%load([basename,'_SAll.mat'])

%% Load Bad Cells from manual basename_ClusteringNotes.csv (if exists)
manualbadcells = BadCellsFromClusteringNotes(basename,shank,cellIx);

%% Look at cellular stability using Mahalanobis distances and total spike energies
SpikingAnalysis_CellStabilityScript
save([basename,'_SStable.mat'],'S','shank','cellIx','numgoodcells','badcells')

% load([basename '_ClusterQualityMeasures'])
% load([basename,'_SStable.mat'])

%% Look at cellular stability using Mahalanobis distances and total spike energies
% % To find indices of bad cells, make correspondence matrix, eg [[1:numunits]' shank
% % cellIx]
% bwbadcells = [1 9 10 11 20 24 25 29 30 34 36 38 40 48 58 62 74 75 77 78];
% SpikingAnalysis_CellStabilityScript

%% Burst Filter to prep for spike transmission
Sbf = burstfilter(S,6);%burst filter at 6ms for looking at connections
save([basename,'_SBurstFiltered.mat'],'Sbf');

%% Get connectivity
funcsynapses = FindSynapseWrapper(Sbf,S,shank,cellIx);

%% If had to delete some clusters and start over... 
% clear ClusterQualityMeasures SelfMahalDistanceChanges SelfMahalDistances SelfMahalDistancesCell UnselectedSpikeTsds badcells
% rmdir('ConnectionFigs/','s')
% %return to START HERE...

%% Pause here to allow for review of funcsynapses figures
% ... they save as they close
save([basename '_funcsynapses'],'funcsynapses')
close all
load([basename,'_funcsynapses.mat']);

%% For time: Use another matlab to Get spike waveforms
% AllSpkWaveform_BW(basename)
% load([basename,'_SpikeWavsAll.mat'])
% 
% good = [];
% for a = 1:length(goodshanks);
%    good = cat(1,good,find(SpkWvform_idx(:,2)==goodshanks(a))); 
% end
% good(ClusterQualityMeasures.allbadcells) = [];
% 
% SpkWvform_good = SpkWvform_all(good,:,:);
% SpkWvform_goodidx = SpkWvform_idx(good,:);
% SpkWvform_goodidx(:,1)=1:numgoodcells;
% 
% save([basename '_SpikeWavsGood.mat'],'SpkWvform_good', 'SpkEWvform_goodidx');
% 
% clear SpkWvform_all SpkWvform_idx good a
% % load([basename '_SpikeWavsGood.mat'])


%% Classify cells (get raw waveforms first)
% load([basename '_AllSpikeWavs.mat'])

[CellClassOutput, PyrBoundary,Waveforms] = BWCellClassification (basename, cellIx, shank, funcsynapses(1).ECells, funcsynapses(1).ICells);
% [CellClassOutput, PyrBoundary] = BWCellClassification (basename, SpkWvform_good, SpkWvform_goodidx, 1:numgoodcells, funcsynapses(1).ECells, funcsynapses(1).ICells);

%Find funcsynapases.ECells' that are part of CellClassOutput(:,4)== -1, set
%back to ICells, remove from EDefinite, put in ILike and remove any Ecnxns
%from funcsynapses... do this in BWCellClassification

CellIDs.EDefinite = funcsynapses(1).ECells';%First approximation... will handle special case later
CellIDs.IDefinite = funcsynapses(1).ICells';%inhibitory interactions 
CellIDs.ELike = find((CellClassOutput(:,4)==1) & (CellClassOutput(:,5)==0));
CellIDs.ILike = find((CellClassOutput(:,4)==-1) & (CellClassOutput(:,5)==0));
CellIDs.EAll = union(CellIDs.EDefinite,CellIDs.ELike);
CellIDs.IAll = union(CellIDs.IDefinite,CellIDs.ILike);
CellClassificationOutput = v2struct(CellClassOutput,PyrBoundary);

% test for ERROR of narrowspiking cell that was called excitatory 
excitnarrow = intersect(funcsynapses(1).ECells,find(CellClassificationOutput.CellClassOutput(:,4)==-1))';
if ~isempty(excitnarrow)
    close all
    [CellIDs,CellClassificationOutput,funcsynapses] = DealWithExcitatoryNarrowSpiker(excitnarrow,CellIDs,CellClassificationOutput,funcsynapses);
    str = input('Press any key to proceed','s');
    close all
    [CellClassOutput, PyrBoundary,Waveforms] = BWCellClassification (basename, cellIx, shank, funcsynapses(1).ECells, funcsynapses(1).ICells);
end

save([basename, '_CellIDs.mat'],'CellIDs')
save([basename,'_CellClassificationOutput.mat'],'CellClassificationOutput')

clear CellClassOutput PyrBoundary SpkWvform_good SpkWvform_goodidx

if ~exist(fullfile(basepath,'CellClassificationFigs'),'dir')
    mkdir(fullfile(basepath,'CellClassificationFigs'))
end
cd(fullfile(basepath,'CellClassificationFigs'))
saveallfigsas('fig')
cd(basepath)

close gcf
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

save([basename '_SSubtypes'],'Se','SeDef','SeLike','Si','SiDef','SiLike','SRates','SeRates','SiRates')
% load([basename '_Subtypes'])


%% Sleep score, get and keep intervals
statefilename = [basename '-states.mat'];
load(statefilename,'states') %gives states, a vector of the state at each second
intervals = ConvertStatesVectorToIntervalSets([],basename);

clear statefilename
save([basename '_Intervals'],'intervals')
% load([basename '_Intervals'])

%% Get intervals useful for Sleep Analysis... sleep minimum = 20min, wake min = 6min
% gf = find(RecordingFilesForSleep);
% 
% if length(gf) == 1;
%     GoodSleepInterval = subset(RecordingFileIntervals,gf);
% else
%     GoodSleepInterval = subset(RecordingFileIntervals,gf(1));
%     for a = 2:length(gf);
%         GoodSleepInterval = timeSpan(cat(GoodSleepInterval, subset(RecordingFileIntervals,gf(a))));
%     end
% end
% 
% [WSWEpisodes,WSWBestIdx] = DefineWakeSleepWakeEpisodes(intervals,GoodSleepInterval);
% [WSEpisodes,WSBestIdx] = DefineWakeSleepEpisodes(intervals,GoodSleepInterval);
% [SWEpisodes,SWBestIdx] = DefineSleepWakeEpisodes(intervals,GoodSleepInterval);
% [SEpisodes,SBestIdx] = DefineSleepEpisodes(intervals,GoodSleepInterval);
% [WEpisodes,WBestIdx] = DefineWakeEpisodes(intervals,GoodSleepInterval);
% save([basename '_WSWEpisodes'],'WSWEpisodes','WSWBestIdx','WSEpisodes','WSBestIdx','SWEpisodes','SWBestIdx','SEpisodes','SBestIdx','WEpisodes','WBestIdx','GoodSleepInterval')
% % load([basename '_WSWEpisodes'])

%% Detect UP and Down states
% goodeegchannelcoshanks = getShanksFromThisChannelAnatomy(goodeegchannel,basename);
% goodeegchannelcoS = S(ismember(shank,goodeegchannelcoshanks));
% 
% [UPInts, DNInts] = DetectUPAndDOWNInSWS(goodeegchannelcoS,intervals,Par.nChannels,goodeegchannel,basename);
% WriteEventFileFromIntervalSet (UPInts,[basename,'.UPS.evt'])
% WriteEventFileFromIntervalSet (DNInts,[basename,'.DNS.evt'])
% save ([basename '_UPDOWNIntervals.mat'], 'UPInts', 'DNInts','goodeegchannel')
% 
% %load([basename,'_UPDOWNIntervals.mat'])

%% Getting binned spike times for all cells combined & for cell types... 10sec bins

if exist('intervals','var')
    [binnedTrains,h] = SpikingAnalysis_PlotPopulationSpikeRates(basename,S,CellIDs,intervals);
else
    [binnedTrains,h] = SpikingAnalysis_PlotPopulationSpikeRates(basename,S,CellIDs);
end

SpikingAnalysis_BinnedTrainsForStateEditor(binnedTrains,basename,basepath);

MakeDirSaveFigsThere('RawSpikeRateFigs',h)


%% Plotting individual cell spike rates.. timelocked to ketamine delivery

[tstarts, counts] = PETH_pg(S,KetamineTimeStamp,KetamineTimeStamp,3600*24,10,1);

SpikingAnalysis_PlotIndividualSpikeRates(basename,basepath,S,CellIDs,counts,KetamineTimeStamp)

%% Plot average firing rate, by cell type, before and after ketamine injection

if exist('states','var')
    SpikingAnalysis_PlotAveragedSpikeRatesBeforeAndAfterInjection(basepath,basename,KetamineTimeStamp,S,Se,Si,RecordingStartsAndEnds,states);
else
    SpikingAnalysis_PlotAveragedSpikeRatesBeforeAndAfterInjection(basepath,basename,KetamineTimeStamp,S,Se,Si,RecordingStartsAndEnds)
end
%% Plot averaged firing rate, by cell type, before and after ketamine injection, normalized to baseline
SpikingAnalysis_PlotNormalizedAvergedSpikeRatesByInterval_S(basepath,basename,KetamineTimeStamp,S,Se,Si,RecordingStartsAndEnds,states);
%% framework for looking at cell-by-cell spike rate changes in different time epochs
% %% Get spike rates in various states
% StateCompressedSpikes = MakeStateCompressedSpikesSet(basename);
% 
% %% Plot correlations between spike rates in different states
% RWake = Rate(StateCompressedSpikes.S_inWake);
% RSWS = Rate(StateCompressedSpikes.S_inSWS);
% RREM = Rate(StateCompressedSpikes.S_inREM);
% RSpindles = Rate(StateCompressedSpikes.S_inSpindles);
% RUPs = Rate(StateCompressedSpikes.S_inUPs);
% 
% figure;
% mcorr_bw_ForCellIDs(StateCompressedSpikes.CellIDs,RWake,RSWS,RREM,RSpindles,RUPs)
