function SpikingAnalysis_PlotAgainstAndRegressLinearAndLog(x,y)

subplot(2,1,1);
% x = pre2I;
% %     x = NoInf_PrewakeESpikeRates;
% y = ISpikingRatioPrePost2;
plot(x,y,'marker','.','Line','none');
[yfit,r2,p] =  RegressAndFindR2(x,y,1);
hold on;
plot(x,yfit,'r')
text(0.8*max(x),0.8*max(y),{['r2=',num2str(r2)];['p=',num2str(p)]})
% title('ICells Percent change in spike rate in first vs last third SWS VS initial spike rate')
% %     xlabel('Cell initial spike rate')
% ylabel('Proportion change in spike rate')
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
% xlabel('Cell initial spike rate')
% % ylabel('Proportion change in spike rate')
% set(gca,'XTickLabel',10.^get(gca,'XTick'))
% set(gca,'YTickLabel',10.^get(gca,'YTick'))
% set(gca,'YTickLabel',10.^get(gca,'YTick'))
% set(h(end),'name',[basename,'_ChangeVsInitialRate-Icells'])