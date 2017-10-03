function PlotIESleepSpikeRateChangesSameAxis(ep1)
if ~exist('ep1','var')
    ep1 = 'FLSWS';
end
ep2 = [];

SpikeWSSnippets = WSSnippets_GatherAllSpikeMedians(ep1,ep2);

SR = SpikingAnalysis_GatherAllStateRates;

%% Declare some variables for later use
ESpikesPre = SpikeWSSnippets.medianRatePreSpikesE;
ESpikesPost = SpikeWSSnippets.medianRatePostSpikesE;
ISpikesPre = SpikeWSSnippets.medianRatePreSpikesI;
ISpikesPost = SpikeWSSnippets.medianRatePostSpikesI;

postvpreproportionE = ConditionedProportion(ESpikesPre,ESpikesPost);
postvpreproportionI = ConditionedProportion(ISpikesPre,ISpikesPost);

badpostI = find(ISpikesPost==0);
badpostISess = SR.SessNumPerICell(badpostI);
badpostISessCell = SR.SessCellNumPerICell(badpostI);

badpostE = find(ESpikesPost==0);
badpostESess = SR.SessNumPerECell(badpostE);
badpostESessCell = SR.SessCellNumPerECell(badpostE);

%% Plot change vs pre
%make fcn for...
h = PlotEIChangeVsOtherSameAxis(ESpikesPre,postvpreproportionE,ISpikesPre,postvpreproportionI);

%% Plot post vs pre
h = PlotEIPrePostSameAxis(ESpikesPre,ESpikesPost,ISpikesPre,ISpikesPost);

%% Plot change vs pre
% %make fcn for...
% badE = postvpreproportionE==min(postvpreproportionE);
% ESpikesPre(badE) = [];
% postvpreproportionE(badE) = [];
% badI = postvpreproportionI==min(postvpreproportionI);
% ISpikesPre(badI) = [];
% postvpreproportionI(badI) = [];
% 
% h(end+1) = PlotEIChangeVsOtherSameAxis(ESpikesPre,postvpreproportionE,ISpikesPre,postvpreproportionI);


MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/SpikeChanges/FLSWS_EITogether',h,'fig')
