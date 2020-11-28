function [h,r,p,coeffs,prepostpercentchg,postvpreproportion] = PlotPrePostVsOther(pre,post,other)
% Pre and Post are vectors of the same length, presumably referring
% element-wise to the same data generators.  Other is of same length as
% well and represents a third aspect of these elements.  (Ie pre is
% pre-sleep spike rate, post is post-sleep spike rate and other is
% burstiness).  This allows one to plot pre-post changes and how those
% correspond to "other".
% h is a handle of all figures generated
% r,p and coeffs are each cell array of 4 values relating to x vs y 
% correlations for linear vs linear, log vs linear, linear vs log and
% log vs log versions of x and y
% Brendon Watson 2015

%% Basic initial calculations and setup
pre = pre(:);
post = post(:);

% percent changes... look at linear changes on this
prepostpercentchg = ConditionedPercentChange(pre,post);

% proportions of original - use geometric stats here
postvpreproportion = ConditionedProportion(pre,post);

h = [];
n1 = inputname(1);
n2 = inputname(2);
n3 = inputname(3);
VsString = [n2 'Ov' n1 'Vs' n3];

%% Naming "other" if possible
eval([n3 ' = other;'])

%% plot other vs change
h(end+1)=figure('name',[VsString],'position',[2 2 600 800]);
subplot(3,1,1:2)
eval(['[r,p,~,coeffs] = PlotAndRegressLinear(' n3 ',postvpreproportion);'])
title(VsString)

%% Plot Relative increases or decreases in top/bottom portions of the of the range of "other" vector
eval(['q_rnk = GetQuartilesByRank(' n3 ');'])
RnkIDPlotVect=[];
lbls = {};
for a = 1:4
    q_rnk_increasers{a} = find(postvpreproportion(q_rnk==a)>1);
    q_rnk_decreasers{a} = find(postvpreproportion(q_rnk==a)<1);
    q_rnk_NC{a} = find(postvpreproportion(q_rnk==a)==1);
    RnkIDPlotVect=cat(2,RnkIDPlotVect,[length(q_rnk_increasers{a}) length(q_rnk_NC{a}) length(q_rnk_decreasers{a}) 0 0 ]);
    
    lbls = cat(1,lbls,{'Inc'},{'NC'},{'Dec'},{'__'},{''});
end

subplot(3,1,3)
    bar(RnkIDPlotVect);
    set(gca,'XTick',[0:length(lbls)-1],'XTickLabel',lbls,'Xlim',[0 length(lbls)+1]);
    xticklabel_rotate
    ylabel(gca,'# Increasers or Decreaers')
    xlabel(gca,'Quartile (by RANK)')
% subplot(3,2,6)
%     v1 = log10(postvpreproportion(q_rnk==1));
%     v2 = log10(postvpreproportion(q_rnk==2));
%     v3 = log10(postvpreproportion(q_rnk==3));
%     v4 = log10(postvpreproportion(q_rnk==4));
%     vect = cat(1,v1,v2,v3,v4);
%     groups = cat(1,ones(length(v1),1),2*ones(length(v2),1),3*ones(length(v3),1),4*ones(length(v4),1));
%     plot([0.5 4.5],[0 0],'k')
%     hold on
%     boxplot(vect,groups,'whisker',0,'boxstyle','filled');
%     delete(findobj('tag','Outliers'))
%     axis tight;  
%     yl = ylim;
%     ylim([yl(1)-0.1*yl(2) yl(2)+0.1*yl(2)]);
%     hax = gca;
%     ylabel(gca,'Post/Pre (proportion)')
%     xlabel(gca,'Quartile (by RANK)')




% %% Plot Relative increases or decreases in top/bottom portions of the of the range of "other" vector
% eval(['q_rng = GetQuartilesByLogRange(' n3 ');'])
% eval(['q_rnk = GetQuartilesByRank(' n3 ');'])
% RngIDPlotVect=[];
% RnkIDPlotVect=[];
% lbls = {};
% for a = 1:4
%     q_rng_increasers{a} = find(postvpreproportion(q_rng==a)>1);
%     q_rng_decreasers{a} = find(postvpreproportion(q_rng==a)<1);
%     q_rng_NC{a} = find(postvpreproportion(q_rng==a)==1);
%     RngIDPlotVect=cat(2,RngIDPlotVect,[length(q_rng_decreasers{a}) length(q_rng_NC{a}) length(q_rng_increasers{a}) 0 0 ]);
% 
%     q_rnk_increasers{a} = find(postvpreproportion(q_rnk==a)>1);
%     q_rnk_decreasers{a} = find(postvpreproportion(q_rnk==a)<1);
%     q_rnk_NC{a} = find(postvpreproportion(q_rnk==a)==1);
%     RnkIDPlotVect=cat(2,RnkIDPlotVect,[length(q_rnk_decreasers{a}) length(q_rnk_NC{a}) length(q_rnk_increasers{a}) 0 0 ]);
%     
%     lbls = cat(1,lbls,{'Dec'},{'NC'},{'Inc'},{'__'},{''});
% end
% 
% h(end+1) = figure('name',[VsString '_PctChgsVsInitialQuartiles'],'Position',[0 2 560 950]);
% subplot(2,2,1)
%     hax = plot_nanmedianSD_bars(log10(postvpreproportion(q_rng==1)),log10(postvpreproportion(q_rng==2)),log10(postvpreproportion(q_rng==3)),log10(postvpreproportion(q_rng==4)));
%     ylabel(hax,'Post/Pre (proportion)')
%     xlabel(hax,'Quartile (by RANGE)')
% %     title(hax,'Median Post v Pre proportion per RANGE quartile')
% subplot(2,2,2)
% %     hax = plot_nanmedianSD_bars(log10(postvpreproportion(q_rnk==1)),log10(postvpreproportion(q_rnk==2)),log10(postvpreproportion(q_rnk==3)),log10(postvpreproportion(q_rnk==4)));
% %     hax = plot_nanmedianSD_bars(log10(postvpreproportion(q_rnk==1)),log10(postvpreproportion(q_rnk==2)),log10(postvpreproportion(q_rnk==3)),log10(postvpreproportion(q_rnk==4)));
%     v1 = log10(postvpreproportion(q_rnk==1));
%     v2 = log10(postvpreproportion(q_rnk==2));
%     v3 = log10(postvpreproportion(q_rnk==3));
%     v4 = log10(postvpreproportion(q_rnk==4));
%     vect = cat(1,v1,v2,v3,v4);
%     groups = cat(1,ones(length(v1),1),2*ones(length(v2),1),3*ones(length(v3),1),4*ones(length(v4),1));
%     plot([0.5 4.5],[0 0],'k')
%     hold on
%     boxplot(vect,groups,'whisker',0,'boxstyle','filled');
%     delete(findobj('tag','Outliers'))
%     axis tight;  
%     yl = ylim;
%     ylim([yl(1)-0.1*yl(2) yl(2)+0.1*yl(2)])
%     hax = gca;
%     ylabel(hax,'Post/Pre (proportion)')
%     xlabel(hax,'Quartile (by RANK)')
% %     title(hax,'Median Post v Pre proportion per RANK quartile')
% subplot(2,2,3)
%     bar(RngIDPlotVect);
%     set(gca,'XTick',[0:length(lbls)-1],'XTickLabel',lbls,'Xlim',[0 length(lbls)+1]);
%     xticklabel_rotate
%     ylabel(gca,'# Increasers or Decreaers')
%     xlabel(gca,'Quartile (by RANGE)')
% subplot(2,2,4)
%     bar(RnkIDPlotVect);
%     set(gca,'XTick',[0:length(lbls)-1],'XTickLabel',lbls,'Xlim',[0 length(lbls)+1]);
%     xticklabel_rotate
%     ylabel(gca,'# Increasers or Decreaers')
%     xlabel(gca,'Quartile (by RANK)')
% 
% %% plot other vs change
% h(end+1)=figure('name',[VsString]);
% eval(['[r,p,~,coeffs] = PlotAndRegressLinearAndLog(' n3 ',postvpreproportion);'])
% AboveTitle(VsString)
% 
%     