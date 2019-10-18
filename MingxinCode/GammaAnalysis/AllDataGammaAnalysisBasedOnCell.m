function AllDataGammaAnalysisBasedOnCell

folders = dir;
passband = [1 625];
nvoice = 12;
% SamplingRate = 1250;
%%
for ii = 1:length(folders) % [23 33:35];
    % for ii = [1:15,17,19:27] % smaller recordings
    basepath = folders(ii).name;
    [~,basename] = fileparts(basepath);
    if exist(fullfile(basepath,[basename '_IsolatedNeighborZScoreIntervals.mat']),'file')
        if ~exist(fullfile(basepath,[basename '_PhasestatsIsolatedBand.mat']),'file');
        display(basename);
        GammaPhaseModIsolatedBand(basepath,basename);
        end
    end
end
%%
% for ii = [13 16 17 20:26 41 42] % [23 33:35];
%     % for ii = [1:15,17,19:27] % smaller recordings
%     basepath = folders(ii).name;
%     [~,basename] = fileparts(basepath);
%     if exist(fullfile(basepath,[basename '_LocalZScoreIntervals.mat']),'file')
%         load(fullfile(basepath,[basename '_LocalZScoreIntervals.mat']));
%         if exist('AboveInt','var')
%             display(basename);
%             AboveInt_ZByState = AboveInt;
%             AboveInt_ZCombined = AboveInt_all;
%             BelowInt_ZByState = BelowInt;
%             BelowInt_ZCombined = BelowInt_all;
%             save(fullfile(basepath,[basename '_LocalZScoreIntervals.mat']),...
%                 'AboveInt_ZByState','BelowInt_ZByState','AboveInt_ZCombined','BelowInt_ZCombined','Shanks',...
%                 'freqlist','zthreshold_all','SamplingRate','-v7.3');
%             clear AboveInt AboveInt_all AboveInt_ZByState AboveInt_ZCombined BelowInt BelowInt_all BelowInt_ZByState BelowInt_ZCombined...
%                 SamplingRate zthreshold_all freqlist Shanks;
%         else
%             clear AboveInt_ZByState AboveInt_ZCombined BelowInt_ZByState BelowInt_ZCombined SamplingRate...
%                 zthreshold_all freqlist Shanks;
%         end
%         %         save(fullfile(basepath,[basename '_LocalZScoreIntervals.mat']),'SamplingRate','-append');
%         %         save(fullfile(basepath,[basename '_NeighborZScoreIntervals.mat']),'SamplingRate','-append');
%     end
% end
% %%
% for ii = 3:37;
%     % for ii = [1:15,17,19:27]
%     if isdir(folders(ii).name)
%         basepath = folders(ii).name;
%         [~,basename] = fileparts(basepath);
%         if ~exist(fullfile(basepath,[basename '_NeighborZScoreIntervals_thresh_0.5.mat']),'file')
%             display(basename);
%             ZScoreIntervalsWrapper(basepath,basename);
%         end
%     end
% end
%%
freqlist= unique(round(2.^(log2(passband(1)):1/nvoice:log2(passband(2)))));

AllCells.phst.r = [];
AllCells.phst.m = [];
AllCells.phst.p = [];
AllCells.phst.mode = [];
AllCells.phst.k = [];
AllCells.phstL.r = [];
AllCells.phstH.r = [];
AllCells.WAKEphst.r = [];
AllCells.WAKEphstL.r = [];
AllCells.WAKEphstH.r = [];
AllCells.NREMphst.r = [];
AllCells.NREMphstL.r = [];
AllCells.NREMphstH.r = [];
AllCells.REMphst.r = [];
AllCells.REMphstL.r = [];
AllCells.REMphstH.r = [];
AllCells.MAphst.r = [];
AllCells.MAphstL.r = [];
AllCells.MAphstH.r = [];

AllJitter.all = [];
AllJitter.H = [];
AllJitter.L = [];
AllJitter.WAKE = [];
AllJitter.WAKEH = [];
AllJitter.WAKEL = [];
AllJitter.NREM = [];
AllJitter.NREMH = [];
AllJitter.NREML = [];
AllJitter.REM = [];
AllJitter.REMH = [];
AllJitter.REML = [];
AllJitter.MA = [];
AllJitter.MAH = [];
AllJitter.MAL = [];

AllRawJitter.all = [];
AllRawJitter.H = [];
AllRawJitter.L = [];
AllRawJitter.WAKE = [];
AllRawJitter.WAKEH = [];
AllRawJitter.WAKEL = [];
AllRawJitter.NREM = [];
AllRawJitter.NREMH = [];
AllRawJitter.NREML = [];
AllRawJitter.REM = [];
AllRawJitter.REMH = [];
AllRawJitter.REML = [];
AllRawJitter.MA = [];
AllRawJitter.MAH = [];
AllRawJitter.MAL = [];

EAll = [];
IAll = [];
SpikeNum = [];
%%
for ii = 1:length(folders)
    basepath = folders(ii).name;
    [~,basename] = fileparts(basepath);
    if exist(fullfile(basepath,[basename '_JitterMRL.mat']),'file')
%         display(basename);
        load(fullfile(basepath,[basename '_PhasestatsByPowerAndState.mat']),'PhstPS');
%         load(fullfile(basepath,[basename '_JitterMRL.mat']),'jitterMRL','jitmeanMRL');
%         load(fullfile(basepath,[basename '_CellIDs.mat']),'CellIDs');
%         load(fullfile(basepath,[basename '_SStable.mat']),'S');
%         for jj = 1:length(S)
%             SpikeNum(end+1) = length(S{jj});
%         end
        AllCells.phst.m = cat(1,AllCells.phst.m,PhstPS.phst.m);
        AllCells.phst.k = cat(1,AllCells.phst.k,PhstPS.phst.k);
        AllCells.phst.p = cat(1,AllCells.phst.p,PhstPS.phst.p);
        AllCells.phst.mode = cat(1,AllCells.phst.mode,PhstPS.phst.mode);
%         AllCells.phst.r = cat(1,AllCells.phst.r,PhstPS.phst.r);
%         AllCells.phstL.r = cat(1,AllCells.phstL.r,PhstPS.phstL.r);
%         AllCells.phstH.r = cat(1,AllCells.phstH.r,PhstPS.phstH.r);
%         AllCells.WAKEphst.r = cat(1,AllCells.WAKEphst.r,PhstPS.WAKEphst.r);
%         AllCells.WAKEphstL.r = cat(1,AllCells.WAKEphstL.r,PhstPS.WAKEphstL.r);
%         AllCells.WAKEphstH.r = cat(1,AllCells.WAKEphstH.r,PhstPS.WAKEphstH.r);
%         AllCells.NREMphst.r = cat(1,AllCells.NREMphst.r,PhstPS.NREMphst.r);
%         AllCells.NREMphstL.r = cat(1,AllCells.NREMphstL.r,PhstPS.NREMphstL.r);
%         AllCells.NREMphstH.r = cat(1,AllCells.NREMphstH.r,PhstPS.NREMphstH.r);
%         AllCells.REMphst.r = cat(1,AllCells.REMphst.r,PhstPS.REMphst.r);
%         AllCells.REMphstL.r = cat(1,AllCells.REMphstL.r,PhstPS.REMphstL.r);
%         AllCells.REMphstH.r = cat(1,AllCells.REMphstH.r,PhstPS.REMphstH.r);
%         AllCells.MAphst.r = cat(1,AllCells.MAphst.r,PhstPS.MAphst.r);
%         AllCells.MAphstL.r = cat(1,AllCells.MAphstL.r,PhstPS.MAphstL.r);
%         AllCells.MAphstH.r = cat(1,AllCells.MAphstH.r,PhstPS.MAphstH.r);
%         
%         AllJitter.all = cat(1,AllJitter.all,jitmeanMRL.all);
%         AllJitter.H = cat(1,AllJitter.H,jitmeanMRL.H);
%         AllJitter.L = cat(1,AllJitter.L,jitmeanMRL.L);
%         AllJitter.WAKE = cat(1,AllJitter.WAKE,jitmeanMRL.WAKE);
%         AllJitter.WAKEH = cat(1,AllJitter.WAKEH,jitmeanMRL.WAKEH);
%         AllJitter.WAKEL = cat(1,AllJitter.WAKEL,jitmeanMRL.WAKEL);
%         AllJitter.NREM = cat(1,AllJitter.NREM,jitmeanMRL.NREM);
%         AllJitter.NREMH = cat(1,AllJitter.NREMH,jitmeanMRL.NREMH);
%         AllJitter.NREML = cat(1,AllJitter.NREML,jitmeanMRL.NREML);
%         AllJitter.REM = cat(1,AllJitter.REM,jitmeanMRL.REM);
%         AllJitter.REMH = cat(1,AllJitter.REMH,jitmeanMRL.REMH);
%         AllJitter.REML = cat(1,AllJitter.REML,jitmeanMRL.REML);
%         AllJitter.MA = cat(1,AllJitter.MA,jitmeanMRL.MA);
%         AllJitter.MAH = cat(1,AllJitter.MAH,jitmeanMRL.MAH);
%         AllJitter.MAL = cat(1,AllJitter.MAL,jitmeanMRL.MAL);
%         
%         AllRawJitter.all = cat(1,AllRawJitter.all,jitterMRL.all);
%         AllRawJitter.H = cat(1,AllRawJitter.H,jitterMRL.H);
%         AllRawJitter.L = cat(1,AllRawJitter.L,jitterMRL.L);
%         AllRawJitter.WAKE = cat(1,AllRawJitter.WAKE,jitterMRL.WAKE);
%         AllRawJitter.WAKEH = cat(1,AllRawJitter.WAKEH,jitterMRL.WAKEH);
%         AllRawJitter.WAKEL = cat(1,AllRawJitter.WAKEL,jitterMRL.WAKEL);
%         AllRawJitter.NREM = cat(1,AllRawJitter.NREM,jitterMRL.NREM);
%         AllRawJitter.NREMH = cat(1,AllRawJitter.NREMH,jitterMRL.NREMH);
%         AllRawJitter.NREML = cat(1,AllRawJitter.NREML,jitterMRL.NREML);
%         AllRawJitter.REM = cat(1,AllRawJitter.REM,jitterMRL.REM);
%         AllRawJitter.REMH = cat(1,AllRawJitter.REMH,jitterMRL.REMH);
%         AllRawJitter.REML = cat(1,AllRawJitter.REML,jitterMRL.REML);
%         AllRawJitter.MA = cat(1,AllRawJitter.MA,jitterMRL.MA);
%         AllRawJitter.MAH = cat(1,AllRawJitter.MAH,jitterMRL.MAH);
%         AllRawJitter.MAL = cat(1,AllRawJitter.MAL,jitterMRL.MAL);
% %         
%         NewE = reshape(CellIDs.EAll+length(EAll)+length(IAll),[],1);
%         NewI = reshape(CellIDs.IAll+length(EAll)+length(IAll),[],1);
%         EAll = cat(1,EAll,NewE);
%         IAll = cat(1,IAll,NewI);
    end
end
%%
% EAll = setdiff(EAll,find(SpikeNum<100));
% IAll = setdiff(IAll,find(SpikeNum<100));
AllCellIDs = v2struct(EAll,IAll);
%%
logAllCells.phst.r = log(AllCells.phst.r);
logAllCells.phstL.r = log(AllCells.phstL.r);
logAllCells.phstH.r = log(AllCells.phstH.r);
logAllCells.WAKEphst.r = log(AllCells.WAKEphst.r);
logAllCells.WAKEphstL.r = log(AllCells.WAKEphstL.r);
logAllCells.WAKEphstH.r = log(AllCells.WAKEphstH.r);
logAllCells.NREMphst.r = log(AllCells.NREMphst.r);
logAllCells.NREMphstL.r = log(AllCells.NREMphstL.r);
logAllCells.NREMphstH.r = log(AllCells.NREMphstH.r);
logAllCells.REMphst.r = log(AllCells.REMphst.r);
logAllCells.REMphstL.r = log(AllCells.REMphstL.r);
logAllCells.REMphstH.r = log(AllCells.REMphstH.r);
logAllCells.MAphst.r = log(AllCells.MAphst.r);
logAllCells.MAphstL.r = log(AllCells.MAphstL.r);
logAllCells.MAphstH.r = log(AllCells.MAphstH.r);

logAllJitter.all = log(AllJitter.all);
logAllJitter.H = log(AllJitter.H);
logAllJitter.L = log(AllJitter.L);
logAllJitter.WAKE = log(AllJitter.WAKE);
logAllJitter.WAKEH = log(AllJitter.WAKEH);
logAllJitter.WAKEL = log(AllJitter.WAKEL);
logAllJitter.NREM = log(AllJitter.NREM);
logAllJitter.NREMH = log(AllJitter.NREMH);
logAllJitter.NREML = log(AllJitter.NREML);
logAllJitter.REM = log(AllJitter.REM);
logAllJitter.REMH = log(AllJitter.REMH);
logAllJitter.REML = log(AllJitter.REML);
logAllJitter.MA = log(AllJitter.MA);
logAllJitter.MAH = log(AllJitter.MAH);
logAllJitter.MAL = log(AllJitter.MAL);

%% p-values of Wilcoxon signed rank test

BonCorrection = 5*4*length(freqlist);

for ii = 1:length(freqlist)
%     
%     pvalues.E.all(ii) = signrank(AllCells.phst.r(EAll,ii),AllJitter.all(EAll,ii),'tail','right')*BonCorrection;
%     pvalues.E.L(ii) = signrank(AllCells.phstL.r(EAll,ii),AllJitter.L(EAll,ii),'tail','right')*BonCorrection;
%     pvalues.E.H(ii) = signrank(AllCells.phstH.r(EAll,ii),AllJitter.H(EAll,ii),'tail','right')*BonCorrection;
%     pvalues.E.HmL(ii) = signrank(AllCells.phstH.r(EAll,ii)-AllCells.phstL.r(EAll,ii),...
%         AllJitter.H(EAll,ii)-AllJitter.L(EAll,ii),'tail','right')*BonCorrection;
%     pvalues.E.WAKE(ii) = signrank(AllCells.WAKEphst.r(EAll,ii),AllJitter.WAKE(EAll,ii),'tail','right')*BonCorrection;
%     pvalues.E.WAKEL(ii) = signrank(AllCells.WAKEphstL.r(EAll,ii),AllJitter.WAKEL(EAll,ii),'tail','right')*BonCorrection;
%     pvalues.E.WAKEH(ii) = signrank(AllCells.WAKEphstH.r(EAll,ii),AllJitter.WAKEH(EAll,ii),'tail','right')*BonCorrection;
%     pvalues.E.WAKEHmL(ii) = signrank(AllCells.WAKEphstH.r(EAll,ii)-AllCells.WAKEphstL.r(EAll,ii),...
%         AllJitter.WAKEH(EAll,ii)-AllJitter.WAKEL(EAll,ii),'tail','right')*BonCorrection;
%     pvalues.E.NREM(ii) = signrank(AllCells.NREMphst.r(EAll,ii),AllJitter.NREM(EAll,ii),'tail','right')*BonCorrection;
%     pvalues.E.NREML(ii) = signrank(AllCells.NREMphstL.r(EAll,ii),AllJitter.NREML(EAll,ii),'tail','right')*BonCorrection;
%     pvalues.E.NREMH(ii) = signrank(AllCells.NREMphstH.r(EAll,ii),AllJitter.NREMH(EAll,ii),'tail','right')*BonCorrection;
%     pvalues.E.NREMHmL(ii) = signrank(AllCells.NREMphstH.r(EAll,ii)-AllCells.NREMphstL.r(EAll,ii),...
%         AllJitter.NREMH(EAll,ii)-AllJitter.NREML(EAll,ii),'tail','right')*BonCorrection;
%     pvalues.E.REM(ii) = signrank(AllCells.REMphst.r(EAll,ii),AllJitter.REM(EAll,ii),'tail','right')*BonCorrection;
%     pvalues.E.REML(ii) = signrank(AllCells.REMphstL.r(EAll,ii),AllJitter.REML(EAll,ii),'tail','right')*BonCorrection;
%     pvalues.E.REMH(ii) = signrank(AllCells.REMphstH.r(EAll,ii),AllJitter.REMH(EAll,ii),'tail','right')*BonCorrection;
%     pvalues.E.REMHmL(ii) = signrank(AllCells.REMphstH.r(EAll,ii)-AllCells.REMphstL.r(EAll,ii),...
%         AllJitter.REMH(EAll,ii)-AllJitter.REML(EAll,ii),'tail','right')*BonCorrection;
%     pvalues.E.MA(ii) = signrank(AllCells.MAphst.r(EAll,ii),AllJitter.MA(EAll,ii),'tail','right')*BonCorrection;
%     pvalues.E.MAL(ii) = signrank(AllCells.MAphstL.r(EAll,ii),AllJitter.MAL(EAll,ii),'tail','right')*BonCorrection;
%     pvalues.E.MAH(ii) = signrank(AllCells.MAphstH.r(EAll,ii),AllJitter.MAH(EAll,ii),'tail','right')*BonCorrection;
%     pvalues.E.MAHmL(ii) = signrank(AllCells.MAphstH.r(EAll,ii)-AllCells.MAphstL.r(EAll,ii),...
%         AllJitter.MAH(EAll,ii)-AllJitter.MAL(EAll,ii),'tail','right')*BonCorrection;
%     
%     pvalues.I.all(ii) = signrank(AllCells.phst.r(IAll,ii),AllJitter.all(IAll,ii),'tail','right')*BonCorrection;
%     pvalues.I.L(ii) = signrank(AllCells.phstL.r(IAll,ii),AllJitter.L(IAll,ii),'tail','right')*BonCorrection;
%     pvalues.I.H(ii) = signrank(AllCells.phstH.r(IAll,ii),AllJitter.H(IAll,ii),'tail','right')*BonCorrection;
%     pvalues.I.HmL(ii) = signrank(AllCells.phstH.r(IAll,ii)-AllCells.phstL.r(IAll,ii),...
%         AllJitter.H(IAll,ii)-AllJitter.L(IAll,ii),'tail','right')*BonCorrection;
%     pvalues.I.WAKE(ii) = signrank(AllCells.WAKEphst.r(IAll,ii),AllJitter.WAKE(IAll,ii),'tail','right')*BonCorrection;
%     pvalues.I.WAKEL(ii) = signrank(AllCells.WAKEphstL.r(IAll,ii),AllJitter.WAKEL(IAll,ii),'tail','right')*BonCorrection;
%     pvalues.I.WAKEH(ii) = signrank(AllCells.WAKEphstH.r(IAll,ii),AllJitter.WAKEH(IAll,ii),'tail','right')*BonCorrection;
%     pvalues.I.WAKEHmL(ii) = signrank(AllCells.WAKEphstH.r(IAll,ii)-AllCells.WAKEphstL.r(IAll,ii),...
%         AllJitter.WAKEH(IAll,ii)-AllJitter.WAKEL(IAll,ii),'tail','right')*BonCorrection;
%     pvalues.I.NREM(ii) = signrank(AllCells.NREMphst.r(IAll,ii),AllJitter.NREM(IAll,ii),'tail','right')*BonCorrection;
%     pvalues.I.NREML(ii) = signrank(AllCells.NREMphstL.r(IAll,ii),AllJitter.NREML(IAll,ii),'tail','right')*BonCorrection;
%     pvalues.I.NREMH(ii) = signrank(AllCells.NREMphstH.r(IAll,ii),AllJitter.NREMH(IAll,ii),'tail','right')*BonCorrection;
%     pvalues.I.NREMHmL(ii) = signrank(AllCells.NREMphstH.r(IAll,ii)-AllCells.NREMphstL.r(IAll,ii),...
%         AllJitter.NREMH(IAll,ii)-AllJitter.NREML(IAll,ii),'tail','right')*BonCorrection;
%     pvalues.I.REM(ii) = signrank(AllCells.REMphst.r(IAll,ii),AllJitter.REM(IAll,ii),'tail','right')*BonCorrection;
%     pvalues.I.REML(ii) = signrank(AllCells.REMphstL.r(IAll,ii),AllJitter.REML(IAll,ii),'tail','right')*BonCorrection;
%     pvalues.I.REMH(ii) = signrank(AllCells.REMphstH.r(IAll,ii),AllJitter.REMH(IAll,ii),'tail','right')*BonCorrection;
%     pvalues.I.REMHmL(ii) = signrank(AllCells.REMphstH.r(IAll,ii)-AllCells.REMphstL.r(IAll,ii),...
%         AllJitter.REMH(IAll,ii)-AllJitter.REML(IAll,ii),'tail','right')*BonCorrection;
%     pvalues.I.MA(ii) = signrank(AllCells.MAphst.r(IAll,ii),AllJitter.MA(IAll,ii),'tail','right')*BonCorrection;
%     pvalues.I.MAL(ii) = signrank(AllCells.MAphstL.r(IAll,ii),AllJitter.MAL(IAll,ii),'tail','right')*BonCorrection;
%     pvalues.I.MAH(ii) = signrank(AllCells.MAphstH.r(IAll,ii),AllJitter.MAH(IAll,ii),'tail','right')*BonCorrection;
%     pvalues.I.MAHmL(ii) = signrank(AllCells.MAphstH.r(IAll,ii)-AllCells.MAphstL.r(IAll,ii),...
%         AllJitter.MAH(IAll,ii)-AllJitter.MAL(IAll,ii),'tail','right')*BonCorrection;
%     
    
    
%     pvalues.EvI.all(ii) = ranksum(AllCells.phst.r(EAll,ii),AllCells.phst.r(IAll,ii))*BonCorrection;
%     pvalues.EvI.L(ii) = ranksum(AllCells.phstL.r(EAll,ii),AllCells.phstL.r(IAll,ii))*BonCorrection;
%     pvalues.EvI.H(ii) = ranksum(AllCells.phstH.r(EAll,ii),AllCells.phstH.r(IAll,ii))*BonCorrection;
%     pvalues.EvI.HmL(ii) = ranksum(AllCells.phstH.r(EAll,ii)-AllCells.phstL.r(EAll,ii),...
%         AllCells.phstH.r(IAll,ii)-AllCells.phstL.r(IAll,ii))*BonCorrection;
%     pvalues.EvI.WAKE(ii) = ranksum(AllCells.WAKEphst.r(EAll,ii),AllCells.WAKEphst.r(IAll,ii))*BonCorrection;
%     pvalues.EvI.WAKEL(ii) = ranksum(AllCells.WAKEphstL.r(EAll,ii),AllCells.WAKEphstL.r(IAll,ii))*BonCorrection;
%     pvalues.EvI.WAKEH(ii) = ranksum(AllCells.WAKEphstH.r(EAll,ii),AllCells.WAKEphstH.r(IAll,ii))*BonCorrection;
%     pvalues.EvI.WAKEHmL(ii) = ranksum(AllCells.WAKEphstH.r(EAll,ii)-AllCells.WAKEphstL.r(EAll,ii),...
%         AllCells.WAKEphstH.r(IAll,ii)-AllCells.WAKEphstL.r(IAll,ii))*BonCorrection;
%     pvalues.EvI.NREM(ii) = ranksum(AllCells.NREMphst.r(EAll,ii),AllCells.NREMphst.r(IAll,ii))*BonCorrection;
%     pvalues.EvI.NREML(ii) = ranksum(AllCells.NREMphstL.r(EAll,ii),AllCells.NREMphstL.r(IAll,ii))*BonCorrection;
%     pvalues.EvI.NREMH(ii) = ranksum(AllCells.NREMphstH.r(EAll,ii),AllCells.NREMphstH.r(IAll,ii))*BonCorrection;
%     pvalues.EvI.NREMHmL(ii) = ranksum(AllCells.NREMphstH.r(EAll,ii)-AllCells.NREMphstL.r(EAll,ii),...
%         AllCells.NREMphstH.r(IAll,ii)-AllCells.NREMphstL.r(IAll,ii))*BonCorrection;
%     pvalues.EvI.REM(ii) = ranksum(AllCells.REMphst.r(EAll,ii),AllCells.REMphst.r(IAll,ii))*BonCorrection;
%     pvalues.EvI.REML(ii) = ranksum(AllCells.REMphstL.r(EAll,ii),AllCells.REMphstL.r(IAll,ii))*BonCorrection;
%     pvalues.EvI.REMH(ii) = ranksum(AllCells.REMphstH.r(EAll,ii),AllCells.REMphstH.r(IAll,ii))*BonCorrection;
%     pvalues.EvI.REMHmL(ii) = ranksum(AllCells.REMphstH.r(EAll,ii)-AllCells.REMphstL.r(EAll,ii),...
%         AllCells.REMphstH.r(IAll,ii)-AllCells.REMphstL.r(IAll,ii))*BonCorrection;
%     pvalues.EvI.MA(ii) = ranksum(AllCells.MAphst.r(EAll,ii),AllCells.MAphst.r(IAll,ii))*BonCorrection;
%     pvalues.EvI.MAL(ii) = ranksum(AllCells.MAphstL.r(EAll,ii),AllCells.MAphstL.r(IAll,ii))*BonCorrection;
%     pvalues.EvI.MAH(ii) = ranksum(AllCells.MAphstH.r(EAll,ii),AllCells.MAphstH.r(IAll,ii))*BonCorrection;
%     pvalues.EvI.MAHmL(ii) = ranksum(AllCells.MAphstH.r(EAll,ii)-AllCells.MAphstL.r(EAll,ii),...
%         AllCells.MAphstH.r(IAll,ii)-AllCells.MAphstL.r(IAll,ii))*BonCorrection;



    pvalues.EvI.all(ii) = ranksum(AllCells.phst.r(EAll,ii)-AllJitter.all(EAll,ii),AllCells.phst.r(IAll,ii)-AllJitter.all(IAll,ii))*BonCorrection;
    pvalues.EvI.L(ii) = ranksum(AllCells.phstL.r(EAll,ii)-AllJitter.L(EAll,ii),AllCells.phstL.r(IAll,ii)-AllJitter.L(IAll,ii))*BonCorrection;
    pvalues.EvI.H(ii) = ranksum(AllCells.phstH.r(EAll,ii)-AllJitter.H(EAll,ii),AllCells.phstH.r(IAll,ii)-AllJitter.H(IAll,ii))*BonCorrection;
    pvalues.EvI.HmL(ii) = ranksum(AllCells.phstH.r(EAll,ii)-AllCells.phstL.r(EAll,ii)-(AllJitter.H(EAll,ii)-AllJitter.L(EAll,ii)),...
        AllCells.phstH.r(IAll,ii)-AllCells.phstL.r(IAll,ii)-(AllJitter.H(IAll,ii)-AllJitter.L(IAll,ii)))*BonCorrection;
    pvalues.EvI.WAKE(ii) = ranksum(AllCells.WAKEphst.r(EAll,ii)-AllJitter.WAKE(EAll,ii),AllCells.WAKEphst.r(IAll,ii)-AllJitter.WAKE(IAll,ii))*BonCorrection;
    pvalues.EvI.WAKEL(ii) = ranksum(AllCells.WAKEphstL.r(EAll,ii)-AllJitter.WAKEL(EAll,ii),AllCells.WAKEphstL.r(IAll,ii)-AllJitter.WAKEL(IAll,ii))*BonCorrection;
    pvalues.EvI.WAKEH(ii) = ranksum(AllCells.WAKEphstH.r(EAll,ii)-AllJitter.WAKEH(EAll,ii),AllCells.WAKEphstH.r(IAll,ii)-AllJitter.WAKEH(IAll,ii))*BonCorrection;
    pvalues.EvI.WAKEHmL(ii) = ranksum(AllCells.WAKEphstH.r(EAll,ii)-AllCells.WAKEphstL.r(EAll,ii)-(AllJitter.WAKEH(EAll,ii)-AllJitter.WAKEL(EAll,ii)),...
        AllCells.WAKEphstH.r(IAll,ii)-AllCells.WAKEphstL.r(IAll,ii)-(AllJitter.WAKEH(IAll,ii)-AllJitter.WAKEL(IAll,ii)))*BonCorrection;
    pvalues.EvI.NREM(ii) = ranksum(AllCells.NREMphst.r(EAll,ii)-AllJitter.NREM(EAll,ii),AllCells.NREMphst.r(IAll,ii)-AllJitter.NREM(IAll,ii))*BonCorrection;
    pvalues.EvI.NREML(ii) = ranksum(AllCells.NREMphstL.r(EAll,ii)-AllJitter.NREML(EAll,ii),AllCells.NREMphstL.r(IAll,ii)-AllJitter.NREML(IAll,ii))*BonCorrection;
    pvalues.EvI.NREMH(ii) = ranksum(AllCells.NREMphstH.r(EAll,ii)-AllJitter.NREMH(EAll,ii),AllCells.NREMphstH.r(IAll,ii)-AllJitter.NREMH(IAll,ii))*BonCorrection;
    pvalues.EvI.NREMHmL(ii) = ranksum(AllCells.NREMphstH.r(EAll,ii)-AllCells.NREMphstL.r(EAll,ii)-(AllJitter.NREMH(EAll,ii)-AllJitter.NREML(EAll,ii)),...
        AllCells.NREMphstH.r(IAll,ii)-AllCells.NREMphstL.r(IAll,ii)-(AllJitter.NREMH(IAll,ii)-AllJitter.NREML(IAll,ii)))*BonCorrection;
    pvalues.EvI.REM(ii) = ranksum(AllCells.REMphst.r(EAll,ii)-AllJitter.REM(EAll,ii),AllCells.REMphst.r(IAll,ii)-AllJitter.REM(IAll,ii))*BonCorrection;
    pvalues.EvI.REML(ii) = ranksum(AllCells.REMphstL.r(EAll,ii)-AllJitter.REML(EAll,ii),AllCells.REMphstL.r(IAll,ii)-AllJitter.REML(IAll,ii))*BonCorrection;
    pvalues.EvI.REMH(ii) = ranksum(AllCells.REMphstH.r(EAll,ii)-AllJitter.REMH(EAll,ii),AllCells.REMphstH.r(IAll,ii)-AllJitter.REMH(IAll,ii))*BonCorrection;
    pvalues.EvI.REMHmL(ii) = ranksum(AllCells.REMphstH.r(EAll,ii)-AllCells.REMphstL.r(EAll,ii)-(AllJitter.REMH(EAll,ii)-AllJitter.REML(EAll,ii)),...
        AllCells.REMphstH.r(IAll,ii)-AllCells.REMphstL.r(IAll,ii)-(AllJitter.REMH(IAll,ii)-AllJitter.REML(IAll,ii)))*BonCorrection;
    pvalues.EvI.MA(ii) = ranksum(AllCells.MAphst.r(EAll,ii)-AllJitter.MA(EAll,ii),AllCells.MAphst.r(IAll,ii)-AllJitter.MA(IAll,ii))*BonCorrection;
    pvalues.EvI.MAL(ii) = ranksum(AllCells.MAphstL.r(EAll,ii)-AllJitter.MAL(EAll,ii),AllCells.MAphstL.r(IAll,ii)-AllJitter.MAL(IAll,ii))*BonCorrection;
    pvalues.EvI.MAH(ii) = ranksum(AllCells.MAphstH.r(EAll,ii)-AllJitter.MAH(EAll,ii),AllCells.MAphstH.r(IAll,ii)-AllJitter.MAH(IAll,ii))*BonCorrection;
    pvalues.EvI.MAHmL(ii) = ranksum(AllCells.MAphstH.r(EAll,ii)-AllCells.MAphstL.r(EAll,ii)-(AllJitter.MAH(EAll,ii)-AllJitter.MAL(EAll,ii)),...
        AllCells.MAphstH.r(IAll,ii)-AllCells.MAphstL.r(IAll,ii)-(AllJitter.MAH(IAll,ii)-AllJitter.MAL(IAll,ii)))*BonCorrection;

    %     [~,pvalues.E.all(ii)] = ttest(AllCells.phst.r(EAll,ii),AllJitter.all(EAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.E.L(ii)] = ttest(AllCells.phstL.r(EAll,ii),AllJitter.L(EAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.E.H(ii)] = ttest(AllCells.phstH.r(EAll,ii),AllJitter.H(EAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.E.HmL(ii)] = ttest(AllCells.phstH.r(EAll,ii)-AllCells.phstL.r(EAll,ii),...
    %         AllJitter.H(EAll,ii)-AllJitter.L(EAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.E.WAKE(ii)] = ttest(AllCells.WAKEphst.r(EAll,ii),AllJitter.WAKE(EAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.E.WAKEL(ii)] = ttest(AllCells.WAKEphstL.r(EAll,ii),AllJitter.WAKEL(EAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.E.WAKEH(ii)] = ttest(AllCells.WAKEphstH.r(EAll,ii),AllJitter.WAKEH(EAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.E.WAKEHmL(ii)] = ttest(AllCells.WAKEphstH.r(EAll,ii)-AllCells.WAKEphstL.r(EAll,ii),...
    %         AllJitter.WAKEH(EAll,ii)-AllJitter.WAKEL(EAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.E.NREM(ii)] = ttest(AllCells.NREMphst.r(EAll,ii),AllJitter.NREM(EAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.E.NREML(ii)] = ttest(AllCells.NREMphstL.r(EAll,ii),AllJitter.NREML(EAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.E.NREMH(ii)] = ttest(AllCells.NREMphstH.r(EAll,ii),AllJitter.NREMH(EAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.E.NREMHmL(ii)] = ttest(AllCells.NREMphstH.r(EAll,ii)-AllCells.NREMphstL.r(EAll,ii),...
    %         AllJitter.NREMH(EAll,ii)-AllJitter.NREML(EAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.E.REM(ii)] = ttest(AllCells.REMphst.r(EAll,ii),AllJitter.REM(EAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.E.REML(ii)] = ttest(AllCells.REMphstL.r(EAll,ii),AllJitter.REML(EAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.E.REMH(ii)] = ttest(AllCells.REMphstH.r(EAll,ii),AllJitter.REMH(EAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.E.REMHmL(ii)] = ttest(AllCells.REMphstH.r(EAll,ii)-AllCells.REMphstL.r(EAll,ii),...
    %         AllJitter.REMH(EAll,ii)-AllJitter.REML(EAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.E.MA(ii)] = ttest(AllCells.MAphst.r(EAll,ii),AllJitter.MA(EAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.E.MAL(ii)] = ttest(AllCells.MAphstL.r(EAll,ii),AllJitter.MAL(EAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.E.MAH(ii)] = ttest(AllCells.MAphstH.r(EAll,ii),AllJitter.MAH(EAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.E.MAHmL(ii)] = ttest(AllCells.MAphstH.r(EAll,ii)-AllCells.MAphstL.r(EAll,ii),...
    %         AllJitter.MAH(EAll,ii)-AllJitter.MAL(EAll,ii),'tail','right')*BonCorrection;
    %
    %     [~,pvalues.I.all(ii)] = ttest(AllCells.phst.r(IAll,ii),AllJitter.all(IAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.I.L(ii)] = ttest(AllCells.phstL.r(IAll,ii),AllJitter.L(IAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.I.H(ii)] = ttest(AllCells.phstH.r(IAll,ii),AllJitter.H(IAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.I.HmL(ii)] = ttest(AllCells.phstH.r(IAll,ii)-AllCells.phstL.r(IAll,ii),...
    %         AllJitter.H(IAll,ii)-AllJitter.L(IAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.I.WAKE(ii)] = ttest(AllCells.WAKEphst.r(IAll,ii),AllJitter.WAKE(IAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.I.WAKEL(ii)] = ttest(AllCells.WAKEphstL.r(IAll,ii),AllJitter.WAKEL(IAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.I.WAKEH(ii)] = ttest(AllCells.WAKEphstH.r(IAll,ii),AllJitter.WAKEH(IAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.I.WAKEHmL(ii)] = ttest(AllCells.WAKEphstH.r(IAll,ii)-AllCells.WAKEphstL.r(IAll,ii),...
    %         AllJitter.WAKEH(IAll,ii)-AllJitter.WAKEL(IAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.I.NREM(ii)] = ttest(AllCells.NREMphst.r(IAll,ii),AllJitter.NREM(IAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.I.NREML(ii)] = ttest(AllCells.NREMphstL.r(IAll,ii),AllJitter.NREML(IAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.I.NREMH(ii)] = ttest(AllCells.NREMphstH.r(IAll,ii),AllJitter.NREMH(IAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.I.NREMHmL(ii)] = ttest(AllCells.NREMphstH.r(IAll,ii)-AllCells.NREMphstL.r(IAll,ii),...
    %         AllJitter.NREMH(IAll,ii)-AllJitter.NREML(IAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.I.REM(ii)] = ttest(AllCells.REMphst.r(IAll,ii),AllJitter.REM(IAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.I.REML(ii)] = ttest(AllCells.REMphstL.r(IAll,ii),AllJitter.REML(IAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.I.REMH(ii)] = ttest(AllCells.REMphstH.r(IAll,ii),AllJitter.REMH(IAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.I.REMHmL(ii)] = ttest(AllCells.REMphstH.r(IAll,ii)-AllCells.REMphstL.r(IAll,ii),...
    %         AllJitter.REMH(IAll,ii)-AllJitter.REML(IAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.I.MA(ii)] = ttest(AllCells.MAphst.r(IAll,ii),AllJitter.MA(IAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.I.MAL(ii)] = ttest(AllCells.MAphstL.r(IAll,ii),AllJitter.MAL(IAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.I.MAH(ii)] = ttest(AllCells.MAphstH.r(IAll,ii),AllJitter.MAH(IAll,ii),'tail','right')*BonCorrection;
    %     [~,pvalues.I.MAHmL(ii)] = ttest(AllCells.MAphstH.r(IAll,ii)-AllCells.MAphstL.r(IAll,ii),...
    %         AllJitter.MAH(IAll,ii)-AllJitter.MAL(IAll,ii),'tail','right')*BonCorrection;
end
%% Plot
PlotMRLSummary(freqlist,AllCells,AllJitter,0.5,AllCellIDs,pvalues,1);
PlotMRLSummary(freqlist,AllCells,AllJitter,0.5,AllCellIDs,pvalues,0);
%%
PlotMRLSummary(freqlist,logAllCells,logAllJitter,0.5,AllCellIDs,pvalues,1);
PlotMRLSummary(freqlist,logAllCells,logAllJitter,0.5,AllCellIDs,pvalues,0);
% PlotMRLSummary_HighPower(freqlist,logAllCells,logAllJitter,0.5,AllCellIDs,pvalues,1);
% PlotMRLSummary_HighPower(freqlist,logAllCells,logAllJitter,0.5,AllCellIDs,pvalues,0);
% figure;
% for kk = 1:length(freqlist)
%     subplot(10,8,kk);
%     hist(log(AllCells.phst.r(SpikeNum>10,kk)),20);
%     title(freqlist(kk));
%     %     xlim([0 0.6]);
% end
% figure;
% for kk = 1:length(freqlist)
%     subplot(10,8,kk);
%     hist(log(AllJitter.all(SpikeNum>10,kk)),20);
%     title(freqlist(kk));
%     %     xlim([0 0.6]);
% end


%% mean angle analysis of phase modulated cells by broad band gamma
alpha = 0.01;
numJitter = 200;
ModCellFreqIdx = false(size(AllCells.phst.r,1),length(freqlist));
ShuffleCutoff = round((1-alpha)*numJitter);
for ii = 1:size(AllCells.phst.r,1)
    for jj = 1:length(freqlist) % freqlist idx, corresponding to 51-181 Hz
        sortedJitter(ii,jj,:) = sort(AllRawJitter.all(ii,jj,:));
        ModCellFreqIdx(ii,jj) = AllCells.phst.r(ii,jj) > sortedJitter(ii,jj,ShuffleCutoff);
    end
end
%% only look at broad band gamma
ModCellIdx = sum(ModCellFreqIdx(:,36:58),2)>2;
[~,FreqIdx] = max(AllCells.phst.r(:,36:58),[],2);
FreqIdx = round(FreqIdx+35);
EIdx = false(size(AllCells.phst.r,1),1);
EIdx(EAll) = true;
IIdx = false(size(AllCells.phst.r,1),1);
IIdx(IAll) = true;
for ii = 1:size(AllCells.phst.r,1)
    ModAngle(ii) = AllCells.phst.m(ii,FreqIdx(ii));
end
EModAngle = ModAngle(ModCellIdx & EIdx);
IModAngle = ModAngle(ModCellIdx & IIdx);

%% all frequencies considered, only cells have most modulation at gamma
AllModCellIdx = sum(ModCellFreqIdx,2)>2;
[~,AllFreqIdx] = max(AllCells.phst.r,[],2);
for ii = 1:size(AllCells.phst.r,1)
    AllModAngle(ii) = AllCells.phst.m(ii,AllFreqIdx(ii));
end
EModAngle_gammaonly = AllModAngle(ModCellIdx & EIdx & AllFreqIdx>35 & AllFreqIdx<59);
IModAngle_gammaonly = AllModAngle(ModCellIdx & IIdx & AllFreqIdx>35 & AllFreqIdx<59);
figure; 
Egammarose = rose(EModAngle_gammaonly,30);
set(Egammarose,'Color','g');
hold on; 
Igammarose = rose(repmat(IModAngle_gammaonly,1,6),30);
set(Igammarose,'Color','r');

%% cells have a peak at gamma band
GammaFreqIdx = nan(size(AllCells.phst.r,1),1);
GammaModAngle = nan(size(AllCells.phst.r,1),1);
for ii = 1:size(AllCells.phst.r,1)
    gammapeaks{ii} = findpeaks_MD(AllCells.phst.r(ii,33:61))+32;
    if ~isempty(gammapeaks{ii}) && ~isempty(find(ModCellFreqIdx(ii,gammapeaks{ii})==1,1))
%         GammaModCellIdx(ii) = sum(ModCellFreqIdx(ii,gammapeaks{ii}))>0;
        [~,gammapeaksIdx] = max(AllCells.phst.r(ii,gammapeaks{ii}));
        GammaFreqIdx(ii) = gammapeaks{ii}(gammapeaksIdx);
        GammaModAngle(ii) = AllCells.phst.m(ii,GammaFreqIdx(ii));
    end
end
%%
figure;
Egammarose = rose(GammaModAngle(EIdx),30);
set(Egammarose,'Color','g');
hold on; 
Igammarose = rose(repmat(GammaModAngle(IIdx),6,1),30);
set(Igammarose,'Color','r');
EMean = CircularMean(GammaModAngle(EIdx & ~isnan(GammaModAngle)));
IMean = CircularMean(GammaModAngle(IIdx & ~isnan(GammaModAngle)));
legend({'E Cells';'I Cells'});
EMean = EMean/pi*180;
IMean = IMean/pi*180;
xlabel({['Mean angle: E: ' num2str(EMean)],['I:' num2str(IMean)]});
%%
figure;fig = gcf;
fig.Position = [1 1 350 920];
ax(1) = subplot(3,1,1);
Egammarose = rose(GammaModAngle(EIdx & GammaFreqIdx<43),30);
set(Egammarose,'Color','g');
hold on; 
Igammarose = rose(repmat(GammaModAngle(IIdx & GammaFreqIdx<43),5,1),30);
set(Igammarose,'Color','r');
EMeanBinned(1) = CircularMean(GammaModAngle(EIdx & ~isnan(GammaModAngle) & GammaFreqIdx<43));
IMeanBinned(1) = CircularMean(GammaModAngle(IIdx & ~isnan(GammaModAngle) & GammaFreqIdx<43));
title('45-75 Hz');
% y = ylim;x=xlim;
% text(mean(x),y(1),['E: ' num2str(EMeanBinned(1)/pi*180)],'Color','g');
% text(mean(x),y(1)-10,['I: ' num2str(IMeanBinned(1)/pi*180)],'Color','r');

ax(2) = subplot(3,1,2);
Egammarose = rose(GammaModAngle(EIdx & GammaFreqIdx>42 & GammaFreqIdx<52),30);
set(Egammarose,'Color','g');
hold on; 
Igammarose = rose(repmat(GammaModAngle(IIdx & GammaFreqIdx>42 & GammaFreqIdx<52),5,1),30);
set(Igammarose,'Color','r');
EMeanBinned(2) = CircularMean(GammaModAngle(EIdx & ~isnan(GammaModAngle) & GammaFreqIdx>42 & GammaFreqIdx<52));
IMeanBinned(2) = CircularMean(GammaModAngle(IIdx & ~isnan(GammaModAngle) & GammaFreqIdx>42 & GammaFreqIdx<52));
title('75-125 Hz');
% y = ylim;x=xlim;
% text(mean(x),y(1),['E: ' num2str(EMeanBinned(2)/pi*180)],'Color','g');
% text(mean(x),y(1)-10,['I: ' num2str(IMeanBinned(2)/pi*180)],'Color','r');

ax(3) = subplot(3,1,3);
Egammarose = rose(GammaModAngle(EIdx & GammaFreqIdx>51),30);
set(Egammarose,'Color','g');
hold on; 
Igammarose = rose(repmat(GammaModAngle(IIdx & GammaFreqIdx>51),5,1),30);
set(Igammarose,'Color','r');
EMeanBinned(3) = CircularMean(GammaModAngle(EIdx & ~isnan(GammaModAngle) & GammaFreqIdx>51));
IMeanBinned(3) = CircularMean(GammaModAngle(IIdx & ~isnan(GammaModAngle) & GammaFreqIdx>51));
title('125-200 Hz')
% y = ylim;x=xlim;
legend({'E Cells';'I Cells'});
% text(mean(x),y(1),['E: ' num2str(EMeanBinned(3)/pi*180)],'Color','g');
% text(mean(x),y(1)-10,['I: ' num2str(IMeanBinned(3)/pi*180)],'Color','r');

EMeanBinned = EMeanBinned/pi*180;
IMeanBinned = IMeanBinned/pi*180;
for ii = 1:3
    xlabel(ax(ii),{['E: ' num2str(EMeanBinned(ii))],['I: ' num2str(IMeanBinned(ii))]});
%     text(ax(ii),-15,-46,['I: ' IMeanBinned(ii)],'Color','r');
end

%% all modulated cells include for 3 bands plot
for ii = 1:3
    [~,GammaFreqIdx3_temp] = max(AllCells.phst.r(:,(9*ii+25):(9*ii+33)),[],2);
    GammaFreqIdx3(:,ii) = GammaFreqIdx3_temp+9*ii+24;
    for jj = 1:size(AllCells.phst.r,1)
        GammaModAngle3(jj,ii) = AllCells.phst.m(jj,GammaFreqIdx3(jj,ii));
    end
end
%%
figure;fig = gcf;
fig.Position = [1 1 350 920];
ax(1) = subplot(3,1,1);
Egammarose = rose(GammaModAngle3(EIdx & ModCellIdx,1),30);
set(Egammarose,'Color','g');
hold on; 
Igammarose = rose(repmat(GammaModAngle3(IIdx & ModCellIdx,1),5,1),30);
set(Igammarose,'Color','r');
EMeanBinned3(1) = CircularMean(GammaModAngle3(EIdx & ModCellIdx,1));
IMeanBinned3(1) = CircularMean(GammaModAngle3(IIdx & ModCellIdx,1));
title('45-75 Hz');

ax(2) = subplot(3,1,2);
Egammarose = rose(GammaModAngle3(EIdx & ModCellIdx,2),30);
set(Egammarose,'Color','g');
hold on; 
Igammarose = rose(repmat(GammaModAngle3(IIdx & ModCellIdx,2),5,1),30);
set(Igammarose,'Color','r');
EMeanBinned3(2) = CircularMean(GammaModAngle3(EIdx & ModCellIdx,2));
IMeanBinned3(2) = CircularMean(GammaModAngle3(IIdx & ModCellIdx,2));
title('75-125 Hz');
% y = ylim;x=xlim;
% text(mean(x),y(1),['E: ' num2str(EMeanBinned(2)/pi*180)],'Color','g');
% text(mean(x),y(1)-10,['I: ' num2str(IMeanBinned(2)/pi*180)],'Color','r');

ax(3) = subplot(3,1,3);
Egammarose = rose(GammaModAngle3(EIdx & ModCellIdx,3),30);
set(Egammarose,'Color','g');
hold on; 
Igammarose = rose(repmat(GammaModAngle3(IIdx & ModCellIdx,3),5,1),30);
set(Igammarose,'Color','r');
EMeanBinned3(3) = CircularMean(GammaModAngle3(EIdx & ModCellIdx,3));
IMeanBinned3(3) = CircularMean(GammaModAngle3(IIdx & ModCellIdx,3));
title('125-200 Hz')
% y = ylim;x=xlim;
legend({'E Cells';'I Cells'});
% text(mean(x),y(1),['E: ' num2str(EMeanBinned(3)/pi*180)],'Color','g');
% text(mean(x),y(1)-10,['I: ' num2str(IMeanBinned(3)/pi*180)],'Color','r');

EMeanBinned3 = EMeanBinned3/pi*180;
IMeanBinned3 = IMeanBinned3/pi*180;
for ii = 1:3
    xlabel(ax(ii),{['E: ' num2str(EMeanBinned3(ii))],['I: ' num2str(IMeanBinned3(ii))]});
%     text(ax(ii),-15,-46,['I: ' IMeanBinned(ii)],'Color','r');
end
end