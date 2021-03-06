function GammaPowerVsSpikeRateBinned_Wavelets(basepath,basename)

%% Constants
numspikerategroups = 6;
% % gammabandstarts = [0:1:19 20:2:38 40:5:195]';
% % gammabandstops = [1:1:20 22:2:40 45:5:200]';
% % gammabandmeans = mean([gammabandstarts gammabandstops],2);
% % gammabands = cat(2,gammabandstarts,gammabandstops);
% bandmeans = unique(round(logspace(0,log10(650),50)));%1 to 650, log spaced except elim some repetitive values near 1-4Hz

binwidthseclist = [0.01,0.02,0.05,0.1,0.2,0.5,1,2,5,10,20];

%% Loading up
if ~exist('basepath','var')
    [~,basename] = fileparts(cd);
    basepath = cd;
end

load([basename '_WaveletForGamma.mat'],'amp')
load([basename '_WaveletForGamma.mat'],'bandmeans')
load([basename '_SSubtypes.mat'])
load([basename '-states.mat'])
load([basename '_EIRatio.mat'])
sr = load(fullfile(basepath,[basename '_StateRates.mat']));
%     load([basename '_EMGCorr.mat'])

%% Bins/Timing: getting state-restricted second-wise bins to use for many purposes
ss = IDXtoINT(states);
wakesecsIN = ss{1};
masecsIN = ss{2};
nremsecsIN = ss{3};
remsecsIN = ss{5};
wakesecsIS = intervalSet(wakesecsIN(:,1),wakesecsIN(:,2));
remsecsIS = intervalSet(remsecsIN(:,1),remsecsIN(:,2));
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


for bw = 1:length(binwidthseclist)
    binwidthsecs = binwidthseclist(bw);
    %% Restrict to a series of bins and use those same bins for all timing ops thereafter so correlations can be done
    starts = [];
    ends = [];
    for a = 1:size(wakesecsIN,1)
        t = wakesecsIN(a,:);
        ts = (t(1):binwidthsecs:t(2)-1)';
        te = (t(1)+1:binwidthsecs:t(2))';
        starts = cat(1,starts,ts);
        ends = cat(1,ends,te);
    end
    wakebins = intervalSet(starts,ends);

    starts = [];
    ends = [];
    for a = 1:size(remsecsIN,1)
        t = remsecsIN(a,:);
        ts = (t(1):binwidthsecs:t(2)-1)';
        te = (t(1)+1:binwidthsecs:t(2))';
        starts = cat(1,starts,ts);
        ends = cat(1,ends,te);
    end
    rembins = intervalSet(starts,ends);

    ERateGroupWakeRatesZ{bw} = [];
    ERateGroupWakeRates{bw} = [];
    ERateGroupREMRatesZ{bw} = [];
    ERateGroupREMRates{bw} = [];

    for a = 1:numspikerategroups
        ERateGroupIdxs{a} = find(rankidxs==a);
        ERateGroupCounts(a) = sum(rankidxs==numspikerategroups);

        t = Data(MakeQfromTsd(oneSeries(Se(ERateGroupIdxs{a})),wakebins));
        ERateGroupWakeRates{bw}(a,:) = t./binwidthsecs/ERateGroupCounts(a);
        ERateGroupWakeRatesZ{bw}(a,:) = nanzscore(ERateGroupWakeRates{bw}(a,:));

        t = Data(MakeQfromTsd(oneSeries(Se(ERateGroupIdxs{a})),rembins));
        ERateGroupREMRates{bw}(a,:) = t./binwidthsecs/ERateGroupCounts(a);
        ERateGroupREMRatesZ{bw}(a,:) = nanzscore(ERateGroupREMRates{bw}(a,:));
    end


    %%
%     EIR = tsd(EIRatioData.bincentertimes,EIRatioData.ZPCEI);
%     EIRwake = Restrict(EIR,wakebins);
%     EIRrem = Restrict(EIR,rembins);
%     EIRbws  = EIRatioData.binwidthsecs;

    %%
    % EMGtsd = tsd(EMGCorr(:,1),EMGCorr(:,2));
    % EMGwake = MakeSummedValQfromS(tsdArray(EMGtsd),wakebins);
    % EMGrem = MakeSummedValQfromS(tsdArray(EMGtsd),rembins);

    %% ploting by bands
    for a = 1:length(bandmeans)

%         gammaidxs = (fo>gammabands(a,1) & fo<=gammabands(a,2));
% 
%         notchidxs = (fo>59 & fo<61);
%         gammaidxs(gammaidxs & notchidxs) = [];
% 
%         gammaband = sum(spec(:,gammaidxs),2);
        gammaband = amp(:,a);
        gammabandtsd = tsd((1:length(gammaband))/1250,gammaband);
        gammabandtsdArray = tsdArray(gammabandtsd);

        baselinewakegammaband = MakeSummedValQfromS(gammabandtsdArray,wakebins);
        baselinewakegammabandData = Data(baselinewakegammaband);

        baselineremgammaband = MakeSummedValQfromS(gammabandtsdArray,rembins);
        baselineremgammabandData = Data(baselineremgammaband);
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

        %% Get per-bin (per-second) spike rates
        % wakePopSe = Data(Restrict(MakeQfromTsd(oneSeries(Se),1),wakesecsIS));
        % wakePopSi = Data(Restrict(MakeQfromTsd(oneSeries(Si),1),wakesecsIS));
        % remPopSe = Data(Restrict(MakeQfromTsd(oneSeries(Se),1),remsecsIS));
        % remPopSi = Data(Restrict(MakeQfromTsd(oneSeries(Si),1),remsecsIS));

        wakePopSeTsd = MakeQfromTsd(oneSeries(Se),wakebins);
        wakePopSeBinData = Data(wakePopSeTsd);
        wakePopSiTsd = MakeQfromTsd(oneSeries(Si),wakebins);
        wakePopSiBinData = Data(wakePopSiTsd);

        remPopSeTsd = MakeQfromTsd(oneSeries(Se),rembins);
        remPopSeBinData = Data(remPopSeTsd);
        remPopSiTsd = MakeQfromTsd(oneSeries(Si),rembins);
        remPopSiBinData = Data(remPopSiTsd);

        %% Plot distributions of spiking rates over seconds
    %     figure
    %     subplot(2,2,1);
    %     semilogxhist(wakePopSeBinData);
    %     set(gca,'xscale','log');
    %     axis tight
    %     xle = get(gca,'xlim');
    %     yl = get(gca,'ylim');
    %     hold on;
    %     plot([median(wakePopSeBinData) median(wakePopSeBinData)],yl,'k','linewidth',2)
    %     ylabel('# seconds')
    %     title('Wake - ECells');
    % 
    %     subplot(2,2,2);
    %     semilogxhist(wakePopSiBinData);
    %     set(gca,'xscale','log');
    %     axis tight
    %     xli = get(gca,'xlim');
    %     yl = get(gca,'ylim');
    %     hold on;
    %     plot([median(wakePopSiBinData) median(wakePopSiBinData)],yl,'k','linewidth',2)
    %     ylabel('# seconds')
    %     title('Wake - ICells');
    % 
    %     subplot(2,2,3);
    %     semilogxhist(remPopSeBinData);
    %     set(gca,'xscale','log');
    %     set(gca,'xlim',xle);
    %     yl = get(gca,'ylim');
    %     hold on;
    %     plot([median(remPopSeBinData) median(remPopSeBinData)],yl,'k','linewidth',2)
    %     ylabel('# seconds')
    %     title('REM - ECells');
    % 
    %     subplot(2,2,4);
    %     semilogxhist(remPopSiBinData);
    %     set(gca,'xscale','log');
    %     set(gca,'xlim',xli);
    %     yl = get(gca,'ylim');
    %     hold on;
    %     plot([median(remPopSiBinData) median(remPopSiBinData)],yl,'k','linewidth',2)
    %     ylabel('# seconds')
    %     title('REM - ICells');
    % 
    %     AboveTitle('Firing rates in 1s bins');


        %% Plot S rates and gamma
    %     figure;
    %     subplot(2,1,1)
    %     plot(smooth(nanzscore(baselinewakegammabandData),30))
    %     hold on;
    %     plot(smooth(nanzscore(wakePopSeBinData),30))
    %     plot(smooth(nanzscore(wakePopSiBinData),30))
    %     xlabel('cumulative seconds in state')
    %     ylabel('zscore')
    %     legend({'Gamma','E Cells','I Cells'})
    %     title('Wake')
    % 
    %     subplot(2,1,2)
    %     plot(smooth(nanzscore(baselineremgammabandData),30))
    %     hold on;
    %     plot(smooth(nanzscore(remPopSeBinData),30))
    %     plot(smooth(nanzscore(remPopSiBinData),30))
    %     xlabel('cumulative seconds in state')
    %     ylabel('zscore')
    %     legend({'Gamma','E Cells','I Cells'})
    %     title('REM')

        %% compare S rate and gamma
    %     figure;
    %     subplot(2,1,1)
    %     plot(smooth(nanzscore(baselinewakegammabandData),30))
    %     hold on;
    %     plot(smooth(nanzscore(wakePopSeBinData),30))
    %     plot(smooth(nanzscore(wakePopSiBinData),30))
    %     plot(EIRbws*(1:length(EIRwake))-2.5,smooth(Data(EIRwake),6)+4);
    %     plot(smooth(zscore(Data(EMGwake)),30)-4);axis tight
    %     xlabel('cumulative seconds in state')
    %     ylabel('zscore/offset zscore')
    %     legend({'Gamma','E Cells','I Cells','E:I Ratio','EMG'})
    %     title('Wake')
    % 
    %     subplot(2,1,2)
    %     plot(smooth(nanzscore(baselineremgammabandData),30))
    %     hold on;
    %     plot(smooth(nanzscore(remPopSeBinData),30))
    %     plot(smooth(nanzscore(remPopSiBinData),30))
    %     plot(EIRbws*(1:length(EIRrem))-2.5,smooth(Data(EIRrem),6)+4);
    %     plot(smooth(zscore(Data(EMGrem)),30)-4);axis tight
    %     xlabel('cumulative seconds in state')
    %     ylabel('zscore/offset zscore')
    %     legend({'Gamma','E Cells','I Cells','E:I Ratio','EMG'})
    %     title('REM')

        EWakeGeneralMatrix = cat(2,baselinewakegammabandData,wakePopSeBinData,ERateGroupWakeRates{bw}');
        IWakeGeneralMatrix = cat(2,baselinewakegammabandData,wakePopSiBinData);

        EREMGeneralMatrix = cat(2,baselineremgammabandData,remPopSeBinData,ERateGroupREMRates{bw}');
        IREMGeneralMatrix = cat(2,baselineremgammabandData,remPopSiBinData);

        rEWake = corr(EWakeGeneralMatrix);
        rEWake(find(bwdiag(length(rEWake)))) = 0;%zero the diag
        rIWake = corr(IWakeGeneralMatrix);
        rIWake(find(bwdiag(length(rIWake)))) = 0;%zero the diag
        rEREM = corr(EREMGeneralMatrix);
        rEREM(find(bwdiag(length(rEREM)))) = 0;%zero the diag
        rIREM = corr(IREMGeneralMatrix);
        rIREM(find(bwdiag(length(rIREM)))) = 0;%zero the diag

        r_AllEWake(a,bw) = rEWake(1,2);
        r_AllIWake(a,bw) = rIWake(1,2);
        r_AllEREM(a,bw) = rEREM(1,2);
        r_AllIREM(a,bw) = rIREM(1,2);

        r_SextilesEWake(a,:,bw) = rEWake(1,3:end);
        r_SextilesEREM(a,:,bw) = rEREM(1,3:end);

%         r_SextilesVsSextilesEWake = rEWake(3:end,3:end);
%         r_SextilesVsSextilesEREM = rEREM(3:end,3:end);

        %% correlation figures
    %     h = figure;
    %     subplot(2,2,1)
    %     [~, ~,~, r_ewake(a), ~, p] = logfit_bw(wakePopSeBinData,baselinewakegammabandData,'loglog');
    %     xlabel('E Rate')
    %     ylabel('Gamma power')
    %     title(['Wake.  r = ' num2str(r_ewake(a)) '. p = ' num2str(p) '.'])
    %     ylabel('r value')
    % 
    %     subplot(2,2,2)
    %     [~, ~,~, r_iwake(a), ~, p] = logfit_bw(wakePopSiBinData,baselinewakegammabandData,'loglog');
    %     xlabel('I Rate')
    %     ylabel('Gamma power')
    %     title(['Wake.  r = ' num2str(r_iwake(a)) '. p = ' num2str(p) '.'])
    %     ylabel('r value')
    % 
    %     subplot(2,2,3)
    %     [~, ~,~, r_erem(a), ~, p] = logfit_bw(remPopSiBinData,baselineremgammabandData,'loglog');
    %     xlabel('E Rate')
    %     ylabel('Gamma power')
    %     title(['REM.  r = ' num2str(r_erem(a)) '. p = ' num2str(p) '.'])
    %     xlabel('Hz')
    % 
    %     subplot(2,2,4)
    %     [~, ~,~, r_irem(a), ~, p] = logfit_bw(remPopSeBinData,baselineremgammabandData,'loglog');
    %     xlabel('I Rate')
    %     ylabel('Gamma power')
    %     title(['REM.  r = ' num2str(r_irem(a)) '. p = ' num2str(p) '.'])
    %     xlabel('Hz')
    % 
    %     close(h)
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

end


h = [];

h(end+1) = figure('position',[1 1 1000 800],'name','RatePowerByBinFreqAllSe');
subplot(2,2,1)
mesh(r_AllEWake)
% colormap(jet)
xlabel('Bin Size (s)')
set(gca,'XTickLabel',binwidthseclist)
ylabel('Frequency(Hz)')
yt = round(linspace(1,length(bandmeans),5));
set(gca,'ytick',yt)
set(gca,'YTickLabel',bandmeans(yt))
zlabel('Spike-LFP correlation (R)')
title_bw('Wake')

subplot(2,2,2)
mesh(r_AllEREM)
% colormap(jet)
xlabel('Bin Size (s)')
set(gca,'XTickLabel',binwidthseclist)
ylabel('Frequency(Hz)')
yt = round(linspace(1,length(bandmeans),5));
set(gca,'ytick',yt)
set(gca,'YTickLabel',bandmeans(yt))
zlabel('Spike-LFP correlation (R)')
title_bw('REM')

subplot(2,2,3)
imagesc(r_AllEWake')
axis xy
% colormap(jet)
xlabel('Frequency(Hz)')
xt = round(linspace(1,length(bandmeans),10));
set(gca,'xtick',xt)
set(gca,'xticklabel',bandmeans(xt))
ylabel('Bin Size (s)')
set(gca,'YTickLabel',binwidthseclist)
c = colorbar;
c.Label.String = 'Spike-LFP correlation (R)';
title_bw('WAKE')

subplot(2,2,4)
imagesc(r_AllEREM')
axis xy
% colormap(jet)
xlabel('Frequency(Hz)')
xt = round(linspace(1,length(bandmeans),10));
set(gca,'xtick',xt)
set(gca,'xticklabel',bandmeans(xt))
ylabel('Bin Size (s)')
set(gca,'YTickLabel',binwidthseclist)
c = colorbar;
c.Label.String = 'Spike-LFP correlation (R)';
title_bw('REM')
AboveTitle(['RatePowerByBin+Freq.  For all pE: ' basename])

%% Sextile plot
h(end+1) = figure('position',[1 1 900 800],'Name','RatePowerByBin+Freq+Sextile');
for a = 1:6
    subplot(2,3,a)
    imagesc(squeeze(r_SextilesEWake(:,a,:)))
    axis xy
    
    ylabel('Frequency(Hz)')
    yt = round(linspace(1,length(bandmeans),5));
    set(gca,'ytick',yt)
    set(gca,'yticklabel',bandmeans(yt))

    xlabel('Bin Size (s)')
    xt = get(gca,'xtick');
    set(gca,'XTickLabel',binwidthseclist(xt))
    
    colorbar
    
    tr = rate(oneSeries(Se(ERateGroupIdxs{a})))/length(ERateGroupIdxs{a});

    title_bw({['Rate Group ' num2str(a)];['FR=' num2str(tr)]})
end
AboveTitle(['RatePowerByBin+Freq+Sextile: ' basename])

MakeDirSaveFigsThere(fullfile(basepath,'GammaRatePowerFigs'),h)
MakeDirSaveFigsThere(fullfile(basepath,'GammaRatePowerFigs'),h,'png')
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