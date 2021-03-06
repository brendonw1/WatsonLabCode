function [binnedTrains,h] = SpikingAnalysis_PlotPopulationSpikeRates(basename,S,CellIDs,intervals)

% AllAllCellSpikes = oneSeries(S);
% AllESpikes = oneSeries(Se);
% AllISpikes = oneSeries(Si);

binningfactor = 100000;%bin every 100000pts, which is 10sec (10000 pts per sec)

binnedEachCell = MakeQfromS(S,binningfactor);
binnedEachCellData = Data(binnedEachCell);
binnedTrains.All = sum(Data(binnedEachCell),2)';
% figure;plot(binnedTrains.All)

binnedTrains.EDefinite = sum(binnedEachCellData(:,CellIDs.EDefinite),2)';
binnedTrains.ELike = sum(binnedEachCellData(:,CellIDs.ELike),2)';
binnedTrains.EAll = sum(binnedEachCellData(:,CellIDs.EAll),2)';
binnedTrains.IDefinite = sum(binnedEachCellData(:,CellIDs.IDefinite),2)';
binnedTrains.ILike = sum(binnedEachCellData(:,CellIDs.ILike),2)';
binnedTrains.IAll = sum(binnedEachCellData(:,CellIDs.IAll),2)';

h=figure;
subplot(2,1,1);
title('Spikes from All cells (black), all ECells (green) and all ICells (red)')
hold on;
plot(binnedTrains.All,'k')
plot(binnedTrains.EAll,'g')
plot(binnedTrains.IAll,'r')
if exist('intervals','var')
    plotIntervalsStrip(gca,intervals,1/binningfactor)
end
if exist('KetamineTimeStamp','var')
    line([KetamineTimeStamp/10 KetamineTimeStamp/10],get(gca,'XLim'))
end

subplot(2,1,2);
title('All cells (black), DefinteE:BoldGrn, DefiniteI:BoldRed, E-Like:PaleGrn, I-Like:PaleRed')
hold on;
plot(binnedTrains.All,'k')
plot(binnedTrains.EDefinite+500,'color',[.3 1 .3])
plot(binnedTrains.IDefinite+500,'color',[1 .3 .3])
plot(binnedTrains.ELike,'color',[.6 1 .6])
plot(binnedTrains.ILike,'color',[1 .6 .6])
if exist('intervals','var')
    plotIntervalsStrip(gca,intervals,1/binningfactor)
end
if exist('KetamineTimeStamp','var')
    line([KetamineTimeStamp/10 KetamineTimeStamp/10],get(gca,'XLim'))
end


set(h,'name',[basename,'RawSpikeRatesOverFullRecordingByCellType'])
% ? ADD STATES to plotintervals = ConvertStatesVectorToIntervalSets