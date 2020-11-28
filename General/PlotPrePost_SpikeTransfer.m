function [h,r,p,coeffs,prepostpercentchg,postvpreproportion] = PlotPrePost(pre,post,smoothwidth)
% Pre and Post are vectors of the same length, presumably referring
% element-wise to the same data generators.  Smoothwidth determines
% smoothing of histograms... if no input defaults to no smoothing.
% h is a handle of all figures generated
% r,p and coeffs are each cell array of 4 values relating to x vs y 
% correlations for linear vs linear, log vs linear, linear vs log and
% log vs log versions of x and y

%% Basic initial calculations and setup
pre = pre(:);
post = post(:);

if ~exist('smoothwidth','var')
    smoothwidth = 1;%default no smoothing of histograms
end

% percent changes... look at linear changes on this
prepostpercentchg = ConditionedPercentChange(pre,post);

% proportions of original - use geometric stats here
postvpreproportion = ConditionedProportion(pre,post);



h = [];
n1 = inputname(1);
n2 = inputname(2);
VsString = [n1 'VS' n2];

%% Summary bar graphs of all changes
h(end+1) = PrePostBars(pre,post,VsString);

%% Histograms pre vs post (affected by smoothwidth)
if length(pre)>5 & length(post)>5 & sum(cat(1,pre,post)>0)>0
    h(end+1) = TwoDistributionsByHistLinearAndLog(pre,post,smoothwidth);
    set(h(end),'name',[VsString '_PrePostDistros'])
end

%% Scatter plot of pre vs post
h(end+1) = figure('name',[VsString '_ScatterPlot'],'position',[2 2 400 800]);
subplot(2,1,1)
ScatterWStats(pre,post)

subplot(2,1,2)
ScatterWStats(pre,post,'loglog')


%% WITHIN-CELL CHANGES NOW
%% Element-by Element changes in rates over various intervals in various states 
% use above to do simple 2 point plots for each comparison

h(end+1) = SpikingAnalysis_PairsPlotsWMedianLinearAndLog(pre',post');
    subplot(1,2,1)
%     title(['E:Pre-Presleep Waking vs Post-Presleep Waking Per Synapse',rt],'fontweight','normal'))
    subplot(1,2,2)
    title('Log scale','fontweight','normal')
%     set(h(end),'name',[basename,'_ESynapseStrengthChanges-PreVsPostWake',rt])
AboveTitle(VsString)
set(h(end),'name',[VsString '_WithinCell'],'Position',[0 2 400 800])

%% histograms of Per-Cell percent changes and increasers vs decreasers (not currently affected by smoothwidth)
if ~isempty(prepostpercentchg)
    h(end+1)=figure('name',[VsString '_HistoPctChgs'],'Position',[0 2 760 600]);
    subplot(2,2,1)
        [~, centers]=hist(prepostpercentchg',max([50 round(length(postvpreproportion)/2)]));%to get counts
        hist(prepostpercentchg',max([50 round(length(postvpreproportion)/2)]));%to plot
        hold on
        yl = get(gca,'ylim');
        plot(([0 0]),[0 yl(2)],'color',[.5 .5 .5],'LineWidth',2)
        plot(([nanmedian(prepostpercentchg) nanmedian(prepostpercentchg)]),[0 yl(2)],'color',[1 0 0],'LineWidth',2,'LineStyle','--')

        binwidth = centers(2)-centers(1);
% %         xlim([min(centers)-binwidth) max(centers)+binwidth])
%         xlim([-100 500])
        title('Percent Changes','fontweight','normal')

    subplot(2,2,3)
        [binedges,counts,minedge] = semilogxhist(postvpreproportion,max([50 round(length(postvpreproportion)/2)]));
        hold on
        yl = get(gca,'ylim');
        plot(([1 1]),[0 yl(2)],'color',[.5 .5 .5],'LineWidth',2)
        plot(([median(postvpreproportion) median(postvpreproportion)]),[0 yl(2)],'color',[1 0 0],'LineWidth',2,'LineStyle','--')
        set(gca,'XScale','log')
        xlim([min(binedges)*.8 max(binedges)*1.5])
%         xlim([.25 4])
%         set(gca,'XTick',[0 .2 .5 1 2 5]);
%         set(gca,'XTickLabel',[0 .2 .5 1 2 5]);
        title('Post as a proportion of Pre Log10','fontweight','normal')

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
        
    AboveTitle([VsString '_WithinCellChanges'])
end


%% Plot Relative increases or decreases in top/bottom portions
q_rng = GetQuartilesByLogRange(pre);
q_rnk = GetQuartilesByRank(pre);
RngIDPlotVect=[];
RnkIDPlotVect=[];
lbls = {};
for a = 1:4
    q_rng_increasers{a} = find(postvpreproportion(q_rng==a)>1);
    q_rng_decreasers{a} = find(postvpreproportion(q_rng==a)<1);
    q_rng_NC{a} = find(postvpreproportion(q_rng==a)==1);
    RngIDPlotVect=cat(2,RngIDPlotVect,[length(q_rng_decreasers{a}) length(q_rng_NC{a}) length(q_rng_increasers{a}) 0 0 ]);

    q_rnk_increasers{a} = find(postvpreproportion(q_rnk==a)>1);
    q_rnk_decreasers{a} = find(postvpreproportion(q_rnk==a)<1);
    q_rnk_NC{a} = find(postvpreproportion(q_rnk==a)==1);
    RnkIDPlotVect=cat(2,RnkIDPlotVect,[length(q_rnk_decreasers{a}) length(q_rnk_NC{a}) length(q_rnk_increasers{a}) 0 0 ]);
    
    q_rng_IncreasersDecrasersRatio(a) = length(q_rng_increasers{a})/length(q_rng_decreasers{a});
    q_rnk_IncreasersDecrasersRatio(a) = length(q_rnk_increasers{a})/length(q_rnk_decreasers{a});
    
    lbls = cat(1,lbls,{'Dec'},{'NC'},{'Inc'},{'__'},{''});
end

pause(1)

h(end+1) = figure('name',[VsString '_PctChgsVsInitialQuartiles'],'Position',[0 2 400 800]);
subplot(3,2,1)
    hax = plot_nanmedianSD_bars(log10(postvpreproportion(q_rng==1)),log10(postvpreproportion(q_rng==2)),log10(postvpreproportion(q_rng==3)),log10(postvpreproportion(q_rng==4)));
    ylabel(hax,'Post/Pre (proportion)')
    xlabel(hax,'Quartile (by RANGE)')
%     title(hax,'Median Post v Pre proportion per RANGE quartile','fontweight','normal'))
subplot(3,2,2)
%     hax = plot_nanmedianSD_bars(log10(postvpreproportion(q_rnk==1)),log10(postvpreproportion(q_rnk==2)),log10(postvpreproportion(q_rnk==3)),log10(postvpreproportion(q_rnk==4)));
    v1 = log10(postvpreproportion(q_rnk==1));
    v2 = log10(postvpreproportion(q_rnk==2));
    v3 = log10(postvpreproportion(q_rnk==3));
    v4 = log10(postvpreproportion(q_rnk==4));
    vect = cat(1,v1,v2,v3,v4);
    groups = cat(1,ones(length(v1),1),2*ones(length(v2),1),3*ones(length(v3),1),4*ones(length(v4),1));
    plot([0.5 4.5],[0 0],'k')
    hold on
    boxplot(vect,groups,'whisker',0,'boxstyle','filled');
    delete(findobj('tag','Outliers'))
    axis tight;  
    yl = ylim;
    ylim([yl(1)-0.1*yl(2) yl(2)+0.1*yl(2)])
    hax = gca;
    ylabel(hax,'Post/Pre (proportion)')
    xlabel(hax,'Quartile (by RANK)')
%     title(hax,'Median Post v Pre proportion per RANK quartile','fontweight','normal'))
subplot(3,2,3)
    bar(RngIDPlotVect);
    set(gca,'XTick',[0:length(lbls)-1],'XTickLabel',lbls,'Xlim',[0 length(lbls)+1]);
    xticklabel_rotate
    ylabel(gca,'# Increasers or Decreaers')
    xlabel(gca,'Quartile (by RANGE)')
subplot(3,2,4)
    bar(RnkIDPlotVect);
    set(gca,'XTick',[0:length(lbls)-1],'XTickLabel',lbls,'Xlim',[0 length(lbls)+1]);
    xticklabel_rotate
    ylabel(gca,'# Increasers or Decreaers')
    xlabel(gca,'Quartile (by RANK)')
subplot(3,2,5)
    bar(log10(q_rng_IncreasersDecrasersRatio))
    xlabel(gca,'Quartile (by RANGE)')
    ylabel(gca,'Log10 of Increaser:Decreaser Ratio')
subplot(3,2,6)
    bar(log10(q_rnk_IncreasersDecrasersRatio))
    xlabel(gca,'Quartile (by RANGE)')
    ylabel(gca,'Log10 of Increaser:Decreaser Ratio')

%% plot initial vs change
% h(end+1)=figure('name',[VsString '_PctChgsVsInitial'],'Position',[0 2 560 950]);
NString = [n2 'Ov' n1 'Vs' n1];
h(end+1)=figure('name',[NString]);
[r,p,~,coeffs] = PlotAndRegressLinearAndLog(pre,postvpreproportion);
AboveTitle(NString)

% Use GetQuartiles