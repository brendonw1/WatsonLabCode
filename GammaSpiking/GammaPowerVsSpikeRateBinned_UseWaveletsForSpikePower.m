function GammaPowerVsSpikeRateBinned_UseWaveletsForSpikePower(basepath,basename)

%% Constants
numspikerategroups = 6;
binwidthseclist = [0.01,0.02,0.05,0.1,0.2,0.5,1,2,5,10,20];

%% Loading up
if ~exist('basepath','var')
    [~,basename] = fileparts(cd);
    basepath = cd;
end

load([basename '_WaveletForSpikePower.mat'],'bandmeans')
load([basename '_WaveletForSpikePower.mat'],'ChannelsDone')
load([basename '_WaveletForSpikePower.mat'],'ChannelMean')

load([basename '_SSubtypes.mat'])
load([basename '-states.mat'])
% load([basename '_EIRatio.mat'])
sr = load(fullfile(basepath,[basename '_StateRates.mat']));
%     load([basename '_EMGCorr.mat'])

%% Bins/Timing: getting state-restricted second-wise bins to use for many purposes
ss = IDXtoINT(states);
wakesecsIN = ss{1};
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


for bw = 1:length(binwidthseclist)%for each bin width
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

    %% get rates of different sextile groups
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

    %% grabbing by band
    for a = 1:length(bandmeans)
        bandpower = ChannelMean(:,a);
        bandpowertsd = tsd((1:length(bandpower))/1250,bandpower);
        bandpowertsdArray = tsdArray(bandpowertsd);

        baselinewakegammaband = MakeSummedValQfromS(bandpowertsdArray,wakebins);
        baselinewakegammabandData = Data(baselinewakegammaband);

        baselineremgammaband = MakeSummedValQfromS(bandpowertsdArray,rembins);
        baselineremgammabandData = Data(baselineremgammaband);

        wakePopSeTsd = MakeQfromTsd(oneSeries(Se),wakebins);
        wakePopSeBinData = Data(wakePopSeTsd);
        wakePopSiTsd = MakeQfromTsd(oneSeries(Si),wakebins);
        wakePopSiBinData = Data(wakePopSiTsd);

        remPopSeTsd = MakeQfromTsd(oneSeries(Se),rembins);
        remPopSeBinData = Data(remPopSeTsd);
        remPopSiTsd = MakeQfromTsd(oneSeries(Si),rembins);
        remPopSiBinData = Data(remPopSiTsd);


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

    end

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
