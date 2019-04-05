%% Get basic info... assuming you're in the right directory already
[basepath,basename,dummy] = fileparts(cd);
basepath = fullfile(basepath,basename);
load([basename '_BasicMetaData.mat'])

%% Plotting cell spike rates, rates by state, invididual cell rate changes and population trends
load([basename '_WSWEpisodes'])
if ~isempty(WSWBestIdx)
    load([basename '_SSubtypes'])
    load([basename '_Intervals'])
    load([basename '_GoodSleepInterval'])
    CellRateVariables = SpikingAnalysis_IndividalCellRatesAnalysesWithSleep(basename,basepath,Se,Si,intervals,GoodSleepInterval,WSWEpisodes);
    SpikingAnalysis_IndividalCellRatesAnalysesWithSleep_Plot(CellRateVariables)
end



%% Plotting basic SWS and UP/DOWN state data and spiking
% [SWSMeasures, UPMeasures] =  SpikingAnalysis_SWSAndUPPlotting(basename,S,Se,Si,UPInts,DNInts,intervals,PrePostSleepMetaData);
% 
% %save figs
% if ~exist(fullfile(basepath,'SWSUPStateBasicFigs'),'dir')
%     mkdir(fullfile(basepath,'SWSUPStateBasicFigs'))
% end
% cd(fullfile(basepath,'SWSUPStateBasicFigs'))
% saveallfigsas('fig')
% cd(basepath)
% 
% save([basename '_SWSAndUPMeasures.mat'],'SWSMeasures','UPMeasures')
% % load([basename '_UPStateMetaData.mat'])
% % load([basename '_SWSAndUPMeasures.mat'])

%% Looking at rate changes over SWS-REM-SWS episodes detected earlier (SRSEpisodes);
% SWSREMSWSEpisode_PopRates = SpikingAnalysis_GetTripletEpisodeSpikeRates(basename,basepath,intervals,subset(WSWEpisodes{WSWBestIdx},2),Se,Si);
% 
% save([basename '_SWSREMSWSEpisode_PopRates.mat'],'SWSREMSWSEpisode_PopRates')
% %load([basename '_SWSREMSWSEpisode_PopRates.mat'])


%% Look at modulation of spike rates by state
% [CellStateRates, CellStateModulations] = WholePopStateModulation(S,CellIDs,intervals);
% save([basename '_CellStateRates.mat'],'CellStateRates')
% save([basename '_CellStateModulations.mat'],'CellStateModulations')
% 
% %save fig
% if ~exist(fullfile(basepath,'CellStateModulations'),'dir')
%     mkdir(fullfile(basepath,'CellStateModulations'))
% end
% cd(fullfile(basepath,'CellStateModulations'))
% saveallfigsas('fig')
% cd(basepath)

%% SpikeTransfer over sleep epochs... using waking before vs after and first/last third of sleep
% % >>Raw Transfer in post spikes per prespike
% raw = 1;
% byratio = 0;
% TransferStrengthsOverSleep_Raw = SpikingAnalysis_TransferRatesOverSleep(WSWEpisodes,Sbf,intervals,funcsynapses,basename,basepath,byratio,raw);
% SpikingAnalysis_TransferRatesOverSleep_Plot(TransferStrengthsOverSleep_Raw);
% save([basename '_TransferStrengthsOverSleep_Raw.mat'],'TransferStrengthsOverSleep_Raw')
% %load([basename '_TransferStrengthsOverSleep.mat'])
% close all
%% >>Normalized by ratio to ccg baseline
% raw = 0;
% byratio = 1;
% TransferStrengthsOverSleep_NormByRatio = SpikingAnalysis_TransferRatesOverSleep(WSWEpisodes,Sbf,intervals,funcsynapses,basename,basepath,byratio,raw);
% SpikingAnalysis_TransferRatesOverSleep_Plot(TransferStrengthsOverSleep_NormByRatio);
% save([basename '_TransferStrengthsOverSleep_NormByRatio.mat'],'TransferStrengthsOverSleep_NormByRatio')
% %load([basename '_TransferStrengthsOverSleep.mat'])
% close allgoodeegchannelcoshanks = getShanksFromThisChannelAnatomy(goodeegchannel,basename);
% goodeegchannelcoS = S(ismember(shank,goodeegchannelcoshanks));

%% >>Normalized by Hz above/below ccg baseline
% raw = 0;
% byratio = 0;
% TransferStrengthsOverSleep_NormByRateChg = SpikingAnalysis_TransferRatesOverSleep(WSWEpisodes,Sbf,intervals,funcsynapses,basename,basepath,byratio,raw);
% SpikingAnalysis_TransferRatesOverSleep_Plot(TransferStrengthsOverSleep_NormByRateChg);
% save([basename '_TransferStrengthsOverSleep_NormByRateChg.mat'],'TransferStrengthsOverSleep_NormByRateChg')
% %load([basename '_TransferStrengthsOverSleep.mat'])


%% Special case of synapses that were zero at start or at end of Sleep - entirely "created" or "destroyed"
%>>?

%% Spike Transfer over entire recording... color coded with sleepstate

%% Particular cells somehow??
% 
% %% Looking at SpikeTransfer changes over SWS-REM-SWS episodes detected earlier (SRSEpisodes);
% SWSREMSWSEpisode_Transfer = SpikingAnalysis_GetTripletEpisodeSpikeTransfers(basename,basepath,intervals,PrePostSleepMetaData,S,funcsynapses);
% 
% save([basename '_SWSREMSWSEpisode_Transfer.mat'],'SWSREMSWSEpisode_Transfer')
% %load([basename '_SWSREMSWSEpisode_PopRates.mat'])
% 
% %% Looking at SpikeTransfer changes over SWS-REM-SWS episodes - normalized to avg per-synapse sterngth
% % percell = 0;
% % normalize = 1;
% % SWSREMSWSEpisode_Transfer = SpikingAnalysis_GetTripletEpisodeSpikeTransfers(basename,basepath,intervals,PrePostSleepMetaData,S,funcsynapses,percell,normalize);
% % 
% % save([basename '_SWSREMSWSEpisode_Transfer.mat'],'SWSREMSWSEpisode_Transfer')
% % %load([basename '_SWSREMSWSEpisode_PopRates.mat'])
% 
% %% SpikeTransfer for each cell, normalized vs unnormalized over SWS-REM-SWS
% % 4x4 plot: cells un-norm, all 9 points, cells norm all 9, cells unnorm 3
% % times, cells norm 3 times
% 
% 
% %% Simple distributions of synaptic strengths
% % EE vs EI vs IE vs IE in each plot x2 for gaus or not
% % REM vs SWS vs AWAKE figures
% 
% %% Mean Syn strength per cell vs mean firing rate per same cell
% 
% 
% %%
% % SpikingAnalysis_REMStartStopLockedSpiking(basename,basepath,SWSREMSWSEpisode_PopRates.PostSleepBWEpisodes,S,Se,Si)
% 
% %% 
% 
% %% Find assemblies
% %bin at 100ms
% 
% % binnedEachCell = MakeQfromS(S,1000);%bin every 1000pts, which is 100msec (10000 pts per sec)
% % binnedTrains.All = sum(Data(binnedEachCell),2)';
% numgoodcells = size(binnedEachCellData,1);
% %figure; imagesc(binnedEachCellData)%% When CCGjitter completes, plot results
% CCG_jitter_plotpositives(ccgjitteroutput,individualplot)
% CCG_jitter_plotzerolag(ccgjitteroutput)
% 
% %save figs
% if ~exist(fullfile(basepath,'CCGJitterFigs'),'dir')
%     mkdir(fullfile(basepath,'CCGJitterFigs'))
% end
% cd(fullfile(basepath,'CCGJitterFigs'))
% saveallfigsas('fig')
% cd(basepath)
%  %view basic binned spiking like this
% 
% 
% % Find assembly patterns
% opts.threshold.method = 'MarcenkoPastur';
% opts.Patterns.method = 'ICA'
% opts.Patterns.number_of_iterations = 1000;
% [Patterns,Threshold] = assembly_patterns_bw(binnedEachCellData,opts)
% 
% % Find and label neurons with significant contributions on to assemblies
% [cellnum,assemblynum]=find(abs(Patterns)>Threshold);%find cell,assembly ID's of contributions with abs>Threshold
% % shigecellnum = cellinds(cellnum,2);%convert back to shige's number system
% 
% 
% % Plot Assembly PatternsPrep for all but final analysis BWRat19... anticipate  
% 
% maxproj = max(Patterns(:));%get the max projection of any initial variable onto any PC
% minproj = min(Patterns(:));%get the min
% numassemblies = size(Patterns,2);
% 
% [v,h]=determinenumsubplots(numassemblies);
% 
% %Stem plots of assemblies
% figure;
% for a = 1:numassemblies
%     subplot(v,h,a);
%     hold on
%         stem(Patterns(:,a));
%         plot([1 numgoodcells],[Threshold Threshold],'r')
%         plot([1 numgoodcells],[-Threshold -Threshold],'r')
%         xlim([1 numgoodcells])
%         ylim([minproj maxproj])
%         title(['Assembly ',num2str(a)])
%         signifassemblycellinds = find(assemblynum==a);
%         for b = 1:length(signifassemblycellinds)
%             x = cellnum(signifassembl%% When CCGjitter completes, plot results
% CCG_jitter_plotpositives(ccgjitteroutput,individualplot)
% CCG_jitter_plotzerolag(ccgjitteroutput)
% 
% %save figs
% if ~exist(fullfile(basepath,'CCGJitterFigs'),'dir')
%     mkdir(fullfile(basepath,'CCGJitterFigs'))
% end
% cd(fullfile(basepath,'CCGJitterFigs'))
% saveallfigsas('fig')
% cd(basepath)
% ycellinds(b));
%             y = Patterns(cellnum(signifassemblycellinds(b)),a);
%             textstr = num2str(signifassemblycellinds(b));Prep for all but final analysis BWRat19... anticipate  
% 
%             text(x+1,y,textstr)
%         end
% end
% % >> highlight connected cells in green or red
% 
% 
% % Get activity of each assembly
% AssemblyActivities = assembly_activity(Patterns,binnedEachCellData);
% SumAssemblyActivities = sum(abs(AssemblyActivities),1);
% 
% % Plot activity of each assembly
% figure 
% subplot(3,1,1) 
% imagesc(binnedEachCellData)
% xlim([1 size(AssemblyActivities,2)])
% 
% subplot(3,1,2) 
% hold on;
% plot(SumAssemblyActivities,'k')
% plot(AssemblyActivities')
% xlim([1 size(AssemblyActivities,2)])
% title('Activities of assemblies found by PCA: Erepmat(sum(ccg,1),size(ccg,1),1)ach color is 1 assembly, Black is sum of all others')
% 
% subplot(3,1,3)
% hold on
% plot(binnedTrains.All,'k')
% plot(binnedTrains.EAll,'g')
% plot(binnedTrains.IAll,'r')
% toplot = [Start(StateIntervals{5}) End(StateIntervals{5})]'/100000;%scale down based on binning
% plot(toplot,5+ones(size(toplot)),'color','m','LineWidth',5)
% toplot = [Start(StateIntervals{3}) End(StateIntervals{3})]'/100000;%scale down based on binning
% plot(toplot,5+ones(size(toplot)),'color','c','LineWidth',5)
% toplot = [Start(StateIntervals{1}) End(StateIntervals{1})]'/100000;%scale down based on binning
% plot(toplot,5+ones(size(toplot)),'color','g','LineWidth',5)
% CCG_jitter_plotpositives(ccgjitteroutput,individualplot)
% CCG_jitter_plotzerolag(ccgjitteroutput)
% 
% %save figs
% if ~exist(fullfile(basepath,'CCGJitterFigs'),'dir')
%     mkdir(fullfile(basepath,'CCGJitterFigs'))
% end
% cd(fullfile(basepath,'CCGJitterFigs'))
% saveallfigsas('fig')
% cd(basepath)
% or','k','LineWidth',5)
% 
% xlim([1 size(binnedTrains.All,2)])
% title({['Spikes from All cells (black), all ECells (green) and all ICells (red)'];['Bottom state indicator: Dark blue-wake, Cyan-SWS, Magenta-REM']})
% 
% 
% % for a = 1:numassemblies;
% %     legendstr{a} = num2str(a);
% % end
% % legend(legendstr,'Location','NorthEastOutside')
% %>>> Find a way to separate these, plot them with spiking
% %normalize by spiking
% %plot states color coded with spikes
% 
% 
% %% Synaptic strength analysis
% % for a = 1:size(S,1); 
% %     individCellsSpikes{a} = Data(S{a})';%get spike times, concat into a vector with times of all other spikes from other clusters/cells
% % end
% 
% oldpath = addpath('/home/brendon/Dropbox/MATLABwork/BuzLabOthersWork/FMAToolbox/Analyses/');
% 
% %% make sure the reference cell is presynaptic if normalizing by reference
% [ccg,x,y] = ShortTimeCCG_bw(Data(S{34})/10000,Data(S{32})/10000,'binsize',0.001,'duration',0.060,'window',60,'overlap',0.5);
% figure;
% PlotShortTimeCCG(ccg,'x',x,'y',y)
% title('Not normalized')
% hold on;
% toplot = [Start(StateIntervals{5}) End(StateIntervals{5})]'/10000;%scale down based on binning
% plot(toplot,5+ones(size(toplot)),'color','m','LineWidth',5)
% toplot = [Start(StateIntervals{3}) End(StateIntervals{3})]'/10000;%scale down based on binning
% plot(toplot,5+ones(size(toplot)),'color','c','LineWidth',5)
% toplot = [Start(StateIntervals{1}) End(StateIntervals{1})]'/10000;%scale down based on binning
% plot(toplot,5+ones(size(toplot)),'color','k','LineWidth',5)
% 
% [ccg,x,y] = ShortTimeCCG_bw(Data(S{34})/10000,Data(S{32})/10000,'binsize',0.001,'duration',0.060,'window',60,'overlap',0.5,'mode','norm');
% figure;
% PlotShortTimeCCG(ccg,'x',x,'y',y)
% title('Normalization by Total CCG count per time bin')
% hold on;
% toplot = [Start(StateIntervals{5}) End(StateIntervals{5})]'/10000;%scale down based on binning
% plot(toplot,5+ones(size(toplot)),'color','m','LineWidth',5)
% toplot = [Start(StateIntervals{3}) End(StateIntervals{3})]'/10000;%scale down based on binning
% plot(toplot,5+ones(size(toplot)),'color','c','LineWidth',5)
% toplot = [Start(StateIntervals{1}) End(StateIntervals{1})]'/10000;%scale down based on binning
% plot(toplot,5+ones(size(toplot)),'color','k','LineWidth',5)
% 
% [ccg,x,y] = ShortTimeCCG_bw(Data(S{34})/10000,Data(S{32})/10000,'binsize',0.001,'duration',0.060,'window',60,'overlap',0.5,'mode','normbyreferencecell');
% figure;
% PlotShortTimeCCG(ccg,'x',x,'y',y)
% title('Normalization by Reference Cell spikes per time bin')
% hold on;
% toplot = [Start(StateIntervals{5}) End(StateIntervals{5})]'/10000;%scale down based on binning
% plot(toplot,5+ones(size(toplot)),'color','m','LineWidth',5)
% toplot = [Start(StateIntervals{3}) End(StateIntervals{3})]'/10000;%scale down based on binning
% plot(toplot,5+ones(size(toplot)),'color','c','LineWidth',5)
% toplot = [Start(StateIntervals{1}) End(StateIntervals{1})]'/10000;%scale down based on binning
% plot(toplot,5+ones(size(toplot)),'color','k','LineWidth',5)
% 
% path(oldpath);
% 
% 