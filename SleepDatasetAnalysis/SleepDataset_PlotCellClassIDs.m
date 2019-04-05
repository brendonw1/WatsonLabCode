function SleepDataset_PlotCellClassIDs

CompleteCellIDs = SleepDataset_GetCellClassIDs;

edcells = CompleteCellIDs(:,2)==2;
elcells = CompleteCellIDs(:,2)==1;
idcells = CompleteCellIDs(:,2)==-2;
ilcells = CompleteCellIDs(:,2)==-1;

h = figure('position',[100 100 600 600],'name','AllCellWaveformProperties');
hold on
plot(CompleteCellIDs(elcells,3),CompleteCellIDs(elcells,4),'.','color',[.7 1 .7]);
plot(CompleteCellIDs(ilcells,3),CompleteCellIDs(ilcells,4),'.','color',[1 .7 .7]);
plot(CompleteCellIDs(edcells,3),CompleteCellIDs(edcells,4),'.','color',[.2 .8 .2]);
plot(CompleteCellIDs(idcells,3),CompleteCellIDs(idcells,4),'r.');

xx = [0 0.8];
yy = [2.4 0.4];
m = diff( yy ) / diff( xx );
b = yy( 1 ) - m * xx( 1 );  % y = ax+b
xb = get(gca,'XLim');
yb = get(gca,'YLim');
plot(xb,[m*xb(1)+b m*xb(2)+b],'k')

xlim([0.9*min(CompleteCellIDs(:,3)) 1.05*max(CompleteCellIDs(:,3))])
ylim([0.9*min(CompleteCellIDs(:,4)) 1.05*max(CompleteCellIDs(:,4))])

xlabel('Peak-Trough ms')
ylabel('Wavelet-based Spike Width')

MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/CellClassification',h,'fig')
% n = ['SleepPopulation_CellClassification_On_' date];
% set(h,'name',n)
% 
% saveas(h,n,'fig')
% epswrite(h,n)