function WSSnippets_PlotPrePostSpikePopCoeffVar(ep1)
% Brendon Watson 2015

%% Load pre-post rates for each cell
if ~exist('ep1','var')
    ep1 = 'FLSWS';
end
ep2 = [];
PopCoeffVarSnippets = WSSnippets_GatherPopCoeffVar(ep1,ep2);

%% Declare some variables for later use...names used for labeling by PlotPrePost
CoVE_pre = PopCoeffVarSnippets.CoVE_pre;
CoVlE_pre = PopCoeffVarSnippets.CoVlE_pre;
CoVI_pre = PopCoeffVarSnippets.CoVI_pre;
CoVlI_pre = PopCoeffVarSnippets.CoVlI_pre;

CoVE_post = PopCoeffVarSnippets.CoVE_post;
CoVlE_post = PopCoeffVarSnippets.CoVlE_post;
CoVI_post = PopCoeffVarSnippets.CoVI_post;
CoVlI_post = PopCoeffVarSnippets.CoVlI_post;

SDE_pre = PopCoeffVarSnippets.SDE_pre;
SDlE_pre = PopCoeffVarSnippets.SDlE_pre;
SDI_pre = PopCoeffVarSnippets.SDI_pre;
SDlI_pre = PopCoeffVarSnippets.SDlI_pre;

SDE_post = PopCoeffVarSnippets.SDE_post;
SDlE_post = PopCoeffVarSnippets.SDlE_post;
SDI_post = PopCoeffVarSnippets.SDI_post;
SDlI_post = PopCoeffVarSnippets.SDlI_post;

%% Plot pre vs post population spike rate CoVs
h = [];
%E linear SD and CoV
VsString = ['SDE_preVSSDE_post'];
h(end+1) = PrePostBars(SDE_pre,SDE_post,VsString);
h(end+1) = figure('name',[VsString '_HistoPctChgs'],'Position',[0 2 760 600]);
    PlotWithinUnitChanges(SDE_pre,SDE_post)
    AboveTitle([VsString '_WithinCellChanges'])

VsString = ['CoVE_preVSCoVE_post'];
h(end+1) = PrePostBars(CoVE_pre,CoVE_post,VsString);
h(end+1) = figure('name',[VsString '_HistoPctChgs'],'Position',[0 2 760 600]);
    PlotWithinUnitChanges(CoVE_pre,CoVE_post)
    AboveTitle([VsString '_WithinCellChanges'])

%E log SD and CoV
VsString = ['SDlE_preVSSDlE_post'];
h(end+1) = PrePostBars(SDlE_pre,SDlE_post,VsString);
h(end+1) = figure('name',[VsString '_HistoPctChgs'],'Position',[0 2 760 600]);
    PlotWithinUnitChanges(SDlE_pre,SDlE_post)
    AboveTitle([VsString '_WithinCellChanges'])

VsString = ['CoVlE_preVSCoVlE_post'];
h(end+1) = PrePostBars(CoVlE_pre,CoVlE_post,VsString);
h(end+1) = figure('name',[VsString '_HistoPctChgs'],'Position',[0 2 760 600]);
    PlotWithinUnitChanges(CoVlE_pre,CoVlE_post)
    AboveTitle([VsString '_WithinCellChanges'])
    
1;


supradir = fullfile('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/SpikePopVarianceChanges',ep1);
MakeDirSaveFigsThereAs(supradir,h,'fig')
MakeDirSaveFigsThereAs(supradir,h,'png')

