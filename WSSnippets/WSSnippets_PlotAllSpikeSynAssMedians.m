function WSSnippets_PlotAllSpikeSynAssMedians(ep1,ep2)
% Available inputs to specify times around WS:
%         - '5mIn' - gather first 5min IN sleep vs last 5 IN sleep
%         - '5mOut' - gather last 5min wake BEFORE sleep vs first 5 min wake AFTER sleep
%         - 'FLSWS' - gather first vs last SWS episodes
%         - '13SWS' - gather SWS from vs vs last third of sleep
%         - 'WakeBA' - Look at wake before vs wake after
%
% Brendon Watson 2015


if ~exist('ep1','var')
    ep1 = '13sws';
end
if ~exist('ep2','var')
    ep2 = '[]';
end

SpikeSynAssWSSnippets = WSSnippets_GatherAllSpikeSynAssMedians(ep1,ep2);

h = [];

%% Plot pre vs post spikes
ESpikesPre = SpikeSynAssWSSnippets.ratePreSpikesE;
ESpikesPost = SpikeSynAssWSSnippets.ratePostSpikesE;
[th,r,p,coeffs] = PlotPrePost(ESpikesPre,ESpikesPost);
h = cat(1,h(:),th(:));

ISpikesPre = SpikeSynAssWSSnippets.ratePreSpikesI;
ISpikesPost = SpikeSynAssWSSnippets.ratePostSpikesI;
[th,r,p,coeffs] = PlotPrePost(ISpikesPre,ISpikesPost);
h = cat(1,h(:),th(:));

%% Plot pre vs post syn correlations
ESynRatioPre = SpikeSynAssWSSnippets.medianPreSynapseRatiosE;
ESynRatioPost = SpikeSynAssWSSnippets.medianPostSynapseRatiosE;
[th,r,p,coeffs] = PlotPrePost(ESynRatioPre,ESynRatioPost);
h = cat(1,h(:),th(:));

ESynDiffPre = SpikeSynAssWSSnippets.medianPreSynapseDiffsE;
ESynDiffPost = SpikeSynAssWSSnippets.medianPostSynapseDiffsE;
[th,r,p,coeffs] = PlotPrePost(ESynDiffPre,ESynDiffPost);
h = cat(1,h(:),th(:));

ISynRatioPre = SpikeSynAssWSSnippets.medianPreSynapseRatiosI;
ISynRatioPost = SpikeSynAssWSSnippets.medianPostSynapseRatiosI;
[th,r,p,coeffs] = PlotPrePost(ISynRatioPre,ISynRatioPost);
h = cat(1,h(:),th(:));

ISynDiffPre = SpikeSynAssWSSnippets.medianPreSynapseDiffsI;
ISynDiffPost = SpikeSynAssWSSnippets.medianPostSynapseDiffsI;
[th,r,p,coeffs] = PlotPrePost(ISynDiffPre,ISynDiffPost);
h = cat(1,h(:),th(:));

%% Plot pre vs post Wake-Based Assemblies (100ms, PCA based)
WakeBIAssPre = SpikeSynAssWSSnippets.medianPreWakeBIAss;
WakeBIAssPost = SpikeSynAssWSSnippets.medianPostWakeBIAss;
[th,r,p,coeffs] = PlotPrePost(WakeBIAssPre,WakeBIAssPost);
h = cat(1,h(:),th(:));
% 
% 
% re-run basic snippets (fix)
% ... ADD per sleep MOTION TO GATHER
% PlotPrePost: fix bars
%             add log plot of correlation thing


MakeDirSaveFigsThereAs(['/mnt/brendon4/Dropbox/BW OUTPUT/Sleep/RateSynCorrAssDropChanges/' ep1],h,'fig')
MakeDirSaveFigsThereAs(['/mnt/brendon4/Dropbox/BW OUTPUT/Sleep/RateSynCorrAssDropChanges/' ep1],h,'png')
