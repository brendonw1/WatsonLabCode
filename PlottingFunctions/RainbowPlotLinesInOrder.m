function h = RainbowPlotLinesInOrder(datamtx);

numlines = size(datamtx,2);

c = RainbowColors(numlines);
% c = OrangeColors(numlines);

for nidx = 1:numlines;
    plot(datamtx(:,nidx),'color',c(nidx,:))
    hold on
end
