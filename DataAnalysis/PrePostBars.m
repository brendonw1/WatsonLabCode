function h = PrePostBars(pre,post,VsString)

if ~exist('VsString','var')
    VsString = [inputname(1) 'VS' inputname(2)];
end


h = figure('Position',[2 2 500 800]);
%     subplot(4,2,1)
%     hax = plot_nanmeanSD_bars(pre',post');
%     title(hax,'Mean + SD')
% %     title(['E:Pre-Presleep Waking vs Post-Presleep Waking',rt])
%     subplot(4,2,2)
%     hax = plot_nanmeanSEM_bars(pre',post');
%     title(hax,'Mean + SEM')
% %     set(h(end),'name',[basename,'_EPopSynapseStrengthChanges-PreVsPostWake',rt])
    pre = pre(:)';
    post = post(:)';
    prepostpercentchg = ConditionedPercentChange(pre,post);

    % proportions of original - use geometric stats here
    postvpreproportion = ConditionedProportion(pre,post);

    prepostpercentchg = prepostpercentchg';
    postvpreproportion = postvpreproportion';
    
    subplot(3,2,1)
    hax = plot_stats_bars(pre,post,'central','median','variance','std');
    set(hax,'xtick',[1 2],'xticklabel',{'pre';'post'})
    title(hax,'Median + SD','fontweight','normal')
%     title(['E:Pre-Presleep Waking vs Post-Presleep Waking',rt])
    subplot(3,2,2)
%     v1 = 10^(mean(log10(pre(pre>0))));
%     v2 = 10^(mean(log10(post(post>0))));
%     s1 = 10^(std(log10(pre(pre>0))));
%     s2 = 10^(std(log10(post(post>0))));
    v1 = mean(pre);
    v2 = mean(post);
    s1 = std(pre);
    s2 = std(post);
    bar([v1 v2])
    hold on
    errorbar([1 2],[v1 v2],[s1 s2],'Color','k','Marker','none','LineStyle','none')
%     title(hax,'MeanOfLog + SDOfLog, lin scale','fontweight','normal')
%     hax = plot_stats_bars(pre,post,'central','median','variance','sem');
%     set(hax,'xtick',[1 2],'xticklabel',{'pre';'post'})
    title(hax,'Mean + SD','fontweight','normal')
%     set(hax,'yscale','log')
    text(0,1,{[num2str(v1),'+-',num2str(s1),];[num2str(v2),'+-',num2str(s2)]})

% Plot population percent changes
    subplot(3,2,3);
%     hax = plot_nanmeanSEM_bars(zeros(size(prepostpercentchg)),prepostpercentchg);
    hax = plot_stats_bars(zeros(size(prepostpercentchg)),prepostpercentchg,'central','nanmean','variance','sem');
    set(hax,'xtick',[1 2],'xticklabel',{'pre';'post'})
    title(hax,'Linear Mean of % change (SEM)','fontweight','normal')

    subplot(3,2,4);
%     hax = plot_nanmedianSEM_bars(zeros(size(prepostpercentchg)),prepostpercentchg);
    hax = plot_stats_bars(zeros(size(prepostpercentchg)),prepostpercentchg,'central','nanmedian','variance','sem');
    set(hax,'xtick',[1 2],'xticklabel',{'pre';'post'})
    title(hax,'Linear Median of % change (SEM)','fontweight','normal')

% Not percent changes, but proportions
    subplot(3,2,5);
%     hax = plot_geomeanSD_bars(ones(size(postvpreproportion)),postvpreproportion);
    hax = plot_stats_bars(ones(size(postvpreproportion)),postvpreproportion,'central','geomean','variance','sd');
    yl = get(gca,'ylim');
%     yl(1) = yl(1)-(mean(yl)-yl(1))*1.5;
% %     yl(2) = yl(2)-(mean(yl)-yl(2))*1.5;
    set(hax,'ylim',yl)
    set(hax,'xtick',[1 2],'xticklabel',{'pre';'post'})
    title(hax,'GeoMean Prop of Orig (SD)','fontweight','normal')

    subplot(3,2,6);
%     hax = plot_geomeanSEM_bars(ones(size(postvpreproportion)),postvpreproportion);
    [hax,~,~,siax] = plot_stats_bars(ones(size(postvpreproportion)),postvpreproportion,'central','geomean','variance','sem');
    axes(hax)
    yl = get(hax,'ylim');
    ylim([yl(1)/10 yl(2)*1.1])
%     set(hax,'YScale','Log')
    set(hax,'xtick',[1 2],'xticklabel',{'pre';'post'})
    title(hax,'GeoMean Prop of Orig (SEM)','fontweight','normal')
    axes(siax(1))
    axes(siax(2))  
    
AboveTitle(VsString)
set(h(end),'name',[VsString '_BarPlots'])
