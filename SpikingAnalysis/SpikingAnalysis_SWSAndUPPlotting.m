function [SWSMeasures, UPMeasures] =  SpikingAnalysis_SWSAndUPPlotting...
    (basename,S,Se,Si,UPInts,DNInts,intervals,PrePostSleepMetaData)


%% Organizaional scheme
%MEASURE
% Duration
% Start
% Stop
% MeanTime
% Count
% Rate
% UPCount (if SWS)
% UPRate (if SWS)
% NumUPs (if SWS)
% Incid 
%TIME
% Per: SWS
% Per: UP
% Per: DOWN
%GENERATOR
% Per: AllCells
% Per: EachCell
% Per: EachECell
% Per: EachICell
% Per: EClass
% Per: IClass
%
% 
% SWS MEASURES
% DurationPerSWS = (1D array xSWS)
% StartPerSWS = (1D array xSWS)
% StopPerSWS = (1D array xSWS)
% MeanTimePerSWS = (1D array xSWS)
% NumUpsPerSWS = (1D array xSWS)
%
% CountPerSWSPerAllCells = (1D array xSWS) 
% CountPerSWSPerEachCell = (2D array xCell xSWS) 
% CountPerSWSPerEachECell = (2D array xECell xSWS) 
% CountPerSWSPerEachICell = (2D array xICell xSWS) 
% CountPerSWSPerEClass = (1D array xSWS) 
% CountPerSWSPerIClass = (1D array xSWS) 
% 
% RatePerSWSPerAllCells = (1D array xSWS) 
% RatePerSWSPerEachCell = (2D array xCell xSWS) 
% RatePerSWSPerEachECell = (2D array xECell xSWS) 
% RatePerSWSPerEachICell = (2D array xECell xSWS) 
% RatePerSWSPerEClass = (1D array xSWS) 
% RatePerSWSPerIClass = (1D array xSWS) 
% 
% UPCountPerSWSPerAllCells = (1D array xSWS) 
% UPCountPerSWSPerEachCell = (2D array xCell xSWS) 
% UPCountPerSWSPerEachECell = (2D array xECell xSWS) 
% UPCountPerSWSPerEachICell = (2D array xICell xSWS) 
% UPCountPerSWSPerEClass = (1D array xSWS) 
% UPCountPerSWSPerIClass = (1D array xSWS) 
%
% UPRatePerSWSPerAllCells = (1D array xSWS) 
% UPRatePerSWSPerEachCell = (2D array xCell xSWS) 
% UPRatePerSWSPerEachECell = (2D array xECell xSWS) 
% UPRatePerSWSPerEachICell = (2D array xICell xSWS) 
% UPRatePerSWSPerEClass = (1D array xSWS) 
% UPRatePerSWSPerIClass = (1D array xSWS) 
%
% UP MEASURES
% DurationPerUP = length...(1D array xUP)
% StartPerUP = (1D array xUP)
% StopPerUP = (1D array xUP)
% MeanTimePerUP = (1D array xUP)
% IncidPerUP = (1D array xUP)
% 
% CountPerUPPerAllCells = ...(1D array xUP)
% CountPerUPPerEachCell = ...(2D array xCell xUP)
% CountPerUPPerEachECell = ...(2D array xECell xUP)
% CountPerUPPerEachICell = ...(2D array xECell xUP)
% CountPerUPPerEClass = ...(1D array xUP)
% CountPerUPPerIClass = ...(1D array xUP)
%
% RatePerUPPerAllCells = ...(1D array xUP)
% RatePerUPPerEachCell = ...(2D array xCellxUP)
% RatePerUPPerEachECell = ...(2D array xECell xUP)
% RatePerUPPerEachICell = ...(2D array xECell xUP)
% RatePerUPPerEClass = ...(1D array xUP)
% RatePerUPPerEClass = ...(1D array xUP)
% 
% DOWN MEASURES
% ... identical to UP measures

%% SWS Measures as above
SWSMeasures = generateSWSMeasures(intervals,S,Se,Si,UPInts);

%% UP Measures as above
UPMeasures = generateUPMeasures(UPInts,S,Se,Si);


%% DOWN Measures as above
DOWNMeasures = generateDOWNMeasures(DNInts,S,Se,Si);

%% Plotting basic SWS durations, rates vs time and vs count
PlotSWSStatsPerClass(basename,SWSMeasures,PrePostSleepMetaData,'AllCells')
PlotSWSStatsPerClass(basename,SWSMeasures,PrePostSleepMetaData,'EClass')
PlotSWSStatsPerClass(basename,SWSMeasures,PrePostSleepMetaData,'IClass')
PlotSWSIndividCells(basename,SWSMeasures,PrePostSleepMetaData)

%% Plotting basic UP & DOWN state durations, rates, counts
PlotUPDownStatsPerClass(basename,UPMeasures,DOWNMeasures,PrePostSleepMetaData,'AllCells')
PlotUPDownStatsPerClass(basename,UPMeasures,DOWNMeasures,PrePostSleepMetaData,'EClass')
PlotUPDownStatsPerClass(basename,UPMeasures,DOWNMeasures,PrePostSleepMetaData,'IClass')
PlotUPIndividCells(basename,UPMeasures,PrePostSleepMetaData)


%% Spike rates during first vs last SWS (or REM) SRSEpisodes in presleep
PlotFirstVsLastRates(intervals,UPInts,S,Se,Si,PrePostSleepMetaData,SWSMeasures)


%% MESSY PLOTTING SUBFUNCTIONS BELOW
function SWSMeasures = generateSWSMeasures(intervals,S,Se,Si,UPInts)

SWS = intervals{3};
numcells = size(S,1);

% basic measures of the intervals themselves
SWSMeasures.DurationPerSWS = Data(length(SWS));
SWSMeasures.StartPerSWS = Start(SWS);
SWSMeasures.StopPerSWS = End(SWS);
SWSMeasures.MeanTimePerSWS = mean([Start(SWS) End(SWS)],2);
upstarts = tsd(Start(UPInts),(1:length(Start(UPInts)))');
SWSMeasures.NumUpsPerSWS = Data(intervalCount(upstarts,SWS));

% spike counts
SWSMeasures.CountPerSWSPerAllCells = Data(intervalCount(oneSeries(S),SWS));
for a = 1:numcells
    SWSMeasures.CountPerSWSPerEachCell(:,a) = Data(intervalCount(S{a},SWS));
end
for a = 1:length(Se)
    SWSMeasures.CountPerSWSPerEachECell(:,a) = Data(intervalCount(Se{a},SWS));
end
for a = 1:length(Si)
    SWSMeasures.CountPerSWSPerEachICell(:,a) = Data(intervalCount(Si{a},SWS));
end
SWSMeasures.CountPerSWSPerEClass = Data(intervalCount(oneSeries(Se),SWS));
SWSMeasures.CountPerSWSPerIClass = Data(intervalCount(oneSeries(Si),SWS));

% spike rates
SWSMeasures.RatePerSWSPerAllCells = Data(intervalRate(oneSeries(S),SWS));
for a = 1:numcells
    SWSMeasures.RatePerSWSPerEachCell(:,a) = Data(intervalRate(S{a},SWS));
end
for a = 1:length(Se)
    SWSMeasures.RatePerSWSPerEachECell(:,a) = Data(intervalRate(Se{a},SWS));
end
for a = 1:length(Si)
    SWSMeasures.RatePerSWSPerEachICell(:,a) = Data(intervalRate(Si{a},SWS));
end
SWSMeasures.RatePerSWSPerEClass = Data(intervalRate(oneSeries(Se),SWS));
SWSMeasures.RatePerSWSPerIClass = Data(intervalRate(oneSeries(Si),SWS));

for a=1:length(length(SWS)) %overall spike rates for each cell during UPs
    thisSWS = subset(SWS,a);
    SWSMeasures.UPCountPerSWSPerAllCells(a) = mean(CountsDuringSpanofUps(oneSeries(S),UPInts,thisSWS))';
    SWSMeasures.UPCountPerSWSPerEachCell(a,:) = mean(CountsDuringSpanofUps(S,UPInts,thisSWS),1);
    SWSMeasures.UPCountPerSWSPerEachECell(a,:) = mean(CountsDuringSpanofUps(Se,UPInts,thisSWS),1);
    SWSMeasures.UPCountPerSWSPerEachICell(a,:) = mean(CountsDuringSpanofUps(Si,UPInts,thisSWS),1);
    SWSMeasures.UPCountPerSWSPerEClass(a) = mean(CountsDuringSpanofUps(oneSeries(Se),UPInts,thisSWS))';
    SWSMeasures.UPCountPerSWSPerIClass(a) = mean(CountsDuringSpanofUps(oneSeries(Si),UPInts,thisSWS))';

    SWSMeasures.UPRatePerSWSPerAllCells(a) = mean(RatesDuringSpanofUps(oneSeries(S),UPInts,thisSWS))';
    SWSMeasures.UPRatePerSWSPerEachCell(a,:) = mean(RatesDuringSpanofUps(S,UPInts,thisSWS),1);
    SWSMeasures.UPRatePerSWSPerEachECell(a,:) = mean(RatesDuringSpanofUps(Se,UPInts,thisSWS),1);
    SWSMeasures.UPRatePerSWSPerEachICell(a,:) = mean(RatesDuringSpanofUps(Si,UPInts,thisSWS),1);
    SWSMeasures.UPRatePerSWSPerEClass(a) = mean(RatesDuringSpanofUps(oneSeries(Se),UPInts,thisSWS))';
    SWSMeasures.UPRatePerSWSPerIClass(a) = mean(RatesDuringSpanofUps(oneSeries(Si),UPInts,thisSWS))';
end

function UPMeasures = generateUPMeasures(UPInts,S,Se,Si)
numcells = size(S,1);

% basic measures of the intervals themselves
UPMeasures.DurationPerUP = Data(length(UPInts));
UPMeasures.StartPerUP = Start(UPInts);
UPMeasures.StopPerUP = End(UPInts);
UPMeasures.MeanTimePerUP = mean([Start(UPInts) End(UPInts)],2);
UPMeasures.IncidPerUP = [diff(UPMeasures.StartPerUP);0]+[0;diff(UPMeasures.StartPerUP)]/2;
UPMeasures.IncidPerUP(1) = UPMeasures.StartPerUP(2)-UPMeasures.StartPerUP(1);
UPMeasures.IncidPerUP(end) = UPMeasures.StartPerUP(end)-UPMeasures.StartPerUP(end-1);

% spike counts
UPMeasures.CountPerUPPerAllCells = Data(intervalCount(oneSeries(S),UPInts));
for a = 1:numcells
    UPMeasures.CountPerUPPerEachCell(:,a) = Data(intervalCount(S{a},UPInts));
end
for a = 1:length(Se)
    UPMeasures.CountPerUPPerEachECell(:,a) = Data(intervalCount(Se{a},UPInts));
end
for a = 1:length(Si)
    UPMeasures.CountPerUPPerEachICell(:,a) = Data(intervalCount(Si{a},UPInts));
end
UPMeasures.CountPerUPPerEClass = Data(intervalCount(oneSeries(Se),UPInts));
UPMeasures.CountPerUPPerIClass = Data(intervalCount(oneSeries(Si),UPInts));

% spike rates
UPMeasures.RatePerUPPerAllCells = Data(intervalRate(oneSeries(S),UPInts));
for a = 1:numcells
    UPMeasures.RatePerUPPerEachCell(:,a) = Data(intervalRate(S{a},UPInts));
end
for a = 1:length(Se)
    UPMeasures.RatePerUPPerEachECell(:,a) = Data(intervalRate(Se{a},UPInts));
end
for a = 1:length(Si)
    UPMeasures.RatePerUPPerEachICell(:,a) = Data(intervalRate(Si{a},UPInts));
end
UPMeasures.RatePerUPPerEClass = Data(intervalRate(oneSeries(Se),UPInts));
UPMeasures.RatePerUPPerIClass = Data(intervalRate(oneSeries(Si),UPInts));

%% 
function DOWNMeasures = generateDOWNMeasures(DNInts,S,Se,Si);
numcells = size(S,1);

% basic measures of the intervals themselves
DOWNMeasures.DurationPerDOWN = Data(length(DNInts));
DOWNMeasures.StartPerDOWN = Start(DNInts);
DOWNMeasures.StopPerDOWN = End(DNInts);
DOWNMeasures.MeanTimePerDOWN = mean([Start(DNInts) End(DNInts)],2);
DOWNMeasures.IncidPerDOWN = [diff(DOWNMeasures.StartPerDOWN);0]+[0;diff(DOWNMeasures.StartPerDOWN)]/2;
DOWNMeasures.IncidPerDOWN(1) = DOWNMeasures.StartPerDOWN(2)-DOWNMeasures.StartPerDOWN(1);
DOWNMeasures.IncidPerDOWN(end) = DOWNMeasures.StartPerDOWN(end)-DOWNMeasures.StartPerDOWN(end-1);

% spike counts
DOWNMeasures.CountPerDOWNPerAllCells = Data(intervalCount(oneSeries(S),DNInts));
for a = 1:numcells
    DOWNMeasures.CountPerDOWNPerEachCell(:,a) = Data(intervalCount(S{a},DNInts));
end
for a = 1:length(Se)
    DOWNMeasures.CountPerDOWNPerEachECell(:,a) = Data(intervalCount(Se{a},DNInts));
end
for a = 1:length(Si)
    DOWNMeasures.CountPerDOWNPerEachICell(:,a) = Data(intervalCount(Si{a},DNInts));
end
DOWNMeasures.CountPerDOWNPerEClass = Data(intervalCount(oneSeries(Se),DNInts));
DOWNMeasures.CountPerDOWNPerIClass = Data(intervalCount(oneSeries(Si),DNInts));

% spike rates
DOWNMeasures.RatePerDOWNPerAllCells = Data(intervalRate(oneSeries(S),DNInts));
for a = 1:numcells
    DOWNMeasures.RatePerDOWNPerEachCell(:,a) = Data(intervalRate(S{a},DNInts));
end
for a = 1:length(Se)
    DOWNMeasures.CountPerDOWNPerEachECell(:,a) = Data(intervalRate(Se{a},DNInts));
end
for a = 1:length(Si)
    DOWNMeasures.CountPerDOWNPerEachICell(:,a) = Data(intervalRate(Si{a},DNInts));
end
DOWNMeasures.RatePerDOWNPerEClass = Data(intervalRate(oneSeries(Se),DNInts));
DOWNMeasures.RatePerDOWNPerIClass = Data(intervalRate(oneSeries(Si),DNInts));



function PlotSWSStatsPerClass(basename,SWSMeasures,PrePostSleepMetaData,class)
h = figure;
set(h,'name',[basename,'_SWSDurationsCountsRatesUPRatesUPCounts_For',class,'_BySWSNumber'],'position',[800 40 1100 925])

% vs event number
subplot(4,2,1);
plot(SWSMeasures.DurationPerSWS)
axis tight
title('SWS Episode Duration')
hold on
plot([PrePostSleepMetaData.presleepSWSlist(end)+0.5 PrePostSleepMetaData.presleepSWSlist(end)+0.5],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postsleepSWSlist(1)-0.5 PrePostSleepMetaData.postsleepSWSlist(1)-0.5],get(gca,'YLim'),'r')

subplot(4,2,3);
eval(['plot(SWSMeasures.CountPerSWSPer',class,')'])
axis tight
title('SWS Episode Spike Count')
hold on
plot([PrePostSleepMetaData.presleepSWSlist(end)+0.5 PrePostSleepMetaData.presleepSWSlist(end)+0.5],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postsleepSWSlist(1)-0.5 PrePostSleepMetaData.postsleepSWSlist(1)-0.5],get(gca,'YLim'),'r')

subplot(4,2,5);
eval(['plot(SWSMeasures.RatePerSWSPer',class,')'])
axis tight
title('SWS Episode Raw Spike Rate')
hold on
plot([PrePostSleepMetaData.presleepSWSlist(end)+0.5 PrePostSleepMetaData.presleepSWSlist(end)+0.5],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postsleepSWSlist(1)-0.5 PrePostSleepMetaData.postsleepSWSlist(1)-0.5],get(gca,'YLim'),'r')

subplot(4,2,7);
eval(['plot(SWSMeasures.UPRatePerSWSPer',class,')'])
axis tight
title('SWS Episode In-UPState Spike Rate')
hold on
plot([PrePostSleepMetaData.presleepSWSlist(end)+0.5 PrePostSleepMetaData.presleepSWSlist(end)+0.5],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postsleepSWSlist(1)-0.5 PrePostSleepMetaData.postsleepSWSlist(1)-0.5],get(gca,'YLim'),'r')

% vs time
subplot(4,2,2);
plot(SWSMeasures.MeanTimePerSWS, SWSMeasures.DurationPerSWS)
axis tight
title('SWS Episode Duration vs Time')
hold on
plot([PrePostSleepMetaData.preSWSStartStopsAll(end) PrePostSleepMetaData.preSWSStartStopsAll(end)],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postSWSStartStopsAll(1) PrePostSleepMetaData.postSWSStartStopsAll(1)],get(gca,'YLim'),'r')

subplot(4,2,4);
eval(['plot(SWSMeasures.MeanTimePerSWS, SWSMeasures.CountPerSWSPer',class,')'])
axis tight
title('SWS Episode Spike Count vs Time')
hold on
plot([PrePostSleepMetaData.preSWSStartStopsAll(end) PrePostSleepMetaData.preSWSStartStopsAll(end)],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postSWSStartStopsAll(1) PrePostSleepMetaData.postSWSStartStopsAll(1)],get(gca,'YLim'),'r')

subplot(4,2,6);
eval(['plot(SWSMeasures.MeanTimePerSWS, SWSMeasures.RatePerSWSPer',class,')'])
axis tight
title('SWS Episode Spike Rate vs Time')
hold on
plot([PrePostSleepMetaData.preSWSStartStopsAll(end) PrePostSleepMetaData.preSWSStartStopsAll(end)],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postSWSStartStopsAll(1) PrePostSleepMetaData.postSWSStartStopsAll(1)],get(gca,'YLim'),'r')

subplot(4,2,8);
eval(['plot(SWSMeasures.MeanTimePerSWS, SWSMeasures.UPRatePerSWSPer',class,')'])
axis tight
title('SWS Episode In-UPState Spike Rate vs Time')
hold on
plot([PrePostSleepMetaData.preSWSStartStopsAll(end) PrePostSleepMetaData.preSWSStartStopsAll(end)],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postSWSStartStopsAll(1) PrePostSleepMetaData.postSWSStartStopsAll(1)],get(gca,'YLim'),'r')

function PlotSWSIndividCells(basename,SWSMeasures,PrePostSleepMetaData)

%Do an imagesc for individual cells
h = figure;
set(h,'name',[basename,'_IndividCellSWSRates'],'position',[800 40 1100 925])
subplot(4,1,1);
imagesc(SWSMeasures.RatePerSWSPerEachCell')
title('Per-Cell Raw Rates for each SWS')
hold on
plot([PrePostSleepMetaData.presleepSWSlist(end)+.5 PrePostSleepMetaData.presleepSWSlist(end)+.5],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postsleepSWSlist(1)-.5 PrePostSleepMetaData.postsleepSWSlist(1)-.5],get(gca,'YLim'),'r')

subplot(4,1,2);
imagesc(bwnormalize_array(SWSMeasures.RatePerSWSPerEachCell)')
title('Per-Cell Raw Rates for each SWS - normalized by cell max & min')
hold on
plot([PrePostSleepMetaData.presleepSWSlist(end)+.5 PrePostSleepMetaData.presleepSWSlist(end)+.5],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postsleepSWSlist(1)-.5 PrePostSleepMetaData.postsleepSWSlist(1)-.5],get(gca,'YLim'),'r')

subplot(4,1,3);
imagesc(SWSMeasures.UPRatePerSWSPerEachCell')
title('Per-Cell UPState-Restricted Rates during each SWS')
hold on
plot([PrePostSleepMetaData.presleepSWSlist(end)+.5 PrePostSleepMetaData.presleepSWSlist(end)+.5],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postsleepSWSlist(1)-.5 PrePostSleepMetaData.postsleepSWSlist(1)-.5],get(gca,'YLim'),'r')

subplot(4,1,4);
imagesc(bwnormalize_array(SWSMeasures.UPRatePerSWSPerEachCell)')
title('Per-Cell UPState-Restricted Rates during each SWS - normalized by cell max & min')
hold on
plot([PrePostSleepMetaData.presleepSWSlist(end)+.5 PrePostSleepMetaData.presleepSWSlist(end)+.5],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postsleepSWSlist(1)-.5 PrePostSleepMetaData.postsleepSWSlist(1)-.5],get(gca,'YLim'),'r')

%Ecells
h = figure;
set(h,'name',[basename,'_IndividECellSWSRates'],'position',[800 40 1100 925])
subplot(4,1,1);
imagesc(SWSMeasures.RatePerSWSPerEachECell')
title('Per-ECell Raw Rates for each SWS')
hold on
plot([PrePostSleepMetaData.presleepSWSlist(end)+.5 PrePostSleepMetaData.presleepSWSlist(end)+.5],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postsleepSWSlist(1)-.5 PrePostSleepMetaData.postsleepSWSlist(1)-.5],get(gca,'YLim'),'r')

subplot(4,1,2);
imagesc(bwnormalize_array(SWSMeasures.RatePerSWSPerEachECell)')
title('Per-ECell Raw Rates for each SWS - normalized by cell max & min')
hold on
plot([PrePostSleepMetaData.presleepSWSlist(end)+.5 PrePostSleepMetaData.presleepSWSlist(end)+.5],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postsleepSWSlist(1)-.5 PrePostSleepMetaData.postsleepSWSlist(1)-.5],get(gca,'YLim'),'r')

subplot(4,1,3);
imagesc(SWSMeasures.UPRatePerSWSPerEachECell')
title('Per-ECell UPState-Restricted Rates during each SWS')
hold on
plot([PrePostSleepMetaData.presleepSWSlist(end)+.5 PrePostSleepMetaData.presleepSWSlist(end)+.5],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postsleepSWSlist(1)-.5 PrePostSleepMetaData.postsleepSWSlist(1)-.5],get(gca,'YLim'),'r')

subplot(4,1,4);
imagesc(bwnormalize_array(SWSMeasures.UPRatePerSWSPerEachECell)')
title('Per-ECell UPState-Restricted Rates during each SWS - normalized by cell max & min')
hold on
plot([PrePostSleepMetaData.presleepSWSlist(end)+.5 PrePostSleepMetaData.presleepSWSlist(end)+.5],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postsleepSWSlist(1)-.5 PrePostSleepMetaData.postsleepSWSlist(1)-.5],get(gca,'YLim'),'r')

%Icells
h = figure;
set(h,'name',[basename,'_IndividICellSWSRates'],'position',[800 40 1100 925])
subplot(4,1,1);
imagesc(SWSMeasures.RatePerSWSPerEachICell')
title('Per-ICell Raw Rates for each SWS')
hold on
plot([PrePostSleepMetaData.presleepSWSlist(end)+.5 PrePostSleepMetaData.presleepSWSlist(end)+.5],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postsleepSWSlist(1)-.5 PrePostSleepMetaData.postsleepSWSlist(1)-.5],get(gca,'YLim'),'r')

subplot(4,1,2);
imagesc(bwnormalize_array(SWSMeasures.RatePerSWSPerEachICell)')
title('Per-ICell Raw Rates for each SWS - normalized by cell max & min')
hold on
plot([PrePostSleepMetaData.presleepSWSlist(end)+.5 PrePostSleepMetaData.presleepSWSlist(end)+.5],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postsleepSWSlist(1)-.5 PrePostSleepMetaData.postsleepSWSlist(1)-.5],get(gca,'YLim'),'r')

subplot(4,1,3);
imagesc(SWSMeasures.UPRatePerSWSPerEachICell')
title('Per-ICell UPState-Restricted Rates during each SWS')
hold on
plot([PrePostSleepMetaData.presleepSWSlist(end)+.5 PrePostSleepMetaData.presleepSWSlist(end)+.5],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postsleepSWSlist(1)-.5 PrePostSleepMetaData.postsleepSWSlist(1)-.5],get(gca,'YLim'),'r')

subplot(4,1,4);
imagesc(bwnormalize_array(SWSMeasures.UPRatePerSWSPerEachICell)')
title('Per-ICell UPState-Restricted Rates during each SWS - normalized by cell max & min')
hold on
plot([PrePostSleepMetaData.presleepSWSlist(end)+.5 PrePostSleepMetaData.presleepSWSlist(end)+.5],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postsleepSWSlist(1)-.5 PrePostSleepMetaData.postsleepSWSlist(1)-.5],get(gca,'YLim'),'r')



%%
function PlotUPDownStatsPerClass(basename,UPMeasures,DOWNMeasures,PrePostSleepMetaData,class)
% vs event number
h = figure;
set(h,'name',[basename,'_UPDownDurationsCountsRates_For',class,'_ByUPNumber'],'position',[800 40 1100 925])

subplot(3,2,1);
plot(UPMeasures.DurationPerUP)
axis tight
title('UP State Duration')
hold on
plot([PrePostSleepMetaData.preUPslist(end) PrePostSleepMetaData.preUPslist(end)],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postUPslist(1) PrePostSleepMetaData.postUPslist(1)],get(gca,'YLim'),'r')

subplot(3,2,3);
eval(['plot(UPMeasures.CountPerUPPer',class,')'])
axis tight
title('UP State Spike Count')
hold on
plot([PrePostSleepMetaData.preUPslist(end) PrePostSleepMetaData.preUPslist(end)],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postUPslist(1) PrePostSleepMetaData.postUPslist(1)],get(gca,'YLim'),'r')

subplot(3,2,5);
eval(['plot(UPMeasures.RatePerUPPer',class,')'])
axis tight
title('UP State Spike Rate')
hold on
plot([PrePostSleepMetaData.preUPslist(end) PrePostSleepMetaData.preUPslist(end)],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postUPslist(1) PrePostSleepMetaData.postUPslist(1)],get(gca,'YLim'),'r')

subplot(3,2,2);
plot(DOWNMeasures.DurationPerDOWN)
axis tight
title('DOWN State Duration')
hold on
plot([PrePostSleepMetaData.preDNslist(end) PrePostSleepMetaData.preDNslist(end)],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postDNslist(1) PrePostSleepMetaData.postDNslist(1)],get(gca,'YLim'),'r')

subplot(3,2,4);
eval(['plot(DOWNMeasures.CountPerDOWNPer',class,')'])
axis tight
title('DOWN State Spike Count')
hold on
plot([PrePostSleepMetaData.preDNslist(end) PrePostSleepMetaData.preDNslist(end)],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postDNslist(1) PrePostSleepMetaData.postDNslist(1)],get(gca,'YLim'),'r')

subplot(3,2,6);
eval(['plot(DOWNMeasures.RatePerDOWNPer',class,')'])
axis tight
title('DOWN State Spike Rate')
hold on
plot([PrePostSleepMetaData.preDNslist(end) PrePostSleepMetaData.preDNslist(end)],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postDNslist(1) PrePostSleepMetaData.postDNslist(1)],get(gca,'YLim'),'r')

% vs time
h = figure;
set(h,'name',[basename,'_UPDownDurationsCountsRates_For',class,'_ByTime'],'position',[800 40 1100 925])
subplot(3,2,1);
plot(UPMeasures.MeanTimePerUP, UPMeasures.DurationPerUP)
axis tight
title('UP State Duration vs Time')
hold on
plot([PrePostSleepMetaData.preUPStartStopsAll(end) PrePostSleepMetaData.preUPStartStopsAll(end)],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postUPStartStopsAll(1) PrePostSleepMetaData.postUPStartStopsAll(1)],get(gca,'YLim'),'r')

subplot(3,2,3);
eval(['plot(UPMeasures.MeanTimePerUP, UPMeasures.CountPerUPPer',class,')'])
axis tight
title('UP State Spike Count vs Time')
hold on
plot([PrePostSleepMetaData.preUPStartStopsAll(end) PrePostSleepMetaData.preUPStartStopsAll(end)],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postUPStartStopsAll(1) PrePostSleepMetaData.postUPStartStopsAll(1)],get(gca,'YLim'),'r')

subplot(3,2,5);
eval(['plot(UPMeasures.MeanTimePerUP, UPMeasures.RatePerUPPer',class,')'])
axis tight
title('UP State Spike Rate vs Time')
hold on
plot([PrePostSleepMetaData.preUPStartStopsAll(end) PrePostSleepMetaData.preUPStartStopsAll(end)],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postUPStartStopsAll(1) PrePostSleepMetaData.postUPStartStopsAll(1)],get(gca,'YLim'),'r')

subplot(3,2,2);
plot(DOWNMeasures.MeanTimePerDOWN, DOWNMeasures.DurationPerDOWN)
axis tight
title('DOWN State Duration vs Time')
hold on
plot([PrePostSleepMetaData.preDNStartStopsAll(end) PrePostSleepMetaData.preDNStartStopsAll(end)],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postDNStartStopsAll(1) PrePostSleepMetaData.postDNStartStopsAll(1)],get(gca,'YLim'),'r')

subplot(3,2,4);
eval(['plot(DOWNMeasures.MeanTimePerDOWN, DOWNMeasures.CountPerDOWNPer',class,')'])
axis tight
title('DOWN State Spike Count vs Time')
hold on
plot([PrePostSleepMetaData.preDNStartStopsAll(end) PrePostSleepMetaData.preDNStartStopsAll(end)],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postDNStartStopsAll(1) PrePostSleepMetaData.postDNStartStopsAll(1)],get(gca,'YLim'),'r')

subplot(3,2,6);
eval(['plot(DOWNMeasures.MeanTimePerDOWN, DOWNMeasures.RatePerDOWNPer',class,')'])
axis tight
title('DOWN State Spike Rate vs Time')
hold on
plot([PrePostSleepMetaData.preDNStartStopsAll(end) PrePostSleepMetaData.preDNStartStopsAll(end)],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postDNStartStopsAll(1) PrePostSleepMetaData.postDNStartStopsAll(1)],get(gca,'YLim'),'r')


function PlotUPIndividCells(basename,UPMeasures,PrePostSleepMetaData)

smoothing = 50;
b = 1/smoothing*ones(1,smoothing);%

%Do an imagesc for individual cells
h = figure;
set(h,'name',[basename,'_IndividCellUPRates'],'position',[800 40 1100 925])
subplot(4,1,1);
imagesc(UPMeasures.RatePerUPPerEachCell')
title('Per-Cell Raw Rates for each UP')
hold on
plot([PrePostSleepMetaData.preUPslist(end) PrePostSleepMetaData.preUPslist(end)],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postUPslist(1) PrePostSleepMetaData.postUPslist(1)],get(gca,'YLim'),'r')

subplot(4,1,2);
imagesc(bwnormalize_array(UPMeasures.RatePerUPPerEachCell)')
title('Per-Cell Raw Rates for each UP - normalized by cell max & min')
hold on
plot([PrePostSleepMetaData.preUPslist(end) PrePostSleepMetaData.preUPslist(end)],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postUPslist(1) PrePostSleepMetaData.postUPslist(1)],get(gca,'YLim'),'r')

subplot(4,1,3);
imagesc(conv2(UPMeasures.RatePerUPPerEachCell',b))
title('Per-Cell Raw Rates for each UP, smoothed')
hold on
plot([PrePostSleepMetaData.preUPslist(end) PrePostSleepMetaData.preUPslist(end)],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postUPslist(1) PrePostSleepMetaData.postUPslist(1)],get(gca,'YLim'),'r')

subplot(4,1,4);
imagesc(conv2(bwnormalize_array(UPMeasures.RatePerUPPerEachCell)',b))
title('Per-Cell Raw Rates for each UP - normalized by cell max & min, smoothed')
hold on
plot([PrePostSleepMetaData.preUPslist(end) PrePostSleepMetaData.preUPslist(end)],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postUPslist(1) PrePostSleepMetaData.postUPslist(1)],get(gca,'YLim'),'r')

%Do an imagesc for individual cells
h = figure;
set(h,'name',[basename,'_IndividECellUPRates'],'position',[800 40 1100 925])
subplot(4,1,1);
imagesc(UPMeasures.RatePerUPPerEachECell')
title('Per-ECell Raw Rates for each UP')
hold on
plot([PrePostSleepMetaData.preUPslist(end) PrePostSleepMetaData.preUPslist(end)],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postUPslist(1) PrePostSleepMetaData.postUPslist(1)],get(gca,'YLim'),'r')

subplot(4,1,2);
imagesc(bwnormalize_array(UPMeasures.RatePerUPPerEachECell)')
title('Per-ECell Raw Rates for each UP - normalized by cell max & min')
hold on
plot([PrePostSleepMetaData.preUPslist(end) PrePostSleepMetaData.preUPslist(end)],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postUPslist(1) PrePostSleepMetaData.postUPslist(1)],get(gca,'YLim'),'r')

subplot(4,1,3);
imagesc(conv2(UPMeasures.RatePerUPPerEachECell',b))
title('Per-ICell Raw Rates for each UP, smoothed')
hold on
plot([PrePostSleepMetaData.preUPslist(end) PrePostSleepMetaData.preUPslist(end)],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postUPslist(1) PrePostSleepMetaData.postUPslist(1)],get(gca,'YLim'),'r')

subplot(4,1,4);
imagesc(conv2(bwnormalize_array(UPMeasures.RatePerUPPerEachECell)',b))
title('Per-ICell Raw Rates for each UP - normalized by cell max & min, smoothed')%Do an imagesc for individual cells
hold on
plot([PrePostSleepMetaData.preUPslist(end) PrePostSleepMetaData.preUPslist(end)],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postUPslist(1) PrePostSleepMetaData.postUPslist(1)],get(gca,'YLim'),'r')

h = figure;
set(h,'name',[basename,'_IndividICellUPRates'],'position',[800 40 1100 925])
subplot(4,1,1);
imagesc(UPMeasures.RatePerUPPerEachICell')
title('Per-ICell Raw Rates for each UP')
hold on
plot([PrePostSleepMetaData.preUPslist(end) PrePostSleepMetaData.preUPslist(end)],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postUPslist(1) PrePostSleepMetaData.postUPslist(1)],get(gca,'YLim'),'r')

subplot(4,1,2);
imagesc(bwnormalize_array(UPMeasures.RatePerUPPerEachICell)')
title('Per-Cell Raw Rates for each UP - normalized by cell max & min')
hold on
plot([PrePostSleepMetaData.preUPslist(end) PrePostSleepMetaData.preUPslist(end)],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postUPslist(1) PrePostSleepMetaData.postUPslist(1)],get(gca,'YLim'),'r')

subplot(4,1,3);
imagesc(conv2(UPMeasures.RatePerUPPerEachICell',b))
title('Per-Cell Raw Rates for each UP, smoothed')
hold on
plot([PrePostSleepMetaData.preUPslist(end) PrePostSleepMetaData.preUPslist(end)],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postUPslist(1) PrePostSleepMetaData.postUPslist(1)],get(gca,'YLim'),'r')

subplot(4,1,4);
imagesc(conv2(bwnormalize_array(UPMeasures.RatePerUPPerEachICell)',b))
title('Per-Cell Raw Rates for each UP - normalized by cell max & min, smoothed')
hold on
plot([PrePostSleepMetaData.preUPslist(end) PrePostSleepMetaData.preUPslist(end)],get(gca,'YLim'),'g')
plot([PrePostSleepMetaData.postUPslist(1) PrePostSleepMetaData.postUPslist(1)],get(gca,'YLim'),'r')


function PlotFirstVsLastRates(intervals,UPInts,S,Se,Si,PrePostSleepMetaData,SWSMeasures)
UPSpikes = Restrict(S,UPInts);
% DNSpikes = Restrict(S,DNInts);

UPSpikesI = Restrict(Si,UPInts);
% DNSpikesI = Restrict(Si,DNInts);
UPSpikesE = Restrict(Se,UPInts);
% DNSpikesE = Restrict(Se,DNInts);

% SWS Raw rates for first vs last SWS ep (separated by E vs I cells)
SWSERawRatesPresleepFirst = Rate(Restrict(UPSpikesE,subset(intervals{3},PrePostSleepMetaData.presleepSWSlist(1))));
SWSERawRatesPresleepLast = Rate(Restrict(UPSpikesE,subset(intervals{3},PrePostSleepMetaData.presleepSWSlist(end))));
SWSIRawRatesPresleepFirst = Rate(Restrict(UPSpikesI,subset(intervals{3},PrePostSleepMetaData.presleepSWSlist(1))));
SWSIRawRatesPresleepLast = Rate(Restrict(UPSpikesI,subset(intervals{3},PrePostSleepMetaData.presleepSWSlist(end))));
SWSERawRatesPostsleepFirst = Rate(Restrict(UPSpikesE,subset(intervals{3},PrePostSleepMetaData.postsleepSWSlist(1))));
SWSERawRatesPostsleepLast = Rate(Restrict(UPSpikesE,subset(intervals{3},PrePostSleepMetaData.postsleepSWSlist(end))));
SWSIRawRatesPostsleepFirst = Rate(Restrict(UPSpikesI,subset(intervals{3},PrePostSleepMetaData.postsleepSWSlist(1))));
SWSIRawRatesPostsleepLast = Rate(Restrict(UPSpikesI,subset(intervals{3},PrePostSleepMetaData.postsleepSWSlist(end))));

h=figure;
subplot(1,2,1)
plot_meanSEM(SWSERawRatesPresleepFirst,SWSERawRatesPresleepLast,0,SWSIRawRatesPresleepFirst,SWSIRawRatesPresleepLast);
title({'Raw Spike Rates during first vs last SWS Periods in PREsleep';...
    'E First Ep, E Last Ep, I First Ep, I Last Ep'})
set(h,'name','FirstVsLastSWSRawRates','Position',[680 555 1200 420])

subplot(1,2,2)
plot_meanSEM(SWSERawRatesPostsleepFirst,SWSERawRatesPostsleepLast,0,SWSIRawRatesPostsleepFirst,SWSIRawRatesPostsleepLast);
title({'POSTsleep';' '})
set(h,'name','FirstVsLastSWSRawRates')

% SWS UPstate rates for first vs last SWS ep (separated by E vs I cells)
SWSEUPsRatesPresleepFirst = SWSMeasures.UPRatePerSWSPerEachECell(PrePostSleepMetaData.presleepSWSlist(1),:);
SWSEUPsRatesPresleepLast = SWSMeasures.UPRatePerSWSPerEachECell(PrePostSleepMetaData.presleepSWSlist(end),:);
SWSIUPsRatesPresleepFirst = SWSMeasures.UPRatePerSWSPerEachICell(PrePostSleepMetaData.presleepSWSlist(1),:);
SWSIUPsRatesPresleepLast = SWSMeasures.UPRatePerSWSPerEachICell(PrePostSleepMetaData.presleepSWSlist(end),:);
SWSEUPsRatesPostsleepFirst = SWSMeasures.UPRatePerSWSPerEachECell(PrePostSleepMetaData.postsleepSWSlist(1),:);
SWSEUPsRatesPostsleepLast = SWSMeasures.UPRatePerSWSPerEachECell(PrePostSleepMetaData.postsleepSWSlist(end),:);
SWSIUPsRatesPostsleepFirst = SWSMeasures.UPRatePerSWSPerEachICell(PrePostSleepMetaData.postsleepSWSlist(1),:);
SWSIUPsRatesPostsleepLast = SWSMeasures.UPRatePerSWSPerEachICell(PrePostSleepMetaData.postsleepSWSlist(end),:);

h=figure;
subplot(1,2,1)
plot_meanSEM(SWSEUPsRatesPresleepFirst,SWSEUPsRatesPresleepLast,0,SWSIUPsRatesPresleepFirst,SWSIUPsRatesPresleepLast);
title({'UP state Spike Rates during first vs last SWS Periods in PREsleep';...
    'E First Ep, E Last Ep, I First Ep, I Last Ep'})
set(h,'name','FirstVsLastSWSUPRates','Position',[680 555 1200 420])

subplot(1,2,2)
plot_meanSEM(SWSEUPsRatesPostsleepFirst,SWSEUPsRatesPostsleepLast,0,SWSIUPsRatesPostsleepFirst,SWSIUPsRatesPostsleepLast);
title({'POSTsleep';' '})
set(h,'name','FirstVsLastSWSUPRates')

% REM rates for first vs last SWS ep (separated by E vs I cells)
REMERatesPresleepFirst = Rate(Restrict(Se,subset(intervals{5},PrePostSleepMetaData.presleepREMlist(1))));
REMERatesPresleepLast = Rate(Restrict(Se,subset(intervals{5},PrePostSleepMetaData.presleepREMlist(end))));
REMIRatesPresleepFirst = Rate(Restrict(Si,subset(intervals{5},PrePostSleepMetaData.presleepREMlist(1))));
REMIRatesPresleepLast = Rate(Restrict(Si,subset(intervals{5},PrePostSleepMetaData.presleepREMlist(end))));
REMERatesPostsleepFirst = Rate(Restrict(Se,subset(intervals{5},PrePostSleepMetaData.postsleepREMlist(1))));
REMERatesPostsleepLast = Rate(Restrict(Se,subset(intervals{5},PrePostSleepMetaData.postsleepREMlist(end))));
REMIRatesPostsleepFirst = Rate(Restrict(Si,subset(intervals{5},PrePostSleepMetaData.postsleepREMlist(1))));
REMIRatesPostsleepLast = Rate(Restrict(Si,subset(intervals{5},PrePostSleepMetaData.postsleepREMlist(end))));

h=figure;
subplot(1,2,1)
plot_meanSEM(REMERatesPresleepFirst,REMERatesPresleepLast,0,REMIRatesPresleepFirst,REMIRatesPresleepLast);
title({'Spike Rates during first vs last REM Periods in PREsleep';...
    'E First Ep, E Last Ep, I First Ep, I Last Ep'})
set(h,'name','FirstVsLastREMRates','Position',[680 555 1200 420])

subplot(1,2,2)
plot_meanSEM(REMERatesPostsleepFirst,REMERatesPostsleepLast,0,REMIRatesPostsleepFirst,REMIRatesPostsleepLast);
title({'POSTsleep';' '})
set(h,'name','FirstVsLastREMRates')

