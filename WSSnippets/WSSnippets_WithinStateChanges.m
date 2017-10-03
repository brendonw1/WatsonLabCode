function WSSnippets_WithinStateChanges
supradir = fullfile('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/SpikeChanges/WithinStates',ep1);


ep1 = 'wake13thirds';
ep2 = [];
WSSnippets_SpikeRates_all(ep1);
SpikeWSSnippets = WSSnippets_GatherAllSpikeMedians(ep1,ep2);
WakeFirstThird = SpikeWSSnippets.medianRatePreSpikesE;
WakeLastThird = SpikeWSSnippets.medianRatePostSpikesE;
h = PlotPrePost(WakeFirstThird,WakeLastThird);
MakeDirSaveFigsThereAs(supradir,h,'fig')
MakeDirSaveFigsThereAs(supradir,h,'png')

ep1 = 'rem13thirds';
ep2 = [];
WSSnippets_SpikeRates_all(ep1);
SpikeWSSnippets = WSSnippets_GatherAllSpikeMedians(ep1,ep2);
RemFirstThird = SpikeWSSnippets.medianRatePreSpikesE;
RemLastThird = SpikeWSSnippets.medianRatePostSpikesE;
h = PlotPrePost(RemFirstThird,RemLastThird);
MakeDirSaveFigsThereAs(supradir,h,'fig')
MakeDirSaveFigsThereAs(supradir,h,'png')

ep1 = 'sws13thirds';
ep2 = [];
WSSnippets_SpikeRates_all(ep1);
SpikeWSSnippets = WSSnippets_GatherAllSpikeMedians(ep1,ep2);
SwsFirstThird = SpikeWSSnippets.medianRatePreSpikesE;
SwsLastThird = SpikeWSSnippets.medianRatePostSpikesE;
h = PlotPrePost(SwsFirstThird,SwsLastThird);
MakeDirSaveFigsThereAs(supradir,h,'fig')
MakeDirSaveFigsThereAs(supradir,h,'png')

ep1 = 'ma13thirds';
ep2 = [];
WSSnippets_SpikeRates_all(ep1);
SpikeWSSnippets = WSSnippets_GatherAllSpikeMedians(ep1,ep2);
MaFirstThird = SpikeWSSnippets.medianRatePreSpikesE;
MaLastThird = SpikeWSSnippets.medianRatePostSpikesE;
h = PlotPrePost(MaFirstThird,MaLastThird);
MakeDirSaveFigsThereAs(supradir,h,'fig')
MakeDirSaveFigsThereAs(supradir,h,'png')

% 
