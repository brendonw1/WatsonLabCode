function h=SpikingAnalysis_PairsPlotsWMeanLinearAndLog(series1,series2)

series1 = series1(:);
series2 = series2(:);

h = figure;
subplot(1,2,1);
plot([series1 series2]','Marker','o');
xlim([0.5 2.5])
hold on
errorbar([0.75 2.25],[mean(series1) mean(series2)],[std(series1) std(series2)],...
    'Color','k','Marker','.','LineStyle','none')

% title({'Individual RS Cell firing rates in First (Left) vs Last (Right) SWS episodes';...
%     'Mean in black, Errors bars offset to allow visualization'})

subplot(1,2,2);
series1(series1==0) = min(series1);
series2(series2==0) = min(series2);
% 
% s1 = log(series1);
% s2 = log(series2);


% hh = ploterr([0.75 2.25], [mean(realnoninfonly(log(series1))) mean(realnoninfonly(log(series2)))],...
%     [], [std(realnoninfonly(log(series1))) std(realnoninfonly(log(series2)))], ...
%     'logy')
% series1 = series1;
if sum(series1>0) > 1
    series1(series1==0) = min(series1(series1>0));
end
% series2 = series2;
if sum(series2>0) > 1
    series2(series2==0) = min(series2(series2>0));
end
x = [0.75 2.25];
[~,bady1] = realnoninfposonly(series1);
[~,bady2] = realnoninfposonly(series2);
allbad = logical(bady1+bady2);
globalmin = min([series1(~allbad);series2(~allbad)]);
try 
    series1(allbad) = globalmin;
    series2(allbad) = globalmin;
    plot([series1 series2]','Marker','o');
    xlim([0.5 2.5])
    hold on
    y = [geomean(series1) geomean(series2)];
    er = [geostd(series1) geostd(series2)];
    warning off
        errorbar(x,y,er,'Color','k','Marker','.','LineStyle','none')
    warning on
    plot([x(1) x(1)],[y(1) y(1)+er(1)],'k')
    plot([x(2) x(2)],[y(2) y(2)+er(2)],'k')
end


% semilogy([series1 series2]','Marker','o');
set(gca,'YScale','Log')
