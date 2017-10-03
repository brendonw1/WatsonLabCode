function h=SpikingAnalysis_PairsPlotsWMeanLinearAndLogByQuartile(series1,series2,quartileidxs)

h = figure;
p = get(h,'Position');
p(3) = 900;
set(h,'Position',p)
QuadColors = GetQuadColors;

subplot(1,3,1);
hold on
xlim([0.5 2.5])
for a = 1:4 %for each quartile
    s1 = series1(quartileidxs==a);
    s2 = series2(quartileidxs==a);
%     ph = plot([s1 s2]','color',QuadColors(a,:),'Marker','o');
    for b = 1:length(s1)
        ph = patchline([1 2],[s1(b) s2(b)],'edgecolor',QuadColors(a,:),'edgealpha',0.15);
    end
    errorbar([0.9-a*.05 2.4-a*.05],[mean(s1) mean(s2)],[std(s1) std(s2)],...
    'Color',QuadColors(a,:),'Marker','.','LineStyle','none')
    line([0.9-a*.05 2.4-a*.05],[mean(s1) mean(s2)],'Color',QuadColors(a,:),'LineWidth',2.2)
end

%% repeat similar but manually make data log before plotting and manually make scale exponential
sh = subplot(1,3,2);
hold on
xlim([0.5 2.5])
for a = 1:4 %for each quartile
    t1 = series1(quartileidxs==a);
    t2 = series2(quartileidxs==a);
    s1 = log(t1);
    s2 = log(t2);
    s1(t1==0) = min(s1(isfinite(s1)));
    s2(t2==0) = min(s2(isfinite(s2)));
    
%     ph = plot([s1 s2]','color',QuadColors(a,:),'Marker','o');
    for b = 1:length(s1)
        ph = patchline([1 2],[s1(b) s2(b)],'edgecolor',QuadColors(a,:),'edgealpha',0.15);
    end
    errorbar([0.9-a*.05 2.4-a*.05],[mean(s1) mean(s2)],[std(s1) std(s2)],...
    'Color',QuadColors(a,:),'Marker','.','LineStyle','none')
    line([0.9-a*.05 2.4-a*.05],[mean(s1) mean(s2)],'Color',QuadColors(a,:),'LineWidth',2.2)
end
% set y axis to be exponential (for log)
yl = get(sh,'YLim');
yl = floor(yl(1)):ceil(yl(2));
set(sh,'YTick',yl);
yl = cellstr(num2str(round(yl(:)), '10e%d'));
set(sh,'YtickLabel',yl)

%% Plot numbers of increasers and decreasers per quartile
sh = subplot(1,3,3);
hold on
xlim([0 12])
for a = 1:4 %for each quartile
    s1 = series1(quartileidxs==a);
    s2 = series2(quartileidxs==a);
    
    increasers = sum((s2-s1)>0);
    decreasers = sum((s2-s1)<0);
    sp = 3*((5-a)-1);
    bar([sp+1 sp+2],[increasers -decreasers],'FaceColor',QuadColors(a,:))
end
ylabel('Increasers vs Decreasers')
xlabel('Quartile')

% set(sh,'YScale','log')

% subplot(1,2,2);
% temp = semilogy([series1 series2]','Marker','o','Visible','off');
% hold on;
% for a = 1:4 %for each quartile
%     s1 = series1(quartileidxs==a);
%     s2 = series2(quartileidxs==a);
%     semilogy([s1 s2]','Marker','o','color',QuadColors(a,:));
%     errorbar([0.9-a*.05 2.4-a*.05],[mean(s1) mean(s2)],[std(s1) std(s2)],...
%     'Color',QuadColors(a,:),'Marker','.','LineStyle','none')
%     for b = 1:length(s1)
%         ph = patchline([1 2],[s1(b) s2(b)],'edgecolor',QuadColors(a,:),'edgealpha',0.25);
%     end
%     errorbar([0.9-a*.05 2.4-a*.05],[mean(s1) mean(s2)],[std(s1) std(s2)],...
%     'Color',QuadColors(a,:),'Marker','.','LineStyle','none')
%     line([0.9-a*.05 2.4-a*.05],[mean(s1) mean(s2)],'Color',QuadColors(a,:))
% 
% end
% delete(temp)
% xlim([0.5 2.5])
