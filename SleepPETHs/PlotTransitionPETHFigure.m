function pethfig = PlotTransitionPETHFigure(pethtimes,pethdata)
% Makes figure to plot data in format of output of IntervalPETH.m

numepochs = size(pethdata,1);

normmean = nanmean(pethdata,2);
normstd = nanstd(pethdata,[],2);


%% Figure

figname = 'IntervalPETH';

pethfig = figure('name',figname,'position',[2 2 400 800]);
subplot(2,1,1)
    hold on
    imagesc(pethtimes,1:numepochs,(pethdata'))
    colormap jet
    axis tight
    try
        caxis([min(normmean-2*normstd) max(normmean+2*normstd)])
    end
    plot([0 0],get(gca,'ylim'),'k')

ax = subplot(2,1,2);
    boundedline(pethtimes,normmean,normstd)
    plot([0 0],get(gca,'ylim'),'k')
    axis tight



