function WSSnippets_PlotAllSpikeRateChangesVWakeRate(ep1,ep2)
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

%% Plot pre vs post changes vs Wake Rate
% Get wake rates... ?

ESpikesPre = SpikeSynAssWSSnippets.ratePreSpikesE;
ESpikesPost = SpikeSynAssWSSnippets.ratePostSpikesE;
[th,r,p,coeffs] = PlotPrePost(ESpikesPre,ESpikesPost);
h = cat(1,h(:),th(:));

ISpikesPre = SpikeSynAssWSSnippets.ratePreSpikesI;
ISpikesPost = SpikeSynAssWSSnippets.ratePostSpikesI;
[th,r,p,coeffs] = PlotPrePost(ISpikesPre,ISpikesPost);
h = cat(1,h(:),th(:));

%save figs
MakeDirSaveFigsThereAs(['/mnt/brendon4/Dropbox/BW OUTPUT/Sleep/RateChangePrePost/' ep1],h,'fig')
MakeDirSaveFigsThereAs(['/mnt/brendon4/Dropbox/BW OUTPUT/Sleep/RateChangePrePost/' ep1],h,'png')


