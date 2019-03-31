function [h,r,p,coeffs,prepostpercentchg,postvpreproportion] = PlotPrePost(pre,post,smoothwidth)
% Pre and Post are vectors of the same length, presumably referring
% element-wise to the same data generators.  Smoothwidth determines
% smoothing of histograms... if no input defaults to no smoothing.
% h is a handle of all figures generated
% r,p and coeffs are each cell array of 4 values relating to x vs y 
% correlations for linear vs linear, log vs linear, linear vs log and
% log vs log versions of x and y

%% Basic initial calculations and setup
numdivisions = 6;%for quartile-style analysis

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
    subplot(1,2,2)
    title('Log scale','fontweight','normal')
AboveTitle(VsString)
set(h(end),'name',[VsString '_WithinCell'],'Position',[0 2 400 800])

%% histograms of Per-Cell percent changes and increasers vs decreasers (not currently affected by smoothwidth)
if ~isempty(prepostpercentchg)
    h(end+1)=figure('name',[VsString '_HistoPctChgs'],'Position',[0 2 760 600]);
    PlotWithinUnitChanges(pre,post)
    AboveTitle([VsString '_WithinCellChanges'])
end


%% Plot Relative increases or decreases in top/bottom portions
h(end+1) = figure('name',[VsString '_PctChgsVsInitialQuartiles'],'Position',[0 2 400 800]);
PlotDivisionwiseChanges(log10(postvpreproportion),numdivisions,pre);

%% plot initial vs change
% h(end+1)=figure('name',[VsString '_PctChgsVsInitial'],'Position',[0 2 560 950]);
NString = [n2 'Ov' n1 'Vs' n1];
h(end+1)=figure('name',[NString]);
[r,p,~,coeffs] = PlotAndRegressLinearAndLog(pre,postvpreproportion);
AboveTitle(NString)

% Use GetQuartiles