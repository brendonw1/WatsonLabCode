function SpikingAnalysis_BinnedTrainsForStateEditor(binnedTrains,basename,basepath)

%% Save binned trains out for StateEditor
load(fullfile(basepath,[basename '-states.mat']))
AllSpikesForStateEditor = resample(binnedTrains.All,size(states,2),size(binnedTrains.All,2));
save(fullfile(basepath,[basename '_StateEditorOverlay_CombinedAllSpikes']),'AllSpikesForStateEditor')

EAllSpikesForStateEditor = resample(binnedTrains.EAll,size(states,2),size(binnedTrains.EAll,2));
save(fullfile(basepath,[basename '_StateEditorOverlay_CombinedEAllSpikes']),'EAllSpikesForStateEditor')
IAllSpikesForStateEditor = resample(binnedTrains.IAll,size(states,2),size(binnedTrains.IAll,2));
save(fullfile(basepath,[basename '_StateEditorOverlay_CombinedIAllSpikes']),'IAllSpikesForStateEditor')

AllandEAllandIAllSpikesForStateEditor = cat(1,AllSpikesForStateEditor,EAllSpikesForStateEditor,IAllSpikesForStateEditor);
save(fullfile(basepath,[basename '_StateEditorOverlay_CombinedI+E+AllSpikes']),'AllandEAllandIAllSpikesForStateEditor')

SpikesForStateEditor = v2struct(AllSpikesForStateEditor,EAllSpikesForStateEditor,IAllSpikesForStateEditor,AllandEAllandIAllSpikesForStateEditor);
clear AllSpikesForStateEditor EAllSpikesForStateEditor IAllSpikesForStateEditor AllandEAllandIAllSpikesForStateEditor states events transitions

% %% defining pre-post sleep epochs
% PrePostSleepMetaData = PrePostSleepIntervals(presleepstartstop,postsleepstartstop,intervals,UPInts,DNInts);
% 
% save([basename '_PrePostSleepMetaData.mat'],'PrePostSleepMetaData')
% %load([basename '_PrePostSleepMetaData.mat'])