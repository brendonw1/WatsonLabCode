function [binnedTrains] = SleepAnalysis_GetPopulationSpikeRateDataOverInterval(int,S,Se,Si,CellIDs)

% AllAllCellSpikes = oneSeries(Restrict(S,int));
% AllESpikes = oneSeries(Restrict(Se,int));
% if prod(size(Si))>0
%     AllISpikes = oneSeries(Restrict(S,int));
% end

binningfactor = 100000;

binnedEachCell = MakeQfromS(Restrict(S,int),binningfactor);%bin every 100000pts, which is 10sec (10000 pts per sec)
binnedEachCellData = Data(binnedEachCell);
binnedTrains.All = sum(Data(binnedEachCell),2)';
% figure;plot(binnedTrains.All)

binnedTrains.EDefinite = sum(binnedEachCellData(:,CellIDs.EDefinite),2)';
binnedTrains.ELike = sum(binnedEachCellData(:,CellIDs.ELike),2)';
binnedTrains.EAll = sum(binnedEachCellData(:,CellIDs.EAll),2)';
if prod(size(Si))>0
    binnedTrains.IDefinite = sum(binnedEachCellData(:,CellIDs.IDefinite),2)';
    binnedTrains.ILike = sum(binnedEachCellData(:,CellIDs.ILike),2)';
    binnedTrains.IAll = sum(binnedEachCellData(:,CellIDs.IAll),2)';
end

% h=figure;
% subplot(2,1,1);
% title('Spikes from All cells (black), all ECells (green) and all ICells (red)')
% hold on;
% plot(binnedTrains.All,'k')
% plot(binnedTrains.EAll,'g')
% if prod(size(Si))>0
%     plot(binnedTrains.IAll,'r')
% end
% plotIntervalsStrip(gca,intervals,1/binningfactor)

% subplot(2,1,2);
% title('All cells (black), DefinteE:BoldGrn, DefiniteI:BoldRed, E-Like:PaleGrn, I-Like:PaleRed')
% hold on;
% plot(binnedTrains.All,'k')
% plot(binnedTrains.EDefinite+500,'color',[.3 1 .3])
% plot(binnedTrains.IDefinite+500,'color',[1 .3 .3])
% plot(binnedTrains.ELike,'color',[.6 1 .6])
% plot(binnedTrains.ILike,'color',[1 .6 .6])
% plotIntervalsStrip(gca,intervals,1/binningfactor)




% set(h,'name','RawSpikeRatesOverFullRecordingByCellType')
% ? ADD STATES to plotintervals = ConvertStatesVectorToIntervalSets