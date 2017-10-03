function h = SpikingAnalysis_PlotPopChangesBetweenIntervals(varargin)
% function h = SpikingAnalysis_PlotPopChangesBetweenIntervals(pre1,post1,pre2,post2,names)
% pre2 and post2 are optional

numinputs = nargin;
if iscell(varargin{end})
    names = varargin{end};
%     if numel(names)<1;
%         names{1} = [];
%     end
%     if numel(names)<2;
%         names{2} = [];
%     end
%     if numel(names)<3;
%         names{3} = [];
%     end    
%     if numel(names)<4;
%         names{4} = [];
%     end
    numinputs = nargin - 1;
else
    names{1} = [];
    names{2}= [];
    names{3} = [];
    names{4} = [];
end
s1 = names{1};
s2 = names{2};
t1 = names{3};
t2 = names{4};

pre1 = varargin{1};
post1 = varargin{2};
if numinputs<4
    pre2 = [];
    post2 = [];
else
    pre2 = varargin{3};
    post2 = varargin{4};
end


%% set up for plotting

num1Cells = length(pre1);
numbins1 = round(num1Cells/5);
if ~isempty(pre2)
    num2Cells = length(pre2);
    numbins1 = round(num2Cells/5);
end

h = [];
swscolor = [.1 .3 1];

%% Plot distro of individual cell spiking rate changes over sleep (bar graph)
h = plotprepostbars(pre1,post1,pre2,post2,h,names);

%% Overlay distributions before vs after sleep
h = plotprepostdistros(pre1,post1,pre2,post2,h,names);


%% Cell-by-cell changes in rates over various intervals in various states 
%>(see BWRat20 analysis)
% use above to do simple 2 point plots for each comparison

h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(pre1,post1);
    subplot(1,2,1)
    title(['s1:' t1 ' vs ' t2])
    subplot(1,2,2)
    title('Log scale')
    set(h(end),'name',[s1 t1 'Vs' t2])
if isempty(pre2)%Icells
%     h(end+1) = figure;
%         title(['No ICells for ' ])
%         set(h(end),'name',['_ICellByCellRateChanges-Prewake vs Postwake'])
else
    h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(pre2,post2);
        subplot(1,2,1)
        title(['s2:' t1 ' vs ' t2])
        subplot(1,2,2)
        title('Log scale')
        set(h(end),'name',[s2 t1 'Vs' t2])
end


% %looking at percent changes per cell
%histograms of those percent changes
RatioPrePost1 = 10.^ConditionedLogOfRatio(post1,pre1);
if ~isempty(pre2)
    RatioPrePost2 = 10.^ConditionedLogOfRatio(post2,pre2);
end

% h(end+1)=figure;
h(end+1) = SpikingAnalysis_PlotRateDistributionsLinearAndLog(RatioPrePost1,'numbins',numbins1);
    title(['Histogram of ' s1 'Percent changes from ' t1 ' to ' t2])
    set(h(end),'name',['HistoOf' s1 'Changes-' t1 'Vs' t2])
if isempty(pre2)%Icells
%     h(end+1) = figure;
%         title(['No ICells for ' ])
%         set(h(end),'name',['_HistoOfICellRateChanges-PrewakeVsPostwake'])
else
    h(end+1)=SpikingAnalysis_PlotRateDistributionsLinearAndLog(RatioPrePost1,'numbins',numbins1);
        title(['Histogram of ' s2 'Percent changes from ' t1 ' to ' t2])
        set(h(end),'name',['HistoOf' s2 'Changes-' t1 'Vs' t2])
end


h(end+1)=figure;
    subplot(2,1,1);
    x = pre1;
%     x = NoInf_PrewakeESpikeRates;
    y = RatioPrePost1;
    plot(x,y,'marker','.','Line','none');
    [yfit,r2,p] =  RegressAndFindR2(x,y,1);
    hold on;
    plot(x,yfit,'r')
    text(0.8*max(x),0.8*max(y),{['r2=',num2str(r2)];['p=',num2str(p)]})
    title([s1 'Percent change in ' t1 'Vs' t2 'VS ' t1 'value'])
%     xlabel('Cell initial spike rate')
    ylabel('Proportion change')
    subplot(2,1,2);
    x(x==0) = min(x(x>0));
    y(y==0) = min(y(y>0));
    x = log10(x);
    y = log10(y);
    plot(x,y,'marker','.','Line','none');
    [yfit,r2,p] =  RegressAndFindR2(x,y,1);
    hold on;
    plot(x,yfit,'r')
    text(0.8*max(x),0.8*max(y),{['r2=',num2str(r2)];['p=',num2str(p)]})
%     title('Ecells: Change in spike rate in early vs late SWS VS initial spike rate')
    xlabel(['Log ' s1 ' ' t1 'Value'])
    ylabel(['Log Proportion change in ' s1])
    set(gca,'XTickLabel',10.^get(gca,'XTick'))
    set(gca,'YTickLabel',10.^get(gca,'YTick'))
    set(gca,'YTickLabel',10.^get(gca,'YTick'))
    set(h(end),'name',['ChangeVsInitialValue-' s1])

if isempty(pre2)%Icells
%     h(end+1) = figure;
%         title(['No ICells for ' ])
%         set(h(end),'name',['_ChangeVsInitialRate-Icells'])
else
    h(end+1)=figure;
        subplot(2,1,1);
        x = pre2;
    %     x = NoInf_PrewakeESpikeRates;
        y = RatioPrePost2;
        plot(x,y,'marker','.','Line','none');
        [yfit,r2,p] =  RegressAndFindR2(x,y,1);
        hold on;
        plot(x,yfit,'r')
        text(0.8*max(x),0.8*max(y),{['r2=',num2str(r2)];['p=',num2str(p)]})
        title([s2 'Percent change in ' t1 'Vs' t2 'VS ' t1 'value'])
    %     xlabel('Cell initial spike rate')
        ylabel('Proportion change')
        subplot(2,1,2);
        x(x==0) = min(x(x>0));
        y(y==0) = min(y(y>0));
        x = log10(x);
        y = log10(y);
        plot(x,y,'marker','.','Line','none');
        [yfit,r2,p] =  RegressAndFindR2(x,y,1);
        hold on;
        plot(x,yfit,'r')
        text(0.8*max(x),0.8*max(y),{['r2=',num2str(r2)];['p=',num2str(p)]})
    %     title('Ecells: Change in spike rate in early vs late SWS VS initial spike rate')
        xlabel(['Log ' s1 ' ' t1 'Value'])
        ylabel(['Log Proportion change in ' s1])
        set(gca,'XTickLabel',10.^get(gca,'XTick'))
        set(gca,'YTickLabel',10.^get(gca,'YTick'))
        set(gca,'YTickLabel',10.^get(gca,'YTick'))
        set(h(end),'name',['_ChangeVsInitialRate-Icells'])
end


%save figs
% MakeDirSaveFigsThere('CellRateDistributionFigs',h)




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = plotprepostbars(pre1,post1,pre2,post2,h,names)
% Plot population rate change stats over sleep (bar graphs)... raw, by
% pre/post diff, by pre/post ratio, in E and I cells, with SD and SEM error
% bars
%% Extract data to invidual variables

% num1Cells = length(pre1);
% numbins1 = round(num1Cells/5);
% if ~isempty(pre2)
%     num2Cells = length(pre2);
%     numbins1 = round(num2Cells/5);
% end
s1 = names{1};
s2 = names{2};
t1 = names{3};
t2 = names{4};

h(end+1) = figure;
    set(h(end),'name',[s1 'ChangesSD'])
    %Raw
    subplot(1,3,1)
    plot_meanSD_bars(pre1',post1');
    title([s1 ':' t1 ' vs ' t2 ' - Raw'])
    ylabel('')
    set(gca,'XTickLabel',{'',t1,'',t2,''})    
    %Per cell difference
    subplot(1,3,2)
    plot_meanSD_bars(pre1-pre1,post1-pre1);
    title({[s1 ':' t1 ' vs ' t2 ' Difference']})
    ylabel('Difference in original units, subtracted unit-wise')
    set(gca,'XTickLabel',{'',t1,'',t2,''})    
         %stats
    te2 = post1-pre1;
    [ht,p,ci,stats] = ttest(te2);
    xl = get(gca,'xlim');
    yl = get(gca,'ylim');
    text(xl(2)*0.8,yl(2)*0.8,['p=' num2str(p)])
    
    %Per cell ratio 
    subplot(1,3,3)
    plot_geomeanoflogofratiosSD_bars(zeros(size(pre1)),ConditionedLogOfRatio(post1,pre1));
    title({[s1 ':' t1 ' vs ' t1 ' Ratio']})
    ylabel('Fold of Original')
    set(gca,'XTickLabel',{'',t1,'',t2,''})    
         %stats
    te2 = ConditionedLogOfRatio(post1,pre1);
    [ht,p,ci,stats] = ttest(te2);
    xl = get(gca,'xlim');
    yl = get(gca,'ylim');
    text(xl(2)*0.8,yl(2)*0.8,['p=' num2str(p)])

if isempty(pre2)%Icells
%     h(end+1) = figure;
%         title(['No ICells for ' ])
%         set(h(end),'name',['_ICellSpikeHisto-WholeRecording'])
else
    h(end+1) = figure;
        set(h(end),'name',[s2 'ChangesSD'])
        %Raw
        subplot(1,3,1)
        plot_meanSD_bars(pre2',post2');
        title([s1 ':' t1 ' vs ' t2 ' - Raw'])
        ylabel('')
        set(gca,'XTickLabel',{'',t1,'',t2,''})    
        %Per cell difference
        subplot(1,3,2)
        plot_meanSD_bars(pre2-pre2,post2-pre2);
        title({[s2 ':' t1 ' vs ' t2 ' Difference']})
        ylabel('Difference in original units, subtracted unit-wise')
        set(gca,'XTickLabel',{'',t1,'',t2,''})    
             %stats
        te2 = post2-pre2;
        [ht,p,ci,stats] = ttest(t2);
        xl = get(gca,'xlim');
        yl = get(gca,'ylim');
        text(xl(2)*0.8,yl(2)*0.8,['p=' num2str(p)])

        %Per cell ratio 
        subplot(1,3,3)
        plot_geomeanoflogofratiosSD_bars(zeros(size(pre2)),ConditionedLogOfRatio(post2,pre2));
        title({[s2 ':' t1 ' vs ' t1 ' Ratio']})
        ylabel('Fold of Original')
        set(gca,'XTickLabel',{'',t1,'',t2,''})    
             %stats
        te2 = ConditionedLogOfRatio(post1,pre1);
        [ht,p,ci,stats] = ttest(t2);
        xl = get(gca,'xlim');
        yl = get(gca,'ylim');
        text(xl(2)*0.8,yl(2)*0.8,['p=' num2str(p)])
end

%% SEM
h(end+1) = figure;
    set(h(end),'name',[s1 'ChangesSEM'])
    %Raw
    subplot(1,3,1)
    plot_meanSEM_bars(pre1',post1');
    title([s1 ':' t1 ' vs ' t2 ' - Raw'])
    ylabel('')
    set(gca,'XTickLabel',{'',t1,'',t2,''})    
    %Per cell difference
    subplot(1,3,2)
    plot_meanSEM_bars(pre1-pre1,post1-pre1);
    title({[s1 ':' t1 ' vs ' t2 ' Difference']})
    ylabel('Difference in original units, subtracted unit-wise')
    set(gca,'XTickLabel',{'',t1,'',t2,''})    
         %stats
    te2 = post1-pre1;
    [ht,p,ci,stats] = ttest(t2);
    xl = get(gca,'xlim');
    yl = get(gca,'ylim');
    text(xl(2)*0.8,yl(2)*0.8,['p=' num2str(p)])
    
    %Per cell ratio 
    subplot(1,3,3)
    plot_geomeanoflogofratiosSEM_bars(zeros(size(pre1)),ConditionedLogOfRatio(post1,pre1));
    title({[s1 ':' t1 ' vs ' t1 ' Ratio']})
    ylabel('Fold of Original')
    set(gca,'XTickLabel',{'',t1,'',t2,''})    
         %stats
    te2 = ConditionedLogOfRatio(post1,pre1);
    [ht,p,ci,stats] = ttest(t2);
    xl = get(gca,'xlim');
    yl = get(gca,'ylim');
    text(xl(2)*0.8,yl(2)*0.8,['p=' num2str(p)])
if isempty(pre2)%Icells
%     h(end+1) = figure;
%         title(['No ICells for ' ])
%         set(h(end),'name',['_ICellSpikeHisto-WholeRecording'])
else
    h(end+1) = figure;
        set(h(end),'name',[s2 'ChangesSEM'])
        %Raw
        subplot(1,3,1)
        plot_meanSEM_bars(pre2',post2');
        title([s1 ':' t1 ' vs ' t2 ' - Raw'])
        ylabel('')
        set(gca,'XTickLabel',{'',t1,'',t2,''})    
        %Per cell difference
        subplot(1,3,2)
        plot_meanSEM_bars(pre2-pre2,post2-pre2);
        title({[s2 ':' t1 ' vs ' t2 ' Difference']})
        ylabel('Difference in original units, subtracted unit-wise')
        set(gca,'XTickLabel',{'',t1,'',t2,''})    
             %stats
        te2 = post2-pre2;
        [ht,p,ci,stats] = ttest(t2);
        xl = get(gca,'xlim');
        yl = get(gca,'ylim');
        text(xl(2)*0.8,yl(2)*0.8,['p=' num2str(p)])

        %Per cell ratio 
        subplot(1,3,3)
        plot_geomeanoflogofratiosSEM_bars(zeros(size(pre2)),ConditionedLogOfRatio(post2,pre2));
        title({[s2 ':' t1 ' vs ' t1 ' Ratio']})
        ylabel('Fold of Original')
        set(gca,'XTickLabel',{'',t1,'',t2,''})    
             %stats
        te2 = ConditionedLogOfRatio(post1,pre1);
        [ht,p,ci,stats] = ttest(t2);
        xl = get(gca,'xlim');
        yl = get(gca,'ylim');
        text(xl(2)*0.8,yl(2)*0.8,['p=' num2str(p)])
end



%%%%%
function h = plotprepostdistros(pre1,post1,pre2,post2,h,names)

s1 = names{1};
s2 = names{2};
t1 = names{3};
t2 = names{4};

num1Cells = length(pre1);
numbins1 = round(num1Cells/5);
if ~isempty(pre2)
    num2Cells = length(pre2);
    numbins1 = round(num2Cells/5);
end
% swscolor = [.1 .3 1];


h(end+1) = SpikingAnalysis_PlotRateDistributionsLinearAndLog(pre1,'numbins',numbins1,'color','k');
    SpikingAnalysis_OverlayRateDistributionsLinearAndLog(h(end),post1,'numbins',numbins1,'color',[.3 .5 .9])
    subplot(2,1,1)
    legend(t1,t2)
    title(['Distribution for ' s1 ' for ' t1 ' vs ' t2 ': Linear scale.''n = ' num2str(num1Cells) 's1'])
    hold on
    subplot(2,1,2)
    title(['Distribution for ' s1 ' for ' t1 ' vs ' t2 ': Semilog scale'])
    set(h(end),'name',[s1 t1 t2 'HistoOverlay'])
if isempty(pre2) | isempty(post2)
%     h(end+1) = figure;
%         title(['No Pre/Post ICells for this recording'])
%         set(h(end),'name',['_ECellPrePostWakeHistoOverlay'])
else
    h(end+1) = SpikingAnalysis_PlotRateDistributionsLinearAndLog(pre2,'numbins',numbins1,'color','k');
        SpikingAnalysis_OverlayRateDistributionsLinearAndLog(h(end),post2,'numbins',numbins1,'color',[.3 .5 .9])
        subplot(2,1,1)
        legend(t1,t2)
        title(['Distribution for ' s2 ' for ' t1 ' vs ' t2 ': Linear scale.''n = ' num2str(num1Cells) 's2'])
        hold on
        subplot(2,1,2)
        title(['Distribution for ' s2 ' for ' t1 ' vs ' t2 ': Semilog scale'])
        set(h(end),'name',[s2 t1 t2 'HistoOverlay'])
end
    