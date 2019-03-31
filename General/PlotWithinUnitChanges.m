function PlotWithinUnitChanges(pre,post)

% percent changes... look at linear changes on this
prepostpercentchg = ConditionedPercentChange(pre,post);

% proportions of original - use geometric stats here
postvpreproportion = ConditionedProportion(pre,post);


subplot(2,2,1)
    [~, centers]=hist(prepostpercentchg',max([50 round(length(postvpreproportion)/2)]));%to get counts
    hist(prepostpercentchg',max([50 round(length(postvpreproportion)/2)]));%to plot
    hold on
    yl = get(gca,'ylim');
    plot(([0 0]),[0 yl(2)],'color',[.5 .5 .5],'LineWidth',2)
    plot(([nanmedian(prepostpercentchg) nanmedian(prepostpercentchg)]),[0 yl(2)],'color',[1 0 0],'LineWidth',2,'LineStyle','--')

    binwidth = centers(2)-centers(1);
%         xlim([min(centers)-binwidth) max(centers)+binwidth])
%         xlim([-100 500])
    title('Percent Changes','fontweight','normal')

subplot(2,2,3)
    [binedges,counts,minedge] = semilogxhist(postvpreproportion,max([50 round(length(postvpreproportion)/2)]));
    hold on
    yl = get(gca,'ylim');
    plot(([1 1]),[0 yl(2)],'color',[.5 .5 .5],'LineWidth',2)
    plot(([median(postvpreproportion) median(postvpreproportion)]),[0 yl(2)],'color',[1 0 0],'LineWidth',2,'LineStyle','--')
    set(gca,'XScale','log')
%         xlim([.25 4])
%         set(gca,'XTick',[0 .2 .5 1 2 5]);
%         set(gca,'XTickLabel',[0 .2 .5 1 2 5]);
% %         xlim([minedge max(edges)])
    title('Post as a proportion of Pre Log X','fontweight','normal')

decreasers = prepostpercentchg<0;
ncs = postvpreproportion==0;
increasers = prepostpercentchg>0;
subplot(3,2,2)%Plot number of incresers & decreasers
    bar([sum(decreasers)/length(prepostpercentchg)*100 sum(ncs)/length(prepostpercentchg)*100 sum(increasers)/length(prepostpercentchg)*100])
    title('Dec v NC v Inc %-ages','fontweight','normal')
    ylabel('%of pop')

subplot(3,4,7)%Plot median pre of increasers, decreasers;
%         hax1 = plot_nanmedianSEM_bars(pre(decreasers),pre(ncs),pre(increasers));
    hax1 = plot_stats_bars(pre(decreasers),pre(ncs),pre(increasers),'central','nanmean','variance','sem');
%         bar([nanmedian(pre(decreasers)) nanmedian(pre(ncs)) nanmedian(pre(increasers))])
    title(hax1,'Med Pre DvNCvI','fontweight','normal')
    yl1 = get(hax1,'ylim');
subplot(3,4,8)%plot mean post of increasers, decreasers
%         hax2 = plot_nanmedianSEM_bars(post(decreasers),post(ncs),post(increasers));
    hax2 = plot_stats_bars(post(decreasers),post(ncs),post(increasers),'central','nanmean','variance','sem');

    title(hax2,'Med Post DvNCvI','fontweight','normal')
    yl2 = get(hax2,'ylim');
    set(hax1,'ylim',[min([yl1(1) yl2(1)]) max([yl1(2) yl2(2)])])
    set(hax2,'ylim',[min([yl1(1) yl2(1)]) max([yl1(2) yl2(2)])])

subplot(3,4,11)%plot mean percent change of increasers, decreasers
%         hax3 = plot_nanmedianSD_bars(prepostpercentchg(decreasers),prepostpercentchg(ncs),prepostpercentchg(increasers));
    hax3 = plot_stats_bars(prepostpercentchg(decreasers),prepostpercentchg(ncs),prepostpercentchg(increasers),'central','nanmean','variance','sem');
    title(hax3,'Med %Chg DvNCvI','fontweight','normal')
subplot(3,4,12)%plot mean proportion of increasers, decreasers
%         hax3 = plot_nanmedianSD_bars(postvpreproportion(decreasers),postvpreproportion(ncs),postvpreproportion(increasers));
    hax4 = plot_stats_bars(10*postvpreproportion(decreasers),10*postvpreproportion(ncs),10*postvpreproportion(increasers),'central','nanmean','variance','sem');
    axes(hax4)
    hold on;
    plot([0 4],[1 1],'k')
    set(hax4,'Yscale','log')
    yl = ylim;
    ylim([yl(1)*.9 yl(2)*1.11])
    title(hax4,'Med Proport DvNCvI','fontweight','normal')
        