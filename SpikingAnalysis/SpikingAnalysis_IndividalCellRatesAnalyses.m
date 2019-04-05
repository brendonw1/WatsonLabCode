%% Script: SpikingAnalysis_IndividalCellRatesAnalyses

%% Plot distribution of Individual cell spike rates
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
% PreSleepUPs = intersect(UPInts,PrePostSleepMetaData.presleepInt);
% UPStateESpikeRates = Rate(Se,PreSleepUPs);
% UPStateISpikeRates = Rate(Si,PreSleepUPs);
% REMESpikeRates = Rate(Se,subset(intervals{5},PrePostSleepMetaData.presleepREMlist));
% REMISpikeRates = Rate(Si,subset(intervals{5},PrePostSleepMetaData.presleepREMlist));

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
    
% h = SpikingAnalysis_PlotRateDistributionsLinearAndLog(UPStateESpikeRates);
%     subplot(2,1,1)
%     title('Distribution of spike rates for E cells for Presleep SWS-UPStates: Linear scale')
%     subplot(2,1,2)
%     title('Distribution of spike rates for E cells for Presleep SWS-UPStates: Semilog Scale')
%     set(h,'name',[basename,'_ECellSpikeHisto-AllPresleepUPStates'])
% h = SpikingAnalysis_PlotRateDistributionsLinearAndLog(UPStateISpikeRates);
%     subplot(2,1,1)
%     title('Distribution of spike rates for I cells for Presleep SWS-UPStates: Linear scale')
%     subplot(2,1,2)
%     title('Distribution of spike rates for I cells for Presleep SWS-UPStates: Semilog Scale')
%     set(h,'name',[basename,'_ICellSpikeHisto-AllPresleepUPStates'])

% h = SpikingAnalysis_PlotRateDistributionsLinearAndLog(REMESpikeRates);
%     subplot(2,1,1)
%     title('Distribution of spike rates for E cells for Presleep REM: Linear scale')
%     subplot(2,1,2)
%     title('Distribution of spike rates for E cells for Presleep REM: Semilog Scale')
%     set(h,'name',[basename,'_ECellSpikeHisto-AllPresleepREM'])
% h = SpikingAnalysis_PlotRateDistributionsLinearAndLog(REMISpikeRates);
%     subplot(2,1,1)
%     title('Distribution of spike rates for I cells for Presleep REM: Linear scale')
%     subplot(2,1,2)
%     title('Distribution of spike rates for I cells for Presleep REM: Semilog Scale')
%     set(h,'name',[basename,'_ICellSpikeHisto-AllPresleepREM'])


% %% Cell-by-cell changes in rates over various intervals in various states 
% %>(see BWRat20 analysis)
% % use above to do simple 2 point plots for each comparison
% 
% h = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(PrePresleepWakingESpikeRates,PostPresleepWakingESpikeRates);
% subplot(1,2,1)
% title('E:Pre-Presleep Waking vs Post-Presleep Waking Per cell')
% subplot(1,2,2)
% title('Log scale')
% set(h,'name',[basename,'_ECellByCellRateChanges-PreVsPostPresleepWaking'])
% h = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(PrePresleepWakingISpikeRates,PostPresleepWakingISpikeRates);
% subplot(1,2,1)
% title('I:Pre-Presleep Waking vs Post-Presleep Waking Per cell')
% subplot(1,2,2)
% title('Log scale')
% set(h,'name',[basename,'_ICellByCellRateChanges-PreVsPostPresleepWaking'])
% 
% h = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(FirstThirdPresleepSWSUPStateESpikeRates,LastThirdPresleepSWSUPStateESpikeRates);
% subplot(1,2,1)
% title('E:First 1/3 SWS UP Rates vs Last 1/3 SWS UP Rates')
% subplot(1,2,2)
% title('Log scale')
% set(h,'name',[basename,'_ECellByCellRateChanges-FirstVsLastThirdPresleepSWS'])
% h = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(FirstThirdPresleepSWSUPStateISpikeRates,LastThirdPresleepSWSUPStateISpikeRates);
% subplot(1,2,1)
% title('I:First 1/3 SWS UP Rates vs Last 1/3 SWS UP Rates')
% subplot(1,2,2)
% title('Log scale')
% set(h,'name',[basename,'_ICellByCellRateChanges-FirstVsLastThirdPresleepSWS'])
% 
% %looking at percent changes per cell
% ECellPercentChangesPreWakeVsPostWake = (PostPresleepWakingESpikeRates-PrePresleepWakingESpikeRates)./PrePresleepWakingESpikeRates;
% ICellPercentChangesPreWakeVsPostWake = (PostPresleepWakingISpikeRates-PrePresleepWakingISpikeRates)./PrePresleepWakingISpikeRates;
% ECellAbsoluteChangesPreWakeVsPostWake = (PostPresleepWakingESpikeRates-PrePresleepWakingESpikeRates);
% ICellAbsoluteChangesPreWakeVsPostWake = (PostPresleepWakingISpikeRates-PrePresleepWakingISpikeRates);
% 
% ECellPercentChangesFirstLastThirdSWS = (LastThirdPresleepSWSUPStateESpikeRates-FirstThirdPresleepSWSUPStateESpikeRates)./FirstThirdPresleepSWSUPStateESpikeRates;
% ICellPercentChangesFirstLastThirdSWS = (LastThirdPresleepSWSUPStateISpikeRates-FirstThirdPresleepSWSUPStateISpikeRates)./FirstThirdPresleepSWSUPStateISpikeRates;
% ECellAbsoluteChangesFirstLastThirdSWS = (LastThirdPresleepSWSUPStateESpikeRates-FirstThirdPresleepSWSUPStateESpikeRates);
% ICellAbsoluteChangesFirstLastThirdSWS = (LastThirdPresleepSWSUPStateISpikeRates-FirstThirdPresleepSWSUPStateISpikeRates);
% 
% %histograms of those percent changes
% h=figure;
% hist(ECellPercentChangesPreWakeVsPostWake,50)
% title('Histogram of E cell Percent Rate changes from: Wake before to After presleep')
% set(h,'name',[basename,'_HistoOfECellRateChanges-PreVsPostPresleepWaking'])
% h=figure;
% hist(ICellPercentChangesPreWakeVsPostWake,50)
% title('Histogram of I cell Percent Rate changes from: Wake before to After presleep')
% set(h,'name',[basename,'_HistoOfICellRateChanges-PreVsPostPresleepWaking'])
% 
% h=figure;
% hist(ECellPercentChangesFirstLastThirdSWS,50)
% title('Histogram of E cell Percent Rate changes from: First 1/3 sleep  to Last 1/3 sleep')
% set(h,'name',[basename,'_HistoOfECellRateChanges-FirstVsLastThirdPresleepSWS'])
% h=figure;
% hist(ICellPercentChangesFirstLastThirdSWS,50)
% title('Histogram of I cell Percent Rate changes from: First 1/3 sleep  to Last 1/3 sleep')
% set(h,'name',[basename,'_HistoOfICellRateChanges-FirstVsLastThirdPresleepSWS'])
% 
% %percent change in relation to intial spike rate
% 
% h=figure;
% subplot(2,1,1);
% x = PrePresleepWakingESpikeRates;
% y = ECellPercentChangesPreWakeVsPostWake;
% plot(x,y,'marker','.','Line','none');
% [yfit,r2] =  RegressAndFindR2(x,y,1);
% hold on;plot(x,yfit,'r')
% text(0.8*max(x),0.8*max(y),['r2=',num2str(r2)])
% title('ECells Percent change in spike rate in pre vs post wake VS initial spike rate')
% subplot(2,1,2);
% x = FirstThirdPresleepSWSUPStateESpikeRates;
% y = ECellPercentChangesFirstLastThirdSWS;
% plot(x,y,'marker','.','Line','none');
% [yfit,r2] =  RegressAndFindR2(x,y,1);
% hold on;plot(x,yfit,'r')
% text(0.8*max(x),0.8*max(y),['r2=',num2str(r2)])
% title('Ecells: Change in spike rate in early vs late SWS in presleep VS initial spike rate')
% set(h,'name',[basename,'_ChangeVsInitialRate-Ecells'])
% 
% h=figure;
% subplot(2,1,1);
% x = PrePresleepWakingISpikeRates;
% y = ICellPercentChangesPreWakeVsPostWake;
% plot(x,y,'marker','.','Line','none');
% [yfit,r2] =  RegressAndFindR2(x,y,1);
% hold on;plot(x,yfit,'r')
% text(0.8*max(x),0.8*max(y),['r2=',num2str(r2)])
% title('ICells Percent change in spike rate in pre vs post wake VS initial spike rate')
% subplot(2,1,2);
% x = FirstThirdPresleepSWSUPStateISpikeRates;
% y = ICellPercentChangesFirstLastThirdSWS;
% plot(x,y,'marker','.','Line','none');
% [yfit,r2] =  RegressAndFindR2(x,y,1);
% 
% hold on;plot(x,yfit,'r')
% text(0.8*max(x),0.8*max(y),['r2=',num2str(r2)])
% title('Icells: Change in spike rate in early vs late SWS in presleep VS initial spike rate')
% set(h,'name',[basename,'_ChangeVsInitialRate-Icells'])

%save figs
if ~exist(fullfile(basepath,'CellRateDistributionFigs'),'dir')
    mkdir(fullfile(basepath,'CellRateDistributionFigs'))
end
cd(fullfile(basepath,'CellRateDistributionFigs'))
saveallfigsas('fig')
cd(basepath)

%saving neatening and arranging data for later
CellRateVariables = v2struct(AllESpikeRates,AllISpikeRates,...
    WakingESpikeRates, WakingISpikeRates);

save([basename '_CellRateVariables.mat'],'CellRateVariables')

clear AllESpikeRates AllISpikeRates ...
    WakingESpikeRates WakingISpikeRates


% load([basename '_CellRateVariables.mat'])