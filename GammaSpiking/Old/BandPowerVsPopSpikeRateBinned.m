function BandPowerVsPopSpikeRateBinned(basepath,basename)
% Broadband gamma vs large chunks of populations of cells

%% Constants
numspikerategroups = 6;
% % gammabandstarts = [0:1:19 20:2:38 40:5:195]';
% % gammabandstops = [1:1:20 22:2:40 45:5:200]';
% % gammabandmeans = mean([gammabandstarts gammabandstops],2);
% % gammabands = cat(2,gammabandstarts,gammabandstops);
% bandmeans = unique(round(logspace(0,log10(650),50)));%1 to 650, log spaced except elim some repetitive values near 1-4Hz

% binwidthseclist = [5 10 20];
binwidthseclist = [0.01,0.02,0.05,0.1,0.2,0.5,1,2,5,10,20];
broadbandgammarange = [60 200];
plotbinwidth = 1;%bin width to do some example plots by default

%% Loading up
if ~exist('basepath','var')
    basepath = cd;
end
if ~exist('basename','var')
    [~,basename] = fileparts(basepath);
end


load(fullfile(basepath,[basename '_WaveletForGamma.mat']),'amp')
load(fullfile(basepath,[basename '_WaveletForGamma.mat']),'bandmeans')
load(fullfile(basepath,[basename '_SSubtypes.mat']))
if exist('Se_TsdArrayFormat','var')
    Se = Se_TsdArrayFormat;
    Si = Si_TsdArrayFormat;
end

% load(fullfile(basepath,[basename '_EIRatio.mat']))
if ~exist(fullfile(basepath,[basename '_StateRates.mat']),'file')
    StateRates(basepath,basename);
end
sr = load(fullfile(basepath,[basename '_StateRates.mat']));
%     load([basename '_EMGCorr.mat'])

%% Bins/Timing: getting state-restricted second-wise bins to use for many purposes
load(fullfile(basepath,[basename '-states.mat']))

%restrict to good sleep interval, always thus far has been a single
%start-stop interval
load(fullfile(basepath,[basename '_GoodSleepInterval.mat']))
states((1:length(states))>GoodSleepInterval.timePairFormat(2)) = [];
states((1:length(states))<GoodSleepInterval.timePairFormat(1)) = [];

%extract intervals of states
ss = IDXtoINT(states);
alltsecsIN = [1 length(states)];
wakesecsIN = ss{1};
masecsIN = ss{2};
nremsecsIN = ss{3};
if length(ss)<5 
    remsecsIN = [];
else
    remsecsIN = ss{5};
end

alltsecsIS = intervalSet(alltsecsIN(:,1),alltsecsIN(:,2));
nremsecsIS = intervalSet(nremsecsIN(:,1),nremsecsIN(:,2));
masecsIS = intervalSet(masecsIN(:,1),masecsIN(:,2));
wakesecsIS = intervalSet(wakesecsIN(:,1),wakesecsIN(:,2));
if ~isempty(remsecsIN)
    remsecsIS = intervalSet(remsecsIN(:,1),remsecsIN(:,2));
else
    remsecsIS = intervalSet([],[]);
end
% wakesecsIDX = INTtoIDX({wakesecsIN},length(spec),1);
% remsecsIDX = INTtoIDX({remsecsIN},length(spec),1);

%% Get sextile rates
numEcells = length(Se);
numIcells = length(Si);

if isfield(sr.StateRates,'EWSWakeRates')
    rankbasis = sr.StateRates.EWSWakeRates;
elseif isfield(sr.StateRates,'EWakeRates')
    rankbasis = sr.StateRates.EWakeRates;
end
bads = find(rankbasis<=0);
goods = find(rankbasis>0);
rankbasis(bads) = [];
Se = Se(goods);

rankidxs = GetQuartilesByRank(rankbasis,numspikerategroups);

for binidx = 1:length(binwidthseclist)
    binwidthsecs = binwidthseclist(binidx);
    %% Restrict to a series of bins and use those same bins for all timing ops thereafter so correlations can be done
    %all
    starts = [];
    ends = [];
    for sgidx = 1:size(alltsecsIN,1)
        t = alltsecsIN(sgidx,:);
        ts = (t(1):binwidthsecs:t(2)-binwidthsecs)';
        te = (t(1)+binwidthsecs:binwidthsecs:t(2))';
        starts = cat(1,starts,ts);
        ends = cat(1,ends,te);
    end
    alltbins = intervalSet(starts,ends);
    %wake
    starts = [];
    ends = [];
    for sgidx = 1:size(wakesecsIN,1)
        t = wakesecsIN(sgidx,:);
        ts = (t(1):binwidthsecs:t(2)-binwidthsecs)';
        te = (t(1)+binwidthsecs:binwidthsecs:t(2))';
        starts = cat(1,starts,ts);
        ends = cat(1,ends,te);
    end
    wakebins = intervalSet(starts,ends);
    %ma
    starts = [];
    ends = [];
    for sgidx = 1:size(masecsIN,1)
        t = masecsIN(sgidx,:);
        ts = (t(1):binwidthsecs:t(2)-binwidthsecs)';
        te = (t(1)+binwidthsecs:binwidthsecs:t(2))';
        starts = cat(1,starts,ts);
        ends = cat(1,ends,te);
    end
    mabins = intervalSet(starts,ends);
    %nrem
    starts = [];
    ends = [];
    for sgidx = 1:size(nremsecsIN,1)
        t = nremsecsIN(sgidx,:);
        ts = (t(1):binwidthsecs:t(2)-binwidthsecs)';
        te = (t(1)+binwidthsecs:binwidthsecs:t(2))';
        starts = cat(1,starts,ts);
        ends = cat(1,ends,te);
    end
    nrembins = intervalSet(starts,ends);
    %rem
    starts = [];
    ends = [];
    for sgidx = 1:size(remsecsIN,1)
        t = remsecsIN(sgidx,:);
        ts = (t(1):binwidthsecs:t(2)-binwidthsecs)';
        te = (t(1)+binwidthsecs:binwidthsecs:t(2))';
        starts = cat(1,starts,ts);
        ends = cat(1,ends,te);
    end
    rembins = intervalSet(starts,ends);

    %% Get per-bin (per-second) spike rates
    %whole population
    % wakePopSe = Data(Restrict(MakeQfromTsd(oneSeries(Se),1),wakesecsIS));
    % wakePopSi = Data(Restrict(MakeQfromTsd(oneSeries(Si),1),wakesecsIS));
    % remPopSe = Data(Restrict(MakeQfromTsd(oneSeries(Se),1),remsecsIS));
    % remPopSi = Data(Restrict(MakeQfromTsd(oneSeries(Si),1),remsecsIS));

    alltPopSeTsd = MakeQfromTsd(oneSeries(Se),alltbins);
    alltPopSeBinData = Data(alltPopSeTsd);
    alltPopSiTsd = MakeQfromTsd(oneSeries(Si),alltbins);
    alltPopSiBinData = Data(alltPopSiTsd);

    wakePopSeTsd = MakeQfromTsd(oneSeries(Se),wakebins);
    wakePopSeBinData = Data(wakePopSeTsd);
    wakePopSiTsd = MakeQfromTsd(oneSeries(Si),wakebins);
    wakePopSiBinData = Data(wakePopSiTsd);

    maPopSeTsd = MakeQfromTsd(oneSeries(Se),mabins);
    maPopSeBinData = Data(maPopSeTsd);
    maPopSiTsd = MakeQfromTsd(oneSeries(Si),mabins);
    maPopSiBinData = Data(maPopSiTsd);

    nremPopSeTsd = MakeQfromTsd(oneSeries(Se),nrembins);
    nremPopSeBinData = Data(nremPopSeTsd);
    nremPopSiTsd = MakeQfromTsd(oneSeries(Si),nrembins);
    nremPopSiBinData = Data(nremPopSiTsd);

    remPopSeTsd = MakeQfromTsd(oneSeries(Se),rembins);
    remPopSeBinData = Data(remPopSeTsd);
    remPopSiTsd = MakeQfromTsd(oneSeries(Si),rembins);
    remPopSiBinData = Data(remPopSiTsd);
    
    %rate groups (sextiles)
    ERateGroupAllTRatesZ{binidx} = [];
    ERateGroupAllTRates{binidx} = [];
    ERateGroupWakeRatesZ{binidx} = [];
    ERateGroupWakeRates{binidx} = [];
    ERateGroupMARatesZ{binidx} = [];
    ERateGroupMARates{binidx} = [];
    ERateGroupNREMRatesZ{binidx} = [];
    ERateGroupNREMRates{binidx} = [];
    ERateGroupREMRatesZ{binidx} = [];
    ERateGroupREMRates{binidx} = [];

    for sgidx = 1:numspikerategroups
        ERateGroupIdxs{sgidx} = find(rankidxs==sgidx);
        ERateGroupCounts(sgidx) = sum(rankidxs==numspikerategroups);

        t = Data(MakeQfromTsd(oneSeries(Se(ERateGroupIdxs{sgidx})),alltbins));
        ERateGroupAllTRates{binidx}(sgidx,:) = t./binwidthsecs/ERateGroupCounts(sgidx);
        ERateGroupAllTRatesZ{binidx}(sgidx,:) = nanzscore(ERateGroupAllTRates{binidx}(sgidx,:));

        t = Data(MakeQfromTsd(oneSeries(Se(ERateGroupIdxs{sgidx})),wakebins));
        ERateGroupWakeRates{binidx}(sgidx,:) = t./binwidthsecs/ERateGroupCounts(sgidx);
        ERateGroupWakeRatesZ{binidx}(sgidx,:) = nanzscore(ERateGroupWakeRates{binidx}(sgidx,:));

        t = Data(MakeQfromTsd(oneSeries(Se(ERateGroupIdxs{sgidx})),mabins));
        ERateGroupMARates{binidx}(sgidx,:) = t./binwidthsecs/ERateGroupCounts(sgidx);
        ERateGroupMARatesZ{binidx}(sgidx,:) = nanzscore(ERateGroupMARates{binidx}(sgidx,:));

        t = Data(MakeQfromTsd(oneSeries(Se(ERateGroupIdxs{sgidx})),nrembins));
        ERateGroupNREMRates{binidx}(sgidx,:) = t./binwidthsecs/ERateGroupCounts(sgidx);
        ERateGroupNREMRatesZ{binidx}(sgidx,:) = nanzscore(ERateGroupNREMRates{binidx}(sgidx,:));

        t = Data(MakeQfromTsd(oneSeries(Se(ERateGroupIdxs{sgidx})),rembins));
        ERateGroupREMRates{binidx}(sgidx,:) = t./binwidthsecs/ERateGroupCounts(sgidx);
        ERateGroupREMRatesZ{binidx}(sgidx,:) = nanzscore(ERateGroupREMRates{binidx}(sgidx,:));
    end


    %% data by bands
    for bandidx = 1:length(bandmeans)+1
        if bandidx<=length(bandmeans)%if one of the bands, just gather power for that band
            tbandpower = amp(:,bandidx);
        else% for the case where we are looking at broadband gamma
            minbin = find(bandmeans>broadbandgammarange(1),1,'first');
            maxbin = find(bandmeans<broadbandgammarange(2),1,'last');
            broadbandpower = mean(amp(:,minbin:maxbin),2);
            tbandpower = broadbandpower;
        end
        
        bandpowertsd = tsd((1:length(tbandpower))/1250,tbandpower);
        bandpowertsdArray = tsdArray(bandpowertsd);

        AlltPowerbandTsd = MakeSummedValQfromS(bandpowertsdArray,alltbins);
        AlltPowerbandData = Data(AlltPowerbandTsd);

        WakePowerbandTsd = MakeSummedValQfromS(bandpowertsdArray,wakebins);
        WakePowerbandData = Data(WakePowerbandTsd);

        MaPowerbandTsd = MakeSummedValQfromS(bandpowertsdArray,mabins);
        MaPowerbandData = Data(MaPowerbandTsd);

        NremPowerbandTsd = MakeSummedValQfromS(bandpowertsdArray,nrembins);
        NremPowerbandData = Data(NremPowerbandTsd);

        RemPowerbandTsd = MakeSummedValQfromS(bandpowertsdArray,rembins);
        RemPowerbandData = Data(RemPowerbandTsd);
    % 
    %     figure
    %     subplot(2,1,1);
    %     semilogxhist(baselinewakegammabandData);
    %     set(gca,'xscale','log');
    %     axis tight
    %     xl = get(gca,'xlim');
    %     yl = get(gca,'ylim');
    %     hold on;
    %     plot([median(baselinewakegammabandData) median(baselinewakegammabandData)],yl,'k')
    %     ylabel('# seconds')
    %     title('Wake');
    % 
    %     subplot(2,1,2);
    %     semilogxhist(baselineremgammabandData);
    %     set(gca,'xscale','log');
    %     set(gca,'xlim',xl);
    %     yl = get(gca,'ylim');
    %     hold on;
    %     plot([median(baselineremgammabandData) median(baselineremgammabandData)],yl,'k')
    %     ylabel('# seconds')
    %     title('REM');
    % 
    %     AboveTitle('65-160Hz Band Power in 1s bins');

        %% make final matrices for correlations
        EAllTGeneralMatrix = cat(2,AlltPowerbandData,alltPopSeBinData,ERateGroupAllTRates{binidx}');
        IAllTGeneralMatrix = cat(2,AlltPowerbandData,alltPopSiBinData);

        EWakeGeneralMatrix = cat(2,WakePowerbandData,wakePopSeBinData,ERateGroupWakeRates{binidx}');
        IWakeGeneralMatrix = cat(2,WakePowerbandData,wakePopSiBinData);

        EMAGeneralMatrix = cat(2,MaPowerbandData,maPopSeBinData,ERateGroupMARates{binidx}');
        IMAGeneralMatrix = cat(2,MaPowerbandData,maPopSiBinData);

        ENREMGeneralMatrix = cat(2,NremPowerbandData,nremPopSeBinData,ERateGroupNREMRates{binidx}');
        INREMGeneralMatrix = cat(2,NremPowerbandData,nremPopSiBinData);

        EREMGeneralMatrix = cat(2,RemPowerbandData,remPopSeBinData,ERateGroupREMRates{binidx}');
        IREMGeneralMatrix = cat(2,RemPowerbandData,remPopSiBinData);

        rEAllT = corr(EAllTGeneralMatrix);
        rEAllT(find(bwdiag(length(rEAllT)))) = 0;%zero the diag
        r_AllEAllT(bandidx,binidx) = rEAllT(1,2);
        r_SextilesEAllT(bandidx,:,binidx) = rEAllT(1,3:end);

        rIAllT = corr(IAllTGeneralMatrix);
        rIAllT(find(bwdiag(length(rIAllT)))) = 0;%zero the diag
        r_AllIAllT(bandidx,binidx) = rIAllT(1,2);

        rEWake = corr(EWakeGeneralMatrix);
        rEWake(find(bwdiag(length(rEWake)))) = 0;%zero the diag
        r_AllEWake(bandidx,binidx) = rEWake(1,2);
        r_SextilesEWake(bandidx,:,binidx) = rEWake(1,3:end);

        rIWake = corr(IWakeGeneralMatrix);
        rIWake(find(bwdiag(length(rIWake)))) = 0;%zero the diag
        r_AllIWake(bandidx,binidx) = rIWake(1,2);

        if ~isempty(EMAGeneralMatrix)
            rEMA = corr(EMAGeneralMatrix);
            rEMA(find(bwdiag(length(rEMA)))) = 0;%zero the diag
            r_AllEMA(bandidx,binidx) = rEMA(1,2);
            r_SextilesEMA(bandidx,:,binidx) = rEMA(1,3:end);
        else
            rEMA = nan;
            r_AllEMA(bandidx,binidx) = nan;        
            r_SextilesEMA(bandidx,:,binidx) = nan(1,size(EMAGeneralMatrix,2)-2);            
        end
            
        if ~isempty(IMAGeneralMatrix)
            rIMA = corr(IMAGeneralMatrix);
            rIMA(find(bwdiag(length(rIMA)))) = 0;%zero the diag
            r_AllIMA(bandidx,binidx) = rIMA(1,2);
        else
            rIMA = nan;
            r_AllIMA(bandidx,binidx) = nan;        
        end
        
        rENREM = corr(ENREMGeneralMatrix);
        rENREM(find(bwdiag(length(rENREM)))) = 0;%zero the diag
        r_AllENREM(bandidx,binidx) = rENREM(1,2);
        r_SextilesENREM(bandidx,:,binidx) = rENREM(1,3:end);

        rINREM = corr(INREMGeneralMatrix);
        rINREM(find(bwdiag(length(rINREM)))) = 0;%zero the diag
        r_AllINREM(bandidx,binidx) = rINREM(1,2);

        if ~isempty(EREMGeneralMatrix)
            rEREM = corr(EREMGeneralMatrix);
            rEREM(find(bwdiag(length(rEREM)))) = 0;%zero the diag
            r_AllEREM(bandidx,binidx) = rEREM(1,2);        
            r_SextilesEREM(bandidx,:,binidx) = rEREM(1,3:end);
        else
            rEREM = nan;
            r_AllEREM(bandidx,binidx) = nan;        
            r_SextilesEREM(bandidx,:,binidx) = nan(1,size(EREMGeneralMatrix,2)-2);            
        end
        
        if ~isempty(IREMGeneralMatrix)
            rIREM = corr(IREMGeneralMatrix);
            rIREM(find(bwdiag(length(rIREM)))) = 0;%zero the diag
            r_AllIREM(bandidx,binidx) = rIREM(1,2);
        else
            rIREM = nan;
            r_AllIREM(bandidx,binidx) = nan;        
        end
            

%         r_SextilesVsSextilesEWake = rEWake(3:end,3:end);
%         r_SextilesVsSextilesEREM = rEREM(3:end,3:end);

% %         correlation figures
%         if binwidthsecs == plotbinwidth
%             h = figure;
%             subplot(2,2,1)
%             [~, ~,~, r_ewake(a), ~, p] = logfit_bw(wakePopSeBinData,baselinewakegammabandData,'loglog');
%             xlabel('E Rate')
%             ylabel('Gamma power')
%             title(['Wake.  r = ' num2str(r_ewake(a)) '. p = ' num2str(p) '.'])
%             ylabel('r value')
% 
%             subplot(2,2,2)
%             [~, ~,~, r_iwake(a), ~, p] = logfit_bw(wakePopSiBinData,baselinewakegammabandData,'loglog');
%             xlabel('I Rate')
%             ylabel('Gamma power')
%             title(['Wake.  r = ' num2str(r_iwake(a)) '. p = ' num2str(p) '.'])
%             ylabel('r value')
% 
%             subplot(2,2,3)
%             [~, ~,~, r_erem(a), ~, p] = logfit_bw(remPopSiBinData,baselineremgammabandData,'loglog');
%             xlabel('E Rate')
%             ylabel('Gamma power')
%             title(['REM.  r = ' num2str(r_erem(a)) '. p = ' num2str(p) '.'])
%             xlabel('Hz')
% 
%             subplot(2,2,4)
%             [~, ~,~, r_irem(a), ~, p] = logfit_bw(remPopSeBinData,baselineremgammabandData,'loglog');
%             xlabel('I Rate')
%             ylabel('Gamma power')
%             title(['REM.  r = ' num2str(r_irem(a)) '. p = ' num2str(p) '.'])
%             xlabel('Hz')
% 
%             close(h)
%         end
    end

    %% freq band vs E/I rate for a given bin width
%     figure;
%     subplot(2,2,1)
%     plot(mean(gammabands,2),r_AllEWake)
%     title(['E cells vs various gamma bands during Wake'])
%     axis tight
% 
%     subplot(2,2,2)
%     plot(mean(gammabands,2),r_AllIWake)
%     title(['I cells vs various gamma bands during Wake'])
%     axis tight
% 
%     subplot(2,2,3)
%     plot(mean(gammabands,2),r_AllEREM)
%     title(['E cells vs various gamma bands during REM'])
%     axis tight
% 
%     subplot(2,2,4)
%     plot(mean(gammabands,2),r_AllIREM)
%     title(['I cells vs various gamma bands during REM'])
%     axis tight
% 
%     AboveTitle('1sec resolution')
% 
%     %
%     figure('position',[5 0 560 800]);
%     % Colors = RainbowColors(numspikerategroups);
%     Colors = makeColorMap([1 0 0],[0 0 1],6);;
%     subplot(2,1,1,'ColorOrder',Colors)
%     hold on
%     for a = numspikerategroups:-1:1
%     plot(mean(gammabands,2),r_SextilesEWake(:,a))
%     end
%     legend({'Highest FR','2','3','4','5','Lowest FR'},'Location','NorthEastOutside')
%     title('Wake Sextile Rate vs Band Power')
%     subplot(2,1,2,'ColorOrder',Colors)
%     hold on
%     for a = numspikerategroups:-1:1
%     plot(mean(gammabands,2),r_SextilesEREM(:,a))
%     end
%     legend({'Highest FR','2','3','4','5','Lowest FR'},'Location','NorthEastOutside')
%     title('REM Sextile Rate vs Band Power')

    if plotbinwidth == binwidthsecs;%bin width to do some example plots by default
        ExampleAllTSePop = alltPopSeBinData;
        ExampleWakeSePop = wakePopSeBinData;
        ExampleNremSePop = nremPopSeBinData;
        ExampleRemSePop = remPopSeBinData;
        ExampleMaSePop = maPopSeBinData;
        ExampleAllTSiPop = alltPopSiBinData;
        ExampleWakeSiPop = wakePopSiBinData;
        ExampleNremSiPop = nremPopSiBinData;
        ExampleRemSiPop = remPopSiBinData;
        ExampleMaSiPop = maPopSiBinData;
        ExampleAllTBroadBand = AlltPowerbandData;
        ExampleWakeBroadBand = WakePowerbandData;
        ExampleNremBroadBand = NremPowerbandData;
        ExampleRemBroadBand = RemPowerbandData;
        ExampleMaBroadBand = MaPowerbandData;
    end
end

BandPowerVsPopSpikeRateData = v2struct(...
    alltsecsIS, nremsecsIS, masecsIS,wakesecsIS,remsecsIS,...
    numEcells,numIcells,rankbasis,rankidxs,...
    ERateGroupAllTRatesZ,ERateGroupAllTRates,ERateGroupWakeRatesZ,...
    ERateGroupWakeRates,ERateGroupMARatesZ,ERateGroupMARates,...
    ERateGroupNREMRatesZ,ERateGroupNREMRates,ERateGroupREMRatesZ,...
    ERateGroupREMRates);
save(fullfile(basepath,[basename '_BandPowerVsPopSpikeRateData']),'BandPowerVsPopSpikeRateData')

h = [];

%just plot power and rate traces
h(end+1) = figure('name','RawBandPowerAndPopTracesOverlaid','position',[5 5 1200 800]);
subplot(3,2,1)
    hold on;
    plot(zscore(ExampleAllTSePop/numEcells/plotbinwidth)+5,'b');
    plot(zscore(ExampleAllTSiPop/numIcells/plotbinwidth),'r');
    plot(zscore(ExampleAllTBroadBand)-5,'k');
    axis tight
    title('AllSecs')
subplot(3,2,2)
    hold on;
    plot(zscore(ExampleWakeSePop/numEcells/plotbinwidth)+5,'b');
    plot(zscore(ExampleWakeSiPop/numIcells/plotbinwidth),'r');
    plot(zscore(ExampleWakeBroadBand)-5,'k');
    axis tight
    title('Wake')
subplot(3,2,3)
    hold on;
    plot(zscore(ExampleNremSePop/numEcells/plotbinwidth)+5,'b');
    plot(zscore(ExampleNremSiPop/numIcells/plotbinwidth),'r');
    plot(zscore(ExampleNremBroadBand)-5,'k');
    axis tight
    title('NREM')
subplot(3,2,4)
    hold on;
    plot(zscore(ExampleRemSePop/numEcells/plotbinwidth)+5,'b');
    plot(zscore(ExampleRemSiPop/numIcells/plotbinwidth),'r');
    plot(zscore(ExampleRemBroadBand)-5,'k');
    axis tight
    title('REM')
subplot(3,2,5)
    hold on;
    plot(zscore(ExampleMaSePop/numEcells/plotbinwidth)+5,'b');
    plot(zscore(ExampleMaSiPop/numIcells/plotbinwidth),'r');
    plot(zscore(ExampleMaBroadBand)-5,'k');
    axis tight
    title('MA')
subplot(3,2,6);%dummy just for legend
    hold on;
    plot(zscore(ExampleMaSePop/numEcells/plotbinwidth)+5,'b');
    plot(zscore(ExampleMaSiPop/numIcells/plotbinwidth),'r');
    plot(zscore(ExampleMaBroadBand)-5,'k');
    axis tight
    legend({'E';'I';'BBGamma'},'location','northwest')
    set(gca,'visible','off')
    set(findobj('parent',gca,'type','line'),'visible','off')

% correlation plots of E cells vs broadband gamma
h(end+1) = figure('name','BandEPopCorrelationPlots','position',[5 5 800 800]);
subplot(3,2,1)
    [~, ~,~, r, ~, p] = logfit_bw(ExampleAllTSePop/numEcells/plotbinwidth,ExampleAllTBroadBand,'linear');
    xlabel('E Rate')
    ylabel('BB Gamma')
    title(['AllSec.  r = ' num2str(r) '. p = ' num2str(p) '.'])
subplot(3,2,2)
    [~, ~,~, r, ~, p] = logfit_bw(ExampleWakeSePop/numEcells/plotbinwidth,ExampleWakeBroadBand,'linear');
    xlabel('E Rate')
    ylabel('BB Gamma')
    title(['Wake.  r = ' num2str(r) '. p = ' num2str(p) '.'])
subplot(3,2,3)
    [~, ~,~, r, ~, p] = logfit_bw(ExampleNremSePop/numEcells/plotbinwidth,ExampleNremBroadBand,'linear');
    xlabel('E Rate')
    ylabel('BB Gamma')
    title(['NREM.  r = ' num2str(r) '. p = ' num2str(p) '.'])
subplot(3,2,4)
    try
        [~, ~,~, r, ~, p] = logfit_bw(ExampleRemSePop/numEcells/plotbinwidth,ExampleRemBroadBand,'linear');
        xlabel('E Rate')
        ylabel('BB Gamma')
    end
    title(['REM.  r = ' num2str(r) '. p = ' num2str(p) '.'])   
subplot(3,2,5)
    try
        [~, ~,~, r, ~, p] = logfit_bw(ExampleMaSePop/numEcells/plotbinwidth,ExampleMaBroadBand,'linear');
        xlabel('E Rate')
        ylabel('BB Gamma')
    end
    title(['MA.  r = ' num2str(r) '. p = ' num2str(p) '.'])
AboveTitle('E Population')
    
% correlation plots of I cells vs broadband gamma
h(end+1) = figure('name','BandIPopCorrelationPlots','position',[5 5 800 800]);
subplot(3,2,1)
    [~, ~,~, r, ~, p] = logfit_bw(ExampleAllTSiPop/numIcells/plotbinwidth,ExampleAllTBroadBand,'linear');
    xlabel('I Rate')
    ylabel('BB Gamma')
    title(['AllSec.  r = ' num2str(r) '. p = ' num2str(p) '.'])
subplot(3,2,2)
    [~, ~,~, r, ~, p] = logfit_bw(ExampleWakeSiPop/numIcells/plotbinwidth,ExampleWakeBroadBand,'linear');
    xlabel('I Rate')
    ylabel('BB Gamma')
    title(['Wake.  r = ' num2str(r) '. p = ' num2str(p) '.'])
subplot(3,2,3)
    [~, ~,~, r, ~, p] = logfit_bw(ExampleNremSiPop/numIcells/plotbinwidth,ExampleNremBroadBand,'linear');
    xlabel('I Rate')
    ylabel('BB Gamma')
    title(['NREM.  r = ' num2str(r) '. p = ' num2str(p) '.'])
subplot(3,2,4)
    try
        [~, ~,~, r, ~, p] = logfit_bw(ExampleRemSiPop/numIcells/plotbinwidth,ExampleRemBroadBand,'linear');
        xlabel('I Rate')
        ylabel('BB Gamma')
    end
    title(['REM.  r = ' num2str(r) '. p = ' num2str(p) '.'])
subplot(3,2,5)
    try
        [~, ~,~, r, ~, p] = logfit_bw(ExampleMaSiPop/numIcells/plotbinwidth,ExampleMaBroadBand,'linear');
        xlabel('I Rate')
        ylabel('BB Gamma')
    end
    title(['MA.  r = ' num2str(r) '. p = ' num2str(p) '.'])
AboveTitle('I Population')


h(end+1) = figure('position',[1 1 1000 800],'name','RatePowerByBinFreqAllSe');
subplot(2,3,1)
imagesc(r_AllEAllT')
axis xy
% colormap(jet)
xlabel('Frequency(Hz)')
xt = round(linspace(1,length(bandmeans),10));
set(gca,'xtick',xt)
set(gca,'xticklabel',bandmeans(xt))
ylabel('Bin Size (s)')
yt = get(gca,'Ytick');
set(gca,'YTickLabel',binwidthseclist(yt))
c = colorbar;
c.Label.String = 'Spike-LFP correlation (R)';
title_bw('AllTime')

subplot(2,3,2)
imagesc(r_AllEWake')
axis xy
% colormap(jet)
xlabel('Frequency(Hz)')
xt = round(linspace(1,length(bandmeans),10));
set(gca,'xtick',xt)
set(gca,'xticklabel',bandmeans(xt))
ylabel('Bin Size (s)')
yt = get(gca,'Ytick');
set(gca,'YTickLabel',binwidthseclist(yt))
c = colorbar;
c.Label.String = 'Spike-LFP correlation (R)';
title_bw('WAKE')

subplot(2,3,3)
mesh(r_AllEWake)
% colormap(jet)
xlabel('Bin Size (s)')
ylabel('Frequency(Hz)')
zlabel('Spike-LFP correlation (R)')
axis tight
xt = get(gca,'Xtick');
set(gca,'XTickLabel',binwidthseclist(xt))
yt = get(gca,'Ytick');
set(gca,'YTickLabel',bandmeans(yt))
title_bw('Wake')

subplot(2,3,4)
imagesc(r_AllEMA')
axis xy
% colormap(jet)
xlabel('Frequency(Hz)')
xt = round(linspace(1,length(bandmeans),10));
set(gca,'xtick',xt)
set(gca,'xticklabel',bandmeans(xt))
ylabel('Bin Size (s)')
yt = get(gca,'Ytick');
set(gca,'YTickLabel',binwidthseclist(yt))
c = colorbar;
c.Label.String = 'Spike-LFP correlation (R)';
title_bw('MA')
AboveTitle(['RatePowerByBin+Freq.  For all pE: ' basename])

subplot(2,3,5)
imagesc(r_AllENREM')
axis xy
% colormap(jet)
xlabel('Frequency(Hz)')
xt = round(linspace(1,length(bandmeans),10));
set(gca,'xtick',xt)
set(gca,'xticklabel',bandmeans(xt))
ylabel('Bin Size (s)')
yt = get(gca,'Ytick');
set(gca,'YTickLabel',binwidthseclist(yt))
c = colorbar;
c.Label.String = 'Spike-LFP correlation (R)';
title_bw('NREM')

subplot(2,3,6)
imagesc(r_AllEREM')
axis xy
% colormap(jet)
xlabel('Frequency(Hz)')
xt = round(linspace(1,length(bandmeans),10));
set(gca,'xtick',xt)
set(gca,'xticklabel',bandmeans(xt))
ylabel('Bin Size (s)')
yt = get(gca,'Ytick');
set(gca,'YTickLabel',binwidthseclist(yt))
c = colorbar;
c.Label.String = 'Spike-LFP correlation (R)';
title_bw('REM')
AboveTitle(['RatePowerByBin+Freq.  For all pE: ' basename])

%% Sextile plot
h(end+1) = figure('position',[1 1 900 800],'Name','RatePowerByBin+Freq+Sextile_AllTime');
h(end+1) = figure('position',[1 1 900 800],'Name','RatePowerByBin+Freq+Sextile_Wake');
h(end+1) = figure('position',[1 1 900 800],'Name','RatePowerByBin+Freq+Sextile_MA');
h(end+1) = figure('position',[1 1 900 800],'Name','RatePowerByBin+Freq+Sextile_NREM');
h(end+1) = figure('position',[1 1 900 800],'Name','RatePowerByBin+Freq+Sextile_REM');
for eind = 4:-1:0;
    tfig = h(end-eind);
    for sgidx = 1:6
        figure(tfig)
        subplot(2,3,sgidx)
        switch eind
            case 4
                thisr = r_SextilesEAllT;
            case 3
                thisr = r_SextilesEWake;
            case 2
                thisr = r_SextilesEMA;
            case 1
                thisr = r_SextilesENREM;
            case 0
                thisr = r_SextilesEREM;
        end
        imagesc(squeeze(thisr(:,sgidx,:)))
        axis xy

        ylabel('Frequency(Hz)')
        yt = round(linspace(1,length(bandmeans),5));
        set(gca,'ytick',yt)
        set(gca,'yticklabel',bandmeans(yt))

        xlabel('Bin Size (s)')
        xt = get(gca,'xtick');
        set(gca,'XTickLabel',binwidthseclist(xt))

        colorbar

        tr = rate(oneSeries(Se(ERateGroupIdxs{sgidx})))/length(ERateGroupIdxs{sgidx});

        title_bw({['Rate Group ' num2str(sgidx)];['FR=' num2str(tr)]})
    end
    AboveTitle(['RatePowerByBin+Freq+Sextile: ' basename],tfig)
end

MakeDirSaveFigsThere(fullfile(basepath,'GammaPowerRateFigs'),h)
MakeDirSaveFigsThere(fullfile(basepath,'GammaPowerRateFigs'),h,'png')
1;

% normanik@gmail.com

%%
% betaidxs = (fo>14 & fo<25);
% baselinerembetaband = spec(remsecs,betaidxs);
% baselinewakebetaband = spec(wakesecs,betaidxs);
% baselinewakebetatotal = sum(baselinewakebetaband,2);
% baselinerembetatotal = sum(baselinerembetaband,2);
% 
% figure
% subplot(2,1,1);
% semilogxhist(baselinewakebetatotal);
% set(gca,'xscale','log');
% xl = get(gca,'xlim');
% title('Wake');
% 
% subplot(2,1,2);
% semilogxhist(baselinerembetatotal);
% set(gca,'xscale','log');
% set(gca,'xlim',xl);
% title('REM');
% AboveTitle('14-25Hz');