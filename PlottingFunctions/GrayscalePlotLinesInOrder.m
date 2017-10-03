function h = GrayscalePlotLinesInOrder(datamtx);

numlines = size(datamtx,2);

c = GrayColors(numlines);
% c = OrangeColors(numlines);

for nidx = 1:numlines;
    plot(datamtx(:,nidx),'color',c(nidx,:))
    hold on
end
