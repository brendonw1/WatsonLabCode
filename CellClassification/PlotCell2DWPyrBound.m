function PlotCell2DWPyrBound(cellnum,CellClassOutput,PyrBoundary)
% called by ReviewCell.m

cellnums = CellClassOutput(:,1);
x = CellClassOutput(:,2);%trough to peak time in ms
y = CellClassOutput(:,3);%full trough time in ms

xx = [0 0.8];
yy = [2.4 0.4];
m = diff( yy ) / diff( xx );
b = yy( 1 ) - m * xx( 1 );  % y = ax+b

plot(x, y,'k.');
hold on
xb = get(gca,'XLim');
yb = get(gca,'YLim');
plot(xb,[m*xb(1)+b m*xb(2)+b])
xlim(xb)
ylim(yb)

plot(PyrBoundary(:,1),PyrBoundary(:,2),'k')

plot(x(cellnum),y(cellnum),'m*');
