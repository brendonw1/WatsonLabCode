BigScript_Ketamine(basepath,noPrompts)

%% Getting rolling
if ~exist('basepath','var')
    basepath = cd;
elseif isempty(basepath)
    basepath = cd;
    1;
end
basename = bz_BasenameFromBasepath(basepath);
if ~exist('noPrompts','var')
    noPrompts = (1);
end
noPrompts = logical(noPrompts);

%% Automated, homogenizing data

% Doesnt matter: combine dats, make LFP, spikesorting.
%
% deleteoriginaldatsboolean = 0;
% bz_ConcatenateDats(basepath,deleteoriginaldatsboolean);
% %% Make LFP file 
% if ~exist(fullfile(basepath,[basename '.lfp']),'file')
%     disp('Converting .dat to .lfp')
%     bz_LFPfromDat(basepath)
% else
%     disp('Not converting .lfp file, since it already exists')
% end
%

if ~exist(fullfile(basepath,[basename '_DatsMetadata.mat']),'file')
    bz_DatFileMetadata(basepath);
end

try
    TimeFromLightCycleStart(basepath);% Zeitgeber times of recording files
    RecordingSecondsToTimeSeconds(basepath,basename)
catch e
    disp(['Received error: "' e.message '" during timestamping.  SKIPPING STEP and Continuing on'])
end

disp('Starting Sleep Scoring')
SleepScoreMaster(basepath,'noPrompts',noPrompts);

%%
RecordingSecondsToTimeSeconds(basepath);
FindInjectionComparisonIntervals(basepath);
bz_CellClassification(basepath);

%% Recording various metrics
HighLowFRRatio
EIRatio
BrustPerBinData
KetamineBinnedDataByIntervalState



KetamineBinnedDataByIntervalState(basepath,basename)
KetamineDatasetWideBinnedComparisons('hrlrBaselineData','hrlrInjp1Data','nanmean');
KetamineDatasetWideBinnedComparisons('hrBaselineData','hrInjp1Data','nanmean');
KetamineDatasetWideBinnedComparisons('lrBaselineData','lrInjp1Data','nanmean');
KetamineDatasetWideBinnedComparisons('ERateBaselineData','ERateInjp1Data','nanmean');
KetamineDatasetWideBinnedComparisons('IRateBaselineData','IRateInjp1Data','nanmean');


KetamineDatasetWideBinnedComparisons('ERateBaselineData','ERateBaseline24Data','nanmedian');
KetamineDatasetWideBinnedComparisons('IRateBaselineData','IRateBaseline24Data','nanmedian');
KetamineDatasetWideBinnedComparisons('hrlrBaselineData','hrlrBaseline24Data','nanmedian');KetamineDatasetWideBinnedComparisons('hrBaselineData','hrBaseline24Data','nanmedian');
KetamineDatasetWideBinnedComparisons('lrBaselineData','lrBaseline24Data','nanmedian');
KetamineDatasetWideBinnedComparisons('EIRBaselineData','EIRBaseline24Data','nanmedian');
KetamineDatasetWideBinnedComparisons('CoVBaselineData','CoVBaseline24Data','nanmedian');
KetamineDatasetWideBinnedComparisons('BurstEBaselineData','BurstEBaseline24Data','nanmean');
etc


% %% Fully automated stuff first, without need for human input
% % Navigate matlab to the folder with .dats and .xml file.  
% % Name of the folder will be given as the overall recording name
% %
% % better to have bad_channels.txt here if possible
% %
% clear
% basepath = cd;
% [~,basename,~] = fileparts(cd);
% 
% % MakeDat and DatInfo about recording lengths and start times
% % MakeConcatDats_OneSession(basepath) 
% DatInfoMake(basepath,basename)
% % Store basic info about the original dat files: names and bytes
% 
% % MakeEEG
% MakeLFPs_OneSession(basepath)
% 
% SecondsAfterLightCycleStart = TimeFromLightCycleStart(basepath,basename);
% % Zeitgeber times of recording files
% % Brendon Watson, 2016
% 
% RecordingSecondsToTimeSeconds(basepath,basename)
% % Store correspondences between recoring (ie dat file) second timestamps
% % and clock time.  0.1sec resolution. 
% 
% % added by MD % BW: I commented this out.  It is too early here, we do not
% % yet have the ketamine timestamp, that comes later and so we cannot run
% % these yet.  Up here are things that can run before humans make
% % BasicMetaData... like overnight immediately after recording.
% % FindInjectionComparisonIntervals(basepath,basename)
% % KetamineIntervalState(basepath,basename)
% 
% 
% % better to have bad_channels.txt here if possible
% CallSleepScoreMaster(basepath,basename)
% % Automated Sleepscoring
% 
% cd(basepath)%double checking
% TheStateEditor(basename)
% % Manual interaction with sleep scoring
% 
% 
% %% Start human here: Review/Create Header
% % make bad_channels.txt?
% headername = [basename,'_Header.m'];
% if ~exist(headername,'file')
%     %>>!!!<<< This will need to be sync'd with regular BigScript!!!
%     w = which('SpikingAnalysis_Header_ForKetamine.m');% copy an example header here to edit
% %     w = which('SpikingAnalysis_Header.m');% copy an example header here to edit
%     copyfile(w,headername);
% end
% edit(headername)
% 
% clear dummy headername w naught
% 
% %% Some way to label channels by anatomy?
% % Spike group anatomy .csv is one way
% % put in basic metadata?
% % see bigscript for way of using that
% 
% %% Create basic recording info from human-entered header file info
% run([basename '_Header.m']);
% % load([basename '_BasicMetaData.mat']);
% 
% %%
% FindInjectionComparisonIntervals(basepath,basename)
% % For injection-based recordings, find a series of time intervals of
% % interest, such as hour after injection, 24hours after, baseline prior
% % to, etc, save as intervals.  Many of these are in pairs, maybe shouldn't
% % have done that.
% KetamineIntervalState(basepath,basename)
% 
% 
% %% Sleep states and sleep events
% RippleDetectWrapper(basepath,basename)
% % Detect Ripples
% 
% SpindleDetectWrapper(bmd.Par.nChannels, bmd.Spindlechannel, bmd.voltsperunit);%use default thresholds
% % Detect Spindles
% 
% 
% %% Spike sorting here!!
% % KiloSortWrapper(basepath,basename)
% % ?else?
% 
% %% Load Spikes
% %%NOTE ON THIS DATASET:
% % shank1 unstable at start of recording, where presleep is.  
% % shanks 7-14 from CEA not stable (and not cortical)
% [S,shank,cellIx] = LoadSpikeData(basename,goodshanks);
% save([basename,'_SAll.mat'],'S','shank','cellIx')
% 
% %load([basename,'_SAll.mat'])
% 
% % Load Bad Cells from manual basename_ClusteringNotes.csv (if exists)
% manualbadcells = BadCellsFromClusteringNotes(basename,shank,cellIx);
% 
% % Look at cellular stability using Mahalanobis distances and total spike energies
% SpikingAnalysis_CellStabilityScript
% save([basename,'_SStable.mat'],'S','shank','cellIx','numgoodcells','badcells')
% 
% % load([basename '_ClusterQualityMeasures'])
% % load([basename,'_SStable.mat'])
% % Burst Filter to prep for spike transmission
% Sbf = burstfilter(S,6);%burst filter at 6ms for looking at connections
% save([basename,'_SBurstFiltered.mat'],'Sbf');
% 
% %% Classify cells (get raw waveforms first)
% % load([basename '_AllSpikeWavs.mat'])
% 
% % [CellClassOutput, PyrBoundary,Waveforms] = BWCellClassification (basename, cellIx, shank, funcsynapses(1).ECells, funcsynapses(1).ICells);
% [CellClassOutput, PyrBoundary,Waveforms] = BWCellClassification (basepath,basename, cellIx, shank);
% CellClassificationOutput = v2struct(CellClassOutput,PyrBoundary);
% h = gcf;% [CellClassOutput, PyrBoundary] = BWCellClassification (basename, SpkWvform_good, SpkWvform_goodidx, 1:numgoodcells, funcsynapses(1).ECells, funcsynapses(1).ICells);
% 
% MakeDirSaveFigsThereAs(fullfile(basepath,'CellClassificationFigs'),h,'fig')
% close gcf
% 
% %Find funcsynapases.ECells' that are part of CellClassOutput(:,4)== -1, set
% %back to ICells, remove from EDefinite, put in ILike and remove any Ecnxns
% %from funcsynapses... do this in BWCellClassification
% 
% CellIDs.ELike = find((CellClassOutput(:,4)==1) & (CellClassOutput(:,5)==0));
% CellIDs.ILike = find((CellClassOutput(:,4)==-1) & (CellClassOutput(:,5)==0));
% CellIDs.EAll = CellIDs.ELike;
% CellIDs.IAll = CellIDs.ILike;
% 
% % test for ERROR of narrowspiking cell that was called excitatory 
% if exist('funcsynapses','var')
%     CellIDs.EDefinite = funcsynapses(1).ECells';%First approximation... will handle special case later
%     CellIDs.IDefinite = funcsynapses(1).ICells';%inhibitory interactions 
%     CellIDs.EAll = union(CellIDs.EDefinite,CellIDs.ELike);
%     CellIDs.IAll = union(CellIDs.IDefinite,CellIDs.ILike);
% 
%     excitnarrow = intersect(funcsynapses(1).ECells,find(CellClassificationOutput.CellClassOutput(:,4)==-1))';
%     if ~isempty(excitnarrow)
%         close all
%         [CellIDs,CellClassificationOutput,funcsynapses] = DealWithExcitatoryNarrowSpiker(excitnarrow,CellIDs,CellClassificationOutput,funcsynapses);
%         str = input('Press any key to proceed','s');
%         close all
%         [CellClassOutput, PyrBoundary,Waveforms] = BWCellClassification (basename, cellIx, shank, funcsynapses(1).ECells, funcsynapses(1).ICells);
%     end
%     save([basename,'_funcsynapsesMoreStringent.mat'],'funcsynapses')
% else
%     CellIDs.EDefinite = [];%First approximation... will handle special case later
%     CellIDs.IDefinite = [];%inhibitory interactions 
% end
% 
% save([basename, '_CellIDs.mat'],'CellIDs')
% save([basename,'_CellClassificationOutput.mat'],'CellClassificationOutput')
% 
% clear CellClassOutput PyrBoundary SpkWvform_good SpkWvform_goodidx
% % load([basename, '_CellIDs.mat'])
% % load([basename,'_CellClassificationOutput.mat'])
% 
% % Dividing spikes by cell class (based on S variable above)
% [Se,SeDef,SeLike,Si,SiDef,SiLike,SRates,SeRates,SiRates] = MakeSSubtypes(basepath,basename);
% % load([basename '_SSubtypes'])
% 
% 
% %% Finding connectivity
% % MonoSynClick etc
% % Or 
% % funcsynapses = FindSynapseWrapper(Sbf,S,shank,cellIx);
% % %Circle back and re-classify funcsynapses based on CellIDs
% % funcsynapses = UpdateFuncSynConnectionClassification(basepath,basename);
% 
% %% Find UP states based on spiking
% UPstates_DetectDatasetUPstates(basepath,basename)
% UPstates_GetUPstateIntervalSpiking(basepath,basename);
% % Detect UP and Down states
% 
% %% Spike quanitifications here
% cd basepath
% HighLowFRRatio
% SpikingCoeffVariation
% EIRatio
% BurstPerBin
% 
% %% Outputting binned data by time interval and brain state
% KetamineBinnedDataByIntervalState(basepath,basename)
% % Loads data from various binned metrics in specified time chunks and subdivides values by
% % brain states, plots and saves.
% 
% %>> Get data from full dataset as follows (change details)
% % KetamineDatasetWideBinnedComparisons('hrlrBaselineData','hrlrInjp1Data','nanmean');
% % KetamineDatasetWideBinnedComparisons('hrBaselineData','hrInjp1Data','nanmean');
% % KetamineDatasetWideBinnedComparisons('lrBaselineData','lrInjp1Data','nanmean');
% % KetamineDatasetWideBinnedComparisons('ERateBaselineData','ERateInjp1Data','nanmean');
% % KetamineDatasetWideBinnedComparisons('IRateBaselineData','IRateInjp1Data','nanmean');
% % 
% % 
% % KetamineDatasetWideBinnedComparisons('ERateBaselineData','ERateBaseline24Data','nanmedian');
% % KetamineDatasetWideBinnedComparisons('IRateBaselineData','IRateBaseline24Data','nanmedian');
% % KetamineDatasetWideBinnedComparisons('hrlrBaselineData','hrlrBaseline24Data','nanmedian');KetamineDatasetWideBinnedComparisons('hrBaselineData','hrBaseline24Data','nanmedian');
% % KetamineDatasetWideBinnedComparisons('lrBaselineData','lrBaseline24Data','nanmedian');
% % KetamineDatasetWideBinnedComparisons('EIRBaselineData','EIRBaseline24Data','nanmedian');
% % KetamineDatasetWideBinnedComparisons('CoVBaselineData','CoVBaseline24Data','nanmedian');
% % KetamineDatasetWideBinnedComparisons('BurstEBaselineData','BurstEBaseline24Data','nanmean');
% % etc
% 
% 
