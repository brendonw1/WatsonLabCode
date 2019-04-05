function h = SpikingAnalysis_IndividalCellRatesAnalysesWithSleep_PlotByQuartile(CellRateVariables)
%% Script: SpikingAnalysis_IndividalCellRatesAnalyses
% Variables needed in work space: 
% basename, Se, Si, intervals,PreSleepUPs,UPInts
% PrePostSleepMetaData for presleep

%% Extract data to invidual variables
v2struct(CellRateVariables)

%% set up for plotting
h = [];


%% Plot distribution of Individual cell spike rates
% all global spike rates for all E cells
% AllESpikeRates = CellRateVariables;
% AllISpikeRates = Rate(Si);
h(end+1) = SpikingAnalysis_PlotRateDistributionsLinearAndLog(AllESpikeRates);
    subplot(2,1,1)
    title('Distribution of spike rates for E cells for entire recording: Linear scale')
    subplot(2,1,2)
    title('Distribution of spike rates for E cells for entire recording: Semilog Scale')
    set(h(end),'name',[basename,'_ECellSpikeHisto-WholeRecording'])
h(end+1) = SpikingAnalysis_PlotRateDistributionsLinearAndLog(AllISpikeRates);
    subplot(2,1,1)
    title('Distribution of spike rates for I cells for entire recording: Linear scale')
    subplot(2,1,2)
    title('Distribution of spike rates for I cells for entire recording: Semilog Scale')
    set(h(end),'name',[basename,'_ICellSpikeHisto-WholeRecording'])

    
% %State-specific rate distributions
% WakingESpikeRates = Rate(Se,intervals{1});
% WakingISpikeRates = Rate(Si,intervals{1});
% SWSESpikeRates = Rate(Se,intersect(intervals{3},GoodSleepInterval));
% SWSISpikeRates = Rate(Si,intersect(intervals{3},GoodSleepInterval));
% % PreSleepUPs = intersect(UPInts,PrePostSleepMetaData.presleepInt);
% % UPStateESpikeRates = Rate(Se,PreSleepUPs);
% % UPStateISpikeRates = Rate(Si,PreSleepUPs);
% REMESpikeRates = Rate(Se,intersect(intervals{5},GoodSleepInterval));
% REMISpikeRates = Rate(Si,intersect(intervals{5},GoodSleepInterval));

h(end+1) = SpikingAnalysis_PlotRateDistributionsLinearAndLog(WakingESpikeRates);
    subplot(2,1,1)
    title('Distribution of spike rates for E cells for All Waking: Linear scale')
    subplot(2,1,2)
    title('Distribution of spike rates for E cells for All Waking: Semilog Scale')
    set(h(end),'name',[basename,'_ECellSpikeHisto-AllWaking'])
h(end+1) = SpikingAnalysis_PlotRateDistributionsLinearAndLog(WakingISpikeRates);
    subplot(2,1,1)
    title('Distribution of spike rates for I cells for All Waking: Linear scale')
    subplot(2,1,2)
    title('Distribution of spike rates for I cells for All Waking: Semilog Scale')
    set(h(end),'name',[basename,'_ICellSpikeHisto-AllWaking'])
    
h(end+1) = SpikingAnalysis_PlotRateDistributionsLinearAndLog(SWSESpikeRates);
    subplot(2,1,1)
    title('Distribution of spike rates for E cells for SWS: Linear scale')
    subplot(2,1,2)
    title('Distribution of spike rates for E cells for SWS: Semilog Scale')
    set(h(end),'name',[basename,'_ECellSpikeHisto-AllPresleepREM'])
h(end+1) = SpikingAnalysis_PlotRateDistributionsLinearAndLog(SWSISpikeRates);
    subplot(2,1,1)
    title('Distribution of spike rates for I cells for SWS: Linear scale')
    subplot(2,1,2)
    title('Distribution of spike rates for I cells for SWS: Semilog Scale')
    set(h(end),'name',[basename,'_ICellSpikeHisto-AllPresleepREM'])
% h(end+1) = SpikingAnalysis_PlotRateDistributionsLinearAndLog(UPStateESpikeRates);
%     subplot(2,1,1)
%     title('Distribution of spike rates for E cells for Presleep SWS-UPStates: Linear scale')
%     subplot(2,1,2)
%     title('Distribution of spike rates for E cells for Presleep SWS-UPStates: Semilog Scale')
%     set(h(end),'name',[basename,'_ECellSpikeHisto-AllPresleepUPStates'])
% h(end+1) = SpikingAnalysis_PlotRateDistributionsLinearAndLog(UPStateISpikeRates);
%     subplot(2,1,1)
%     title('Distribution of spike rates for I cells for Presleep SWS-UPStates: Linear scale')
%     subplot(2,1,2)
%     title('Distribution of spike rates for I cells for Presleep SWS-UPStates: Semilog Scale')
%     set(h(end),'name',[basename,'_ICellSpikeHisto-AllPresleepUPStates'])

h(end+1) = SpikingAnalysis_PlotRateDistributionsLinearAndLog(REMESpikeRates);
    subplot(2,1,1)
    title('Distribution of spike rates for E cells for REM: Linear scale')
    subplot(2,1,2)
    title('Distribution of spike rates for E cells for REM: Semilog Scale')
    set(h(end),'name',[basename,'_ECellSpikeHisto-AllPresleepREM'])
h(end+1) = SpikingAnalysis_PlotRateDistributionsLinearAndLog(REMISpikeRates);
    subplot(2,1,1)
    title('Distribution of spike rates for I cells for REM: Linear scale')
    subplot(2,1,2)
    title('Distribution of spike rates for I cells for REM: Semilog Scale')
    set(h(end),'name',[basename,'_ICellSpikeHisto-AllPresleepREM'])

% % Comparisons of before/early vs after/late sleep epochs
% % % cat together all intervals from all WSWs
% % preSleepWakes = intervalSet([],[]);
% % for a=1:length(length(WSWEpisodes));
% %     preSleepWakes = cat(preSleepWakes,subset(WSWEpisodes{a},1));
% % end
% preSleepWakes = subset(WSWEpisodes{1},1);% just first WSW (see above)
% PrewakeESpikeRates = Rate(Se,preSleepWakes);
% PrewakeISpikeRates = Rate(Si,preSleepWakes);
% 
% % % cat together all intervals from all WSWs
% % postSleepWakes = intervalSet([],[]);
% % for a=1:length(length(WSWEpisodes));
% %     postSleepWakes = cat(postSleepWakes,subset(WSWEpisodes{a},3));
% % end
% postSleepWakes = subset(WSWEpisodes{1},3);% just first WSW (see immediate above)
% PostwakeESpikeRates = Rate(Se,postSleepWakes);
% PostwakeISpikeRates = Rate(Si,postSleepWakes);
% % prepresleepWakes = find(End(intervals{1})<=FirstTime(PrePostSleepMetaData.presleepInt));
% % PrePresleepWakingESpikeRates = Rate(Se,subset(intervals{1},prepresleepWakes(end)));
% % PrePresleepWakingISpikeRates = Rate(Si,subset(intervals{1},prepresleepWakes(end)));
% % postpresleepWakes = find(Start(intervals{1})>=LastTime(PrePostSleepMetaData.presleepInt));
% % PostPresleepWakingESpikeRates = Rate(Se,subset(intervals{1},postpresleepWakes(1)));
% % PostPresleepWakingISpikeRates = Rate(Si,subset(intervals{1},postpresleepWakes(1)));
% 
% sleepthirds = regIntervals(subset(WSWEpisodes{1},2),3);
% FirstThirdSleepSWSESpikeRates = Rate(Se,intersect(sleepthirds{1},intervals{3}));
% LastThirdSleepSWSESpikeRates = Rate(Se,intersect(sleepthirds{3},intervals{3}));
% FirstThirdSleepSWSISpikeRates = Rate(Si,intersect(sleepthirds{1},intervals{3}));
% LastThirdSleepSWSISpikeRates = Rate(Si,intersect(sleepthirds{3},intervals{3}));

% FirstThirdSleepREMESpikeRates = Rate(Se,intersect(sleepthirds{1},intervals{5}));
% LastThirdSleepREMESpikeRates = Rate(Se,intersect(sleepthirds{3},intervals{5}));
% FirstThirdSleepREMISpikeRates = Rate(Si,intersect(sleepthirds{1},intervals{5}));
% LastThirdSleepREMISpikeRates = Rate(Si,intersect(sleepthirds{3},intervals{5}));


% EndFirstThirdSleep = (Start(PrePostSleepMetaData.presleepInt))+Data(length(PrePostSleepMetaData.presleepInt))/3;
% StartLastThirdSleep = (Start(PrePostSleepMetaData.presleepInt))+(Data(length(PrePostSleepMetaData.presleepInt))*2/3);
% % 
% % FirstThirdPresleepREM = intersect(PrePostSleepMetaData.presleepREMlist, ...
% %     find(End(intervals{5})<=EndFirstThirdPresleep));
% % FirstPresleepREMESpikeRates = Rate(Se,subset(intervals{5},FirstThirdPresleepREM));
% % LastThirdPresleepREM = intersect(PrePostSleepMetaData.presleepREMlist, ...
% %     find(Start(intervals{5})>=StartLastThirdPresleep));
% % LastPresleepREMESpikeRates = Rate(Se,subset(intervals{5},LastThirdPresleepREM));
% 
% SleepFirstThirdUPsList = find(Start(UPInts)>=Start(PrePostSleepMetaData.presleepInt) & End(UPInts)<=EndFirstThirdSleep);
% % PresleepFirstSWSUPs = intersect(UPInts,subset(intervals{3},PrePostSleepMetaData.presleepSWSlist(1:3)));
% FirstThirdSleepSWSUPStateESpikeRates = Rate(Se,subset(UPInts,SleepFirstThirdUPsList));
% FirstThirdSleepSWSUPStateISpikeRates = Rate(Si,subset(UPInts,SleepFirstThirdUPsList));
% SleepLastThirdUPsList = find(Start(UPInts)>=StartLastThirdSleep & End(UPInts)<=End(PrePostSleepMetaData.presleepInt));
% % PresleepLastSWSUPs = intersect(UPInts,subset(intervals{3},PrePostSleepMetaData.presleepSWSlist(end-3:end)));
% LastThirdSleepSWSUPStateESpikeRates = Rate(Se,subset(UPInts,SleepLastThirdUPsList));
% LastThirdSleepSWSUPStateISpikeRates = Rate(Si,subset(UPInts,SleepLastThirdUPsList));



% h(end+1) = SpikingAnalysis_PlotRateDistributionsLinearAndLog(PrewakeESpikeRates,PostwakeESpikeRates);
%     subplot(2,2,1)
%     title('E:Pre-sleep Waking')
%     subplot(2,2,2)
%     title('E:Post-sleep Waking')
%     set(h(end),'name',[basename,'_ECellSpikeHisto-PreVsPostwake'])
% h(end+1) = SpikingAnalysis_PlotRateDistributionsLinearAndLog(PrewakeISpikeRates,PostwakeISpikeRates);
%     subplot(2,2,1)
%     title('I:Pre-sleep Waking')
%     subplot(2,2,2)
%     title('I:Post-sleep Waking')
%     set(h(end),'name',[basename,'_ICellSpikeHisto-PreVsPostwake'])
% % % h = SpikingAnalysis_PlotRateDistributionsLinearAndLog(FirstPresleepREMESpikeRates,LastPresleepREMESpikeRates);
% % %     subplot(2,1,1)
% % %     title('Pre-Presleep Waking')
% % %     subplot(2,1,2)
% % %     title('Post-Presleep Waking')
% % %     set(h,'name',[basename,'_CellSpikeHisto-PreVsPostPresleepWaking'])
% % h(end+1) = SpikingAnalysis_PlotRateDistributionsLinearAndLog(FirstThirdSleepSWSUPStateESpikeRates,LastThirdSleepSWSUPStateESpikeRates);
% %     subplot(2,2,1)
% %     title('E:Presleep 1st 1/3 SWS UP Rates')
% %     subplot(2,2,2)
% %     title('E:Presleep 1st 1/3 SWS UP Rates')
% %     set(h(end),'name',[basename,'_ECellSpikeHisto-FirstVsLastThirdPresleepSWS'])
% % h(end+1) = SpikingAnalysis_PlotRateDistributionsLinearAndLog(FirstThirdPresleepSWSUPStateISpikeRates,LastThirdSleepSWSUPStateISpikeRates);
% %     subplot(2,2,1)
% %     title('I:Presleep 1st 1/3 SWS UP Rates')
% %     subplot(2,2,2)
% %     title('I:Presleep 1st 1/3 SWsed here:S UP Rates')
% %     set(h(end),'name',[basename,'_ICellSpikeHisto-FirstVsLastThirdPresleepSWS'])
% 
% % %save figs
% % if ~exist(fullfile(basepath,'CellRateDistributionFigs'),'dir')
% %     mkdir(fullfile(basepath,'CellRateDistributionFigs'))
% % end
% % cd(fullfile(basepath,'CellRateDistributionFigs'))
% % saveallfigsas('fig')
% % cd(basepath)
% %     

% %% Prepare data by eliminating cases of NaN or Inf or -Inf
% [PrewakeESpikeRates,PostwakeESpikeRates] = ElimAnyNanInf(PrewakeESpikeRates,PostwakeESpikeRates);
% [PrewakeISpikeRates,PostwakeISpikeRates] = ElimAnyNanInf(PrewakeISpikeRates,PostwakeISpikeRates);
% [PrewakeEESpikeRates,PostwakeEESpikeRates] = ElimAnyNanInf(PrewakeEESpikeRates,PostwakeEESpikeRates);
% [PrewakeEISpikeRates,PostwakeEISpikeRate] = ElimAnyNanInf(PrewakeEISpikeRates,PostwakeEISpikeRate);
% [PrewakeIESpikeRates,PostwakeIESpikeRates] = ElimAnyNanInf(PrewakeIESpikeRates,PostwakeIESpikeRates);
% [PrewakeIISpikeRates,PostwakeIISpikeRates] = ElimAnyNanInf(PrewakeIISpikeRates,PostwakeIISpikeRates);


%% Plot pop spiking rate changes over sleep (bar graph)
h(end+1) = figure;
    subplot(1,2,1)
    plot_meanSD_bars(PrewakeESpikeRates',PostwakeESpikeRates');
    title(['E:Pre-Presleep Waking vs Post-Presleep Waking'])
    subplot(1,2,2)
    plot_meanSEM_bars(PrewakeESpikeRates',PostwakeESpikeRates');
    title('SEM')
    set(h(end),'name',[basename,'_EPopSpikeRateChanges-PreVsPostWake'])
h(end+1) = figure;
    subplot(1,2,1)
    plot_meanSD_bars(PrewakeISpikeRates',PostwakeISpikeRates');
    title(['I:Pre-Presleep Waking vs Post-Presleep Waking'])
    subplot(1,2,2)
    plot_meanSEM_bars(PrewakeISpikeRates',PostwakeISpikeRates');
    title('SEM')
    set(h(end),'name',[basename,'_IPopSpikeRateChanges-PreVsPostWake'])
% h(end+1) = figure;
%     subplot(1,2,1)
%     plot_meanSD_bars(PrewakeEESpikeRates',PostwakeEESpikeRates');
%     title(['EE:Pre-Presleep Waking vs Post-Presleep Waking'])
%     subplot(1,2,2)
%     plot_meanSEM_bars(PrewakeEESpikeRates',PrewakeEESpikeRates');
%     title('SEM')
%     set(h(end),'name',[basename,'_EEPopSpikeRateChanges-PreVsPostWake'])
% h(end+1) = figure;
%     subplot(1,2,1)
%     plot_meanSD_bars(PrewakeEISpikeRates',PostwakeEISpikeRates');
%     title(['EI:Pre-Presleep Waking vs Post-Presleep Waking'])
%     subplot(1,2,2)
%     plot_meanSEM_bars(PrewakeEISpikeRates',PrewakeEISpikeRates');
%     title('SEM')
%     set(h(end),'name',[basename,'_EIPopSpikeRateChanges-PreVsPostWake'])
% h(end+1) = figure;
%     subplot(1,2,1)
%     plot_meanSD_bars(PrewakeIESpikeRates',PostwakeIESpikeRates');
%     title(['E:Pre-Presleep Waking vs Post-Presleep Waking'])
%     subplot(1,2,2)
%     plot_meanSEM_bars(PrewakeIESpikeRates',PrewakeIESpikeRates');
%     title('SEM')
%     set(h(end),'name',[basename,'_IEPopSpikeRateChanges-PreVsPostWake'])
% h(end+1) = figure;
%     subplot(1,2,1)
%     plot_meanSD_bars(PrewakeIISpikeRates',PostwakeIISpikeRates');
%     title(['II:Pre-Presleep Waking vs Post-Presleep Waking'])
%     subplot(1,2,2)
%     plot_meanSEM_bars(PrewakeIISpikeRates',PrewakeIISpikeRates');
%     title('SEM')



%% Cell-by-cell changes in rates over various intervals in various states 
%>(see BWRat20 analysis)
% use above to do simple 2 point plots for each comparison

h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(PrewakeESpikeRates,PostwakeESpikeRates);
    subplot(1,2,1)
    title('E:Prewake vs Postwake Rate Per cell')
    subplot(1,2,2)
    title('Log scale')
    set(h(end),'name',[basename,'_ECellByCellRateChanges-Prewake vs Postwake'])
h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(PrewakeISpikeRates,PostwakeISpikeRates);
    subplot(1,2,1)
    title('I:Prewake vs Postwake Rate Per cell')
    subplot(1,2,2)
    title('Log scale')
    set(h(end),'name',[basename,'_ICellByCellRateChanges-Prewake vs Postwake'])

h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(FirstThirdSleepSWSESpikeRates,LastThirdSleepSWSESpikeRates);
    subplot(1,2,1)
    title('E:First 1/3 SWS Rates vs Last 1/3 SWS Rates')
    subplot(1,2,2)
    title('Log scale')
    set(h(end),'name',[basename,'_ECellByCellRateChanges-FirstVsLastThirdSleepSWS'])
h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(FirstThirdSleepSWSISpikeRates,LastThirdSleepSWSISpikeRates);
    subplot(1,2,1)
    title('I:First 1/3 SWS Rates vs Last 1/3 SWS Rates')
    subplot(1,2,2)
    title('Log scale')
    set(h(end),'name',[basename,'_ICellByCellRateChanges-FirstVsLastThirdSleepSWS'])

% %looking at percent changes per cell
% ECellPercentChangesPreWakeVsPostWake = (PostwakeESpikeRates-PrewakeESpikeRates)./PrewakeESpikeRates;
% ICellPercentChangesPreWakeVsPostWake = (PostwakeISpikeRates-PrewakeISpikeRates)./PrewakeISpikeRates;
% ECellAbsoluteChangesPreWakeVsPostWake = (PostwakeESpikeRates-PrewakeESpikeRates);
% ICellAbsoluteChangesPreWakeVsPostWake = (PostwakeISpikeRates-PrewakeISpikeRates);
% 
% ECellPercentChangesFirstLastThirdSWS = (LastThirdSleepSWSESpikeRates-FirstThirdSleepSWSESpikeRates)./FirstThirdSleepSWSESpikeRates;
% ICellPercentChangesFirstLastThirdSWS = (LastThirdSleepSWSISpikeRates-FirstThirdSleepSWSISpikeRates)./FirstThirdSleepSWSISpikeRates;
% ECellAbsoluteChangesFirstLastThirdSWS = (LastThirdSleepSWSESpikeRates-FirstThirdSleepSWSESpikeRates);
% ICellAbsoluteChangesFirstLastThirdSWS = (LastThirdSleepSWSISpikeRates-FirstThirdSleepSWSISpikeRates);

%histograms of those percent changes
h(end+1)=figure;
    hist(ECellPercentChangesPreWakeVsPostWake,50)
    title('Histogram of E cell Percent Rate changes from: Wake before to After sleep')
    set(h(end),'name',[basename,'_HistoOfECellRateChanges-PrewakeVsPostwake'])
h(end+1)=figure;
    hist(ICellPercentChangesPreWakeVsPostWake,50)
    title('Histogram of I cell Percent Rate changes from: Wake before to After sleep')
    set(h(end),'name',[basename,'_HistoOfICellRateChanges-PrewakeVsPostwake'])

h(end+1)=figure;
    hist(ECellPercentChangesFirstLastThirdSWS,50)
    title('Histogram of E cell Percent Rate changes from: First 1/3 sleep  to Last 1/3 sleep')
    set(h(end),'name',[basename,'_HistoOfECellRateChanges-FirstVsLastThirdSleepSWS'])
h(end+1)=figure;
    hist(ICellPercentChangesFirstLastThirdSWS,50)
    title('Histogram of I cell Percent Rate changes from: First 1/3 sleep  to Last 1/3 sleep')
    set(h(end),'name',[basename,'_HistoOfICellRateChanges-FirstVsLastThirdSleepSWS'])

%percent change in relation to intial spike rate
v2struct(CellRateVariables)

h(end+1)=figure;
    subplot(2,1,1);
    x = PrewakeESpikeRates;
    y = ECellPercentChangesPreWakeVsPostWake;
    plot(x,y,'marker','.','Line','none');
    [yfit,r2] =  RegressAndFindR2(x,y,1);
    hold on;plot(x,yfit,'r')
    text(0.8*max(x),0.8*max(y),['r2=',num2str(r2)])
    title('ECells Percent change in spike rate in pre vs post wake VS initial spike rate')
    subplot(2,1,2);
    x = FirstThirdSleepSWSESpikeRates;
    y = ECellPercentChangesFirstLastThirdSWS;
    plot(x,y,'marker','.','Line','none');
    [yfit,r2] =  RegressAndFindR2(x,y,1);
    hold on;plot(x,yfit,'r')
    text(0.8*max(x),0.8*max(y),['r2=',num2str(r2)])
    title('Ecells: Change in spike rate in early vs late SWS VS initial spike rate')
    set(h(end),'name',[basename,'_ChangeVsInitialRate-Ecells'])

h(end+1)=figure;
    subplot(2,1,1);
    x = PrewakeISpikeRates;
    y = ICellPercentChangesPreWakeVsPostWake;
    plot(x,y,'marker','.','Line','none');
    [yfit,r2] =  RegressAndFindR2(x,y,1);
    hold on;plot(x,yfit,'r')
    text(0.8*max(x),0.8*max(y),['r2=',num2str(r2)])
    title('ICells Percent change in spike rate in pre vs post wake VS initial spike rate')
    subplot(2,1,2);
    x = FirstThirdSleepSWSISpikeRates;
    y = ICellPercentChangesFirstLastThirdSWS;
    plot(x,y,'marker','.','Line','none');
    [yfit,r2] =  RegressAndFindR2(x,y,1);
    hold on;plot(x,yfit,'r')
    text(0.8*max(x),0.8*max(y),['r2=',num2str(r2)])
    title('Icells: Change in spike rate in early vs late SWS VS initial spike rate')
    set(h(end),'name',[basename,'_ChangeVsInitialRate-Icells'])

%save figs
if ~exist(fullfile(basepath,'CellRateDistributionFigs'),'dir')
    mkdir(fullfile(basepath,'CellRateDistributionFigs'))
end
cd(fullfile(basepath,'CellRateDistributionFigs'))
% !rm -R * %remove all old figs
savethesefigsas(h,'fig')
% savethesefigsas(h,'eps')
cd(basepath)

% %saving neatening and arranging data for later
% CellRateVariables = v2struct(AllESpikeRates,AllISpikeRates,...
%     WakingESpikeRates, WakingISpikeRates,...
%     REMESpikeRates,REMISpikeRates,...
%     PrewakeESpikeRates,PrewakeISpikeRates,...
%     PostwakeESpikeRates,PostwakeISpikeRates,...
%     FirstThirdSleepSWSESpikeRates,FirstThirdSleepSWSISpikeRates,...
%     LastThirdSleepSWSESpikeRates,LastThirdSleepSWSISpikeRates,...
%     ECellPercentChangesPreWakeVsPostWake, ICellPercentChangesPreWakeVsPostWake,...
%     ECellAbsoluteChangesPreWakeVsPostWake, ICellAbsoluteChangesPreWakeVsPostWake,...
%     ECellPercentChangesFirstLastThirdSWS, ICellPercentChangesFirstLastThirdSWS,...
%     ECellAbsoluteChangesFirstLastThirdSWS, ICellAbsoluteChangesFirstLastThirdSWS);
% %     UPStateESpikeRates,UPStateISpikeRates,...
% 
% save([basename '_CellRateVariables.mat'],'CellRateVariables')

% clear AllESpikeRates AllISpikeRates ...
%     WakingESpikeRates WakingISpikeRates ...
%     UPStateESpikeRates UPStateISpikeRates ...
%     REMESpikeRates REMISpikeRates ...
%     PrePresleepWakingESpikeRates PrePresleepWakingISpikeRates ...
%     PostPresleepWakingESpikeRates PostPresleepWakingISpikeRates ...
%     FirstThirdPresleepSWSUPStateESpikeRates irstThirdPresleepSWSUPStateISpikeRates ...
%     LastThirdPresleepSWSU(end+1)PStateESpikeRates LastThirdPresleepSWSUPStateISpikeRates ...
%     ECellPercentChangesPreWakeVsPostWake ICellPercentChangesPreWakeVsPostWake ...
%     ECellAbsoluteChangesPreWakeVsPostWake ICellAbsoluteChangesPreWakeVsPostWake ...
%     ECellPercentChangesFirstLastThirdSWS ICellPercentChangesFirstLastThirdSWS ...
%     ECellAbsoluteChangesFirstLastThirdSWS ICellAbsoluteChangesFirstLastThirdSWS ...
%     PreSleepUPs PresleepFirstThirdUPsList PresleepFirstThirdUPsList ...
%     prepresleepWakes postpresleepWakes


% load([basename '_CellRateVariables.mat'])











%% OLD... also run as a script not a function
%% Script: SpikingAnalysis_IndividalCellRatesAnalyses
% Variables needed in work space: 
% basename, Se, Si, intervals,PreSleepUPs,UPInts
% PrePostSleepMetaData for presleep
% 
% %% Plot distribution of Individual cell spike rates
% % all global spike rates for all E cells
% AllESpikeRates = Rate(Se);
% AllISpikeRates = Rate(Si);
% h = SpikingAnalysis_PlotRateDistributionsLinearAndLog(AllESpikeRates);
%     subplot(2,1,1)
%     title('Distribution of spike rates for E cells for entire recording: Linear scale')
%     subplot(2,1,2)
%     title('Distribution of spike rates for E cells for entire recording: Semilog Scale')
%     set(h,'name',[basename,'_ECellSpikeHisto-WholeRecording'])
% h = SpikingAnalysis_PlotRateDistributionsLinearAndLog(AllISpikeRates);
%     subplot(2,1,1)
%     title('Distribution of spike rates for I cells for entire recording: Linear scale')
%     subplot(2,1,2)
%     title('Distribution of spike rates for I cells for entire recording: Semilog Scale')
%     set(h,'name',[basename,'_ICellSpikeHisto-WholeRecording'])
% 
% %State-specific rate distributions
% WakingESpikeRates = Rate(Se,intervals{1});
% WakingISpikeRates = Rate(Si,intervals{1});
% PreSleepUPs = intersect(UPInts,PrePostSleepMetaData.presleepInt);
% UPStateESpikeRates = Rate(Se,PreSleepUPs);
% UPStateISpikeRates = Rate(Si,PreSleepUPs);
% REMESpikeRates = Rate(Se,subset(intervals{5},PrePostSleepMetaData.presleepREMlist));
% REMISpikeRates = Rate(Si,subset(intervals{5},PrePostSleepMetaData.presleepREMlist));
% 
% h = SpikingAnalysis_PlotRateDistributionsLinearAndLog(WakingESpikeRates);
%     subplot(2,1,1)
%     title('Distribution of spike rates for E cells for All Waking: Linear scale')
%     subplot(2,1,2)
%     title('Distribution of spike rates for E cells for All Waking: Semilog Scale')
%     set(h,'name',[basename,'_ECellSpikeHisto-AllWaking'])
% h = SpikingAnalysis_PlotRateDistributionsLinearAndLog(WakingISpikeRates);
%     subplot(2,1,1)
%     title('Distribution of spike rates for I cells for All Waking: Linear scale')
%     subplot(2,1,2)
%     title('Distribution of spike rates for I cells for All Waking: Semilog Scale')
%     set(h,'name',[basename,'_ICellSpikeHisto-AllWaking'])
%     
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
% 
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
% 
% % Comparisons of before/early vs after/late sleep epochs, all related to
% % presleep
% prepresleepWakes = find(End(intervals{1})<=FirstTime(PrePostSleepMetaData.presleepInt));
% PrePresleepWakingESpikeRates = Rate(Se,subset(intervals{1},prepresleepWakes(end)));
% PrePresleepWakingISpikeRates = Rate(Si,subset(intervals{1},prepresleepWakes(end)));
% postpresleepWakes = find(Start(intervals{1})>=LastTime(PrePostSleepMetaData.presleepInt));
% PostPresleepWakingESpikeRates = Rate(Se,subset(intervals{1},postpresleepWakes(1)));
% PostPresleepWakingISpikeRates = Rate(Si,subset(intervals{1},postpresleepWakes(1)));
% 
% EndFirstThirdPresleep = (Start(PrePostSleepMetaData.presleepInt))+Data(length(PrePostSleepMetaData.presleepInt))/3;
% StartLastThirdPresleep = (Start(PrePostSleepMetaData.presleepInt))+(Data(length(PrePostSleepMetaData.presleepInt))*2/3);
% % 
% % FirstThirdPresleepREM = intersect(PrePostSleepMetaData.presleepREMlist, ...
% %     find(End(intervals{5})<=EndFirstThirdPresleep));
% % FirstPresleepREMESpikeRates = Rate(Se,subset(intervals{5},FirstThirdPresleepREM));
% % LastThirdPresleepREM = intersect(PrePostSleepMetaData.presleepREMlist, ...
% %     find(Start(intervals{5})>=StartLastThirdPresleep));
% % LastPresleepREMESpikeRates = Rate(Se,subset(intervals{5},LastThirdPresleepREM));
% 
% PresleepFirstThirdUPsList = find(Start(UPInts)>=Start(PrePostSleepMetaData.presleepInt) & End(UPInts)<=EndFirstThirdPresleep);
% % PresleepFirstSWSUPs = intersect(UPInts,subset(intervals{3},PrePostSleepMetaData.presleepSWSlist(1:3)));
% FirstThirdPresleepSWSUPStateESpikeRates = Rate(Se,subset(UPInts,PresleepFirstThirdUPsList));
% FirstThirdPresleepSWSUPStateISpikeRates = Rate(Si,subset(UPInts,PresleepFirstThirdUPsList));
% PresleepLastThirdUPsList = find(Start(UPInts)>=StartLastThirdPresleep & End(UPInts)<=End(PrePostSleepMetaData.presleepInt));
% % PresleepLastSWSUPs = intersect(UPInts,subset(intervals{3},PrePostSleepMetaData.presleepSWSlist(end-3:end)));
% LastThirdPresleepSWSUPStateESpikeRates = Rate(Se,subset(UPInts,PresleepLastThirdUPsList));
% LastThirdPresleepSWSUPStateISpikeRates = Rate(Si,subset(UPInts,PresleepLastThirdUPsList));
% 
% h = SpikingAnalysis_PlotRateDistributionsLinearAndLog(PrePresleepWakingESpikeRates,PostPresleepWakingESpikeRates);
%     subplot(2,2,1)
%     title('E:PPre-Presleep Waking')
%     subplot(2,2,2)
%     title('E:Post-Presleep Waking')
%     set(h,'name',[basename,'_ECellSpikeHisto-PreVsPostPresleepWaking'])
% h = SpikingAnalysis_PlotRateDistributionsLinearAndLog(PrePresleepWakingISpikeRates,PostPresleepWakingISpikeRates);
%     subplot(2,2,1)
%     title('I:PPre-Presleep Waking')
%     subplot(2,2,2)
%     title('I:Post-Presleep Waking')
%     set(h,'name',[basename,'_ICellSpikeHisto-PreVsPostPresleepWaking'])
% % h = SpikingAnalysis_PlotRateDistributionsLinearAndLog(FirstPresleepREMESpikeRates,LastPresleepREMESpikeRates);
% %     subplot(2,1,1)
% %     title('Pre-Presleep Waking')
% %     subplot(2,1,2)
% %     title('Post-Presleep Waking')
% %     set(h,'name',[basename,'_CellSpikeHisto-PreVsPostPresleepWaking'])
% h = SpikingAnalysis_PlotRateDistributionsLinearAndLog(FirstThirdPresleepSWSUPStateESpikeRates,LastThirdPresleepSWSUPStateESpikeRates);
%     subplot(2,2,1)
%     title('E:Presleep 1st 1/3 SWS UP Rates')
%     subplot(2,2,2)
%     title('E:Presleep 1st 1/3 SWS UP Rates')
%     set(h,'name',[basename,'_ECellSpikeHisto-FirstVsLastThirdPresleepSWS'])
% h = SpikingAnalysis_PlotRateDistributionsLinearAndLog(FirstThirdPresleepSWSUPStateISpikeRates,LastThirdPresleepSWSUPStateISpikeRates);
%     subplot(2,2,1)
%     title('I:Presleep 1st 1/3 SWS UP Rates')
%     subplot(2,2,2)
%     title('I:Presleep 1st 1/3 SWS UP Rates')
%     set(h,'name',[basename,'_ICellSpikeHisto-FirstVsLastThirdPresleepSWS'])
% 
% %save figs
% if ~exist(fullfile(basepath,'CellRateDistributionFigs'),'dir')
%     mkdir(fullfile(basepath,'CellRateDistributionFigs'))
% end
% cd(fullfile(basepath,'CellRateDistributionFigs'))
% saveallfigsas('fig')
% cd(basepath)
%     
% 
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
% %percent change in relation to intial spike ratehttp://klusters.sourceforge.net/howto.html
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
% 
% %save figs
% if ~exist(fullfile(basepath,'CellRateDistributionFigs'),'dir')
%     mkdir(fullfile(basepath,'CellRateDistributionFigs'))
% end
% cd(fullfile(basepath,'CellRateDistributionFigs'))
% saveallfigsas('fig')
% cd(basepath)
% 
% %saving neatening and arranging data for later
% CellRateVariables = v2struct(AllESpikeRates,AllISpikeRates,...
%     WakingESpikeRates, WakingISpikeRates,...
%     UPStateESpikeRates,UPStateISpikeRates,...
%     REMESpikeRates,REMISpikeRates,...
%     PrePresleepWakingESpikeRates,PrePresleepWakingISpikeRates,...
%     PostPresleepWakingESpikeRates,PostPresleepWakingISpikeRates,...
%     FirstThirdPresleepSWSUPStateESpikeRates,FirstThirdPresleepSWSUPStateISpikeRates,...
%     LastThirdPresleepSWSUPStateESpikeRates,LastThirdPresleepSWSUPStateISpikeRates,...
%     ECellPercentChangesPreWakeVsPostWake, ICellPercentChangesPreWakeVsPostWake,...
%     ECellAbsoluteChangesPreWakeVsPostWake, ICellAbsoluteChangesPreWakeVsPostWake,...
%     ECellPercentChangesFirstLastThirdSWS, ICellPercentChangesFirstLastThirdSWS,...
%     ECellAbsoluteChangesFirstLastThirdSWS, ICellAbsoluteChangesFirstLastThirdSWS);
% 
% save([basename '_CellRateVariables.mat'],'CellRateVariables')
% 
% clear AllESpikeRates AllISpikeRates ...
%     WakingESpikeRates WakingISpikeRates ...
%     UPStateESpikeRates UPStateISpikeRates ...
%     REMESpikeRates REMISpikeRates ...
%     PrePresleepWakingESpikeRates PrePresleepWakingISpikeRates ...
%     PostPresleepWakingESpikeRates PostPresleepWakingISpikeRates ...
%     FirstThirdPresleepSWSUPStateESpikeRates irstThirdPresleepSWSUPStateISpikeRates ...
%     LastThirdPresleepSWSUPStateESpikeRates LastThirdPresleepSWSUPStateISpikeRates ...
%     ECellPercentChangesPreWakeVsPostWake ICellPercentChangesPreWakeVsPostWake ...
%     ECellAbsoluteChangesPreWakeVsPostWake ICellAbsoluteChangesPreWakeVsPostWake ...
%     ECellPercentChangesFirstLastThirdSWS ICellPercentChangesFirstLastThirdSWS ...
%     ECellAbsoluteChangesFirstLastThirdSWS ICellAbsoluteChangesFirstLastThirdSWS ...
%     PreSleepUPs PresleepFirstThirdUPsList PresleepFirstThirdUPsList ...
%     prepresleepWakes postpresleepWakes
% 
% 
% % load([basename '_CellRateVariables.mat'])