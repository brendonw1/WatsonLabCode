function PopulationSpikeRateHistograms(basepath)
%histograms of second-wise population spike rates

%% constants
nhistbins = 100;
numspikerategroups = 6;
binwidthsecs = 1;%default bin width
numsmoothbins = 10;

%% manage inputs
if ~exist('basepath','var')
    basepath = cd;
end
basename = bz_BasenameFromBasepath(basepath);

load(fullfile(basepath,[basename '-states.mat']))
load(fullfile(basepath,[basename '_SSubtypes.mat']))
if exist('Se_TsdArrayFormat')
    Se = Se_TsdArrayFormat;
    Si = Si_TsdArrayFormat;
end    
if ~exist(fullfile(basepath,[basename '_StateRates.mat']))
    StateRates(basepath,basename);
end
sr = load(fullfile(basepath,[basename '_StateRates.mat']));


%% Bins/Timing: getting state-restricted second-wise bins to use for many purposes
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

%% Restrict to a series of bins and use those same bins for all timing ops thereafter so correlations can be done
%all
starts = [];
ends = [];
for sgidx = 1:size(alltsecsIN,1)
    t = alltsecsIN(sgidx,:);
    ts = (t(1):binwidthsecs:t(2)-1)';
    te = (t(1)+1:binwidthsecs:t(2))';
    starts = cat(1,starts,ts);
    ends = cat(1,ends,te);
end
alltbins = intervalSet(starts,ends);
%wake
starts = [];
ends = [];
for sgidx = 1:size(wakesecsIN,1)
    t = wakesecsIN(sgidx,:);
    ts = (t(1):binwidthsecs:t(2)-1)';
    te = (t(1)+1:binwidthsecs:t(2))';
    starts = cat(1,starts,ts);
    ends = cat(1,ends,te);
end
wakebins = intervalSet(starts,ends);
%ma
starts = [];
ends = [];
for sgidx = 1:size(masecsIN,1)
    t = masecsIN(sgidx,:);
    ts = (t(1):binwidthsecs:t(2)-1)';
    te = (t(1)+1:binwidthsecs:t(2))';
    starts = cat(1,starts,ts);
    ends = cat(1,ends,te);
end
mabins = intervalSet(starts,ends);
%nrem
starts = [];
ends = [];
for sgidx = 1:size(nremsecsIN,1)
    t = nremsecsIN(sgidx,:);
    ts = (t(1):binwidthsecs:t(2)-1)';
    te = (t(1)+1:binwidthsecs:t(2))';
    starts = cat(1,starts,ts);
    ends = cat(1,ends,te);
end
nrembins = intervalSet(starts,ends);
%rem
starts = [];
ends = [];
for sgidx = 1:size(remsecsIN,1)
    t = remsecsIN(sgidx,:);
    ts = (t(1):binwidthsecs:t(2)-1)';
    te = (t(1)+1:binwidthsecs:t(2))';
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
ERateGroupAllTRatesZ = [];
ERateGroupAllTRates = [];
ERateGroupWakeRatesZ = [];
ERateGroupWakeRates = [];
ERateGroupMARatesZ = [];
ERateGroupMARates = [];
ERateGroupNREMRatesZ = [];
ERateGroupNREMRates = [];
ERateGroupREMRatesZ = [];
ERateGroupREMRates = [];

for sgidx = 1:numspikerategroups
    ERateGroupIdxs{sgidx} = find(rankidxs==sgidx);
    ERateGroupCounts(sgidx) = sum(rankidxs==numspikerategroups);

    t = Data(MakeQfromTsd(oneSeries(Se(ERateGroupIdxs{sgidx})),alltbins));
    ERateGroupAllTRates(sgidx,:) = t./binwidthsecs/ERateGroupCounts(sgidx);
    ERateGroupAllTRatesZ(sgidx,:) = nanzscore(ERateGroupAllTRates(sgidx,:));

    t = Data(MakeQfromTsd(oneSeries(Se(ERateGroupIdxs{sgidx})),wakebins));
    ERateGroupWakeRates(sgidx,:) = t./binwidthsecs/ERateGroupCounts(sgidx);
    ERateGroupWakeRatesZ(sgidx,:) = nanzscore(ERateGroupWakeRates(sgidx,:));

    t = Data(MakeQfromTsd(oneSeries(Se(ERateGroupIdxs{sgidx})),mabins));
    ERateGroupMARates(sgidx,:) = t./binwidthsecs/ERateGroupCounts(sgidx);
    ERateGroupMARatesZ(sgidx,:) = nanzscore(ERateGroupMARates(sgidx,:));

    t = Data(MakeQfromTsd(oneSeries(Se(ERateGroupIdxs{sgidx})),nrembins));
    ERateGroupNREMRates(sgidx,:) = t./binwidthsecs/ERateGroupCounts(sgidx);
    ERateGroupNREMRatesZ(sgidx,:) = nanzscore(ERateGroupNREMRates(sgidx,:));

    t = Data(MakeQfromTsd(oneSeries(Se(ERateGroupIdxs{sgidx})),rembins));
    ERateGroupREMRates(sgidx,:) = t./binwidthsecs/ERateGroupCounts(sgidx);
    ERateGroupREMRatesZ(sgidx,:) = nanzscore(ERateGroupREMRates(sgidx,:));
end

%% Plotting
% E and I whole populations
h = figure('name','PopulationSpikeRateHistograms_AllCells','position',[100 1 1000 800]);
xls = [];

subplot(2,3,1,'xscale','log')
    hold on
    [centers_EAllSecs,counts_EAllSecs] = semilogxhist(alltPopSeBinData,nhistbins+1,0);
    plot(centers_EAllSecs,smooth(counts_EAllSecs,numsmoothbins),'color','g');
    if numIcells>0
        [centers_IAllSecs,counts_IAllSecs] = semilogxhist(alltPopSiBinData,nhistbins+1,0);
        plot(centers_IAllSecs,smooth(counts_IAllSecs,numsmoothbins),'color','r');
    else
        centers_IAllSecs = [];
        counts_IAllSecs = [];
    end
    axis tight
    title('All States')
    xls(end+1,:) = get(gca,'xlim');

subplot(2,3,2,'xscale','log')
    hold on
    [centers_EWake,counts_EWake] = semilogxhist(wakePopSeBinData,nhistbins+1,0);
    plot(centers_EWake,smooth(counts_EWake,numsmoothbins),'color','g');
    if numIcells > 0
        [centers_IWake,counts_IWake] = semilogxhist(wakePopSiBinData,nhistbins+1,0);
        plot(centers_IWake,smooth(counts_IWake,numsmoothbins),'color','r');
    else
        centers_IWake = [];
        counts_IWake = [];
    end        
    axis tight
    title('Wake')
    xls(end+1,:) = get(gca,'xlim');

subplot(2,3,3,'xscale','log')
    hold on
    [centers_ENREM,counts_ENREM] = semilogxhist(nremPopSeBinData,nhistbins+1,0);
    plot(centers_ENREM,smooth(counts_ENREM,numsmoothbins),'color','g');
    if numIcells>0
        [centers_INREM,counts_INREM] = semilogxhist(nremPopSiBinData,nhistbins+1,0);
        plot(centers_INREM,smooth(counts_INREM,numsmoothbins),'color','r');
    else
        centers_INREM = [];
        counts_INREM = [];
    end
    axis tight
    title('NREM')
    xls(end+1,:) = get(gca,'xlim');

subplot(2,3,4,'xscale','log')
    try
        hold on
        [centers_EREM,counts_EREM] = semilogxhist(remPopSeBinData,nhistbins+1,0);
        plot(centers_EREM,smooth(counts_EREM,numsmoothbins),'color','g');
        if numIcells>0
            [centers_IREM,counts_IREM] = semilogxhist(remPopSiBinData,nhistbins+1,0);
            plot(centers_IREM,smooth(counts_IREM,numsmoothbins),'color','r');
        else
            centers_IREM = [];
            counts_IREM = [];
        end
        axis tight
        title('REM')
        xls(end+1,:) = get(gca,'xlim');
    catch
        centers_EREM = [];
        counts_EREM = [];
        centers_IREM = [];
        counts_IREM = [];
    end
    
subplot(2,3,5,'xscale','log')
    try
        hold on
        [centers_EMA,counts_EMA] = semilogxhist(maPopSeBinData,nhistbins+1,0);
        plot(centers_EMA,smooth(counts_EMA,numsmoothbins),'color','g');
        if numIcells>0
            [centers_IMA,counts_IMA] = semilogxhist(maPopSiBinData,nhistbins+1,0);
            plot(centers_IMA,smooth(counts_IMA,numsmoothbins),'color','r');
        else
            centers_IMA = [];
            counts_IMA = [];
        end
        axis tight
        title('MA')
        xls(end+1,:) = get(gca,'xlim');
    catch
        centers_EMA = [];
        counts_EMA = [];
        centers_IMA = [];
        counts_IMA = [];
    end

subplot(2,3,6);%just for legend
    hold on
    %dummy plots
    plot(centers_EAllSecs,smooth(counts_EAllSecs,numsmoothbins),'color','g');
    plot(centers_IAllSecs,smooth(counts_IAllSecs,numsmoothbins),'color','r');
    bandmeannames{1} = 'E';
    bandmeannames{2} = 'I';
    legend(bandmeannames,'location','northwest')
    set(gca,'visible','off')
    set(findobj('parent',gca,'type','line'),'visible','off')
AboveTitle([basename ' E & I Cell pop rates'])

   % equalize all xlims
xlims(1,1) = min(xls(:,1));
xlims(1,2) = max(xls(:,2));
subplot(2,3,1)
set(gca,'xlim',xlims)
subplot(2,3,2)
set(gca,'xlim',xlims)
subplot(2,3,3)
set(gca,'xlim',xlims)
subplot(2,3,4)
set(gca,'xlim',xlims)
subplot(2,3,5)
set(gca,'xlim',xlims)

% E rate groups (sextiles)
h(end+1) = figure('name','PopulationSpikeRateHistograms_ECellRateGroups','position',[100 1 1000 800]);
c = RainbowColors(numspikerategroups);
xls = [];

subplot(2,3,1,'xscale','log')
    hold on
    for sgidx = 1:numspikerategroups
        [centers_Groups_AllSec(sgidx,:),counts_Groups_AllSec(sgidx,:)] = semilogxhist(ERateGroupAllTRates(sgidx,:),nhistbins+1,0);
        plot(centers_Groups_AllSec(sgidx,:),smooth(counts_Groups_AllSec(sgidx,:),numsmoothbins),'color',c(sgidx,:));
    end
    axis tight
    title('All States')
    xls(end+1,:) = get(gca,'xlim');

subplot(2,3,2,'xscale','log')
    hold on
    for sgidx = 1:numspikerategroups
        [centers_Groups_Wake(sgidx,:),counts_Groups_Wake(sgidx,:)] = semilogxhist(ERateGroupWakeRates(sgidx,:),nhistbins+1,0);
        plot(centers_Groups_Wake(sgidx,:),smooth(counts_Groups_Wake(sgidx,:),numsmoothbins),'color',c(sgidx,:));
    end
    axis tight
    title('Wake')
    xls(end+1,:) = get(gca,'xlim');

subplot(2,3,3,'xscale','log')
    hold on
    for sgidx = 1:numspikerategroups
        [centers_Groups_NREM(sgidx,:),counts_Groups_NREM(sgidx,:)] = semilogxhist(ERateGroupNREMRates(sgidx,:),nhistbins+1,0);
        plot(centers_Groups_NREM(sgidx,:),smooth(counts_Groups_NREM(sgidx,:),numsmoothbins),'color',c(sgidx,:));
    end
    axis tight
    title('NREM')
    xls(end+1,:) = get(gca,'xlim');

subplot(2,3,4,'xscale','log')
    try
        hold on
        for sgidx = 1:numspikerategroups
            [centers_Groups_REM(sgidx,:),counts_Groups_REM(sgidx,:)] = semilogxhist(ERateGroupREMRates(sgidx,:),nhistbins+1,0);
            plot(centers_Groups_REM(sgidx,:),smooth(counts_Groups_REM(sgidx,:),numsmoothbins),'color',c(sgidx,:));
        end
        axis tight
        title('REM')
        xls(end+1,:) = get(gca,'xlim');
    catch
        for sgidx = 1:numspikerategroups
            centers_Groups_REM = [];
            counts_Groups_REM = [];
        end
    end

subplot(2,3,5,'xscale','log')
    try
        hold on
        for sgidx = 1:numspikerategroups
            [centers_Groups_MA(sgidx,:),counts_Groups_MA(sgidx,:)] = semilogxhist(ERateGroupMARates(sgidx,:),nhistbins+1,0);
            plot(centers_Groups_MA(sgidx,:),smooth(counts_Groups_MA(sgidx,:),numsmoothbins),'color',c(sgidx,:));
        end
        axis tight
        title('MA')
        xls(end+1,:) = get(gca,'xlim');
    catch
        for sgidx = 1:numspikerategroups
            centers_Groups_MA = [];
            counts_Groups_MA = [];
        end
    end
    
subplot(2,3,6,'xscale','log')
    hold on
    %dummy plots
    for sgidx = 1:numspikerategroups
        plot(centers_Groups_AllSec(sgidx,:),smooth(counts_Groups_AllSec(sgidx,:),numsmoothbins),'color',c(sgidx,:));
        bandmeannames{sgidx} = num2str(sgidx);
    end
    legend(bandmeannames,'location','northwest')
    set(gca,'visible','off')
    set(findobj('parent',gca,'type','line'),'visible','off')

AboveTitle([basename ' Spike Rate Groups'])
   % equalize all xlims
xlims(1,1) = min(xls(:,1));
xlims(1,2) = max(xls(:,2));
subplot(2,3,1)
set(gca,'xlim',xlims)
subplot(2,3,2)
set(gca,'xlim',xlims)
subplot(2,3,3)
set(gca,'xlim',xlims)
subplot(2,3,4)
set(gca,'xlim',xlims)
subplot(2,3,5)
set(gca,'xlim',xlims)

    
    
PopulationSpikeRateHistogramsData = v2struct(...
    centers_EAllSecs,counts_EAllSecs,centers_IAllSecs,counts_IAllSecs,...
    centers_EWake,counts_EWake,centers_IWake,counts_IWake,...
    centers_ENREM,counts_ENREM,centers_INREM,counts_INREM,...
    centers_EREM,counts_EREM,centers_IREM,counts_IREM,...
    centers_EMA,counts_EMA,centers_IMA,counts_IMA,...
    centers_Groups_AllSec,counts_Groups_AllSec,...
    centers_Groups_Wake,counts_Groups_Wake,...
    centers_Groups_NREM,counts_Groups_NREM,...
    centers_Groups_REM,counts_Groups_REM,...
    centers_Groups_MA,counts_Groups_MA,...
    nhistbins,numspikerategroups,numsmoothbins,binwidthsecs);
save(fullfile(basepath,[basename '_PopulationSpikeRateHistogramData']),'PopulationSpikeRateHistogramsData')

%% save figure
MakeDirSaveFigsThere(fullfile(basepath,'GammaPowerRateFigs'),h,'fig')
MakeDirSaveFigsThere(fullfile(basepath,'GammaPowerRateFigs'),h,'png')
