function WSSnippets_PlotAllSpikeRateChanges(ep1)
% C
% Brendon Watson 2015

%% Load pre-post rates for each cell
if ~exist('ep1','var')
    ep1 = 'FLSWS';
end
ep2 = [];
SpikeWSSnippets = WSSnippets_GatherAllSpikeMedians(ep1,ep2);
SpikeWSSnippets_WakeB = WSSnippets_GatherAllSpikeMedians('WakeB',ep2);
SpikeWSSnippets_WakeAllB = WSSnippets_GatherAllSpikeMedians('WakeAllB',ep2);
SpikeWSSnippets_WakeAllA = WSSnippets_GatherAllSpikeMedians('WakeAllA',ep2);
SpikeWSSnippets_WakeA = WSSnippets_GatherAllSpikeMedians('WakeA',ep2);
SpikeWSSnippets_WSSleep = WSSnippets_GatherAllSpikeMedians('WSSleep',ep2);
SpikeWSSnippets_WSSWS = WSSnippets_GatherAllSpikeMedians('WSSWS',ep2);
SpikeWSSnippets_WSREM = WSSnippets_GatherAllSpikeMedians('WSREM',ep2);

%% Load StateRates for each cell
StateRates = SpikingAnalysis_GatherAllStateRates;

%% Declare some variables for later use
ESpikesEarly = SpikeWSSnippets.medianRatePreSpikesE;
ESpikesLate = SpikeWSSnippets.medianRatePostSpikesE;
ISpikesEarly = SpikeWSSnippets.medianRatePreSpikesI;
ISpikesLate = SpikeWSSnippets.medianRatePostSpikesI;
ESpikesELMean = (ESpikesEarly+ESpikesLate)/2;
ISpikesELMean =  (ISpikesEarly+ISpikesLate)/2;

ESpikesWakeB = SpikeWSSnippets_WakeB.medianRatePreSpikesE;
ISpikesWakeB = SpikeWSSnippets_WakeB.medianRatePreSpikesI;
% ESpikesWakeA = SpikeWSSnippets_WakeA.medianRatePreSpikesE;
% ISpikesWakeA = SpikeWSSnippets_WakeA.medianRatePreSpikesI;
% ESpikesWakeAllB = SpikeWSSnippets_WakeAllB.medianRatePreSpikesE;
% ISpikesWakeAllB = SpikeWSSnippets_WakeAllB.medianRatePreSpikesI;
% ESpikesWakeAllA = SpikeWSSnippets_WakeAllA.medianRatePreSpikesE;
% ISpikesWakeAllA = SpikeWSSnippets_WakeAllA.medianRatePreSpikesI;
% 
% ESpikesWSSleep = SpikeWSSnippets_WSSleep.medianRatePreSpikesE;
% ISpikesWSSleep = SpikeWSSnippets_WSSleep.medianRatePreSpikesI;
% ESpikesWSSWS = SpikeWSSnippets_WSSWS.medianRatePreSpikesE;
% ISpikesWSSWS = SpikeWSSnippets_WSSWS.medianRatePreSpikesI;
% ESpikesWSREM = SpikeWSSnippets_WSREM.medianRatePreSpikesE;
% ISpikesWSREM = SpikeWSSnippets_WSREM.medianRatePreSpikesI;


EAll = StateRates.EAllRates;
IAll = StateRates.IAllRates;
EWake = StateRates.EWSWakeRates;
IWake = StateRates.IWSWakeRates;
ESWS = StateRates.ESWSRates;
ISWS = StateRates.ISWSRates;
EREM = StateRates.EREMRates;
IREM = StateRates.IREMRates;
% EMWake = StateRates.EMWakeRates;
% IMWake = StateRates.IMWakeRates;
% ENMWake = StateRates.ENMWakeRates;
% INMWake = StateRates.INMWakeRates;
% EMovMod = EMWake./ENMWake;
% IMovMod = IMWake./INMWake;

%% Plot pre vs post spikes
h = [];
[th,rE,pE,coeffsE,prepostpercentchgE,postvpreproportionE] = PlotPrePost(ESpikesEarly,ESpikesLate,20);
h = cat(1,h(:),th(:));
th = PlotPrePost(ESpikesEarly,ESpikesLate,20);
nh = copyfig(th(3));
delete(th)
nh2 = copyfig(nh);
delete(nh);
h = cat(1,h(:),nh2);

[th,rI,pI,coeffsI,prepostpercentchgI,postvpreproportionI] = PlotPrePost(ISpikesEarly,ISpikesLate,20);
h = cat(1,h(:),th(:));

PrePostCorrelations = v2struct(rE,pE,coeffsE,prepostpercentchgE,postvpreproportionE,rI,pI,coeffsI,prepostpercentchgI,postvpreproportionI);

%% Plot post/pre vs post
% i = [];
% [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESpikesEarly,ESpikesLate,ESpikesLate);
% i = cat(1,i(:),th(:));
% 
% [th,rI,pI,coeffsI] = PlotPrePostVsOther(ISpikesEarly,ISpikesLate,ISpikesLate);
% i = cat(1,i(:),th(:));
% 
% PrePostVsPostCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);

%% Plot post/pre vs pre/post mean
% j = [];
% [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESpikesEarly,ESpikesLate,ESpikesELMean);
% j = cat(1,j(:),th(:));
% 
% [th,rI,pI,coeffsI] = PlotPrePostVsOther(ISpikesEarly,ISpikesLate,ISpikesELMean);
% j = cat(1,j(:),th(:));
% 
% PrePostVsPPMeanCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);

%% Plot post/pre vs Wake total
k = [];
[th,rE,pE,coeffsE] = PlotPrePostVsOther(ESpikesEarly,ESpikesLate,EWake);
k = cat(1,k(:),th(:));

[th,rI,pI,coeffsI] = PlotPrePostVsOther(ISpikesEarly,ISpikesLate,IWake);
k = cat(1,k(:),th(:));

PrePostVsWakeCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);

%% Plot post/pre vs SWS total
% l = [];
% [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESpikesEarly,ESpikesLate,ESWS);
% l = cat(1,l(:),th(:));
% 
% [th,rI,pI,coeffsI] = PlotPrePostVsOther(ISpikesEarly,ISpikesLate,ISWS);
% l = cat(1,l(:),th(:));
% 
% PrePostVsSWSCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);

%% Plot post/pre vs REM total
% m = [];
% [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESpikesEarly,ESpikesLate,EREM);
% m = cat(1,m(:),th(:));
% 
% [th,rI,pI,coeffsI] = PlotPrePostVsOther(ISpikesEarly,ISpikesLate,IREM);
% m = cat(1,m(:),th(:));
% 
% PrePostVsREMCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);

%% Plot post/pre vs Wake Immediately Before
n = [];
[th,rE,pE,coeffsE] = PlotPrePostVsOther(ESpikesEarly,ESpikesLate,ESpikesWakeB);
n = cat(1,n(:),th(:));

[th,rI,pI,coeffsI] = PlotPrePostVsOther(ISpikesEarly,ISpikesLate,ISpikesWakeB);
n = cat(1,n(:),th(:));

PrePostVsWakeBeforeCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);

%% Plot post/pre vs WSEpoch Sleep Avg
% o = [];
% [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESpikesEarly,ESpikesLate,ESpikesWSSleep);
% o = cat(1,o(:),th(:));
% 
% [th,rI,pI,coeffsI] = PlotPrePostVsOther(ISpikesEarly,ISpikesLate,ISpikesWSSleep);
% o = cat(1,o(:),th(:));
% 
% PrePostVsWSSleepCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);

%% Plot post/pre vs WSEpoch SWS Avg
% p = [];
% [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESpikesEarly,ESpikesLate,ESpikesWSSWS);
% p = cat(1,p(:),th(:));
% 
% [th,rI,pI,coeffsI] = PlotPrePostVsOther(ISpikesEarly,ISpikesLate,ISpikesWSSWS);
% p = cat(1,p(:),th(:));
% 
% PrePostVsWSSWSCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);

%% Plot post/pre vs WSEpoch REM Avg
% q = [];
% [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESpikesEarly,ESpikesLate,ESpikesWSREM);
% q = cat(1,q(:),th(:));
% 
% [th,rI,pI,coeffsI] = PlotPrePostVsOther(ISpikesEarly,ISpikesLate,ISpikesWSREM);
% q = cat(1,q(:),th(:));
% 
% PrePostVsWSREMCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);

%% Plot post/pre vs MWake total
% r = [];
% [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESpikesEarly,ESpikesLate,EMWake);
% r = cat(1,r(:),th(:));
% 
% [th,rI,pI,coeffsI] = PlotPrePostVsOther(ESpikesEarly,ISpikesLate,IMWake);
% r = cat(1,r(:),th(:));
% 
% PrePostVsMWakeCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);

%% Plot post/pre vs NMWake total
% s = [];
% [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESpikesEarly,ESpikesLate,ENMWake);
% s = cat(1,s(:),th(:));
% 
% [th,rI,pI,coeffsI] = PlotPrePostVsOther(ESpikesEarly,ISpikesLate,INMWake);
% s = cat(1,s(:),th(:));
% 
% PrePostVsNMWakeCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);

%% Plot post/pre vs MovementModulation total
% t = [];
% [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESpikesEarly,ESpikesLate,EMovMod);
% t = cat(1,t(:),th(:));
% 
% [th,rI,pI,coeffsI] = PlotPrePostVsOther(ESpikesEarly,ISpikesLate,IMovMod);
% t = cat(1,t(:),th(:));
% 
% PrePostVsMovModCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);

%% Plot post/pre vs All Session Wake Before this sleep
% u = [];
% [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESpikesEarly,ESpikesLate,ESpikesWakeAllB);
% u = cat(1,u(:),th(:));
% 
% [th,rI,pI,coeffsI] = PlotPrePostVsOther(ESpikesEarly,ISpikesLate,ISpikesWakeAllB);
% u = cat(1,u(:),th(:));
% 
% PrePostVsWakeAllBeforeCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);

%% Plot post/pre vs All Session Wake After this sleep
% v = [];
% [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESpikesEarly,ESpikesLate,ESpikesWakeAllA);
% v = cat(1,v(:),th(:));
% 
% [th,rI,pI,coeffsI] = PlotPrePostVsOther(ESpikesEarly,ISpikesLate,ISpikesWakeAllA);
% v = cat(1,v(:),th(:));
% 
% PrePostVsWakeAllAfterCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);
%% Plot post/pre vs All Session Wake After this sleep
% v = [];
% [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESpikesEarly,ESpikesLate,ESpikesWakeA);
% v = cat(1,v(:),th(:));
% 
% [th,rI,pI,coeffsI] = PlotPrePostVsOther(ISpikesEarly,ISpikesLate,ISpikesWakeA);
% v = cat(1,v(:),th(:));
% 
% PrePostVsWakeAfterCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);

%% Plot post/pre vs All total
% w = [];
% [th,rE,pE,coeffsE] = PlotPrePostVsOther(ESpikesEarly,ESpikesLate,EAll);
% w = cat(1,w(:),th(:));
% 
% [th,rI,pI,coeffsI] = PlotPrePostVsOther(ISpikesEarly,ISpikesLate,IAll);
% w = cat(1,w(:),th(:));
% 
% PrePostVsAllRateCorrelations = v2struct(rE,pE,coeffsE,rI,pI,coeffsI);




%% Save Figs
supradir = fullfile('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/SpikeChanges',ep1);
% 
MakeDirSaveFigsThereAs(supradir,h,'fig')
MakeDirSaveFigsThereAs(supradir,h,'png')
% 
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsPost'),i,'fig')
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsPost'),i,'png')
% 
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsPPMean'),j,'fig')
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsPPMean'),j,'png')
% 
MakeDirSaveFigsThereAs(fullfile(supradir,'VsWake'),k,'fig')
MakeDirSaveFigsThereAs(fullfile(supradir,'VsWake'),k,'png')
% 
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsSWS'),l,'fig')
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsSWS'),l,'png')
% 
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsREM'),m,'fig')
% MakeDirSaveFigsThereAs(fullfile(supradir,'VsREM'),m,'png')
% 
MakeDirSaveFigsThereAs(fullfile(supradir,'VsWakeBefore'),n,'fig')
MakeDirSaveFigsThereAs(fullfile(supradir,'VsWakeBefore'),n,'png')

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
% % SaveDirectoryImagesToSinglePDF(fullfile(supradir,'ImagesOnly'),'ECorrs','png',{'ESpikes';'OvE'},'Quartiles')
% % cd(supradir);
% % SaveDirectoryImagesToSinglePDF(fullfile(supradir,'ImagesOnly'),'EQuartiles','png',{'ESpikes';'Quartiles'})
% % cd(supradir);
% % SaveDirectoryImagesToSinglePDF(fullfile(supradir,'ImagesOnly'),'ICorrs','png',{'ISpikes';'OvI'},'Quartiles')
% % cd(supradir);
% % SaveDirectoryImagesToSinglePDF(fullfile(supradir,'ImagesOnly'),'IQuartiles','png',{'ISpikes';'Quartiles'})
% % cd(supradir);
% SaveDirectoryImagesToSinglePDF(fullfile(supradir,'ImagesOnly'),'ECorrs','png',{'ESpikes','Ov'})
% cd(supradir);
% SaveDirectoryImagesToSinglePDF(fullfile(supradir,'ImagesOnly'),'EOtherBasics','png','ESpikes','Ov')
% cd(supradir);
% SaveDirectoryImagesToSinglePDF(fullfile(supradir,'ImagesOnly'),'ICorrs','png',{'ISpikes','Ov'})
% cd(supradir);
% SaveDirectoryImagesToSinglePDF(fullfile(supradir,'ImagesOnly'),'IOtherBasics','png','ISpikes','Ov')
% cd(supradir);
% 
% 
% %% Save Data structs
% %underlying data
% MakeDirSaveVarThere(supradir,SpikeWSSnippets);
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


