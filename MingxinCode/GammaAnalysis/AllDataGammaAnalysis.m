function AllDataGammaAnalysis
% folders = struct([]);
% foldersall = dir;
% for ii = 3:length(foldersall)
%     if foldersall(ii).isdir
%         folders(end+1) = foldersall(ii);
%     end
% end
folders = dir;
passband = [1 625];
nvoice = 12;
% SamplingRate = 1250;
%%
% for ii = 1:length(folders) % [23 33:35];
for ii = [52 51 22]; % 22 41 need running
    % for ii = [1:15,17,19:27] % smaller recordings
    basepath = folders(ii).name;
    [~,basename] = fileparts(basepath);
    if exist(fullfile(basepath,[basename '_IsolatedNeighborZScoreIntervals.mat']),'file')
        if ~exist(fullfile(basepath,[basename '_JitterPhasestatsIsolatedBand.mat']),'file');
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
SpikeNum.H = [];
SpikeNum.WAKEH = [];
SpikeNum.NREMH = [];
SpikeNum.REMH = [];
SpikeNum.MAH = [];

for ii = 1:length(folders)
    basepath = folders(ii).name;
    [~,basename] = fileparts(basepath);
    if exist(fullfile(basepath,[basename '_JitterPhasestatsIsolatedBand.mat']),'file')
        display(basename);
        load(fullfile(basepath,[basename '_PhasestatsIsolatedBand.mat']),'phasestats','spkNum');
        load(fullfile(basepath,[basename '_JitterPhasestatsIsolatedBand.mat']),'jitmeanMRL');
        %         load(fullfile(basepath,[basename '_PhasestatsByPowerAndState.mat']),'PhstPS');
        %         load(fullfile(basepath,[basename '_JitterMRL.mat']),'jitmeanMRL');
        load(fullfile(basepath,[basename '_CellIDs.mat']),'CellIDs');
        %         load(fullfile(basepath,[basename '_SStable.mat']),'S');
        %         load(fullfile(basepath,[basename '_NeighborZScoreIntervals.mat']),'AboveInt_ZCombined');
        %         for jj = 1:length(S)
        %             SpikeNum(end+1) = length(S{jj});
        %         end
        %         AllCells.phst.r = cat(1,AllCells.phst.r,PhstPS.phst.r);
        %         AllCells.phstL.r = cat(1,AllCells.phstL.r,PhstPS.phstL.r);
        % AllCells.phstH.r = cat(1,AllCells.phstH.r,PhstPS.phstH.r);
        AllCells.phstH.r = cat(1,AllCells.phstH.r,phasestats.phstH.r);
        %         AllCells.WAKEphst.r = cat(1,AllCells.WAKEphst.r,PhstPS.WAKEphst.r);
        %         AllCells.WAKEphstL.r = cat(1,AllCells.WAKEphstL.r,PhstPS.WAKEphstL.r);
        % AllCells.WAKEphstH.r = cat(1,AllCells.WAKEphstH.r,PhstPS.WAKEphstH.r);
        AllCells.WAKEphstH.r = cat(1,AllCells.WAKEphstH.r,phasestats.WAKEphstH.r);
        %         AllCells.NREMphst.r = cat(1,AllCells.NREMphst.r,PhstPS.NREMphst.r);
        %         AllCells.NREMphstL.r = cat(1,AllCells.NREMphstL.r,PhstPS.NREMphstL.r);
        % AllCells.NREMphstH.r = cat(1,AllCells.NREMphstH.r,PhstPS.NREMphstH.r);
        AllCells.NREMphstH.r = cat(1,AllCells.NREMphstH.r,phasestats.NREMphstH.r);
        %         AllCells.REMphst.r = cat(1,AllCells.REMphst.r,PhstPS.REMphst.r);
        %         AllCells.REMphstL.r = cat(1,AllCells.REMphstL.r,PhstPS.REMphstL.r);
        % AllCells.REMphstH.r = cat(1,AllCells.REMphstH.r,PhstPS.REMphstH.r);
        AllCells.REMphstH.r = cat(1,AllCells.REMphstH.r,phasestats.REMphstH.r);
        %         AllCells.MAphst.r = cat(1,AllCells.MAphst.r,PhstPS.MAphst.r);
        %         AllCells.MAphstL.r = cat(1,AllCells.MAphstL.r,PhstPS.MAphstL.r);
        % AllCells.MAphstH.r = cat(1,AllCells.MAphstH.r,PhstPS.MAphstH.r);
        AllCells.MAphstH.r = cat(1,AllCells.MAphstH.r,phasestats.MAphstH.r);
        
        %         AllJitter.all = cat(1,AllJitter.all,jitmeanMRL.all);
        AllJitter.H = cat(1,AllJitter.H,jitmeanMRL.H);
        %         AllJitter.L = cat(1,AllJitter.L,jitmeanMRL.L);
        %         AllJitter.WAKE = cat(1,AllJitter.WAKE,jitmeanMRL.WAKE);
        AllJitter.WAKEH = cat(1,AllJitter.WAKEH,jitmeanMRL.WAKEH);
        %         AllJitter.WAKEL = cat(1,AllJitter.WAKEL,jitmeanMRL.WAKEL);
        %         AllJitter.NREM = cat(1,AllJitter.NREM,jitmeanMRL.NREM);
        AllJitter.NREMH = cat(1,AllJitter.NREMH,jitmeanMRL.NREMH);
        %         AllJitter.NREML = cat(1,AllJitter.NREML,jitmeanMRL.NREML);
        %         AllJitter.REM = cat(1,AllJitter.REM,jitmeanMRL.REM);
        AllJitter.REMH = cat(1,AllJitter.REMH,jitmeanMRL.REMH);
        %         AllJitter.REML = cat(1,AllJitter.REML,jitmeanMRL.REML);
        %         AllJitter.MA = cat(1,AllJitter.MA,jitmeanMRL.MA);
        AllJitter.MAH = cat(1,AllJitter.MAH,jitmeanMRL.MAH);
        %         AllJitter.MAL = cat(1,AllJitter.MAL,jitmeanMRL.MAL);
        
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
        %
        SpikeNum.H = cat(1,SpikeNum.H,spkNum.H);
        SpikeNum.WAKEH = cat(1,SpikeNum.WAKEH,spkNum.WAKEH);
        SpikeNum.NREMH = cat(1,SpikeNum.NREMH,spkNum.NREMH);
        SpikeNum.REMH = cat(1,SpikeNum.REMH,spkNum.REMH);
        SpikeNum.MAH = cat(1,SpikeNum.MAH,spkNum.MAH);
        NewE = reshape(CellIDs.EAll+length(EAll)+length(IAll),[],1);
        NewI = reshape(CellIDs.IAll+length(EAll)+length(IAll),[],1);
        EAll = cat(1,EAll,NewE);
        IAll = cat(1,IAll,NewI);
    end
end
%% old intervals without isolating bands
SamplingRate = 1250;
SpikeNum_old = [];
for ii = 1:length(folders)
    basepath = folders(ii).name;
    [~,basename] = fileparts(basepath);
    if exist(fullfile(basepath,[basename '_JitterPhasestatsIsolatedBand.mat']),'file')
        load(fullfile(basepath,[basename '_SStable.mat']),'S','shank');
        load(fullfile(basepath,[basename '_NeighborZScoreIntervals.mat']),'AboveInt_ZCombined');
        spikes = cellArray(S);
        for jj = 1:length(shank)
            cellneighborIdx(jj) = find(unique(shank)==shank(jj));
            spikes{jj} = Data(spikes{jj});
            for kk = 1:length(freqlist)
                if ~isempty(AboveInt_ZCombined{cellneighborIdx(jj),kk,2})
                    [status,~,~] = InIntervals(spikes{jj}*SamplingRate,AboveInt_ZCombined{cellneighborIdx(jj),kk});
                else
                    status = false(length(spikes{jj}),1);
                end
                spkNumIn(jj,kk) = sum(status);
            end
        end
        SpikeNum_old = cat(1,SpikeNum_old,spkNumIn);
    end
end

%%
EAll = setdiff(EAll,find(mean(SpikeNum.H,2)<10));
IAll = setdiff(IAll,find(mean(SpikeNum.H,2)<10));
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

BonCorrection = 5*2*length(freqlist);

for ii = 1:length(freqlist)
    
    %     pvalues.E.all(ii) = signrank(AllCells.phst.r(EAll,ii),AllJitter.all(EAll,ii),'tail','right')*BonCorrection;
    %     pvalues.E.L(ii) = signrank(AllCells.phstL.r(EAll,ii),AllJitter.L(EAll,ii),'tail','right')*BonCorrection;
    pvalues.E.H(ii) = signrank(AllCells.phstH.r(EAll,ii),AllJitter.H(EAll,ii),'tail','right')*BonCorrection;
    %     pvalues.E.HmL(ii) = signrank(AllCells.phstH.r(EAll,ii)-AllCells.phstL.r(EAll,ii),...
    %         AllJitter.H(EAll,ii)-AllJitter.L(EAll,ii),'tail','right')*BonCorrection;
    %     pvalues.E.WAKE(ii) = signrank(AllCells.WAKEphst.r(EAll,ii),AllJitter.WAKE(EAll,ii),'tail','right')*BonCorrection;
    %     pvalues.E.WAKEL(ii) = signrank(AllCells.WAKEphstL.r(EAll,ii),AllJitter.WAKEL(EAll,ii),'tail','right')*BonCorrection;
    pvalues.E.WAKEH(ii) = signrank(AllCells.WAKEphstH.r(EAll,ii),AllJitter.WAKEH(EAll,ii),'tail','right')*BonCorrection;
    %     pvalues.E.WAKEHmL(ii) = signrank(AllCells.WAKEphstH.r(EAll,ii)-AllCells.WAKEphstL.r(EAll,ii),...
    %         AllJitter.WAKEH(EAll,ii)-AllJitter.WAKEL(EAll,ii),'tail','right')*BonCorrection;
    %     pvalues.E.NREM(ii) = signrank(AllCells.NREMphst.r(EAll,ii),AllJitter.NREM(EAll,ii),'tail','right')*BonCorrection;
    %     pvalues.E.NREML(ii) = signrank(AllCells.NREMphstL.r(EAll,ii),AllJitter.NREML(EAll,ii),'tail','right')*BonCorrection;
    pvalues.E.NREMH(ii) = signrank(AllCells.NREMphstH.r(EAll,ii),AllJitter.NREMH(EAll,ii),'tail','right')*BonCorrection;
    %     pvalues.E.NREMHmL(ii) = signrank(AllCells.NREMphstH.r(EAll,ii)-AllCells.NREMphstL.r(EAll,ii),...
    %         AllJitter.NREMH(EAll,ii)-AllJitter.NREML(EAll,ii),'tail','right')*BonCorrection;
    %     pvalues.E.REM(ii) = signrank(AllCells.REMphst.r(EAll,ii),AllJitter.REM(EAll,ii),'tail','right')*BonCorrection;
    %     pvalues.E.REML(ii) = signrank(AllCells.REMphstL.r(EAll,ii),AllJitter.REML(EAll,ii),'tail','right')*BonCorrection;
    pvalues.E.REMH(ii) = signrank(AllCells.REMphstH.r(EAll,ii),AllJitter.REMH(EAll,ii),'tail','right')*BonCorrection;
    %     pvalues.E.REMHmL(ii) = signrank(AllCells.REMphstH.r(EAll,ii)-AllCells.REMphstL.r(EAll,ii),...
    %         AllJitter.REMH(EAll,ii)-AllJitter.REML(EAll,ii),'tail','right')*BonCorrection;
    %     pvalues.E.MA(ii) = signrank(AllCells.MAphst.r(EAll,ii),AllJitter.MA(EAll,ii),'tail','right')*BonCorrection;
    %     pvalues.E.MAL(ii) = signrank(AllCells.MAphstL.r(EAll,ii),AllJitter.MAL(EAll,ii),'tail','right')*BonCorrection;
    pvalues.E.MAH(ii) = signrank(AllCells.MAphstH.r(EAll,ii),AllJitter.MAH(EAll,ii),'tail','right')*BonCorrection;
    %     pvalues.E.MAHmL(ii) = signrank(AllCells.MAphstH.r(EAll,ii)-AllCells.MAphstL.r(EAll,ii),...
    %         AllJitter.MAH(EAll,ii)-AllJitter.MAL(EAll,ii),'tail','right')*BonCorrection;
    
    %     pvalues.I.all(ii) = signrank(AllCells.phst.r(IAll,ii),AllJitter.all(IAll,ii),'tail','right')*BonCorrection;
    %     pvalues.I.L(ii) = signrank(AllCells.phstL.r(IAll,ii),AllJitter.L(IAll,ii),'tail','right')*BonCorrection;
    pvalues.I.H(ii) = signrank(AllCells.phstH.r(IAll,ii),AllJitter.H(IAll,ii),'tail','right')*BonCorrection;
    %     pvalues.I.HmL(ii) = signrank(AllCells.phstH.r(IAll,ii)-AllCells.phstL.r(IAll,ii),...
    %         AllJitter.H(IAll,ii)-AllJitter.L(IAll,ii),'tail','right')*BonCorrection;
    %     pvalues.I.WAKE(ii) = signrank(AllCells.WAKEphst.r(IAll,ii),AllJitter.WAKE(IAll,ii),'tail','right')*BonCorrection;
    %     pvalues.I.WAKEL(ii) = signrank(AllCells.WAKEphstL.r(IAll,ii),AllJitter.WAKEL(IAll,ii),'tail','right')*BonCorrection;
    pvalues.I.WAKEH(ii) = signrank(AllCells.WAKEphstH.r(IAll,ii),AllJitter.WAKEH(IAll,ii),'tail','right')*BonCorrection;
    %     pvalues.I.WAKEHmL(ii) = signrank(AllCells.WAKEphstH.r(IAll,ii)-AllCells.WAKEphstL.r(IAll,ii),...
    %         AllJitter.WAKEH(IAll,ii)-AllJitter.WAKEL(IAll,ii),'tail','right')*BonCorrection;
    %     pvalues.I.NREM(ii) = signrank(AllCells.NREMphst.r(IAll,ii),AllJitter.NREM(IAll,ii),'tail','right')*BonCorrection;
    %     pvalues.I.NREML(ii) = signrank(AllCells.NREMphstL.r(IAll,ii),AllJitter.NREML(IAll,ii),'tail','right')*BonCorrection;
    pvalues.I.NREMH(ii) = signrank(AllCells.NREMphstH.r(IAll,ii),AllJitter.NREMH(IAll,ii),'tail','right')*BonCorrection;
    %     pvalues.I.NREMHmL(ii) = signrank(AllCells.NREMphstH.r(IAll,ii)-AllCells.NREMphstL.r(IAll,ii),...
    %         AllJitter.NREMH(IAll,ii)-AllJitter.NREML(IAll,ii),'tail','right')*BonCorrection;
    %     pvalues.I.REM(ii) = signrank(AllCells.REMphst.r(IAll,ii),AllJitter.REM(IAll,ii),'tail','right')*BonCorrection;
    %     pvalues.I.REML(ii) = signrank(AllCells.REMphstL.r(IAll,ii),AllJitter.REML(IAll,ii),'tail','right')*BonCorrection;
    pvalues.I.REMH(ii) = signrank(AllCells.REMphstH.r(IAll,ii),AllJitter.REMH(IAll,ii),'tail','right')*BonCorrection;
    %     pvalues.I.REMHmL(ii) = signrank(AllCells.REMphstH.r(IAll,ii)-AllCells.REMphstL.r(IAll,ii),...
    %         AllJitter.REMH(IAll,ii)-AllJitter.REML(IAll,ii),'tail','right')*BonCorrection;
    %     pvalues.I.MA(ii) = signrank(AllCells.MAphst.r(IAll,ii),AllJitter.MA(IAll,ii),'tail','right')*BonCorrection;
    %     pvalues.I.MAL(ii) = signrank(AllCells.MAphstL.r(IAll,ii),AllJitter.MAL(IAll,ii),'tail','right')*BonCorrection;
    pvalues.I.MAH(ii) = signrank(AllCells.MAphstH.r(IAll,ii),AllJitter.MAH(IAll,ii),'tail','right')*BonCorrection;
    %     pvalues.I.MAHmL(ii) = signrank(AllCells.MAphstH.r(IAll,ii)-AllCells.MAphstL.r(IAll,ii),...
    %         AllJitter.MAH(IAll,ii)-AllJitter.MAL(IAll,ii),'tail','right')*BonCorrection;
    
    
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
% PlotMRLSummary(freqlist,AllCells,AllJitter,0.5,AllCellIDs,pvalues,1);
% PlotMRLSummary(freqlist,AllCells,AllJitter,0.5,AllCellIDs,pvalues,0);
%%
% PlotMRLSummary(freqlist,logAllCells,logAllJitter,0.5,AllCellIDs,pvalues,1);
% PlotMRLSummary(freqlist,logAllCells,logAllJitter,0.5,AllCellIDs,pvalues,0);
% PlotMRLSummary_HighPower(freqlist,AllCells,AllJitter,0.5,AllCellIDs,pvalues,1);
% PlotMRLSummary_HighPower(freqlist,AllCells,AllJitter,0.5,AllCellIDs,pvalues,0);
PlotMRLSummary_HighPower(freqlist,logAllCells,logAllJitter,0.5,AllCellIDs,pvalues,1);
PlotMRLSummary_HighPower(freqlist,logAllCells,logAllJitter,0.5,AllCellIDs,pvalues,0);
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
end