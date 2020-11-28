function WSSnippets_WakeSlopeVsSleepSlope
% Brendon Watson 2015

%% Load pre-post rates for each cell - median across sleep sessions
SpikeWSSnippets_SleepFLSWS_M = WSSnippets_GatherAllSpikeMedians('FLSWS',[]);
SpikeWSSnippets_WakeFL5_M = WSSnippets_GatherAllSpikeMedians('fl5wswake',[]);
SpikeWSSnippets_WakeWhole_M = WSSnippets_GatherAllSpikeMedians('wswake',[]);

WmeanEM = SpikeWSSnippets_WakeWhole_M.medianRatePreSpikesE;
WmeanIM = SpikeWSSnippets_WakeWhole_M.medianRatePreSpikesI;

SpreEM = SpikeWSSnippets_SleepFLSWS_M.medianRatePreSpikesE;
SpostEM = SpikeWSSnippets_SleepFLSWS_M.medianRatePostSpikesE;
SpreIM = SpikeWSSnippets_SleepFLSWS_M.medianRatePreSpikesI;
SpostIM = SpikeWSSnippets_SleepFLSWS_M.medianRatePostSpikesI;

WpreEM = SpikeWSSnippets_WakeFL5_M.medianRatePreSpikesE;
WpostEM = SpikeWSSnippets_WakeFL5_M.medianRatePostSpikesE;
WpreIM = SpikeWSSnippets_WakeFL5_M.medianRatePreSpikesI;
WpostIM = SpikeWSSnippets_WakeFL5_M.medianRatePostSpikesI;

WChgEM = ConditionedProportion(WpreEM,WpostEM);
SChgEM = ConditionedProportion(SpreEM,SpostEM);

figure;
ScatterWStats(WChgEM,SChgEM,'loglog')

figure;
ScatterWStats(WmeanEM,SChgEM,'loglog')

%% Load pre-post rates for each cell - median across sleep sessions
SpikeWSSnippets_SleepFLSWS_S = WSSnippets_GatherAllSpikeSingleEps('FLSWS',[]);
SpikeWSSnippets_WakeFL5_S = WSSnippets_GatherAllSpikeSingleEps('fl5wswake',[]);
SpikeWSSnippets_WakeWhole_S = WSSnippets_GatherAllSpikeSingleEps('wswake',[]);

WmeanES = SpikeWSSnippets_WakeWhole_S.RatePreSpikesE;
WmeanIS = SpikeWSSnippets_WakeWhole_S.RatePreSpikesI;

SpreES = SpikeWSSnippets_SleepFLSWS_S.RatePreSpikesE;
SpostES = SpikeWSSnippets_SleepFLSWS_S.RatePostSpikesE;
SpreIS = SpikeWSSnippets_SleepFLSWS_S.RatePreSpikesI;
SpostIS = SpikeWSSnippets_SleepFLSWS_S.RatePostSpikesI;

WpreES = SpikeWSSnippets_WakeFL5_S.RatePreSpikesE;
WpostES = SpikeWSSnippets_WakeFL5_S.RatePostSpikesE;
WpreIS = SpikeWSSnippets_WakeFL5_S.RatePreSpikesI;
WpostIS = SpikeWSSnippets_WakeFL5_S.RatePostSpikesI;

WChgES = ConditionedProportion(WpreES,WpostES);
SChgES = ConditionedProportion(SpreES,SpostES);

figure;
ScatterWStats(WChgES,SChgES,'loglog')

figure;
ScatterWStats(WmeanES,SChgES,'loglog')


1;
