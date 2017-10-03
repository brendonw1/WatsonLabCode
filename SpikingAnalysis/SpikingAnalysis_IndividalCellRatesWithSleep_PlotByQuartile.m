function h = SpikingAnalysis_IndividalCellRatesWithSleep_PlotByQuartile(CellRateVariables)
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
h(end+1) = SpikingAnalysis_PlotRateDistributionsLinearAndLogByQuartile(AllESpikeRates);
    subplot(2,1,1)
    title('Distribution of spike rates for E cells for entire recording: Linear scale')
    subplot(2,1,2)
    title('Distribution of spike rates for E cells for entire recording: Semilog Scale')
    set(h(end),'name',[basename,'_ECellSpikeHisto-WholeRecording'])
h(end+1) = SpikingAnalysis_PlotRateDistributionsLinearAndLogByQuartile(AllISpikeRates);
    subplot(2,1,1)
    title('Distribution of spike rates for I cells for entire recording: Linear scale')
    subplot(2,1,2)
    title('Distribution of spike rates for I cells for entire recording: Semilog Scale')
    set(h(end),'name',[basename,'_ICellSpikeHisto-WholeRecording'])

    
h(end+1) = SpikingAnalysis_PlotRateDistributionsLinearAndLogByQuartile(WakingESpikeRates);
    subplot(2,1,1)
    title('Distribution of spike rates for E cells for All Waking: Linear scale')
    subplot(2,1,2)
    title('Distribution of spike rates for E cells for All Waking: Semilog Scale')
    set(h(end),'name',[basename,'_ECellSpikeHisto-AllWaking'])
h(end+1) = SpikingAnalysis_PlotRateDistributionsLinearAndLogByQuartile(WakingISpikeRates);
    subplot(2,1,1)
    title('Distribution of spike rates for I cells for All Waking: Linear scale')
    subplot(2,1,2)
    title('Distribution of spike rates for I cells for All Waking: Semilog Scale')
    set(h(end),'name',[basename,'_ICellSpikeHisto-AllWaking'])
    
h(end+1) = SpikingAnalysis_PlotRateDistributionsLinearAndLogByQuartile(SWSESpikeRates);
    subplot(2,1,1)
    title('Distribution of spike rates for E cells for SWS: Linear scale')
    subplot(2,1,2)
    title('Distribution of spike rates for E cells for SWS: Semilog Scale')
    set(h(end),'name',[basename,'_ECellSpikeHisto-AllPresleepREM'])
h(end+1) = SpikingAnalysis_PlotRateDistributionsLinearAndLogByQuartile(SWSISpikeRates);
    subplot(2,1,1)
    title('Distribution of spike rates for I cells for SWS: Linear scale')
    subplot(2,1,2)
    title('Distribution of spike rates for I cells for SWS: Semilog Scale')
    set(h(end),'name',[basename,'_ICellSpikeHisto-AllPresleepREM'])

    
h(end+1) = SpikingAnalysis_PlotRateDistributionsLinearAndLogByQuartile(REMESpikeRates);
    subplot(2,1,1)
    title('Distribution of spike rates for E cells for REM: Linear scale')
    subplot(2,1,2)
    title('Distribution of spike rates for E cells for REM: Semilog Scale')
    set(h(end),'name',[basename,'_ECellSpikeHisto-AllPresleepREM'])
h(end+1) = SpikingAnalysis_PlotRateDistributionsLinearAndLogByQuartile(REMISpikeRates);
    subplot(2,1,1)
    title('Distribution of spike rates for I cells for REM: Linear scale')
    subplot(2,1,2)
    title('Distribution of spike rates for I cells for REM: Semilog Scale')
    set(h(end),'name',[basename,'_ICellSpikeHisto-AllPresleepREM'])

    
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

%% Cell-by-cell changes in rates over various intervals in various states 
%>(see BWRat20 analysis)
% use above to do simple 2 point plots for each comparison

quartileidxs = logQuartiles(PrewakeESpikeRates);
h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLogByQuartile(PrewakeESpikeRates,PostwakeESpikeRates,quartileidxs);
    subplot(1,3,1)
    title({['E Cells. n=',num2str(length(quartileidxs))]; 'Prewake vs Postwake Linear Scale Cell by Cell Rate Changes.';'By quadrant, Quadrant means in solid lines'})
    subplot(1,3,2)
    title({['E Cell Log Scale Rate Changes.'];'';''})
    subplot(1,3,3)
    title({'Number of increasing (up) vs'; 'decreasing (down) cells per quadrant'})
quartileidxs = logQuartiles(PrewakeISpikeRates);
h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLogByQuartile(PrewakeISpikeRates,PostwakeISpikeRates,quartileidxs);
    subplot(1,3,1)
    title({['I Cells. n=',num2str(length(quartileidxs))]; 'Prewake vs Postwake Linear Scale Cell by Cell Rate Changes.';'By quadrant, Quadrant means in solid lines'})
    subplot(1,3,2)
    title({['I Cell Log Scale Rate Changes.'];'';''})
    subplot(1,3,3)
    title({'Number of increasing (up) vs'; 'decreasing (down) cells per quadrant'})

quartileidxs = logQuartiles(FirstThirdSleepSWSESpikeRates);    
h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLogByQuartile(FirstThirdSleepSWSESpikeRates,LastThirdSleepSWSESpikeRates,quartileidxs);
    subplot(1,3,1)
    title({['E Cells. n=',num2str(length(quartileidxs))]; '1st vs Last Third SWS Rates Linear Scale Cell by Cell Rate Changes.';'By quadrant, Quadrant means in solid lines'})
    subplot(1,3,2)
    title({['E Cell Log Scale Rate Changes.'];'';''})
    subplot(1,3,3)
    title({'Number of increasing (up) vs'; 'decreasing (down) cells per quadrant'})
quartileidxs = logQuartiles(FirstThirdSleepSWSISpikeRates);
h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLogByQuartile(FirstThirdSleepSWSISpikeRates,LastThirdSleepSWSISpikeRates,quartileidxs);
    subplot(1,3,1)
    title({['I Cells. n=',num2str(length(quartileidxs))]; '1st vs Last Third SWS Rates Linear Scale Cell by Cell Rate Changes.';'By quadrant, Quadrant means in solid lines'})
    subplot(1,3,2)
    title({['I Cell Log Scale Rate Changes.'];'';''})
    subplot(1,3,3)
    title({'Number of increasing (up) vs'; 'decreasing (down) cells per quadrant'})
    
%% Control figures... reverse order of histograms and therefore which cells put in which quartiles
quartileidxs = logQuartiles(PostwakeESpikeRates);
h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLogByQuartile(PostwakeESpikeRates,PrewakeESpikeRates,quartileidxs);
    subplot(1,3,1)
    title({['CONTROL FIGURE: E Cells. n=',num2str(length(quartileidxs))]; 'POSTwake vs PREwake Linear Scale Cell by Cell Rate Changes.';'By quadrant, Quadrant means in solid lines'})
    subplot(1,3,2)
    title({['E Cell Log Scale Rate Changes.'];'';''})
    subplot(1,3,3)
    title({'Number of increasing (up) vs'; 'decreasing (down) cells per quadrant'})
quartileidxs = logQuartiles(PostwakeISpikeRates);
h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLogByQuartile(PostwakeISpikeRates,PrewakeISpikeRates,quartileidxs);
    subplot(1,3,1)
    title({['CONTROL FIGURE: I Cells. n=',num2str(length(quartileidxs))]; 'POSTwake vs PREwake Linear Scale Cell by Cell Rate Changes.';'By quadrant, Quadrant means in solid lines'})
    subplot(1,3,2)
    title({['I Cell Log Scale Rate Changes.'];'';''})
    subplot(1,3,3)
    title({'Number of increasing (up) vs'; 'decreasing (down) cells per quadrant'})

quartileidxs = logQuartiles(LastThirdSleepSWSESpikeRates);    
h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLogByQuartile(LastThirdSleepSWSESpikeRates,FirstThirdSleepSWSESpikeRates,quartileidxs);
    subplot(1,3,1)
    title({['CONTROL FIGURE: E Cells. n=',num2str(length(quartileidxs))]; 'LAST VS FIRST Third SWS Rates Linear Scale Cell by Cell Rate Changes.';'By quadrant, Quadrant means in solid lines'})
    subplot(1,3,2)
    title({['E Cell Log Scale Rate Changes.'];'';''})
    subplot(1,3,3)
    title({'Number of increasing (up) vs'; 'decreasing (down) cells per quadrant'})
quartileidxs = logQuartiles(LastThirdSleepSWSISpikeRates);    
h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLogByQuartile(LastThirdSleepSWSISpikeRates,FirstThirdSleepSWSISpikeRates,quartileidxs);
    subplot(1,3,1)
    title({['CONTROL FIGURE: I Cells. n=',num2str(length(quartileidxs))]; 'LAST VS FIRST Third SWS Rates Linear Scale Cell by Cell Rate Changes.';'By quadrant, Quadrant means in solid lines'})
    subplot(1,3,2)
    title({['I Cell Log Scale Rate Changes.'];'';''})
    subplot(1,3,3)
    title({'Number of increasing (up) vs'; 'decreasing (down) cells per quadrant'})

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
