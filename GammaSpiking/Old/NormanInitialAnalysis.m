%From BWRat20_101513


[~,basename] = fileparts(cd);
basepath = cd;

load([basename '.eegstates.mat'])
load([basename '_SSubtypes.mat'])
load([basename '_KetamineBinnedDataByIntervalState.mat'])
load([basename '_EIRatio.mat'])
load([basename '_EMGCorr.mat'])
fo = StateInfo.fspec{1}.fo;
to = StateInfo.fspec{1}.to;
spec = StateInfo.fspec{1}.spec;

%% timing: getting state-restricted second-wise bins to use for many purposes
wakesecsIS = KetamineBinnedDataByIntervalState.baselineStateIntervals.int1WAKE;
remsecsIS = KetamineBinnedDataByIntervalState.baselineStateIntervals.int1REM;
wakesecsIN = StartEnd(wakesecsIS);
remsecsIN = StartEnd(remsecsIS);
wakesecsIDX = INTtoIDX({wakesecsIN},length(spec),1);
remsecsIDX = INTtoIDX({remsecsIN},length(spec),1);

%restrict to a series of 1sec bins
starts = [];
ends = [];
for a = 1:size(wakesecsIN,1)
    t = wakesecsIN(a,:);
    ts = (t(1):t(2)-1)';
    te = (t(1)+1:t(2))';
    starts = cat(1,starts,ts);
    ends = cat(1,ends,te);
end
binwakesecs = intervalSet(starts,ends);

starts = [];
ends = [];
for a = 1:size(remsecsIN,1)
    t = remsecsIN(a,:);
    ts = (t(1):t(2)-1)';
    te = (t(1)+1:t(2))';
    starts = cat(1,starts,ts);
    ends = cat(1,ends,te);
end
binremsecs = intervalSet(starts,ends);

%%
EIR = tsd(EIRatioData.bincentertimes,EIRatioData.ZPCEI);
EIRwake = Restrict(EIR,binwakesecs);
EIRrem = Restrict(EIR,binremsecs);
EIRbws  = EIRatioData.binwidthsecs;

%%
EMGtsd = tsd(EMGCorr(:,1),EMGCorr(:,2));
EMGwake = MakeSummedValQfromS(tsdArray(EMGtsd),binwakesecs);
EMGrem = MakeSummedValQfromS(tsdArray(EMGtsd),binremsecs);

%% ploting by bands
gammabands = [25 30; 30 35; 40 45; 45 50; 50 60; 60 70; 70 80; 80 90; 90 100; 100 120; 120 140; 140 160];

for a = 1:size(gammabands,1)

    gammaidxs = (fo>gammabands(a,1) & fo<=gammabands(a,2));
    
    notchidxs = (fo>58 & fo<62);
    gammaidxs(gammaidxs & notchidxs) = [];
    
    gammaband = sum(spec(:,gammaidxs),2);
    gammabandtsd = tsd(1:length(gammaband),gammaband);
    gammabandtsdArray = tsdArray(gammabandtsd);

    baselinewakegammaband = MakeSummedValQfromS(gammabandtsdArray,binwakesecs);
    baselinewakegammabandData = Data(baselinewakegammaband);

    baselineremgammaband = MakeSummedValQfromS(gammabandtsdArray,binremsecs);
    baselineremgammabandData = Data(baselineremgammaband);

    figure
    subplot(2,1,1);
    semilogxhist(baselinewakegammabandData);
    set(gca,'xscale','log');
    axis tight
    xl = get(gca,'xlim');
    yl = get(gca,'ylim');
    hold on;
    plot([median(baselinewakegammabandData) median(baselinewakegammabandData)],yl,'k')
    ylabel('# seconds')
    title('Wake');

    subplot(2,1,2);
    semilogxhist(baselineremgammabandData);
    set(gca,'xscale','log');
    set(gca,'xlim',xl);
    yl = get(gca,'ylim');
    hold on;
    plot([median(baselineremgammabandData) median(baselineremgammabandData)],yl,'k')
    ylabel('# seconds')
    title('REM');

    AboveTitle('65-160Hz Band Power in 1s bins');

    %% Get per-bin (per-second) spike rates
    % wakePopSe = Data(Restrict(MakeQfromTsd(oneSeries(Se),1),wakesecsIS));
    % wakePopSi = Data(Restrict(MakeQfromTsd(oneSeries(Si),1),wakesecsIS));
    % remPopSe = Data(Restrict(MakeQfromTsd(oneSeries(Se),1),remsecsIS));
    % remPopSi = Data(Restrict(MakeQfromTsd(oneSeries(Si),1),remsecsIS));

    wakePopSeTsd = MakeQfromTsd(oneSeries(Se),binwakesecs);
    wakePopSeBinData = Data(wakePopSeTsd);
    wakePopSiTsd = MakeQfromTsd(oneSeries(Si),binwakesecs);
    wakePopSiBinData = Data(wakePopSiTsd);

    remPopSeTsd = MakeQfromTsd(oneSeries(Se),binremsecs);
    remPopSeBinData = Data(remPopSeTsd);
    remPopSiTsd = MakeQfromTsd(oneSeries(Si),binremsecs);
    remPopSiBinData = Data(remPopSiTsd);

    %% Plot distributions of spiking rates over seconds
    figure
    subplot(2,2,1);
    semilogxhist(wakePopSeBinData);
    set(gca,'xscale','log');
    axis tight
    xle = get(gca,'xlim');
    yl = get(gca,'ylim');
    hold on;
    plot([median(wakePopSeBinData) median(wakePopSeBinData)],yl,'k','linewidth',2)
    ylabel('# seconds')
    title('Wake - ECells');

    subplot(2,2,2);
    semilogxhist(wakePopSiBinData);
    set(gca,'xscale','log');
    axis tight
    xli = get(gca,'xlim');
    yl = get(gca,'ylim');
    hold on;
    plot([median(wakePopSiBinData) median(wakePopSiBinData)],yl,'k','linewidth',2)
    ylabel('# seconds')
    title('Wake - ICells');

    subplot(2,2,3);
    semilogxhist(remPopSeBinData);
    set(gca,'xscale','log');
    set(gca,'xlim',xle);
    yl = get(gca,'ylim');
    hold on;
    plot([median(remPopSeBinData) median(remPopSeBinData)],yl,'k','linewidth',2)
    ylabel('# seconds')
    title('REM - ECells');

    subplot(2,2,4);
    semilogxhist(remPopSiBinData);
    set(gca,'xscale','log');
    set(gca,'xlim',xli);
    yl = get(gca,'ylim');
    hold on;
    plot([median(remPopSiBinData) median(remPopSiBinData)],yl,'k','linewidth',2)
    ylabel('# seconds')
    title('REM - ICells');

    AboveTitle('Firing rates in 1s bins');


    %% Plot S rates and gamma
    figure;
    subplot(2,1,1)
    plot(smooth(nanzscore(baselinewakegammabandData),30))
    hold on;
    plot(smooth(nanzscore(wakePopSeBinData),30))
    plot(smooth(nanzscore(wakePopSiBinData),30))
    xlabel('cumulative seconds in state')
    ylabel('zscore')
    legend({'Gamma','E Cells','I Cells'})
    title('Wake')

    subplot(2,1,2)
    plot(smooth(nanzscore(baselineremgammabandData),30))
    hold on;
    plot(smooth(nanzscore(remPopSeBinData),30))
    plot(smooth(nanzscore(remPopSiBinData),30))
    xlabel('cumulative seconds in state')
    ylabel('zscore')
    legend({'Gamma','E Cells','I Cells'})
    title('REM')

    %% compare S rate and gamma
    figure;
    subplot(2,1,1)
    plot(smooth(nanzscore(baselinewakegammabandData),30))
    hold on;
    plot(smooth(nanzscore(wakePopSeBinData),30))
    plot(smooth(nanzscore(wakePopSiBinData),30))
    plot(EIRbws*(1:length(EIRwake))-2.5,smooth(Data(EIRwake),6)+4);
    plot(smooth(zscore(Data(EMGwake)),30)-4);axis tight
    xlabel('cumulative seconds in state')
    ylabel('zscore/offset zscore')
    legend({'Gamma','E Cells','I Cells','E:I Ratio','EMG'})
    title('Wake')

    subplot(2,1,2)
    plot(smooth(nanzscore(baselineremgammabandData),30))
    hold on;
    plot(smooth(nanzscore(remPopSeBinData),30))
    plot(smooth(nanzscore(remPopSiBinData),30))
    plot(EIRbws*(1:length(EIRrem))-2.5,smooth(Data(EIRrem),6)+4);
    plot(smooth(zscore(Data(EMGrem)),30)-4);axis tight
    xlabel('cumulative seconds in state')
    ylabel('zscore/offset zscore')
    legend({'Gamma','E Cells','I Cells','E:I Ratio','EMG'})
    title('REM')


    %% correlations
    figure;
    subplot(2,2,1)
    [~, ~,~, r_ewake(a), ~, p] = logfit_bw(wakePopSeBinData,baselinewakegammabandData,'loglog');
    xlabel('E Rate')
    ylabel('Gamma power')
    title(['Wake.  r = ' num2str(r) '. p = ' num2str(p) '.'])

    subplot(2,2,2)
    [~, ~,~, r_iwake(a), ~, p] = logfit_bw(wakePopSiBinData,baselinewakegammabandData,'loglog');
    xlabel('I Rate')
    ylabel('Gamma power')
    title(['Wake.  r = ' num2str(r) '. p = ' num2str(p) '.'])

    subplot(2,2,3)
    [~, ~,~, r_erem(a), ~, p] = logfit_bw(remPopSiBinData,baselineremgammabandData,'loglog');
    xlabel('E Rate')
    ylabel('Gamma power')
    title(['REM.  r = ' num2str(r) '. p = ' num2str(p) '.'])

    subplot(2,2,4)
    [~, ~,~, r_irem(a), ~, p] = logfit_bw(remPopSeBinData,baselineremgammabandData,'loglog');
    xlabel('I Rate')
    ylabel('Gamma power')
    title(['REM.  r = ' num2str(r) '. p = ' num2str(p) '.'])

end


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