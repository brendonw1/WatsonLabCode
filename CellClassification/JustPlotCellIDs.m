function JustPlotCellIDs(Data, EDCells, IDCells, ELCells, ILCells, m,b)

hold on

plot(Data(:,1), Data(:,2),'k.');
plot(Data(ELCells,1),Data(ELCells,2),'color',[.6 1 .6],'marker','.','line','none')
plot(Data(ILCells,1),Data(ILCells,2),'color',[1 .6 .6],'marker','.','line','none')
plot(Data(EDCells,1),Data(EDCells,2),'color','g','marker','.','line','none')
plot(Data(IDCells,1),Data(IDCells,2),'color','r','marker','.','line','none')
xb = get(gca,'XLim');
yb = get(gca,'YLim');
plot(xb,[m*xb(1)+b m*xb(2)+b])
xlim(xb)
ylim(yb)


