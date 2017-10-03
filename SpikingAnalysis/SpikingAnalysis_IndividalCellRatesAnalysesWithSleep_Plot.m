function h = SpikingAnalysis_IndividalCellRatesAnalysesWithSleep_Plot(CellRateVariables)
%% Script: SpikingAnalysis_IndividalCellRatesAnalyses
% Variables needed in work space: 
% basename, Se, Si, intervals,PreSleepUPs,UPInts
% PrePostSleepMetaData for presleep

%% Extract data to invidual variables
v2struct(CellRateVariables)
pre1E = PrewakeESpikeRates;
post1E = PostwakeESpikeRates;
pre1I = PrewakeISpikeRates;
post1I = PostwakeISpikeRates;

pre2E = FirstThirdSleepSWSESpikeRates;
post2E = LastThirdSleepSWSESpikeRates;
pre2I = FirstThirdSleepSWSISpikeRates;
post2I = LastThirdSleepSWSISpikeRates;

pre3E = FirstSWSESpikeRates;
post3E = LastSWSESpikeRates;
pre3I = FirstSWSISpikeRates;
post3I = LastSWSISpikeRates;

pre4E = First5SleepESpikeRates;
post4E = Last5SleepESpikeRates;
pre4I = First5SleepISpikeRates;
post4I = Last5SleepISpikeRates;

pre5E = Last5PreWakeESpikeRates;
post5E = First5PostWakeESpikeRates;
pre5I = Last5PreWakeISpikeRates;
post5I = First5PostWakeISpikeRates;

%% set up for plotting
h = [];
swscolor = [.1 .3 1];

%% Basic stats
% texttext = {['N Rats = ' num2str(NumRats)];...
%     ['N Sesssions = ' num2str(length(SessionNames))];...
%     ['N WSW Episodes = ' num2str(sum(numWSWEpisodes))];...
%     ['N Unique Total Cells = ' num2str(sum(numUniqueECells) + sum(numUniqueECells))];...
%     ['N Unique E Cells = ' num2str(sum(numUniqueECells))];...
%     ['N Unique I Cells = ' num2str(sum(numUniqueICells))];...
%     ['N All Cell-WSW Measures = ' num2str(length(FirstSWSESpikeRates)+length(FirstSWSESpikeRates))];...
%     ['N E Cell-WSW Measures = ' num2str(length(FirstSWSESpikeRates))];...
%     ['N I Cell-WSW Measures = ' num2str(length(FirstSWSISpikeRates))];...
%     };
% h(end+1) = figure;    
% % Create a uicontrol of type "text"
% mTextBox = uicontrol('style','text');
% title('IndividualCellRatesOverSleep')
% set(mTextBox,'Units','Normalized','Position',[.1 .1 .8 .8])
% set(mTextBox,'String',texttext)


%% Plot distribution of Individual cell spike rates
% all global spike rates for all E cells
% AllESpikeRates = CellRateVariables;
% AllISpikeRates = Rate(Si);
numECells = length(AllESpikeRates);
numICells = length(AllISpikeRates);
numbinsE = round(numECells/5);
numbinsI = round(numICells/5);

h(end+1) = PlotRateDistributionsLinearAndLog(AllESpikeRates,'numbins',numbinsE,'color',[.6 .6 .6]);
    [~] = OverlayRateDistributionsLinearAndLog(h(end),WakingESpikeRates,'numbins',numbinsE,'color','k');
    [~]  = OverlayRateDistributionsLinearAndLog(h(end),SWSESpikeRates,'numbins',numbinsE,'color',swscolor);
    [~]  = OverlayRateDistributionsLinearAndLog(h(end),REMESpikeRates,'numbins',numbinsE,'color','r');
    subplot(2,1,1)
    legend('AllSpikes','Waking','SWS','REM')
    title(['Distribution of spike rates for E cells. Linear x axis.  n=' num2str(numECells) ' E Cells'])
    subplot(2,1,2)
    title('Distribution of spike rates for E cells: Log x axis')
    set(h(end),'name',[basename,'_ECellSpikeHistosAllStates'])
if isempty(AllISpikeRates)%Icells
    h(end+1) = figure;
        title(['No ICells for ' basename])
        set(h(end),'name',[basename,'_ICellSpikeHisto-WholeRecording'])
else
    h(end+1) = PlotRateDistributionsLinearAndLog(AllISpikeRates,'numbins',numbinsI,'color',[.6 .6 .6]);
    %waking
    if isempty(WakingISpikeRates)
        legstr1 = 'NoWaking';
        subplot(2,1,1); plot(0,0,'color','k')
    else
        legstr1 = 'Waking';
        [~]  = OverlayRateDistributionsLinearAndLog(h(end),WakingISpikeRates,'numbins',numbinsI,'color','k');
    end
    %SWS
    if isempty(SWSISpikeRates)
        legstr2 = 'NoSWS';
        subplot(2,1,1); plot(0,0,'color','k')
    else
        legstr2 = 'SWS';
        [~]  = OverlayRateDistributionsLinearAndLog(h(end),SWSISpikeRates,'numbins',numbinsI,'color',swscolor);
    end
    %REM
    if isempty(SWSISpikeRates)
        legstr3 = 'NoREM';
        subplot(2,1,1); plot(0,0,'color','k')
    else
        legstr3 = 'REM';
        [~]  = OverlayRateDistributionsLinearAndLog(h(end),REMISpikeRates,'numbins',numbinsI,'color','r');
    end
    subplot(2,1,1)
    legend('AllSpikes',legstr1,legstr2,legstr3)
    title(['Distribution of spike rates for I cells. Linear x axis.  n=' num2str(numICells) ' I Cells'])
    subplot(2,1,2)
    title('Distribution of spike rates for I cells: Log x axis')
    set(h(end),'name',[basename,'_ICellSpikeHistosAllStates'])
end
    

% h(end+1) = PlotRateDistributionsLinearAndLog(WakingESpikeRates,'numbins',numbinsE);
%     subplot(2,1,1)
%     title({'Distribution of spike rates for E cells for Waking: Linear scale';...
%                 ['n = ' num2str(numECells) ' E Cells']})
%     subplot(2,1,2)
%     title('Distribution of spike rates for E cells for Waking: Semilog Scale')
%     set(h(end),'name',[basename,'_ECellSpikeHisto-AllWaking'])
% if isempty(AllISpikeRates)%Icells
%     h(end+1) = figure;
%         title(['No ICells for ' basename])
%         set(h(end),'name',[basename,'_ICellSpikeHisto-AllWaking'])
% else
%     h(end+1) = PlotRateDistributionsLinearAndLog(WakingISpikeRates,'numbins',numbinsI);
%         subplot(2,1,1)
%         title({'Distribution of spike rates for I cells for Waking: Linear scale';...
%                 ['n = ' num2str(numICells) ' I Cells']})
%         subplot(2,1,2)
%         title('Distribution of spike rates for I cells for Waking: Semilog Scale')
%         set(h(end),'name',[basename,'_ICellSpikeHisto-AllWaking'])
% end
% 
% 
% h(end+1) = PlotRateDistributionsLinearAndLog(SWSESpikeRates,'numbins',numbinsE);
%     subplot(2,1,1)
%     title({'Distribution of spike rates for E cells for SWS: Linear scale';...
%                 ['n = ' num2str(length(AllESpikeRates)) ' E Cells']})
%     subplot(2,1,2)
%     title('Distribution of spike rates for E cells for SWS: Semilog Scale')
%     set(h(end),'name',[basename,'_ECellSpikeHisto-AllPresleepSWS'])
% %     axh = AxesInset(gca,0.4)
% %     SpikingAnalysis_PlotRateDistributionsLog(SWSESpikeRates,'numbins',numbinsE)
% %     vals = get(findobj('Parent',gca,'BarLayout','grouped'),'YData');
% %     ylim([min(vals) max(vals)])
% if isempty(AllISpikeRates)%Icells
%     h(end+1) = figure;
%         title(['No ICells for ' basename])
%         set(h(end),'name',[basename,'_ICellSpikeHisto-AllPresleepSWS'])
% else
%     h(end+1) = PlotRateDistributionsLinearAndLog(SWSISpikeRates,'numbins',numbinsI);
%         subplot(2,1,1)
%         title({'Distribution of spike rates for I cells for SWS: Linear scale';...
%                 ['n = ' num2str(numICells) ' I Cells']})
%         subplot(2,1,2)
%         title('Distribution of spike rates for I cells for SWS: Semilog Scale')
%         set(h(end),'name',[basename,'_ICellSpikeHisto-AllPresleepSWS'])
% %         axh = AxesInset(gca,0.35)
% %         SpikingAnalysis_PlotRateDistributionsLog(SWSISpikeRates,'numbins',numbinsI)
% %         vals = get(findobj('Parent',gca,'BarLayout','grouped'),'YData');
% %         ylim([min(vals) max(vals)])
% end
% 
% h(end+1) = PlotRateDistributionsLinearAndLog(REMESpikeRates,'numbins',numbinsE);
%     subplot(2,1,1)
%     title({'Distribution of spike rates for E cells for REM: Linear scale';...
%                 ['n = ' num2str(length(AllESpikeRates)) ' E Cells']})
%     subplot(2,1,2)
%     title('Distribution of spike rates for E cells for REM: Semilog Scale')
%     set(h(end),'name',[basename,'_ECellSpikeHisto-AllPresleepREM'])
% %     axh = AxesInset(gca,0.4)
% %     SpikingAnalysis_PlotRateDistributionsLog(REMESpikeRates,'numbins',numbinsE)
% %     vals = get(findobj('Parent',gca,'BarLayout','grouped'),'YData');
% %     ylim([min(vals) max(vals)])
% if isempty(AllISpikeRates)%Icells
%     h(end+1) = figure;
%         title(['No ICells for ' basename])
%         set(h(end),'name',[basename,'_ICellSpikeHisto-AllPresleepREM'])
% else
%     numbins = round(length(AllISpikeRates)/10);
%     h(end+1) = PlotRateDistributionsLinearAndLog(REMISpikeRates,'numbins',numbinsI);
%         subplot(2,1,1)
%         title({'Distribution of spike rates for I cells for entire recording: Linear scale';...
%                 ['n = ' num2str(numICells) ' I Cells']})
%         subplot(2,1,2)
%         title('Distribution of spike rates for I cells for REM: Semilog Scale')
%         set(h(end),'name',[basename,'_ICellSpikeHisto-AllPresleepREM'])
% %         axh = AxesInset(gca,0.35)
% %         SpikingAnalysis_PlotRateDistributionsLog(REMISpikeRates,'numbins',numbinsI)
% %         vals = get(findobj('Parent',gca,'BarLayout','grouped'),'YData');
% %         ylim([min(vals) max(vals)])
% end

%% Plot distro of individual cell spiking rate changes over sleep (bar graph)
h = plotprepostbars(CellRateVariables,h);

%% Overlay histogram distributions before vs after sleep
h = plotprepostdistros(CellRateVariables,h);

%% Scatterplots of before vs after sleep
h = scatterplotrates(CellRateVariables,h);

%% Cell-by-cell changes in rates over various intervals in various states 
%>(see BWRat20 analysis)
% use above to do simple 2 point plots for each comparison

%Prewake vs Postwake
h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(pre1E,post1E);
    subplot(1,2,1)
    title('E:Prewake vs Postwake Rate Per cell')
    subplot(1,2,2)
    title('Log scale')
    set(h(end),'name',[basename,'_ECellByCellRateChanges-Prewake vs Postwake'])
if isempty(AllISpikeRates)%Icells
    h(end+1) = figure;
        title(['No ICells for ' basename])
        set(h(end),'name',[basename,'_ICellByCellRateChanges-Prewake vs Postwake'])
else
    h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(pre1I,post1I);
        subplot(1,2,1)
        title('I:Prewake vs Postwake Rate Per cell')
        subplot(1,2,2)
        title('Log scale')
        set(h(end),'name',[basename,'_ICellByCellRateChanges-Prewake vs Postwake'])
end

%First 1/3 SWS vs Last 1/3 SWS
h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(pre2E,post2E);
    subplot(1,2,1)
    title('E:First 1/3 SWS vs Last 1/3 SWS Rates')
    subplot(1,2,2)
    title('Log scale')
    set(h(end),'name',[basename,'_ECellByCellRateChanges-FirstVsLastThirdSleepSWS'])
if isempty(AllISpikeRates)%Icells
    h(end+1) = figure;
        title(['No ICells for ' basename])
        set(h(end),'name',[basename,'_ICellByCellRateChanges-FirstVsLastThirdSleepSWS'])
else
    h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(pre2I,post2I);
        subplot(1,2,1)
        title('I:First 1/3 SWS Rates vs Last 1/3 SWS Rates')
        subplot(1,2,2)
        title('Log scale')
        set(h(end),'name',[basename,'_ICellByCellRateChanges-FirstVsLastThirdSleepSWS'])
end

%First SWS Rates vs Last SWS
h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(pre3E,post3E);
    subplot(1,2,1)
    title('E:First SWS Rates vs Last SWS Rates')
    subplot(1,2,2)
    title('Log scale')
    set(h(end),'name',[basename,'_ECellByCellRateChanges-FirstVsLastSWS'])
if isempty(AllISpikeRates)%Icells
    h(end+1) = figure;
        title(['No ICells for ' basename])
        set(h(end),'name',[basename,'_ICellByCellRateChanges-FirstVsLastSWS'])
else
    h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(pre3I,post3I);
        subplot(1,2,1)
        title('I:First SWS Rates vs Last SWS Rates')
        subplot(1,2,2)
        title('Log scale')
        set(h(end),'name',[basename,'_ICellByCellRateChanges-FirstVsLastSWS'])
end

%First5MinSleep vs Last5MinSleep
h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(pre4E,post4E);
    subplot(1,2,1)
    title('E:First5MinSleep vs Last5MinSleep Rates')
    subplot(1,2,2)
    title('Log scale')
    set(h(end),'name',[basename,'_ECellByCellRateChanges-First5SleepVsLast5Sleep'])
if isempty(AllISpikeRates)%Icells
    h(end+1) = figure;
        title(['No ICells for ' basename])
        set(h(end),'name',[basename,'_ICellByCellRateChanges-First5SWSVsLast5Sleep'])
else
    h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(pre4I,post4I);
        subplot(1,2,1)
        title('I:First5MinSWS vs Last5MinSleep Rates')
        subplot(1,2,2)
        title('Log scale')
        set(h(end),'name',[basename,'_ICellByCellRateChanges-First5VsLast5Sleep'])
end

%Last5PreWake vs First4PostWake
h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(pre5E,post5E);
    subplot(1,2,1)
    title('E: Last5PreWake vs First5PostWake Rates')
    subplot(1,2,2)
    title('Log scale')
    set(h(end),'name',[basename,'_ECellByCellRateChanges-Last5PreVsFirst5PostWake'])
if isempty(AllISpikeRates)%Icells
    h(end+1) = figure;
        title(['No ICells for ' basename])
        set(h(end),'name',[basename,'_ICellByCellRateChanges-Last5PreVsFirst5PostWake'])
else
    h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(pre5I,post5I);
        subplot(1,2,1)
        title('I:Last5PreWake vs First5PostWake Rates')
        subplot(1,2,2)
        title('Log scale')
        set(h(end),'name',[basename,'_ICellByCellRateChanges-Last5PreVsFirst5PostWake'])
end

% %looking at percent changes per cell
%histograms of those percent changes
ESpikingRatioPrePost1 = 10.^ConditionedLogOfRatio(post1E,pre1E);
ISpikingRatioPrePost1 = 10.^ConditionedLogOfRatio(post1I,pre1I);
ESpikingRatioPrePost2 = 10.^ConditionedLogOfRatio(pre2E,post2E);
ISpikingRatioPrePost2 = 10.^ConditionedLogOfRatio(pre2I,post2I);
ESpikingRatioPrePost3 = 10.^ConditionedLogOfRatio(pre3E,post3E);
ISpikingRatioPrePost3 = 10.^ConditionedLogOfRatio(pre3I,post3I);
ESpikingRatioPrePost4 = 10.^ConditionedLogOfRatio(pre4E,post4E);
ISpikingRatioPrePost4 = 10.^ConditionedLogOfRatio(pre4I,post4I);
ESpikingRatioPrePost5 = 10.^ConditionedLogOfRatio(pre5E,post5E);
ISpikingRatioPrePost5 = 10.^ConditionedLogOfRatio(pre5I,post5I);

% h(end+1)=figure;
h(end+1) = PlotRateDistributionsLinearAndLog(ESpikingRatioPrePost1,'numbins',numbinsE);
    title('Histogram of E cell Rate Ratios from: Wake before to After sleep')
    set(h(end),'name',[basename,'_HistoOfECellRateChanges-PrewakeVsPostwake'])
if isempty(AllISpikeRates)%Icells
    h(end+1) = figure;
        title(['No ICells for ' basename])
        set(h(end),'name',[basename,'_HistoOfICellRateChanges-PrewakeVsPostwake'])
else
    h(end+1)=PlotRateDistributionsLinearAndLog(ISpikingRatioPrePost1,'numbins',numbinsI);
        title('Histogram of I cell Rate Ratios from: Wake before to After sleep')
        set(h(end),'name',[basename,'_HistoOfICellRateRatios-PrewakeVsPostwake'])
end

h(end+1)=PlotRateDistributionsLinearAndLog(ESpikingRatioPrePost2,'numbins',numbinsE);
    title('Histogram of E cell Rate Ratios from: First 1/3 sleep  to Last 1/3 sleep')
    set(h(end),'name',[basename,'_HistoOfECellRateRatios-FirstVsLastThirdSleepSWS'])
if isempty(AllISpikeRates)%Icells
    h(end+1) = figure;
        title(['No ICells for ' basename])
        set(h(end),'name',[basename,'_HistoOfICellRateRatios-FirstVsLastThirdSleepSWS'])
else
h(end+1)=PlotRateDistributionsLinearAndLog(ISpikingRatioPrePost2,'numbins',numbinsI);
        title('Histogram of I cell Rate Ratios from: First 1/3 sleep  to Last 1/3 sleep')
        set(h(end),'name',[basename,'_HistoOfICellRateRatios-FirstVsLastThirdSleepSWS'])
end

h(end+1)=PlotRateDistributionsLinearAndLog(ESpikingRatioPrePost3,'numbins',numbinsE);
    title('Histogram of E cell Rate Ratios from: First SWS  to Last SWS')
    set(h(end),'name',[basename,'_HistoOfECellRateRatios-FirstVsLastSWS'])
if isempty(AllISpikeRates)%Icells
    h(end+1) = figure;
        title(['No ICells for ' basename])
        set(h(end),'name',[basename,'_HistoOfICellRateRatios-FirstVsLastSWS'])
else
h(end+1)=PlotRateDistributionsLinearAndLog(ISpikingRatioPrePost3,'numbins',numbinsI);
        title('Histogram of I cell Rate Ratios from: First SWS to Last SWS')
        set(h(end),'name',[basename,'_HistoOfICellRateRatios-FirstVsLastSWS'])
end

h(end+1)=PlotRateDistributionsLinearAndLog(ESpikingRatioPrePost4,'numbins',numbinsE);
    title('Histogram of E cell Rate Ratios from: First SWS  to Last SWS')
    set(h(end),'name',[basename,'_HistoOfECellRateRatios-FirstVsLastSWS'])
if isempty(AllISpikeRates)%Icells
    h(end+1) = figure;
        title(['No ICells for ' basename])
        set(h(end),'name',[basename,'_HistoOfICellRateRatios-FirstVsLastSWS'])
else
h(end+1)=PlotRateDistributionsLinearAndLog(ISpikingRatioPrePost4,'numbins',numbinsI);
        title('Histogram of I cell Rate Ratios from: First SWS to Last SWS')
        set(h(end),'name',[basename,'_HistoOfICellRateRatios-FirstVsLastSWS'])
end

h(end+1)=PlotRateDistributionsLinearAndLog(ESpikingRatioPrePost5,'numbins',numbinsE);
    title('Histogram of E cell Rate Ratios from: First SWS  to Last SWS')
    set(h(end),'name',[basename,'_HistoOfECellRateRatios-FirstVsLastSWS'])
if isempty(AllISpikeRates)%Icells
    h(end+1) = figure;
        title(['No ICells for ' basename])
        set(h(end),'name',[basename,'_HistoOfICellRateRatios-FirstVsLastSWS'])
else
h(end+1)=PlotRateDistributionsLinearAndLog(ISpikingRatioPrePost5,'numbins',numbinsI);
        title('Histogram of I cell Rate Ratios rom: First SWS to Last SWS')
        set(h(end),'name',[basename,'_HistoOfICellRateRatios-FirstVsLastSWS'])
end
%percent change in relation to intial spike rate
% v2struct(CellRateVariables)

% NoInf_PrewakeESpikeRates = pre1E(~isinf(ECellPercentChangesPreWakeVsPostWake));
% NoInf_PrewakeISpikeRates = pre1I(~isinf(ICellPercentChangesPreWakeVsPostWake));
% NoInf_FirstThirdSleepSWSESpikeRates = pre2E(~isinf(ECellPercentChangesFirstLastThirdSWS));
% NoInf_FirstThirdSleepSWSISpikeRates = pre2I(~isinf(ICellPercentChangesFirstLastThirdSWS));

% Prewake/Postwake
h(end+1)=figure;
    x = pre1E;
    y = ESpikingRatioPrePost1;
    h = PlotPrepostRatioVsInitialRate(x,y,h);
    AboveTitle('ECells PostWake:PostWake Rate Ratio VS Initial Rate')
    set(h(end),'name',[basename,'_PrewakevPostwakeRateRatioVsInitialRate-Ecells'])
if isempty(AllISpikeRates)%Icells
    h(end+1) = figure;
        title(['No ICells for ' basename])
        set(h(end),'name',[basename,'_PrewakevPostwakeRateRatioVsInitialRate-Icells'])
else
    h(end+1)=figure;
        x = pre1I;
    %     x = NoInf_PrewakeESpikeRates;
        y = ISpikingRatioPrePost1;
        h = PlotPrepostRatioVsInitialRate(x,y,h);
        AboveTitle('ICells PostWake:PostWake Rate Ratio VS Initial Rate')
        set(h(end),'name',[basename,'_PrewakevPostwakeRateRatioVsInitialRate-Icells'])
end

% First/Last third
h(end+1)=figure;
    x = pre2E;
    y = ESpikingRatioPrePost2;
    h = PlotPrepostRatioVsInitialRate(x,y,h);
    AboveTitle('ECells FirstThird:LastThird Rate Ratio VS Initial Rate')
    set(h(end),'name',[basename,'_FirstThirdvLastThirdRateRatioVsInitialRate-Ecells'])
if isempty(AllISpikeRates)%Icells
    h(end+1) = figure;
        title(['No ICells for ' basename])
        set(h(end),'name',[basename,'_FirstThirdvLastThirdRateRatioVsInitialRate-Icells'])
else
    h(end+1)=figure;
        x = pre2I;
    %     x = NoInf_PrewakeESpikeRates;
        y = ISpikingRatioPrePost2;
        h = PlotPrepostRatioVsInitialRate(x,y,h);
        AboveTitle('ICells FirstThird:LastThird Rate Ratio VS Initial Rate')
        set(h(end),'name',[basename,'__FirstThirdvLastThirdRateRatioVsInitialRate-Icells'])
end


% First/Last SWS
h(end+1)=figure;
    x = pre3E;
    y = ESpikingRatioPrePost3;
    h = PlotPrepostRatioVsInitialRate(x,y,h);
    AboveTitle('ECells FirstSWS:LastSWS Rate Ratio VS Initial Rate')
    set(h(end),'name',[basename,'_FirstSWSvLastSWSRateRatioVsInitialRate-Ecells'])
if isempty(AllISpikeRates)%Icells
    h(end+1) = figure;
        title(['No ICells for ' basename])
        set(h(end),'name',[basename,'_FirstSWSvLastSWSRateRatioVsInitialRate-Icells'])
else
    h(end+1)=figure;
        x = pre3I;
    %     x = NoInf_PrewakeESpikeRates;
        y = ISpikingRatioPrePost3;
        h = PlotPrepostRatioVsInitialRate(x,y,h);
        AboveTitle('ICells FirstSWS:LastSWS Rate Ratio VS Initial Rate')
        set(h(end),'name',[basename,'_FirstSWSvLastSWSRateRatioVsInitialRate-Icells'])
end

% First/Last 5min Sleep
h(end+1)=figure;
    x = pre4E;
    y = ESpikingRatioPrePost4;
    h = PlotPrepostRatioVsInitialRate(x,y,h);
    AboveTitle('ECells First5min:Last5min Rate Ratio VS Initial Rate')
    set(h(end),'name',[basename,'_First5minvLast5minRateRatioVsInitialRate-Ecells'])
if isempty(AllISpikeRates)%Icells
    h(end+1) = figure;
        title(['No ICells for ' basename])
        set(h(end),'name',[basename,'_First5minvLast5minRateRatioVsInitialRate-Icells'])
else
    h(end+1)=figure;
        x = pre4I;
    %     x = NoInf_PrewakeESpikeRates;
        y = ISpikingRatioPrePost4;
        h = PlotPrepostRatioVsInitialRate(x,y,h);
        AboveTitle('ICells First5min:Last5min Rate Ratio VS Initial Rate')
        set(h(end),'name',[basename,'_First5minvLast5minRateRatioVsInitialRate-Icells'])
end


% Last5Prewake Vs First5Postwake
h(end+1)=figure;
    x = pre5E;
    y = ESpikingRatioPrePost5;
    h = PlotPrepostRatioVsInitialRate(x,y,h);
    AboveTitle('ECells Last5PreWk:First5PostWk Rate Ratio VS Initial Rate')
    set(h(end),'name',[basename,'_Last5PreWkvFirst5PostWkRateRatioVsInitialRate-Ecells'])
if isempty(AllISpikeRates)%Icells
    h(end+1) = figure;
        title(['No ICells for ' basename])
        set(h(end),'name',[basename,'_Last5PreWkvFirst5PostWkRateRatioVsInitialRate-Icells'])
else
    h(end+1)=figure;
        x = pre5I;
    %     x = NoInf_PrewakeESpikeRates;
        y = ISpikingRatioPrePost5;
        h = PlotPrepostRatioVsInitialRate(x,y,h);
        AboveTitle('ICells Last5PreWk:First5PostWk Rate Ratio VS Initial Rate')
        set(h(end),'name',[basename,'_Last5PreWkvFirst5PostWkRateRatioVsInitialRate-Icells'])
end







%save figs
% MakeDirSaveFigsThere('CellRateDistributionFiSpikingAnalysis_IndividalCellRatesAnalysesWithSleep_Plotgs',h)




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = plotprepostbars(CellRateVariables,h)
% Plot population rate change stats over sleep (bar graphs)... raw, by
% pre/post diff, by pre/post ratio, in E and I cells, with SD and SEM error
% bars

%% defaults
ptx = 0.2;
pty = 0.8;

%% Extract data to invidual variables
v2struct(CellRateVariables)
pre1E = PrewakeESpikeRates;
post1E = PostwakeESpikeRates;
pre1I = PrewakeISpikeRates;
post1I = PostwakeISpikeRates;

pre2E = FirstThirdSleepSWSESpikeRates;
post2E = LastThirdSleepSWSESpikeRates;
pre2I = FirstThirdSleepSWSISpikeRates;
post2I = LastThirdSleepSWSISpikeRates;

pre3E = FirstSWSESpikeRates;
post3E = LastSWSESpikeRates;
pre3I = FirstSWSISpikeRates;
post3I = LastSWSISpikeRates;

pre4E = First5SleepESpikeRates;
post4E = Last5SleepESpikeRates;
pre4I = First5SleepISpikeRates;
post4I = Last5SleepISpikeRates;

pre5E = Last5PreWakeESpikeRates;
post5E = First5PostWakeESpikeRates;
pre5I = Last5PreWakeISpikeRates;
post5I = First5PostWakeISpikeRates;


h(end+1) = figure;
    set(h(end),'name',[basename,'_EPopSpikeRateChangesSD'])
    %Raw
    subplot(3,5,1)
    hax = plot_meanSD_bars(pre1E',post1E');
    title(hax,['E:PreWake vs PostWake - Raw'])
    ylabel(hax,'Hz')
    set(hax,'XTickLabel',{'','Pre','','Post',''})    
    p = ranksum(pre1E,post1E);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)

    subplot(3,5,2)
    hax = plot_meanSD_bars(pre2E',post2E');
    title(hax,'E:First vs Last Third SWS Sleep - Raw')
    ylabel(hax,'Hz')
    set(hax,'XTickLabel',{'','1/3','','3/3',''})    
    p = ranksum(pre2E,post2E);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)

    subplot(3,5,3)
    hax = plot_meanSD_bars(pre3E',post3E');
    title(hax,'E:First vs Last SWS Sleep - Raw')
    ylabel(hax,'Hz')
    set(hax,'XTickLabel',{'','FirstSWS','','LastSWS',''})    
    p = ranksum(pre3E,post3E);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)

    subplot(3,5,4)
    hax = plot_meanSD_bars(pre4E',post4E');
    title(hax,'E:First vs Last 5min Sleep - Raw')
    ylabel(hax,'Hz')
    set(hax,'XTickLabel',{'','First5min','','Last5min',''})    
    p = ranksum(pre4E,post4E);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)

    subplot(3,5,5)
    hax = plot_meanSD_bars(pre5E',post5E');
    title(hax,'E:Last5PreWake vs First5PostWake - Raw')
    ylabel(hax,'Hz')
    set(hax,'XTickLabel',{'','Last5PreWk','','First5PostWk',''})    
    p = ranksum(pre4E,post4E);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)

    %Per cell difference
    subplot(3,5,6)
    hax = plot_meanSD_bars(pre1E-pre1E,post1E-pre1E);
    title(hax,{'E:PreWake vs PostWake Ratio';'Normalized by Prewake Rate per cell'})
    ylabel(hax,'Hz Difference')
    set(hax,'XTickLabel',{'','Pre','','Post',''})    
         %stats
    t2 = post1E-pre1E;
    p = signrank(t2);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)
    
    subplot(3,5,7)
    hax = plot_meanSD_bars(pre2E-pre2E,post2E-pre2E);
    title(hax,{'E:First vs Last Third SWS Sleep Ratio';'Normalized by First Third Rate per cell'})
    ylabel(hax,'Hz Difference')
    set(hax,'XTickLabel',{'','1/3','','3/3',''})    
        %stats
    t2 = post2E-pre2E;
    p = signrank(t2);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)
    
    subplot(3,5,8)
    hax = plot_meanSD_bars(pre3E-pre3E,post3E-pre3E);
    title(hax,{'E:First vs Last SWS Sleep Ratio';'Normalized by First SWS per cell'})
    ylabel(hax,'Hz Difference')
    set(hax,'XTickLabel',{'','FirstSWS','','LastSWS',''})    
        %stats
    t2 = post3E-pre3E;
    p = signrank(t2);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)

    subplot(3,5,9)
    hax = plot_meanSD_bars(pre4E-pre4E,post4E-pre4E);
    title(hax,{'E:First vs Last 5min Sleep Ratio';'Normalized by First 5min per cell'})
    ylabel(hax,'Hz Difference')
    set(hax,'XTickLabel',{'','First5Min','','Last5min',''})    
        %stats
    t2 = post3E-pre3E;
    p = signrank(t2);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)

    subplot(3,5,10)
    hax = plot_meanSD_bars(pre5E-pre5E,post5E-pre5E);
    title(hax,{'E:Last5Prewake vs First5Postwake Ratio';'Normalized by Last5Prewake per cell'})
    ylabel(hax,'Hz Difference')
    set(hax,'XTickLabel',{'','Last5PreWk','','First5PostWk',''})    
        %stats
    t2 = post5E-pre5E;
    p = signrank(t2);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)
    
    %Per cell ratio 
    subplot(3,5,11)
    hax = plot_geomeanoflogofratiosSD_bars(zeros(size(pre1E)),ConditionedLogOfRatio(post1E,pre1E));
    title(hax,{'E:PreWake vs PostWake Ratio';'Normalized per cell'})
    ylabel(hax,'Fold Change')
    set(hax,'XTickLabel',{'','Pre','','Post',''})    
         %stats
    t2 = ConditionedLogOfRatio(post1E,pre1E);
    p = signrank(t2);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)
 
    subplot(3,5,12)
    hax = plot_geomeanoflogofratiosSD_bars(zeros(size(pre2E)),ConditionedLogOfRatio(post2E,pre2E));
    title(hax,{'E:First vs Last Third SWS Sleep Ratio';'Normalized per cell'})
    ylabel(hax,'Fold Change')
    set(hax,'XTickLabel',{'','1/3','','3/3',''})    
        %stats
    t2 = ConditionedLogOfRatio(post2E,pre2E);
    p = signrank(t2);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)
    
    subplot(3,5,13)
    hax = plot_geomeanoflogofratiosSD_bars(zeros(size(pre3E)),ConditionedLogOfRatio(post3E,pre3E));
    title(hax,{'E:First vs Last SWS Sleep Ratio';'Normalized per cell'})
    ylabel(hax,'Fold Change')
    set(hax,'XTickLabel',{'','FirstSWS','','LastSWS',''})    
        %stats
    t2 = ConditionedLogOfRatio(post3E,pre3E);
    p = signrank(t2);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)

    subplot(3,5,14)
    hax = plot_geomeanoflogofratiosSD_bars(zeros(size(pre4E)),ConditionedLogOfRatio(post4E,pre4E));
    title(hax,{'E:First vs Last 5min Sleep Ratio';'Normalized per cell'})
    ylabel(hax,'Fold Change')
    set(hax,'XTickLabel',{'','First5min','','Last5min',''})    
        %stats
    t2 = ConditionedLogOfRatio(post4E,pre4E);
    p = signrank(t2);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)

    subplot(3,5,15)
    hax = plot_geomeanoflogofratiosSD_bars(zeros(size(pre5E)),ConditionedLogOfRatio(post5E,pre5E));
    title(hax,{'E:Last5Prewake vs Last5Postwake Ratio';'Normalized per cell'})
    ylabel(hax,'Fold Change')
    set(hax,'XTickLabel',{'','L5Prewake','','F5Postwake',''})    
        %stats
    t2 = ConditionedLogOfRatio(post5E,pre5E);
    p = signrank(t2);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)

if isempty(AllISpikeRates)%Icells
    h(end+1) = figure;
        title(['No ICells for ' basename])
        set(h(end),'name',[basename,'_ICellSpikeHisto-WholeRecording'])
else
    h(end+1) = figure;
    set(h(end),'name',[basename,'_IPopSpikeRateChangesSD'])
    %Raw
    subplot(3,5,1)
    hax = plot_meanSD_bars(pre1I',post1I');
    title(hax,['I:PreWake vs PostWake - Raw'])
    ylabel(hax,'Hz')
    set(hax,'XTickLabel',{'','Pre','','Post',''})    
    p = ranksum(pre1I,post1I);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)

    subplot(3,5,2)
    hax = plot_meanSD_bars(pre2I',post2I');
    title(hax,'I:First vs Last Third SWS Sleep - Raw')
    ylabel(hax,'Hz')
    set(hax,'XTickLabel',{'','1/3','','3/3',''})    
    p = ranksum(pre2I,post2I);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)

    subplot(3,5,3)
    hax = plot_meanSD_bars(pre3I',post3I');
    title(hax,'I:First vs Last SWS Sleep - Raw')
    ylabel(hax,'Hz')
    set(hax,'XTickLabel',{'','FirstSWS','','LastSWS',''})    
    p = ranksum(pre3I,post3I);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)

    subplot(3,5,4)
    hax = plot_meanSD_bars(pre4I',post4I');
    title(hax,'I:First vs Last 5min Sleep - Raw')
    ylabel(hax,'Hz')
    set(hax,'XTickLabel',{'','First5min','','Last5min',''})    
    p = ranksum(pre4I,post4I);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)

    subplot(3,5,5)
    hax = plot_meanSD_bars(pre5I',post5I');
    title(hax,'I:Last5PreWake vs First5PostWake - Raw')
    ylabel(hax,'Hz')
    set(hax,'XTickLabel',{'','Last5PreWk','','First5PostWk',''})    
    p = ranksum(pre4I,post4I);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)

    %Per cell difference
    subplot(3,5,6)
    hax = plot_meanSD_bars(pre1I-pre1I,post1I-pre1I);
    title(hax,{'I:PreWake vs PostWake Ratio';'Normalized by Prewake Rate per cell'})
    ylabel(hax,'Hz Difference')
    set(hax,'XTickLabel',{'','Pre','','Post',''})    
         %stats
    t2 = post1I-pre1I;
    p = signrank(t2);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)
    
    subplot(3,5,7)
    hax = plot_meanSD_bars(pre2I-pre2I,post2I-pre2I);
    title(hax,{'I:First vs Last Third SWS Sleep Ratio';'Normalized by First Third Rate per cell'})
    ylabel(hax,'Hz Difference')
    set(hax,'XTickLabel',{'','1/3','','3/3',''})    
        %stats
    t2 = post2I-pre2I;
    p = signrank(t2);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)
    
    subplot(3,5,8)
    hax = plot_meanSD_bars(pre3I-pre3I,post3I-pre3I);
    title(hax,{'I:First vs Last SWS Sleep Ratio';'Normalized by First SWS per cell'})
    ylabel(hax,'Hz Difference')
    set(hax,'XTickLabel',{'','FirstSWS','','LastSWS',''})    
        %stats
    t2 = post3I-pre3I;
    p = signrank(t2);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)

    subplot(3,5,9)
    hax = plot_meanSD_bars(pre4I-pre4I,post4I-pre4I);
    title(hax,{'I:First vs Last 5min Sleep Ratio';'Normalized by First 5min per cell'})
    ylabel(hax,'Hz Difference')
    set(hax,'XTickLabel',{'','First5Min','','Last5min',''})    
        %stats
    t2 = post3I-pre3I;
    p = signrank(t2);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)

    subplot(3,5,10)
    hax = plot_meanSD_bars(pre5I-pre5I,post5I-pre5I);
    title(hax,{'I:Last5Prewake vs First5Postwake Ratio';'Normalized by Last5Prewake per cell'})
    ylabel(hax,'Hz Difference')
    set(hax,'XTickLabel',{'','Last5PreWk','','First5PostWk',''})    
        %stats
    t2 = post5I-pre5I;
    p = signrank(t2);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)
    
    %Per cell ratio 
    subplot(3,5,11)
    hax = plot_geomeanoflogofratiosSD_bars(zeros(size(pre1I)),ConditionedLogOfRatio(post1I,pre1I));
    title(hax,{'I:PreWake vs PostWake Ratio';'Normalized per cell'})
    ylabel(hax,'Fold Change')
    set(hax,'XTickLabel',{'','Pre','','Post',''})    
         %stats
    t2 = ConditionedLogOfRatio(post1I,pre1I);
    p = signrank(t2);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)
 
    subplot(3,5,12)
    hax = plot_geomeanoflogofratiosSD_bars(zeros(size(pre2I)),ConditionedLogOfRatio(post2I,pre2I));
    title(hax,{'I:First vs Last Third SWS Sleep Ratio';'Normalized per cell'})
    ylabel(hax,'Fold Change')
    set(hax,'XTickLabel',{'','1/3','','3/3',''})    
        %stats
    t2 = ConditionedLogOfRatio(post2I,pre2I);
    p = signrank(t2);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)
    
    subplot(3,5,13)
    hax = plot_geomeanoflogofratiosSD_bars(zeros(size(pre3I)),ConditionedLogOfRatio(post3I,pre3I));
    title(hax,{'I:First vs Last SWS Sleep Ratio';'Normalized per cell'})
    ylabel(hax,'Fold Change')
    set(hax,'XTickLabel',{'','FirstSWS','','LastSWS',''})    
        %stats
    t2 = ConditionedLogOfRatio(post3I,pre3I);
    p = signrank(t2);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)

    subplot(3,5,14)
    hax = plot_geomeanoflogofratiosSD_bars(zeros(size(pre4I)),ConditionedLogOfRatio(post4I,pre4I));
    title(hax,{'I:First vs Last 5min Sleep Ratio';'Normalized per cell'})
    ylabel(hax,'Fold Change')
    set(hax,'XTickLabel',{'','First5min','','Last5min',''})    
        %stats
    t2 = ConditionedLogOfRatio(post4I,pre4I);
    p = signrank(t2);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)

    subplot(3,5,15)
    hax = plot_geomeanoflogofratiosSD_bars(zeros(size(pre5I)),ConditionedLogOfRatio(post5I,pre5I));
    title(hax,{'I:Last5Prewake vs Last5Postwake Ratio';'Normalized per cell'})
    ylabel(hax,'Fold Change')
    set(hax,'XTickLabel',{'','L5Prewake','','F5Postwake',''})    
        %stats
    t2 = ConditionedLogOfRatio(post5I,pre5I);
    p = signrank(t2);
    xl = get(hax,'xlim');
    yl = get(hax,'ylim');
    text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)
end

%% SEM

%%%%%
function h = plotprepostdistros(CellRateVariables,h);
v2struct(CellRateVariables)

pre1E = PrewakeESpikeRates;
post1E = PostwakeESpikeRates;
pre1I = PrewakeISpikeRates;
post1I = PostwakeISpikeRates;

pre2E = FirstThirdSleepSWSESpikeRates;
post2E = LastThirdSleepSWSESpikeRates;
pre2I = FirstThirdSleepSWSISpikeRates;
post2I = LastThirdSleepSWSISpikeRates;

pre3E = FirstSWSESpikeRates;
post3E = LastSWSESpikeRates;
pre3I = FirstSWSISpikeRates;
post3I = LastSWSISpikeRates;

pre4E = First5SleepESpikeRates;
post4E = Last5SleepESpikeRates;
pre4I = First5SleepISpikeRates;
post4I = Last5SleepISpikeRates;

pre5E = Last5PreWakeESpikeRates;
post5E = First5PostWakeESpikeRates;
pre5I = Last5PreWakeISpikeRates;
post5I = First5PostWakeISpikeRates;

numECells = length(AllESpikeRates);
numICells = length(AllISpikeRates);
numbinsE = round(numECells/5);
numbinsI = round(numICells/5);
% swscolor = [.1 .3 1];


h(end+1) = PlotRateDistributionsLinearAndLog(pre1E,'numbins',numbinsE,'color','k');
    OverlayRateDistributionsLinearAndLog(h(end),post1E,'numbins',numbinsE,'color',[.3 .5 .9])
    subplot(2,1,1)
    legend('Prewake','Postwake')
    title(['Distribution of spike rates for E cells for pre vs post wake: Linear scale''n = ' num2str(numECells) ' E Cells'])
    hold on
    subplot(2,1,2)
    title('Distribution of spike rates for E cells for pre vs post wake: Semilog Scale')
    set(h(end),'name',[basename,'_ECellPrePostWakeHistoOverlay'])
if isempty(pre1I) | isempty(post1I)
    h(end+1) = figure;
        title(['No Pre/Post ICells for this recording'])
%         set(h(end),'name',[basename,'_ECellPrePostWakeHistoOverlay'])
else
    h(end+1) = PlotRateDistributionsLinearAndLog(pre1I,'numbins',numbinsI,'color','k');
    OverlayRateDistributionsLinearAndLog(h(end),post1I,'numbins',numbinsI,'color',[.3 .5 .9])
    subplot(2,1,1)
    legend('Prewake','Postwake')
    title(['Distribution of spike rates for I cells for pre vs post wake: Linear scale''n = ' num2str(numICells) ' I Cells'])
    hold on
    subplot(2,1,2)
    title('Distribution of spike rates for I cells for pre vs post wake: Semilog Scale')
    set(h(end),'name',[basename,'_ICellPrePostWakeHistoOverlay'])
end
    
h(end+1) = PlotRateDistributionsLinearAndLog(pre2E,'numbins',numbinsE,'color','k');
    OverlayRateDistributionsLinearAndLog(h(end),post2E,'numbins',numbinsE,'color',[.3 .5 .9])
    subplot(2,1,1)
    legend('FirstThirdSWS','LastThirdSWS')
    title(['Distribution of spike rates for E cells for first vs last third SWS: Linear scale''n = ' num2str(numECells) ' E Cells'])
    hold on
    subplot(2,1,2)
    title('Distribution of spike rates for E cells for first vs last third SWS: Semilog Scale')
    set(h(end),'name',[basename,'_ECellFirstLastThirdSWSHistoOverlay'])
if isempty(pre2I) | isempty(post2I)
    h(end+1) = figure;
        title(['No First/Last Third SWS ICells for this recording'])
        set(h(end),'name',[basename,'_ICellFirstLastThirdSWSHistoOverlay'])
else
    h(end+1) = PlotRateDistributionsLinearAndLog(pre2I,'numbins',numbinsI,'color','k');
    OverlayRateDistributionsLinearAndLog(h(end),post2I,'numbins',numbinsI,'color',[.3 .5 .9])
    subplot(2,1,1)
    legend('FirstThirdSWS','LastThirdSWS')
    title(['Distribution of spike rates for I cells for first vs last third SWS: Linear scale''n = ' num2str(numICells) ' I Cells'])
    hold on
    subplot(2,1,2)
    title('Distribution of spike rates for I cells for first vs last third SWS: Semilog Scale')
    set(h(end),'name',[basename,'_ICellFirstLastThirdSWSHistoOverlay'])
end

h(end+1) = PlotRateDistributionsLinearAndLog(pre3E,'numbins',numbinsE,'color','k');
    OverlayRateDistributionsLinearAndLog(h(end),post3E,'numbins',numbinsE,'color',[.3 .5 .9])
    subplot(2,1,1)
    legend('FirstSWS','LastSWS')
    title(['Distribution of spike rates for E cells for first vs last SWS: Linear scale''n = ' num2str(numECells) ' E Cells'])
    hold on
    subplot(2,1,2)
    title('Distribution of spike rates for E cells for first vs last SWS: Semilog Scale')
    set(h(end),'name',[basename,'_ECellFirstLastSWSHistoOverlay'])
if isempty(pre3I) | isempty(post3I)
    h(end+1) = figure;
        title(['No First/Last SWS ICells for this recording'])
        set(h(end),'name',[basename,'_ICellFirstLastSWSHistoOverlay'])
else
    h(end+1) = PlotRateDistributionsLinearAndLog(pre3I,'numbins',numbinsI,'color','k');
    OverlayRateDistributionsLinearAndLog(h(end),post3I,'numbins',numbinsI,'color',[.3 .5 .9])
    subplot(2,1,1)
    legend('FirstSWS','LastSWS')
    title(['Distribution of spike rates for I cells for first vs last SWS: Linear scale''n = ' num2str(numICells) ' I Cells'])
    hold on
    subplot(2,1,2)
    title('Distribution of spike rates for I cells for first vs last SWS: Semilog Scale')
    set(h(end),'name',[basename,'_ICellFirstLastSWSHistoOverlay'])
end


h(end+1) = PlotRateDistributionsLinearAndLog(pre4E,'numbins',numbinsE,'color','k');
    OverlayRateDistributionsLinearAndLog(h(end),post4E,'numbins',numbinsE,'color',[.3 .5 .9])
    subplot(2,1,1)
    legend('First5minSleep','Last5minSleep')
    title(['Distribution of spike rates for E cells for first vs last 5min Sleep: Linear scale''n = ' num2str(numECells) ' E Cells'])
    hold on
    subplot(2,1,2)
    title('Distribution of spike rates for E cells for first vs last 5min sleep: Semilog Scale')
    set(h(end),'name',[basename,'_ECellFirstLast5MinSleepHistoOverlay'])
if isempty(pre3I) | isempty(post3I)
    h(end+1) = figure;
        title(['No First/Last SWS ICells for this recording'])
        set(h(end),'name',[basename,'_ICellFirstLast5MinSleepHistoOverlay'])
else
    h(end+1) = PlotRateDistributionsLinearAndLog(pre4I,'numbins',numbinsI,'color','k');
    OverlayRateDistributionsLinearAndLog(h(end),post4I,'numbins',numbinsI,'color',[.3 .5 .9])
    subplot(2,1,1)
    legend('FirstSWS','LastSWS')
    title(['Distribution of spike rates for I cells for first vs last 5min sleep: Linear scale''n = ' num2str(numICells) ' I Cells'])
    hold on
    subplot(2,1,2)
    title('Distribution of spike rates for I cells for first vs last 5min sleep: Semilog Scale')
    set(h(end),'name',[basename,'_ICellFirstLast5MinSleepHistoOverlay'])
end


h(end+1) = PlotRateDistributionsLinearAndLog(pre5E,'numbins',numbinsE,'color','k');
    OverlayRateDistributionsLinearAndLog(h(end),post5E,'numbins',numbinsE,'color',[.3 .5 .9])
    subplot(2,1,1)
    legend('Last5PreWake','First5PostWake')
    title(['Distribution of spike rates for E cells for Last5minPreWake vs First5MinPostWake: Linear scale''n = ' num2str(numECells) ' E Cells'])
    hold on
    subplot(2,1,2)
    title('Distribution of spike rates for E cells for Last5minPreWake vs First5MinPostWake: Semilog Scale')
    set(h(end),'name',[basename,'_ECellPreWk5VsPostWk5HistoOverlay'])
if isempty(pre3I) | isempty(post3I)
    h(end+1) = figure;
        title(['No First/Last SWS ICells for this recording'])
        set(h(end),'name',[basename,'_ICellPreWk5VsPostWk5HistoOverlay'])
else
    h(end+1) = PlotRateDistributionsLinearAndLog(pre5I,'numbins',numbinsI,'color','k');
    OverlayRateDistributionsLinearAndLog(h(end),post5I,'numbins',numbinsI,'color',[.3 .5 .9])
    subplot(2,1,1)
    legend('Last5PreWake','First5PostWake')
    title(['Distribution of spike rates for I cells for Last5minPreWake vs First5MinPostWake: Linear scale''n = ' num2str(numICells) ' I Cells'])
    hold on
    subplot(2,1,2)
    title('Distribution of spike rates for I cells for Last5minPreWake vs First5MinPostWake: Semilog Scale')
    set(h(end),'name',[basename,'_ICellPreWk5VsPostWk5HistoOverlay'])
end


function h = scatterplotrates(CellRateVariables,h)
ptx = 0.2;
pty = 0.8;

v2struct(CellRateVariables)

pre1E = PrewakeESpikeRates;
post1E = PostwakeESpikeRates;
pre1I = PrewakeISpikeRates;
post1I = PostwakeISpikeRates;

pre2E = FirstThirdSleepSWSESpikeRates;
post2E = LastThirdSleepSWSESpikeRates;
pre2I = FirstThirdSleepSWSISpikeRates;
post2I = LastThirdSleepSWSISpikeRates;

pre3E = FirstSWSESpikeRates;
post3E = LastSWSESpikeRates;
pre3I = FirstSWSISpikeRates;
post3I = LastSWSISpikeRates;

pre4E = First5SleepESpikeRates;
post4E = Last5SleepESpikeRates;
pre4I = First5SleepISpikeRates;
post4I = Last5SleepISpikeRates;

pre5E = Last5PreWakeESpikeRates;
post5E = First5PostWakeESpikeRates;
pre5I = Last5PreWakeISpikeRates;
post5I = First5PostWakeISpikeRates;


h(end+1) = figure;
set(h(end),'name',[basename,'_EPrePostScatterPlotsLinear'])

hax = subplot(3,2,1);
plot(pre1E,post1E,'.k');
[yfit,r,p] =  RegressAndFindR(pre1E,post1E);
hold on
plot(pre1E,yfit,'r');
xlabel('Prewake')
ylabel('Postwake')
xl = get(hax,'xlim');
yl = get(hax,'ylim');
plot([0 max([xl(2) yl(2)])],[0 max([xl(2) yl(2)])],'color',[.5 .5 .5])
% text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)

hax = subplot(3,2,2);
plot(pre2E,post2E,'.k');
[yfit,r,p] =  RegressAndFindR(pre2E,post2E);
hold on
plot(pre2E,yfit,'r');
xlabel('FirstThirdSWS')
ylabel('LastThirdSWS')
xl = get(hax,'xlim');
yl = get(hax,'ylim');
plot([0 max([xl(2) yl(2)])],[0 max([xl(2) yl(2)])],'color',[.5 .5 .5])
% text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)

hax = subplot(3,2,3);
plot(pre3E,post3E,'.k');
[yfit,r,p] =  RegressAndFindR(pre3E,post3E);
hold on
plot(pre3E,yfit,'r');
xlabel('FirstSWS')
ylabel('LastSWS')
xl = get(hax,'xlim');
yl = get(hax,'ylim');
plot([0 max([xl(2) yl(2)])],[0 max([xl(2) yl(2)])],'color',[.5 .5 .5])
% text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)

hax = subplot(3,2,4);
plot(pre4E,post4E,'.k');
[yfit,r,p] =  RegressAndFindR(pre4E,post4E);
hold on
plot(pre4E,yfit,'r');
ylabel('First5min')
xlabel('Last5min')
xl = get(hax,'xlim');
yl = get(hax,'ylim');
plot([0 max([xl(2) yl(2)])],[0 max([xl(2) yl(2)])],'color',[.5 .5 .5])
% text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)

hax = subplot(3,2,5);
plot(pre5E,post5E,'.k');
[yfit,r,p] =  RegressAndFindR(pre5E,post5E);
hold on
plot(pre5E,yfit,'r');
ylabel('Last5PreWk')
xlabel('First5PostWk')
xl = get(hax,'xlim');
yl = get(hax,'ylim');
plot([0 max([xl(2) yl(2)])],[0 max([xl(2) yl(2)])],'color',[.5 .5 .5])
% text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)

% 
% h(end+1) = figure;
% set(h(end),'name',[basename,'_EPrePostScatterPlotsLog'])
% 
% hax = subplot(3,2,1);
% x = pre1E;
% y = post1E;
% x(x==0|y==0) = min(x(x>0));
% y(x==0|y==0) = min(y(y>0));
% x = log10(x);
% y = log10(y);
% % x1 = pre1E;
% % y1 = pre2E;
% 
% plot(x,y,'.k');
% [yfit,r,p] =  RegressAndFindR(x,y);
% hold on
% plot(x,yfit,'r');
% ylabel('Prewake')
% xlabel('Postwake')
% xl = get(hax,'xlim');
% yl = get(hax,'ylim');
% val = max(abs([xl yl]));
% plot([-val val],[-val val],'color',[.5 .5 .5])
% set(hax,'XTickLabel',10.^(get(hax,'XTick')))
% set(hax,'YTickLabel',10.^(get(hax,'YTick')))
% % text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)
% 
% hax = subplot(3,2,2);
% plot(pre2E,post2E,'.k');
% [yfit,r,p] =  RegressAndFindR(pre2E,post2E);
% hold on
% plot(pre2E,yfit,'r');
% ylabel('FirstThirdSWS')
% xlabel('LastThirdSWS')
% xl = get(hax,'xlim');
% yl = get(hax,'ylim');
% plot([0 max([xl(2) yl(2)])],[0 max([xl(2) yl(2)])],'color',[.5 .5 .5])
% % text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)
% 
% hax = subplot(3,2,3);
% plot(pre3E,post3E,'.k');
% [yfit,r,p] =  RegressAndFindR(pre3E,post3E);
% hold on
% plot(pre3E,yfit,'r');
% ylabel('FirstSWS')
% xlabel('LastSWS')
% xl = get(hax,'xlim');
% yl = get(hax,'ylim');
% plot([0 max([xl(2) yl(2)])],[0 max([xl(2) yl(2)])],'color',[.5 .5 .5])
% % text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)
% 
% hax = subplot(3,2,4);
% plot(pre4E,post4E,'.k');
% [yfit,r,p] =  RegressAndFindR(pre4E,post4E);
% hold on
% plot(pre4E,yfit,'r');
% ylabel('First5min')
% xlabel('Last5min')
% xl = get(hax,'xlim');
% yl = get(hax,'ylim');
% plot([0 max([xl(2) yl(2)])],[0 max([xl(2) yl(2)])],'color',[.5 .5 .5])
% % text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)
% 
% hax = subplot(3,2,5);
% plot(pre5E,post5E,'.k');
% [yfit,r,p] =  RegressAndFindR(pre5E,post5E);
% hold on
% plot(pre5E,yfit,'r');
% ylabel('Last5PreWk')
% xlabel('First5PostWk')
% xl = get(hax,'xlim');
% yl = get(hax,'ylim');
% plot([0 max([xl(2) yl(2)])],[0 max([xl(2) yl(2)])],'color',[.5 .5 .5])
% % text(xl(2)*ptx,yl(2)*pty,['p=' num2str(p)],'parent',hax)
%     

function h = PlotPrepostRatioVsInitialRate(x,y,h)
hax = subplot(2,1,1);
    plot(x,y,'marker','.','Line','none');
    [yfit,r,p] =  RegressAndFindR(x,y,1);
    hold on;
    plot(x,yfit,'r')
    xl = xlim(hax);
    yl = ylim(hax);
    xlim(hax,[max([0.8*xl(1) -100]) min([0.8*xl(2) 100])])
    ylim(hax,[max([0.8*yl(1) -100]) min([0.8*yl(2) 100])])
    xl = xlim(hax);
    yl = ylim(hax);
    text(0.8*xl(2),0.8*yl(2),{['r = ',num2str(r)];['p = ',num2str(p)]})    
    ylabel(hax,'Ratio of post:pre rate')
subplot(2,1,2);
    x(x==0) = min(x(x>0));
    y(y==0) = min(y(y>0));
    x = log10(x);
    y = log10(y);
    plot(x,y,'marker','.','Line','none');
    [yfit,r,p] =  RegressAndFindR(x,y,1);
    hold on;
    plot(x,yfit,'r')
    text(0.8*max(x),0.8*max(y),{['r=',num2str(r)];['p=',num2str(p)]})
%     title('Ecells: Change in spike rate in early vs late SWS VS initial spike rate')
    xlabel('Cell initial spike rate')
    ylabel('Log Ratio post/pre spike rate')
    set(gca,'XTickLabel',10.^get(gca,'XTick'))
    set(gca,'YTickLabel',10.^get(gca,'YTick'))