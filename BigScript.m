%BigScript
%% get basename and basepath from CD
clear
basepath = cd;
[~,basename,~] = fileparts(cd);

%% MakeDat and DatInfo about recording lengths and start times
MakeConcatDats_OneSession(basepath) 
DatInfoMake(basepath,basename)

%% MakeEEG
MakeEEGs_OneSession(basepath)

%% Auto sleep scoring
CallSleepScoreMaster(basepath,basename)

%% Prep for 

% Get voltage
% Detect Ripples
% Detect Spindles
% What to do with BasicMetaData... automatize some?
%    - Add Behavior time and notes?
%    - Denote Cx channels vs Hpc channels
% MakeProbeMapKlusta

% After spikes:
% FuncSyns (Sam's code?)
% Cell types
% Find UPstates on cortical channels
% ?

%% OVERALL DATA ANALYSIS SCRIPT APRIL 2014.
% Assumes you've already created and run a "_Header" script for any given recording in order to create a basename_BasicMetaData.mat.
% Assumes matlab is pointed at the homefolder for that recording and step 1 will be to load the _BasicMetaData.mat
% See below for an example Header
% USE: Note, if "load" command is at the end of a section then executing that load can subsitute for the entire section (if the data has already been stored to disk)


%% Review/Create Header
headername = [basename,'_Header.m'];
if ~exist(headername,'file')
    w = which('SpikingAnalysis_Header.m');% copy an example header here to edit
    copyfile(w,headername);
end
edit(headername)

clear dummy headername w naught

%% Create basic recording info from human-entered header file info
run([basename '_Header.m']);
% load([basename '_BasicMetaData.mat']);

%% Store an interval with start/stop of time with acceptable sleep
% if ~exist('manualGoodSleep','var');
%     gf = find(RecordingFilesForSleep);
%     if length(gf) == 1;
%         GoodSleepInterval = subset(RecordingFileIntervals,gf);
%     else
%         GoodSleepInterval = subset(RecordingFileIntervals,gf(1));
%         for a = 2:length(gf);
%             GoodSleepInterval = timeSpan(cat(GoodSleepInterval, subset(RecordingFileIntervals,gf(a))));
%         end
%     end
% elseif manualGoodSleep==1
%     GoodSleepInterval = intervalSet(10000*sleepstart,10000*sleepstop);
% else
%     disp('Unsure how to make GoodSleepInterval')
% end
% save([basename '_GoodSleepInterval'],'GoodSleepInterval')
% % load([basename '_GoodSleepInterval'])

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
%% Burst Filter to prep for spike transmission
Sbf = burstfilter(S,6);%burst filter at 6ms for looking at connections
save([basename,'_SBurstFiltered.mat'],'Sbf');

%% Get connectivity
% funcsynapses = FindSynapseWrapper(Sbf,S,shank,cellIx);

%% If had to delete some clusters and start over... 
% clear ClusterQualityMeasures SelfMahalDistanceChanges SelfMahalDistances SelfMahalDistancesCell UnselectedSpikeTsds badcells
% rmdir('ConnectionFigs/','s')
% %return to Load Spikes

%% Pause here to allow for review of funcsynapses figures
% % ... they save as they close
% save([basename '_funcsynapsesMoreStringent'],'funcsynapses')
% close all
% % load([basename,'_funcsynapsesMoreStringent.mat']);

%% Classify cells (get raw waveforms first)
% load([basename '_AllSpikeWavs.mat'])

% [CellClassOutput, PyrBoundary,Waveforms] = BWCellClassification (basename, cellIx, shank, funcsynapses(1).ECells, funcsynapses(1).ICells);
[CellClassOutput, PyrBoundary,Waveforms] = BWCellClassification (basepath,basename, cellIx, shank);
CellClassificationOutput = v2struct(CellClassOutput,PyrBoundary);
h = gcf;% [CellClassOutput, PyrBoundary] = BWCellClassification (basename, SpkWvform_good, SpkWvform_goodidx, 1:numgoodcells, funcsynapses(1).ECells, funcsynapses(1).ICells);

MakeDirSaveFigsThereAs(fullfile(basepath,'CellClassificationFigs'),h,'fig')
close gcf

%Find funcsynapases.ECells' that are part of CellClassOutput(:,4)== -1, set
%back to ICells, remove from EDefinite, put in ILike and remove any Ecnxns
%from funcsynapses... do this in BWCellClassification

CellIDs.ELike = find((CellClassOutput(:,4)==1) & (CellClassOutput(:,5)==0));
CellIDs.ILike = find((CellClassOutput(:,4)==-1) & (CellClassOutput(:,5)==0));
CellIDs.EAll = CellIDs.ELike;
CellIDs.IAll = CellIDs.ILike;

% test for ERROR of narrowspiking cell that was called excitatory 
if exist('funcsynapses','var')
    CellIDs.EDefinite = funcsynapses(1).ECells';%First approximation... will handle special case later
    CellIDs.IDefinite = funcsynapses(1).ICells';%inhibitory interactions 
    CellIDs.EAll = union(CellIDs.EDefinite,CellIDs.ELike);
    CellIDs.IAll = union(CellIDs.IDefinite,CellIDs.ILike);

    excitnarrow = intersect(funcsynapses(1).ECells,find(CellClassificationOutput.CellClassOutput(:,4)==-1))';
    if ~isempty(excitnarrow)
        close all
        [CellIDs,CellClassificationOutput,funcsynapses] = DealWithExcitatoryNarrowSpiker(excitnarrow,CellIDs,CellClassificationOutput,funcsynapses);
        str = input('Press any key to proceed','s');
        close all
        [CellClassOutput, PyrBoundary,Waveforms] = BWCellClassification (basename, cellIx, shank, funcsynapses(1).ECells, funcsynapses(1).ICells);
    end
    save([basename,'_funcsynapsesMoreStringent.mat'],'funcsynapses')
else
    CellIDs.EDefinite = [];%First approximation... will handle special case later
    CellIDs.IDefinite = [];%inhibitory interactions 
end

save([basename, '_CellIDs.mat'],'CellIDs')
save([basename,'_CellClassificationOutput.mat'],'CellClassificationOutput')

clear CellClassOutput PyrBoundary SpkWvform_good SpkWvform_goodidx
% load([basename, '_CellIDs.mat'])
% load([basename,'_CellClassificationOutput.mat'])

%% Dividing spikes by cell class (based on S variable above)
[Se,SeDef,SeLike,Si,SiDef,SiLike,SRates,SeRates,SiRates] = MakeSSubtypes(basepath,basename);
% load([basename '_SSubtypes'])

%% Circle back and re-classify funcsynapses based on CellIDs
% funcsynapses = UpdateFuncSynConnectionClassification(basepath,basename);

%% Keep a version of funcsynapses that only has different-shank cells
% FindSynapse_KeepOnlyDiffShank(basepath,basename);
% %saves as save(fullfile(basepath,[basename '_funcsynapsesMS_DiffShank.mat']),'funcsynapses')

%% Make a file of which anatomical site each channel was in (based on a csv made in gdrive by hand)
% ChannelAnatomyFileFromSpikeGroupAnatomy(basename)
% 
% % Make subdirectory for each anatomical region
% tx = read_mixed_csv([basename '_SpikeGroupAnatomy.csv'],',');
% for a = 2:size(tx,1);
%     txx{a-1} = tx{a,2};
% end
% anatregions = unique(txx);
% for a = 1:length(anatregions)
%     if ~exist([basename,'_',anatregions{a}],'dir')
%         mkdir([basename,'_',anatregions{a}])
%     end
% end
% 
% %% Sleep score, get and keep intervals
% % statefilename = [basename '-states.mat'];
% % load(statefilename,'states') %gives states, a vector of the state at each second
% intervals = ConvertStatesVectorToIntervalSets([],basename);
% 
% clear statefilename
% save([basename '_Intervals'],'intervals')
% % load([basename '_Intervals'])
% 
% %% Get intervals useful for Sleep Analysis... sleep minimum = 20min, wake min = 6min
% WS = DefineWakeSleepWakeEpisodes;
% % [WSWEpisodes,WSWBestIdx] = DefineWakeSleepWakeEpisodes(intervals,GoodSleepInterval);
% % [WSEpisodes,WSBestIdx] = DefineWakeSleepEpisodes(intervals,GoodSleepInterval);
% % [SWEpisodes,SWBestIdx] = DefineSleepWakeEpisodes(intervals,GoodSleepInterval);
% % [SEpisodes,SBestIdx] = DefineSleepEpisodes(intervals,GoodSleepInterval);
% % [WEpisodes,WBestIdx] = DefineWakeEpisodes(intervals,GoodSleepInterval);
% v2struct(WS)%unpacks a lot
% save([basename '_WSWEpisodes'],'WSWEpisodes','WSWBestIdx','WSEpisodes','WSBestIdx','SWEpisodes','SWBestIdx','SEpisodes','SBestIdx','WEpisodes','WBestIdx','GoodSleepInterval')
% % load([basename '_WSWEpisodes'])
% 
% 
% %% Getting binned spike times for all cells combined & for cell types... 10sec bins
% [binnedTrains,h] = SpikingAnalysis_PlotPopulationSpikeRates(basename,S,CellIDs,intervals);
% SpikingAnalysis_BinnedTrainsForStateEditor(binnedTrains,basename,basepath);
% 
% MakeDirSaveFigsThere('RawSpikeRateFigs',h)
% 
% %% Binary Motion Scoring
% if ~exist([fullfile(basepath,[basename '_Motion.mat'])],'file')
%     t = load([fullfile(basepath,basename) '.eegstates.mat']);
%     motion = t.StateInfo.motion;
%     clear t
% 
%     [~,h] = FilterAndBinaryDetectMotion(motion,'clean',20,1);
%     title(basename)
% 
%     strs = {'Clean (Baseline fluct OK)';'High Freq Noise'};
%     [s,v] = listdlg('PromptString','Clean or noisy baseline?','SelectionMode','single','ListString',strs);
%     close(h)
% 
%     motiondata.motion = motion;
%     switch s
%         case 1
%             motiondata.filttype = 'clean';
%         case 2 
%             motiondata.filttype = 'noisybaseline';
%     end
% 
%     % Refilter using mode asked by user
%     movementsecs = FilterAndBinaryDetectMotion(motiondata.motion,motiondata.filttype,20,1);
%     title([basename,' ',motiondata.filttype,'.  Final Detection'])
% 
%     motiondata.thresholdedsecs = movementsecs;
% 
%     save([fullfile(basepath,basename) '_Motion.mat'],'motiondata')
%     %     motiondata.thresholdedsecs = movementsecs;
% end

%%
%% Detect UP and Down states
UPstates_DetectDatasetUPstates(basepath,basename)
UPstates_GetUPstateIntervalSpiking(basepath,basename);

%% Detect Spindles
SpindleDetectWrapper(Par.nChannels,Spindlechannel,voltsperunit);
Spindles_GetSpindleIntervalSpiking(basepath,basename);

%% Detect Ripples
RippleDetectWrapper(basepath,basename);
Ripples_GetRippleIntervalSpiking(basepath,basename)

%% Save basic rates by states/events
StateRates(basepath,basename);


%%
% Go on to SpikingAnalysis_BigScript_Sleep_SeparateShanks
% ... and  SpikingAnalysis_BigScript_PostBasics


