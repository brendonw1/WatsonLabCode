function pethfig = PlotPETHFigure(epaligned,plotparams)
% Makes figure to plot data in format of output of IntervalPETH.m

% v2struct(PETH)
v2struct(epaligned)
numepochs = size(align_onset,2);

if exist('align_norm','var')
    norm = align_norm;
end

normmean = nanmean(norm,2);
normstd = nanstd(norm,[],2);
onsetmean = nanmean(align_onset,2);
offsetmean = nanmean(align_offset,2);
onsetstd = nanstd(align_onset,[],2);
offsetstd = nanstd(align_offset,[],2);


%% Figure
plotparams.init = [];
if isfield(plotparams,'title')
    plottitle = plotparams.title;
else
    plottitle = 1:numepochs;
end
if isfield(plotparams,'sort')
    sortepochs = plotparams.sort;
    %sortepochs(sortepochs==dropped) = [];
else
    sortepochs = 1:numepochs;
end
if isfield(plotparams,'figname')
    figname = plotparams.figname;
    savename = plotparams.figname;
    saveloc = plotparams.saveloc;
else
    figname = 'IntervalPETH';
end

if isfield(plotparams,'xview')
    xview_on = [-plotparams.xview(1) plotparams.xview(2)];
    xview_off = [-plotparams.xview(2) plotparams.xview(1)];
else
    xview_on = [-10 40];
    xview_off = -fliplr(xview_on);
end
 
if isfield(plotparams,'sortname')
    ysort = ['Sorted by ',plotparams.sortname];
else
    ysort = [];
end
 
if isfield(plotparams,'figformat')
    figformat = plotparams.figformat;
else
    figformat = 'jpg';
end

if isfield(plotparams,'prepostsec')
    prepostsec = plotparams.prepostsec;
else
    prepostsec = [-10 40];
end
prepostsec = sort(prepostsec);

    pethfig = figure('name',figname,'position',[2 2 800 600]);
    %All Epochs;
    subplot(4,3,[1,4])
        hold on
%         images'c(t_align_on,1:numepochs,nanzscore(align_onset(:,sortepochs))')
%         imagesc(t_align_on,1:numepochs,bwnormalizebymean_array(align_onset(:,sortepochs)'))
        imagesc(t_align_on,1:numepochs,(align_onset(:,sortepochs)'))
        colormap jet
        xlim(xview_on);ylim([0.5 numepochs+0.5])
        ylabel({'Epochs',ysort})
        title('Align to Onset')
        try
            caxis([min(onsetmean-2*onsetstd) max(onsetmean+2*onsetstd)]);
        end
        plot([0 0],get(gca,'ylim'),'k');
    subplot(4,3,[3,6])
        hold on
%         imagesc('t_align_off,1:numepochs,nanzscore(align_offset(:,sortepochs))')
%         imagesc(t_align_off,1:numepochs,bwnormalizebymean_array(align_offset(:,sortepochs)'))
        imagesc(t_align_off,1:numepochs,(align_offset(:,sortepochs)'))
        colormap jet
        xlim(xview_off);ylim([0.5 numepochs+0.5])
        title('Align to Offset')
        try
            caxis([min(offsetmean-2*offsetstd) max(offsetmean+2*offsetstd)]);
        end
        plot([0 0],get(gca,'ylim'),'k')
    subplot(4,3,[2,5]);
        hold on
%         imagesc(t_norm,1:numepochs,nanzscore(align_norm(:,sortepochs))')
%         imagesc(t_norm,1:numepochs,bwnormalizebymean_array(align_norm(:,sortepochs)'))
        imagesc(t_norm,1:numepochs,(norm(:,sortepochs)'))
        colormap jet
        xlim([-0.1 1.1,]);ylim([0.5 numepochs+0.5]);
        title({plottitle,'Time-Normalized'})
        try
            caxis([min(normmean-2*normstd) max(normmean+2*normstd)])
        end
        plot([0 0],get(gca,'ylim'),'k')
        plot([1 1],get(gca,'ylim'),'k')
% 
%     %Example Epoch
%     randex = randi(numepochs);
%     subplot(4,3,7)
%         hold on
%         plot(t_align_on,align_onset(:,randex),'k')
%         ylabel('Random Epoch')
%         xlim(xview_on)
%         ylim([min(normmean-2*normstd) max(normmean+2*normstd)])
%         plot([0 0],get(gca,'ylim'),'k')
%     subplot(4,3,8)
%         hold on
%         plot(t_norm,align_norm(:,randex),'k')
%         xlim([-0.2 1.2]);
%         ylim([min(normmean-2*normstd) max(normmean+2*normstd)])
%         plot([0 0],get(gca,'ylim'),'k')
%         plot([1 1],get(gca,'ylim'),'k')
%     subplot(4,3,9)
%         hold on
%         plot(t_align_off,align_offset(:,randex),'k')
%         xlim(xview_off)
%         ylim([min(normmean-2*normstd) max(normmean+2*normstd)])
%         plot([0 0],get(gca,'ylim'),'k')
    %Mean Epoch
    subplot(4,3,[7,10]);
        hold on
        plot(t_align_on,onsetmean,'k.')
        plot(t_align_on,onsetmean,'k')
        plot(t_align_on,onsetmean+onsetstd,'k:')
        plot(t_align_on,onsetmean-onsetstd,'k:')
        ylabel('Mean/Std Epoch');xlabel('t, aligned to onset (s)')
        xlim(xview_on) 
        try
            ylim([min(onsetmean-2*onsetstd) max(onsetmean+2*onsetstd)])
        end
        plot([0 0],get(gca,'ylim'),'k')
    ax = subplot(4,3,[8,11]);
        PlotPETHNormAxesData(epaligned,ax,'k',1,1);

%         hold on
%         plot([0 0],[-100 100],'k')
%         plot([1 1],[-100 100],'k')
%         plot(t_norm,normmean,'k.')
%         plot(t_norm,normmean,'k')
%         plot(t_norm,normmean+normstd,'k:')
%         plot(t_norm,normmean-normstd,'k:')
%         xlabel('t, normalized (s)')
%         xlim([-0.1 1.1])
%         try
%             ylim([min(normmean-2*normstd) max(normmean+2*normstd)])
%         end
%         plot([0 0],get(gca,'ylim'),'k')
%         plot([1 1],get(gca,'ylim'),'k')
    subplot(4,3,[9,12]);
        hold on
        plot(t_align_off,offsetmean,'k.')
        plot(t_align_off,offsetmean,'k')
        plot(t_align_off,offsetmean+offsetstd,'k:')
        plot(t_align_off,offsetmean-offsetstd,'k:')
        xlabel('t, aligned to offset (s)')
        xlim(xview_off)
        try
            ylim([min(offsetmean-2*offsetstd) max(offsetmean+2*offsetstd)])
        end
        plot([0 0],get(gca,'ylim'),'k')
        
if exist('savename','var')
    saveas(pethfig,fullfile(saveloc,savename),figformat)
end

