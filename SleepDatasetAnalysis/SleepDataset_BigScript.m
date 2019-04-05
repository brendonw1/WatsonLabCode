% SleepDataset_BigScript
[~,cname]=system('hostname');

% if strcmp(cname(1:9),'MAC157688')%if I'm on my laptop
%     homepath = '/Users/brendon/Dropbox/Data/SleepDatasetAnalysis';
% else %ie if at lab
    homepath = '/mnt/brendon4/Dropbox/Data/SleepDatasetAnalysis';
% end
cd(homepath)

%% Plot Cells by class
cdwithmakedir (fullfile(homepath,'CellClassIDs'));
SleepDataset_CellIDs = SleepDataset_GetCellClassIDs;
SleepDataset_PlotCellClassIDs(SleepDataset_CellIDs);
cd (homepath)

%% Plot basic occurrence stats for various types of synapses
SleepDataset_GatherAndPlotAllSynapseStats

%% Basic spike rates over recordings with scored behavioral state
cdwithmakedir (fullfile(homepath,'SpikeRatesVsTime'));
SleepDataset_DisplayPopulationSpikeRatesVsTime
cd (homepath)

%% Spike rate changes over sleep
% % st = 'CellRateVariables = SpikingAnalysis_IndividalCellRatesAnalysesWithSleep(basename,basepath,Se,Si,intervals,GoodSleepInterval,WSWEpisodes);h = SpikingAnalysis_IndividalCellRatesAnalysesWithSleep_Plot(CellRateVariables);close all;';
% st = 'CellRateVariables = SpikingAnalysis_IndividalCellRatesAnalysesWithSleep(basename,basepath,Se,Si,intervals,GoodSleepInterval,WSWEpisodes);';
% SleepDataset_ExecuteOnDatasets(st,{'Se','Si','intervals','GoodSleepInterval','WSWEpisodes'},'WSWCellsSynapses')

cdwithmakedir (fullfile(homepath,'CellRateDistribsAndChanges'));
SleepDataset_CellRateDistribsAndChanges
cd (homepath)

%% Spike rate changes over sleep Broken down by whether there was 200sec motion prior
% st = 'CellRateVariables = SpikingAnalysis_IndividalCellRatesAnalysesByMotionBool(basename,basepath,Se,Si,intervals,GoodSleepInterval,WSWEpisodes,WSWPreWakeAbove200,1);';
% SleepDataset_ExecuteOnDatasets(st,{'Se','Si','intervals','GoodSleepInterval','WSWEpisodes','WSWPreWakeAbove200'},'WSWCellsSynapses')
% 
% st = 'CellRateVariables = SpikingAnalysis_IndividalCellRatesAnalysesByMotionBool(basename,basepath,Se,Si,intervals,GoodSleepInterval,WSWEpisodes,WSWPreWakeAbove200,0);';
% SleepDataset_ExecuteOnDatasets(st,{'Se','Si','intervals','GoodSleepInterval','WSWEpisodes','WSWPreWakeAbove200'},'WSWCellsSynapses')

cdwithmakedir (fullfile(homepath,'CellRateDistribsAndChanges'));
SleepDataset_CellRateDistribsAndChanges_ByMotionBoolean
cd (homepath)

%% Single cell spiking rate changes over sleep
% cdwithmakedir (fullfile(homepath,'SingleCellSpikingChanges'));
% SleepDataset_SingleCellSleepChanges
% cd (homepath)
% 
% %get rates over 10sec, break into intervals, take distrib over bins, ttest2 by pre vs post

%% Plot SWS-REM transitions
% cdwithmakedir (fullfile(homepath,'SWS-REMTransitions'));
% SleepDataset_SleepStateTriggeredSpectrogramPETH(5,100,30,['Se' 'Si'])
% cd (homepath)

%% Plot REM-SWS transitions
% cdwithmakedir (fullfile(homepath,'REM-SWSTransitions'));
% SleepDataset_SleepStateOffsetTriggeredSpectrogramPETH(5,30,100,['Se' 'Si'])
% cd (homepath)

%% Plot (Andres-like) mean rates across SWS-REM-SWS triplet episodes
% cdwithmakedir (fullfile(homepath,'SRSEpisodeRates'));
% SleepDataset_SRSEpisodeRates
% cd (homepath)

%% Look at SWS episodes that DON'T lead to REM


%% Basic transfer rates by behavioral state


%% Spike Transfer rates over sleep - raw
cd (fullfile(homepath,'CellTransferDistribsAndChangesRaw'));
SleepDataset_PlotTransferRateChangesRaw
cd (homepath)%% Spike Transfer rates over sleep

%% Spike Transfer rates over sleep - in hz
% cd (fullfile(homepath,'CellTransferDistribsAndChangesInHz'));
% SleepDataset_PlotTransferRateChangesInHz
% cd (homepath)

