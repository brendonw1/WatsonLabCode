function WSSnippets_PlotAllSynapseStrengthChanges(ep1)
% Brendon Watson 2015

%% Load pre-post rates for each cell
if ~exist('ep1','var')
    ep1 = 'FLSWS';
end
ep2 = [];
SynCorrWSSnippets = WSSnippets_GatherAllSynCorrMedians;
% SpikeWSSnippets_WakeB = WSSnippets_GatherAllSpikeMedians('WakeB',ep2);
% % SpikeWSSnippets_WakeAllB = WSSnippets_GatherAllSpikeMedians('WakeAllB',ep2);
% % SpikeWSSnippets_WakeAllA = WSSnippets_GatherAllSpikeMedians('WakeAllA',ep2);
% SpikeWSSnippets_WakeA = WSSnippets_GatherAllSpikeMedians('WakeA',ep2);
% SpikeWSSnippets_WSSleep = WSSnippets_GatherAllSpikeMedians('WSSleep',ep2);
% SpikeWSSnippets_WSSWS = WSSnippets_GatherAllSpikeMedians('WSSWS',ep2);
% SpikeWSSnippets_WSREM = WSSnippets_GatherAllSpikeMedians('WSREM',ep2);

%% Load StateRates for each cell
StateRates = SpikingAnalysis_GatherAllStateRates;

% %% Declare some variables for later use
ESynRatioEarly = SynCorrWSSnippets.medianPreSynCorrRatioE;
ESynRatioLate = SynCorrWSSnippets.medianPostSynCorrRatioE;
ISynRatioEarly = SynCorrWSSnippets.medianPreSynCorrRatioI;
ISynRatioLate = SynCorrWSSnippets.medianPostSynCorrRatioI;

ESynDiffEarly = SynCorrWSSnippets.medianPreSynCorrRateChgE;
ESynDiffLate = SynCorrWSSnippets.medianPostSynCorrRateChgE;
ISynDiffEarly = SynCorrWSSnippets.medianPreSynCorrRateChgI;
ISynDiffLate = SynCorrWSSnippets.medianPostSynCorrRateChgI;


% ESynRatioELMean = (ESynRatioEarly+ESynRatioLate)/2;
% ISynRatioELMean =  (ISynRatioEarly+ISynRatioLate)/2;
% 
% ESynRatioWakeB = SpikeWSSnippets_WakeB.medianRatePrESynRatioE;
% ISynRatioWakeB = SpikeWSSnippets_WakeB.medianRatePrESynRatioI;
% ESynRatioWakeA = SpikeWSSnippets_WakeA.medianRatePrESynRatioE;
% ISynRatioWakeA = SpikeWSSnippets_WakeA.medianRatePrESynRatioI;
% % ESynRatioWakeAllB = SpikeWSSnippets_WakeAllB.medianRatePrESynRatioE;
% % ISynRatioWakeAllB = SpikeWSSnippets_WakeAllB.medianRatePrESynRatioI;
% % ESynRatioWakeAllA = SpikeWSSnippets_WakeAllA.medianRatePrESynRatioE;
% % ISynRatioWakeAllA = SpikeWSSnippets_WakeAllA.medianRatePrESynRatioI;
% 
% ESynRatioWSSleep = SpikeWSSnippets_WSSleep.medianRatePrESynRatioE;
% ISynRatioWSSleep = SpikeWSSnippets_WSSleep.medianRatePrESynRatioI;
% ESynRatioWSSWS = SpikeWSSnippets_WSSWS.medianRatePrESynRatioE;
% ISynRatioWSSWS = SpikeWSSnippets_WSSWS.medianRatePrESynRatioI;
% ESynRatioWSREM = SpikeWSSnippets_WSREM.medianRatePrESynRatioE;
% ISynRatioWSREM = SpikeWSSnippets_WSREM.medianRatePrESynRatioI;
% 
% 
% EAll = StateRates.EAllRates;
% IAll = StateRates.IAllRates;
% EWake = StateRates.EWakeRates;
% IWake = StateRates.IWakeRates;
% ESWS = StateRates.ESWSRates;
% ISWS = StateRates.ISWSRates;
% EREM = StateRates.EREMRates;
% IREM = StateRates.IREMRates;
% % EMWake = StateRates.EMWakeRates;
% % IMWake = StateRates.IMWakeRates;
% % ENMWake = StateRates.ENMWakeRates;
% % INMWake = StateRates.INMWakeRates;
% % EMovMod = EMWake./ENMWake;
% % IMovMod = IMWake./INMWake;

h = [];
%% Pre vs post Bar plots
h(end+1) = PrePostBars(ESynRatioEarly,ESynRatioLate);
h(end+1) = PrePostBars(ISynRatioEarly,ISynRatioLate);
 
%% Plot pre vs post spikes
VsString = ['ERatioLate_vs_ERatioEarly'];
h(end+1) = figure('name',[VsString '_ScatterPlot'],'position',[2 2 400 400]);
% subplot(2,1,1)
% ScatterWStats(ESynRatioEarly,ESynRatioLate);
% title('linear')
% subplot(2,1,2)
ScatterWStats(ESynRatioEarly,ESynRatioLate,'loglog');
title('loglog')
pause(1)

[th,rE,pE,coeffsE] = PlotPrePostVsOther(ESynRatioEarly,ESynRatioLate,ESynRatioEarly);
h = cat(1,h(:),th(:));
%
pause(1)
VsString = ['IRatioLate_vs_IRatioEarly'];
h(end+1) = figure('name',[VsString '_ScatterPlot'],'position',[2 2 400 400]);
% subplot(2,1,1)
% ScatterWStats(ISynRatioEarly,ISynRatioLate);
% title('linear')
% subplot(2,1,2)
ScatterWStats(ISynRatioEarly,ISynRatioLate,'loglog');
title('loglog')

pause(1)
[th,rI,pI,coeffsI] = PlotPrePostVsOther(ISynRatioEarly,ISynRatioLate,ISynRatioEarly);
h = cat(1,h(:),th(:));

%% distribution comparisons
th = TwoDistributionsByHistLinearAndLog(ESynRatioEarly,ESynRatioLate);
h = cat(1,h(:),th(:));
th = TwoDistributionsByHistLinearAndLog(ISynRatioEarly,ISynRatioLate);
h = cat(1,h(:),th(:));

% Diffs
% VsString = ['EDiffLate_vs_EDiffEarly'];
% h(end+1) = figure('name',[VsString '_ScatterPlot'],'position',[2 2 400 800]);
% subplot(2,1,1)
% ScatterWStats(ESynDiffEarly,ESynDiffLate);
% subplot(2,1,2)
% ScatterWStats(ESynDiffEarly,ESynDiffLate,'loglog');
% 
% [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESynDiffEarly,ESynDiffLate,ESynDiffEarly);
% h = cat(1,h(:),th(:));
% %
% VsString = ['IDiffLate_vs_IDiffEarly'];
% h(end+1) = figure('name',[VsString '_ScatterPlot'],'position',[2 2 400 800]);
% subplot(2,1,1)
% ScatterWStats(ISynDiffEarly,ISynDiffLate);
% subplot(2,1,2)
% ScatterWStats(ISynDiffEarly,ISynDiffLate,'loglog');
% 
% [th,rI,pI,coeffsI] = PlotPrePostVsOtherLinear(ISynDiffEarly,ISynDiffLate,ISynDiffEarly);
% h = cat(1,h(:),th(:));

% Save
supradir = fullfile('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/SynCorrChanges',ep1);
MakeDirSaveVarThere(supradir,SynCorrWSSnippets);
MakeDirSaveFigsThereAs(supradir,h,'fig')
% MakeDirSaveFigsThereAs(supradir,h,'svg')
MakeDirSaveFigsThereAs(fullfile(supradir,'ImagesOnly'),h,'png')
SaveDirectoryImagesToSinglePDF(fullfile(supradir,'ImagesOnly'),[ep1 'SynCorrChanges'],'png')
cd(supradir);

% [th,rE,pE,coeffsE,prepostpercentchgE,postvpreproportionE] = PlotPrePost(ESynRatioEarly,ESynRatioLate,20);
% h = cat(1,h(:),th(:));
% 
% [th,rI,pI,coeffsI,prepostpercentchgI,postvpreproportionI] = PlotPrePost(ISynRatioEarly,ISynRatioLate,20);
% h = cat(1,h(:),th(:));

% PrePostCorrelations = v2struct(rE,pE,coeffsE,prepostpercentchgE,postvpreproportionE,rI,pI,coeffsI,prepostpercentchgI,postvpreproportionI);

% 
% %% Plot post/pre vs post
% i = [];
% [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESynRatioEarly,ESynRatioLate,ESynRatioLate);
% i = cat(1,i(:),th(:));
% 
% [th,rI,pI,coeffsI] = PlotPrePostVsOther(ISynRatioEarly,ISynRatioLate,ISynRatioLate);
% i = cat(1,i(:),th(:));
% 
% PrePostVsPostCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);
% 
% %% Plot post/pre vs pre/post mean
% j = [];
% [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESynRatioEarly,ESynRatioLate,ESynRatioELMean);
% j = cat(1,j(:),th(:));
% 
% [th,rI,pI,coeffsI] = PlotPrePostVsOther(ISynRatioEarly,ISynRatioLate,ISynRatioELMean);
% j = cat(1,j(:),th(:));
% 
% PrePostVsPPMeanCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);
% 
% %% Plot post/pre vs Wake total
% k = [];
% [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESynRatioEarly,ESynRatioLate,EWake);
% k = cat(1,k(:),th(:));
% 
% [th,rI,pI,coeffsI] = PlotPrePostVsOther(ISynRatioEarly,ISynRatioLate,IWake);
% k = cat(1,k(:),th(:));
% 
% PrePostVsWakeCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);
% 
% %% Plot post/pre vs SWS total
% l = [];
% [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESynRatioEarly,ESynRatioLate,ESWS);
% l = cat(1,l(:),th(:));
% 
% [th,rI,pI,coeffsI] = PlotPrePostVsOther(ISynRatioEarly,ISynRatioLate,ISWS);
% l = cat(1,l(:),th(:));
% 
% PrePostVsSWSCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);
% 
% %% Plot post/pre vs REM total
% m = [];
% [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESynRatioEarly,ESynRatioLate,EREM);
% m = cat(1,m(:),th(:));
% 
% [th,rI,pI,coeffsI] = PlotPrePostVsOther(ISynRatioEarly,ISynRatioLate,IREM);
% m = cat(1,m(:),th(:));
% 
% PrePostVsREMCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);
% 
% %% Plot post/pre vs Wake Immediately Before
% n = [];
% [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESynRatioEarly,ESynRatioLate,ESynRatioWakeB);
% n = cat(1,n(:),th(:));
% 
% [th,rI,pI,coeffsI] = PlotPrePostVsOther(ISynRatioEarly,ISynRatioLate,ISynRatioWakeB);
% n = cat(1,n(:),th(:));
% 
% PrePostVsWakeBeforeCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);
% 
% %% Plot post/pre vs WSEpoch Sleep Avg
% o = [];
% [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESynRatioEarly,ESynRatioLate,ESynRatioWSSleep);
% o = cat(1,o(:),th(:));
% 
% [th,rI,pI,coeffsI] = PlotPrePostVsOther(ISynRatioEarly,ISynRatioLate,ISynRatioWSSleep);
% o = cat(1,o(:),th(:));
% 
% PrePostVsWSSleepCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);
% 
% %% Plot post/pre vs WSEpoch SWS Avg
% p = [];
% [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESynRatioEarly,ESynRatioLate,ESynRatioWSSWS);
% p = cat(1,p(:),th(:));
% 
% [th,rI,pI,coeffsI] = PlotPrePostVsOther(ISynRatioEarly,ISynRatioLate,ISynRatioWSSWS);
% p = cat(1,p(:),th(:));
% 
% PrePostVsWSSWSCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);
% 
% %% Plot post/pre vs WSEpoch REM Avg
% q = [];
% [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESynRatioEarly,ESynRatioLate,ESynRatioWSREM);
% q = cat(1,q(:),th(:));
% 
% [th,rI,pI,coeffsI] = PlotPrePostVsOther(ISynRatioEarly,ISynRatioLate,ISynRatioWSREM);
% q = cat(1,q(:),th(:));
% 
% PrePostVsWSREMCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);
% 
% %% Plot post/pre vs MWake total
% % r = [];
% % [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESynRatioEarly,ESynRatioLate,EMWake);
% % r = cat(1,r(:),th(:));
% % 
% % [th,rI,pI,coeffsI] = PlotPrePostVsOther(ESynRatioEarly,ISynRatioLate,IMWake);
% % r = cat(1,r(:),th(:));
% % 
% % PrePostVsMWakeCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);
% 
% %% Plot post/pre vs NMWake total
% % s = [];
% % [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESynRatioEarly,ESynRatioLate,ENMWake);
% % s = cat(1,s(:),th(:));
% % 
% % [th,rI,pI,coeffsI] = PlotPrePostVsOther(ESynRatioEarly,ISynRatioLate,INMWake);
% % s = cat(1,s(:),th(:));
% % 
% % PrePostVsNMWakeCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);
% 
% %% Plot post/pre vs MovementModulation total
% % t = [];
% % [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESynRatioEarly,ESynRatioLate,EMovMod);
% % t = cat(1,t(:),th(:));
% % 
% % [th,rI,pI,coeffsI] = PlotPrePostVsOther(ESynRatioEarly,ISynRatioLate,IMovMod);
% % t = cat(1,t(:),th(:));
% % 
% % PrePostVsMovModCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);
% 
% %% Plot post/pre vs All Session Wake Before this sleep
% % u = [];
% % [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESynRatioEarly,ESynRatioLate,ESynRatioWakeAllB);
% % u = cat(1,u(:),th(:));
% % 
% % [th,rI,pI,coeffsI] = PlotPrePostVsOther(ESynRatioEarly,ISynRatioLate,ISynRatioWakeAllB);
% % u = cat(1,u(:),th(:));
% % 
% % PrePostVsWakeAllBeforeCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);
% 
% %% Plot post/pre vs All Session Wake After this sleep
% % v = [];
% % [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESynRatioEarly,ESynRatioLate,ESynRatioWakeAllA);
% % v = cat(1,v(:),th(:));
% % 
% % [th,rI,pI,coeffsI] = PlotPrePostVsOther(ESynRatioEarly,ISynRatioLate,ISynRatioWakeAllA);
% % v = cat(1,v(:),th(:));
% % 
% % PrePostVsWakeAllAfterCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);
% %% Plot post/pre vs All Session Wake After this sleep
% v = [];
% [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESynRatioEarly,ESynRatioLate,ESynRatioWakeA);
% v = cat(1,v(:),th(:));
% 
% [th,rI,pI,coeffsI] = PlotPrePostVsOther(ISynRatioEarly,ISynRatioLate,ISynRatioWakeA);
% v = cat(1,v(:),th(:));
% 
% PrePostVsWakeAfterCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);
% 
% %% Plot post/pre vs All total
% w = [];
% [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESynRatioEarly,ESynRatioLate,EAll);
% w = cat(1,w(:),th(:));
% 
% [th,rI,pI,coeffsI] = PlotPrePostVsOther(ISynRatioEarly,ISynRatioLate,IAll);
% w = cat(1,w(:),th(:));
% 
% PrePostVsAllRateCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);
% 
% 
% 
% 
% %% Save Figs
% supradir = fullfile('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/SpikeChanges',ep1);
% 
% MakeDirSaveFigsThereAs(supradir,h,'fig')
% MakeDirSaveFigsThereAs(supradir,h,'png')
% 
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsPost'),i,'fig')
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsPost'),i,'png')
% 
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsPPMean'),j,'fig')
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsPPMean'),j,'png')
% 
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsWake'),k,'fig')
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsWake'),k,'png')
% 
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsSWS'),l,'fig')
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsSWS'),l,'png')
% 
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsREM'),m,'fig')
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsREM'),m,'png')
% 
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsWakeBefore'),n,'fig')
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsWakeBefore'),n,'png')
% 
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsWSSleep'),o,'fig')
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsWSSleep'),o,'png')
% 
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsWSSWS'),p,'fig')
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsWSSWS'),p,'png')
% 
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsWSREM'),q,'fig')
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsWSREM'),q,'png')
% 
% % MakeDirSaveFigsThereAs(fullfile(supradir,'VsMWake'),r,'fig')
% % MakeDirSaveFigsThereAs(fullfile(supradir,'VsMWake'),r,'png')
% % 
% % MakeDirSaveFigsThereAs(fullfile(supradir,'VsNMWake'),s,'fig')
% % MakeDirSaveFigsThereAs(fullfile(supradir,'VsNMWake'),s,'png')
% % 
% % MakeDirSaveFigsThereAs(fullfile(supradir,'VsMovMod'),t,'fig')
% % MakeDirSaveFigsThereAs(fullfile(supradir,'VsMovMod'),t,'png')
% % 
% % MakeDirSaveFigsThereAs(fullfile(supradir,'VsWakeAllBefore'),u,'fig')
% % MakeDirSaveFigsThereAs(fullfile(supradir,'VsWakeAllBefore'),u,'png')
% % 
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsWakeAfter'),v,'fig')
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsWakeAfter'),v,'png')
% 
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsAllRate'),w,'fig')
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsAllRate'),w,'png')
% 
% MakeDirSaveFigsThereAs(fullfile(supradir,'ImagesOnly'),h,'png')
% MakeDirSaveFigsThereAs(fullfile(supradir,'ImagesOnly'),i,'png')
% MakeDirSaveFigsThereAs(fullfile(supradir,'ImagesOnly'),j,'png')
% MakeDirSaveFigsThereAs(fullfile(supradir,'ImagesOnly'),k,'png')
% MakeDirSaveFigsThereAs(fullfile(supradir,'ImagesOnly'),l,'png')
% MakeDirSaveFigsThereAs(fullfile(supradir,'ImagesOnly'),m,'png')
% MakeDirSaveFigsThereAs(fullfile(supradir,'ImagesOnly'),n,'png')
% MakeDirSaveFigsThereAs(fullfile(supradir,'ImagesOnly'),o,'png')
% MakeDirSaveFigsThereAs(fullfile(supradir,'ImagesOnly'),p,'png')
% MakeDirSaveFigsThereAs(fullfile(supradir,'ImagesOnly'),q,'png')
% % MakeDirSaveFigsThereAs(fullfile(supradir,'ImagesOnly'),r,'png')
% % MakeDirSaveFigsThereAs(fullfile(supradir,'ImagesOnly'),s,'png')
% % MakeDirSaveFigsThereAs(fullfile(supradir,'ImagesOnly'),t,'png')
% % MakeDirSaveFigsThereAs(fullfile(supradir,'ImagesOnly'),u,'png')
% MakeDirSaveFigsThereAs(fullfile(supradir,'ImagesOnly'),v,'png')
% MakeDirSaveFigsThereAs(fullfile(supradir,'ImagesOnly'),w,'png')
% 
% % SaveDirectoryImagesToSinglePDF(fullfile(supradir,'ImagesOnly'),'ECorrs','png',{'ESynRatio';'OvE'},'Quartiles')
% % cd(supradir);
% % SaveDirectoryImagesToSinglePDF(fullfile(supradir,'ImagesOnly'),'EQuartiles','png',{'ESynRatio';'Quartiles'})
% % cd(supradir);
% % SaveDirectoryImagesToSinglePDF(fullfile(supradir,'ImagesOnly'),'ICorrs','png',{'ISynRatio';'OvI'},'Quartiles')
% % cd(supradir);
% % SaveDirectoryImagesToSinglePDF(fullfile(supradir,'ImagesOnly'),'IQuartiles','png',{'ISynRatio';'Quartiles'})
% % cd(supradir);
% SaveDirectoryImagesToSinglePDF(fullfile(supradir,'ImagesOnly'),'ECorrs','png',{'ESynRatio','Ov'})
% cd(supradir);
% SaveDirectoryImagesToSinglePDF(fullfile(supradir,'ImagesOnly'),'EOtherBasics','png','ESynRatio','Ov')
% cd(supradir);
% SaveDirectoryImagesToSinglePDF(fullfile(supradir,'ImagesOnly'),'ICorrs','png',{'ISynRatio','Ov'})
% cd(supradir);
% SaveDirectoryImagesToSinglePDF(fullfile(supradir,'ImagesOnly'),'IOtherBasics','png','ISynRatio','Ov')
% cd(supradir);
% 
% 
% %% Save Data structs
% %underlying data
% MakeDirSaveVarThere(supradir,SynStrWSSnippets);
% MakeDirSaveVarThere(supradir,StateRates);
% MakeDirSaveVarThere(supradir,SpikeWSSnippets_WakeB);
% MakeDirSaveVarThere(supradir,SpikeWSSnippets_WakeA);
% MakeDirSaveVarThere(supradir,SpikeWSSnippets_WSSleep);
% MakeDirSaveVarThere(supradir,SpikeWSSnippets_WSSWS);
% MakeDirSaveVarThere(supradir,SpikeWSSnippets_WSREM);
% 
% %later correlation data
% MakeDirSaveVarThere(supradir,PrePostCorrelations);
% MakeDirSaveVarThere(fullfile(supradir,'VsPost'),PrePostVsPostCorrelations);
% MakeDirSaveVarThere(fullfile(supradir,'VsPPMean'),PrePostVsPPMeanCorrelations);
% MakeDirSaveVarThere(fullfile(supradir,'VsWake'),PrePostVsWakeCorrelations);
% MakeDirSaveVarThere(fullfile(supradir,'VsSWS'),PrePostVsSWSCorrelations);
% MakeDirSaveVarThere(fullfile(supradir,'VsREM'),PrePostVsREMCorrelations);
% MakeDirSaveVarThere(fullfile(supradir,'VsWakeBefore'),PrePostVsWakeBeforeCorrelations);
% MakeDirSaveVarThere(fullfile(supradir,'VsWSSleep'),PrePostVsWSSleepCorrelations);
% MakeDirSaveVarThere(fullfile(supradir,'VsWSSWS'),PrePostVsWSSWSCorrelations);
% MakeDirSaveVarThere(fullfile(supradir,'VsWSREM'),PrePostVsWSREMCorrelations);
% % MakeDirSaveVarThere(fullfile(supradir,'VsMWake'),PrePostVsMWakeCorrelations);
% % MakeDirSaveVarThere(fullfile(supradir,'VsNMWake'),PrePostVsNMWakeCorrelations);
% % MakeDirSaveVarThere(fullfile(supradir,'VsMovMod'),PrePostVsMovModCorrelations);
% % MakeDirSaveVarThere(fullfile(supradir,'VsWakeAllBefore'),PrePostVsWakeAllBeforeCorrelations);
% % MakeDirSaveVarThere(fullfile(supradir,'VsWakeAllAfter'),PrePostVsWakeAllAfterCorrelations);
% MakeDirSaveVarThere(fullfile(supradir,'VsWakeAfter'),PrePostVsWakeAfterCorrelations);
% MakeDirSaveVarThere(fullfile(supradir,'VsAllRate'),PrePostVsAllRateCorrelations);
% 
% 
