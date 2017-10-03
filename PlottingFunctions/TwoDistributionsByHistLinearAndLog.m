function h = TwoDistributionsByHistLinearAndLog(s1,s2,smoothwidth,VsString,precolor,postcolor,numbins)

if ~exist('smoothwidth','var')
    smoothwidth = 1;
end
if ~exist('VsString','var')
    VsString = [inputname(1) 'vs' inputname(2) 'Comparison'];
end
if ~exist('precolor','var')
    precolor = 'b';
end
if ~exist('postcolor','var')
    postcolor = 'r';
end
if ~exist('numbins','var')
    numbins = max([25 length(s1)/2]);
end

s1 = s1(:);
s2 = s2(:);
s1(s1==Inf) = max(s1(s1<inf));
s1(s1==-Inf) = min(s1(s1>-inf));
s2(s2==Inf) = max(s2(s2<inf));
s2(s2==-Inf) = min(s2(s2>-inf));


h = figure('name',[VsString '_DistroComparison'],'Position',[0 2 1000 800]);

t = {s1,s2};
[lin_binbounds,log_binbounds] = GetBinBounds(t,numbins);%initial guess at good bins, will be refined below

[binloc_prelin,binval_prelin,binloc_prelog,binval_prelog] = RateDistributionsLinearAndLog...
        (s1,'binbounds_lin',lin_binbounds,'binbounds_log',log_binbounds);
[binloc_postlin,binval_postlin,binloc_postlog,binval_postlog] = RateDistributionsLinearAndLog...
        (s2,'binbounds_lin',lin_binbounds,'binbounds_log',log_binbounds);

subplot(3,2,1)%linear overlay
    hold on
    plot(binloc_prelin{1},smooth(binval_prelin,smoothwidth),'color',precolor)
    plot(binloc_postlin{1},smooth(binval_postlin,smoothwidth),'color',postcolor)
    %plotting medians
    plot([median(s1) median(s1)],[0 max([binval_prelin(:);binval_postlin(:)])],'color',precolor,'LineWidth',2)
    plot([median(s2) median(s2)],[0 max([binval_prelin(:);binval_postlin(:)])],'color',postcolor,'LineWidth',2)
    xllin = get(gca,'xlim');
    yllin = get(gca,'ylim');

    %variance stat test
    bad = isnan(s1)|isinf(s1)|isnan(s2)|isinf(s2);
    pptovartest = cat(2,s1(~bad),s2(~bad));
    variancep = vartestn(pptovartest,'testtype','brownforsythe','display','off');
    text(xllin+0.6*(xllin(2)-xllin(1)),yllin+0.4*(yllin(2)-yllin(1)),['Variance Diff: p = ' num2str(variancep)]);
    text(xllin+0.6*(xllin(2)-xllin(1)),yllin+0.64*(yllin(2)-yllin(1)),['SD pre = ' num2str(nanstd(s1))]);
    text(xllin+0.6*(xllin(2)-xllin(1)),yllin+0.52*(yllin(2)-yllin(1)),['SD post = ' num2str(nanstd(s2))]);

    %plot patches relating to stds
%     x1e = median(s1)-nanstd(s1);
%     x2e = median(s1) + nanstd(s1);
%     y1e = yllin(1)+1.1*(yllin(2)-yllin(1));
%     y2e = yllin(1)+1.2*(yllin(2)-yllin(1));
%     x1o = median(s2)-nanstd(s2);
%     x2o = median(s2) + nanstd(s2);
%     y1o = yllin(1)+1*(yllin(2)-yllin(1));
%     y2o = yllin(1)+1.1*(yllin(2)-yllin(1));
%     patch([x1e,x1e,x2e,x2e],[y1e y2e y2e y1e],precolor)
%     patch([x1o,x1o,x2o,x2o],[y1o y2o y2o y1o],postcolor)
%     yllin = [yllin(1) y2e];
%     xllin = [min([xllin(1) x1e x1o]) max([xllin(2) x2e x2o])];
%     set(gca,'ylim',yllin)
%     set(gca,'xlim',xllin)

    legend('pre','post','Location','NorthEast')
%     title('Linear (bars are median+-SD)','fontweight','normal')
    title('Linear','fontweight','normal')
    
subplot(3,2,2)%log overlay
    hold on
    plot(log10(binloc_prelog{1}),smooth(binval_prelog,smoothwidth),'color',precolor,'LineWidth',1);
    plot(log10(binloc_postlog{1}),smooth(binval_postlog,smoothwidth),'color',postcolor,'LineWidth',1);
    set(gca,'Xticklabel',10.^get(gca,'Xtick'))
    if min(binloc_prelog{1}) == max(binloc_prelog{1});
        xlim([min([binloc_prelog{1} binloc_postlog{1}])-1 min([binloc_prelog{1} binloc_postlog{1}])+1])
    else
        xlim(log10([min([binloc_prelog{1} binloc_postlog{1}])/1.4 max([binloc_prelog{1} binloc_postlog{1}])*1.4]))
    end
    %     goodymax = max([binval_prelog(2:end);binval_prelog(2:end)]);
%     ylim([0 goodymax*1.2])
    xllog = get(gca,'xlim');
    yllog = get(gca,'ylim');
    plot(log10([median(s1) median(s1)]),[0 1.2*max([binval_prelog(:); binval_postlog(:)])],'color',precolor,'LineWidth',2)
    plot(log10([median(s2) median(s2)]),[0 1.2*max([binval_prelog(:); binval_postlog(:)])],'color',postcolor,'LineWidth',2)

    %variance stat test
    l1 = log10(s1);
    l2 = log10(s2);
    l1(l1==-Inf) = min(l1(~isinf(l1)));
    l2(l2==-Inf) = min(l2(~isinf(l2)));
    pptovartest = cat(2,l1,l2);
    variancep = vartestn(pptovartest,'testtype','brownforsythe','display','off');
    text(xllog+0.6*(xllog(2)-xllog(1)),yllog+0.4*(yllog(2)-yllog(1)),['Variance Diff: p = ' num2str(variancep)]);
    text(xllog+0.6*(xllog(2)-xllog(1)),yllin+0.64*(yllog(2)-yllog(1)),['SD pre = ' num2str(nanstd(l1))]);
    text(xllog+0.6*(xllog(2)-xllog(1)),yllin+0.52*(yllog(2)-yllog(1)),['SD post = ' num2str(nanstd(l2))]);
%     x1e = percentilevalue(s1,5);
%     x2e = percentilevalue(s1,95);
%     y1e = yllog(1)+1.1*(yllog(2)-yllog(1));
%     y2e = yllog(1)+1.2*(yllog(2)-yllog(1));
%     x1o = percentilevalue(s2,5);
%     x2o = percentilevalue(s2,95);
%     y1o = yllog(1)+1*(yllog(2)-yllin(1));
%     y2o = yllog(1)+1.1*(yllog(2)-yllin(1));
%     patch(log10([x1e,x1e,x2e,x2e]),[y1e y2e y2e y1e],precolor)
%     patch(log10([x1o,x1o,x2o,x2o]),[y1o y2o y2o y1o],postcolor)
%     yllog = [yllog(1) y2e];
%     xllog = [min([xllog(1) log10(x1e) log10(x1o)]) max([xllog(2) log10(x2e) log10(x2o)])];
%     set(gca,'ylim',yllog)
%     set(gca,'xlim',xllog)
    
    legend('pre','post','Location','NorthEast')
%     title('log10 values (bars are 5th,95th %iles','fontweight','normal')
    title('log10 values','fontweight','normal')

subplot(6,2,5) %subtraction tendencies vs expected from plot linear
    numer = smooth((binval_postlin-binval_prelin),smoothwidth);
    plot(binloc_prelin{1},numer,'k')
    hold on
    plot(xllin,[0 0],'--k')
    axis tight
    set(gca,'xlim',xllin)
    title('Diff of distributions (post-pre)','fontweight','normal')
subplot(6,2,7) %normalized by expected abs based on raw distrib
    denom = smooth((binval_prelin),smoothwidth);%smoothed x
    numer = smooth((binval_postlin-binval_prelin),smoothwidth);
    plot(binloc_prelin{1},numer./denom,'k')
    hold on
    plot(xllin,[0 0],'--k')
    axis tight
    set(gca,'xlim',xllin)
    title('Diff of distributions OVER pre distrib ','fontweight','normal')

subplot(6,2,6)%subtraction log
    if ~isempty(binval_prelog) && ~isempty(binval_postlog)
        numer = smooth((binval_postlog-binval_prelog),smoothwidth);
        plot(log10(binloc_prelog{1}),numer,'k')
    end
    hold on
    plot(xllog,[0 0],'--k')
    plot([0 0],get(gca,'ylim'),'--k')
    title('Diff of log distributions (post-pre)','fontweight','normal')
    axis tight
    set(gca,'xlim',xllog)
subplot(6,2,8)%normalized by expected abs based on raw distrib
    if ~isempty(binval_prelog) && ~isempty(binval_postlog)
        denom = smooth(binval_prelog,smoothwidth);
        plot(log10(binloc_prelog{1}),numer./denom,'k')
    end
    hold on
    plot(xllog,[0 0],'--k')
    plot([0 0],get(gca,'ylim'),'--k')
    title('Diff of log distributions OVER pre distrib','fontweight','normal')
    axis tight
    set(gca,'xlim',xllog)

subplot(3,2,5)
    plot(binloc_prelin{1},cumsum(binval_prelin),'color',precolor)
    hold on;
    plot(binloc_postlin{1},cumsum(binval_postlin),postcolor)
    title('linear cum distrib','fontweight','normal')
    set(gca,'xlim',xllin)
    
subplot(3,2,6)
    if ~isempty(binloc_prelog{1}) & ~isempty(binloc_postlog{1})
        plot(log10(binloc_prelog{1}),cumsum(binval_prelog),'color',precolor)
        hold on;
        plot(log10(binloc_postlog{1}),cumsum(binval_postlog),'color',postcolor)
        title('semilogx cum distrib','fontweight','normal')
        legend('pre','post','Location','SouthEast')
        set(gca,'xlim',xllog)
    end

AboveTitle(VsString)
