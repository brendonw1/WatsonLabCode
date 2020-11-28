function WSSnippets_PlotAllSpikeSynAssMeans(ep1)

if ~exist('ep1','var')
    ep1 = '13sws';
end

SpikeSynAssSnippets = Snippets_GatherAllSpikeSynAssMeans(ep1);

h = [];

%% Plot pre vs post spikes
ESpikesPre = SpikeSynAssSnippets.ratePreSpikesE;
ESpikesPost = SpikeSynAssSnippets.ratePostSpikesE;
[th,r,p,coeffs] = PlotPrePost(ESpikesPre,ESpikesPost);
h = cat(1,h,th);

ISpikesPre = SpikeSynAssSnippets.ratePreSpikesI;
ISpikesPost = SpikeSynAssSnippets.ratePostSpikesI;
[th,r,p,coeffs] = PlotPrePost(ISpikesPre,ISpikesPost);
h = cat(1,h,th);

%% Plot pre vs post syn correlations
ESynRatioPre = SpikeSynAssSnippets.meanPreSynapseRatiosE;
ESynRatioPost = SpikeSynAssSnippets.meanPostSynapseRatiosE;
[th,r,p,coeffs] = PlotPrePost(ESynRatioPre,ESynRatioPost);
h = cat(1,h,th);

ESynDiffPre = SpikeSynAssSnippets.meanPreSynapseDiffsE;
ESynDiffPost = SpikeSynAssSnippets.meanPostSynapseDiffsE;
[th,r,p,coeffs] = PlotPrePost(ESynDiffPre,ESynDiffPost);
h = cat(1,h,th);

ISynRatioPre = SpikeSynAssSnippets.meanPreSynapseRatiosI;
ISynRatioPost = SpikeSynAssSnippets.meanPostSynapseRatiosI;
[th,r,p,coeffs] = PlotPrePost(ISynRatioPre,ISynRatioPost);
h = cat(1,h,th);

ISynDiffPre = SpikeSynAssSnippets.meanPreSynapseDiffsI;
ISynDiffPost = SpikeSynAssSnippets.meanPostSynapseDiffsI;
[th,r,p,coeffs] = PlotPrePost(ISynDiffPre,ISynDiffPost);
h = cat(1,h,th);

%% Plot pre vs post Wake-Based Assemblies (100ms, PCA based)
WakeBAssPre = SpikeSynAssSnippets.meanPreWakeBAss;
WakeBAssPost = SpikeSynAssSnippets.meanPostWakeBAss;
[th,r,p,coeffs] = PlotPrePost(WakeBAssPre,WakeBAssPost);
h = cat(1,h,th);
% 
% 
% re-run basic snippets (fix)
% ... ADD per sleep MOTION TO GATHER
% PlotPrePost: fix bars
%             add log plot of correlation thing