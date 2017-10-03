function [h,r,p,coeffs,prepostpercentchg,postvpreprop] = PlotPrePostVsOther(pre,post,other)
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
numdivisions = 6;%for quartile-style analysis

pre = pre(:);
post = post(:);

% percent changes... look at linear changes on this
% prepostpercentchg = ConditionedPercentChange(pre,post);

% proportions of original - use geometric stats here
postvprepropCondit = ConditionedProportion(pre,post);
[postvprepropMin,bad] = MinimizedProportion(pre,post);
premin = pre(~bad);
postmin = post(~bad);
othermin = other(~bad);

h = [];
n1 = inputname(1);
n2 = inputname(2);
n3 = inputname(3);
VsString = [n2 'Ov' n1 'Vs' n3];

%% Naming "other" if possible
eval([n3 ' = other;'])
eval([n3 'min = othermin;'])

%% plotting conditioned data
% plot other vs change
h(end+1)=figure('name',[VsString],'position',[2 2 1000 800]);
subplot(3,4,[1,2,5,6])
eval(['[r,p,~,coeffs] = PlotAndRegressLog(' n3 ',postvprepropCondit);'])
title(VsString)

% Plot Relative increases or decreases in top/bottom portions of the of the range of "other" vector
eval(['q_rnk = GetQuartilesByRank(' n3 ');'])
RnkIDPlotVect=[];
lbls = {};

subplot(3,4,9)
    eval(['plot_IncDecAbyQuartilesofB(postvprepropCondit,' n3 ');'])
subplot(3,4,10)
    eval(['plot_boxAbyquartilesofB(postvprepropCondit,' n3 ');'])

%% plotting only-good data
% plot other vs change
subplot(3,4,[3,4,7,8])
eval(['[r,p,~,coeffs] = PlotAndRegressLog(' n3 'min,postvprepropMin);'])
title(VsString)

% Plot Relative increases or decreases in top/bottom portions of the of the range of "other" vector
eval(['q_rnk = GetQuartilesByRank(' n3 'min);'])
RnkIDPlotVect=[];
lbls = {};

subplot(3,4,11)
    eval(['plot_IncDecAbyQuartilesofB(postvprepropMin,' n3 'min);'])
subplot(3,4,12)
    eval(['plot_boxAbyquartilesofB(postvprepropMin,' n3 'min);'])

%% Plot Relative increases or decreases in top/bottom portions
h(end+1) = figure('name',[VsString '_PctChgsbyQuartiles'],'Position',[0 2 400 800]);
PlotDivisionwiseChanges(log10(postvprepropCondit),numdivisions,other);

%% Plot Quartile-wise element-by-element changes
% sort cell rates by other
[~,idx] = sort(other);
pres = pre(idx);
posts = post(idx);
% set up colors based on sextiles of other (setiles when numdiv = 6)
numdiv = 6;
tcol = RainbowColors(numdiv);
q_rnk = GetQuartilesByRank(other,numdiv);
col = [];
for a = 1:6;
    t = repmat(tcol(a,:),[sum(q_rnk==a),1]);
    col = cat(1,col,t);
end
pres(q_rnk<6 & q_rnk>1) = [];%blank out all sextiles but top and bottom
posts(q_rnk<6 & q_rnk>1) = [];
col(sum(q_rnk==1)+1 : end-(sum(q_rnk==6)),:) = [];

h(end+1) = SpikingAnalysis_PairsPlotsWMedianLinearAndLog(pres',posts','externalsort',col);
    subplot(1,2,2)
    title('Log scale','fontweight','normal')
AboveTitle(VsString)
set(h(end),'name',[VsString '_WithinCell'],'Position',[0 2 400 800])

