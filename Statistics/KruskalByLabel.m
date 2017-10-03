function [p,PairwiseCIs,h] = KruskalByLabel(Vector,NumElementsPerLabel,Labels)
% Runs a Kruskal-Wallis test (non-parametric ANOVA) on a vector of values
% to see if there are groupwise differences between the groups defined by
% Labels.  Plots figures including overview table, boxplot and an
% interactive comparison figure.  
%
% INPUTS
% Vector - series of values to compare.  Should be in chunks of values
%   coming from a "Label" at a time: Values from group described in the
%   first value of "Label" are 1:n, next group of values is n+1:m, etc.  
% NumElementsPerLabel - vector describing how to breakdown "Vector" by 
%   group. Has same length as number of groups to compare, the values in 
%   this vector represent the number of elements in each group in sequence 
%   of their appearance in vector. Total sum of elements in this input
%   should equal the length of "Vector"
% Labels - charactercell with labels for each group in the dataset /
%   described by NumElementsPerLabel
% 
% OUTPUTS
% p - p value of hypothesis that there is a significant difference between
%   groups by KruskalWallis test
% PairWiseCIs - n-pairwise-comparisons x 6 matrix summarizing results.  
%   column 1: integer of first of groups compared
%   column 2: integer of second of groups compared
%   column 3: bottom of CI rank difference between this pair
%   column 4: mean of diff between values in this pair
%   column 5: top of CI rank difference between this pair
%   column 6: p value of difference
%
% Brendon Watson 2015, based on matlab Statistics Toolbox


% h - handles for figures generated, 3 figures.
if exist('Labels','var')
    [ulabels,~,labelidx]=unique(Labels);
else
    labelidx = 1:length(NumElementsPerLabel);
    for a = 1:length(NumElementsPerLabel)
        ulabels{a} = num2str(labelidx(a));
    end
end
    
labelvector = [];
wordlabelvector = {};
for a = 1:length(NumElementsPerLabel)
    labelvector = cat(1,labelvector,labelidx(a)*ones(NumElementsPerLabel(a),1));
    wordlabelvector = cat(1,wordlabelvector,repmat(ulabels(labelidx(a)),[NumElementsPerLabel(a),1]));
end

% for a = 1:length(ulabels);
%    groupeddata{a} =  Vector(labelvector==a);
% end

h = [];

[p,~,stats] = kruskalwallis(Vector,wordlabelvector);
th = findobj('type','figure');
h(end+1:end+2) = th([2,1]');%grab and save the two most recently made ones (always listed first)
try
    tf = findobj('type','figure','tag','boxplot');
    set(tf,'name','KruskalWallisBoxPlot')
    [t1,t2] = ismember(tf,h);
    axes(findobj('type','axes','parent',tf(find(t1))))
    title('Box plot: Medians red. Diag notches show CIs for medians. Box ends show 25/75%iles','fontweight','normal','fontsize',9)
end

h(end+1) = figure;
[PairwiseCIs] = multcompare(stats);
title({'Click on the group you want to test.';'Displayed are Mean Rank per group and CIs of Mean Ranks'})
