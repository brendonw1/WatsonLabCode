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


%% Plot pre vs post spikes
h = [];
[th,rE,pE,coeffsE,prepostpercentchgE,postvpreproportionE] = PlotPrePost_Spiking(CoVE_pre,CoVE_post,1);
h = cat(1,h(:),th(:));

[th,rI,pI,coeffsI,prepostpercentchgI,postvpreproportionI] = PlotPrePost_Spiking(ISpikesEarly,ISpikesLate,20);
h = cat(1,h(:),th(:));

PrePostCorrelations = v2struct(rE,pE,coeffsE,prepostpercentchgE,postvpreproportionE,...
    rI,pI,coeffsI,prepostpercentchgI,postvpreproportionI);

%% Save Figs
supradir = fullfile('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/SpikeChanges',ep1);
MakeDirSaveFigsThereAs(supradir,h,'fig')
MakeDirSaveFigsThereAs(supradir,h,'png')