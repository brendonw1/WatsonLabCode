function FrequencyBandPowerHistograms(basepath,basename)
%histograms of power in various bands based on wavelet spectrogram

%% constants
nhistbins = 100;
broadbandgammarange = [60 200];
numsmoothbins = 10;
lfpsamprate = 1250;
binwidthsecs = 1;%default bin width

%% manage inputs
if ~exist('basepath','var')
    basepath = cd;
end
if ~exist('basename','var')
    [~,basename] = fileparts(basepath);
end
load(fullfile(basepath,[basename '_WaveletForGamma.mat']))
load(fullfile(basepath,[basename '-states.mat']))


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

%% prep a bit for broadband measures
minbin = find(bandmeans>broadbandgammarange(1),1,'first');
maxbin = find(bandmeans<broadbandgammarange(2),1,'last');
broadbandpower = mean(amp(:,minbin:maxbin),2);
broadbandpowertsd = tsd((1:length(broadbandpower))/lfpsamprate,broadbandpower);
broadbandpowertsdArray = tsdArray(broadbandpowertsd);

%% plot 
idxs = 1:5:length(bandmeans);%subset
h = figure('name','FrequencyBandPowerHistograms','position',[100 100 1000 800]);
c = RainbowColors(length(idxs));

% each subplot is a state 
% all states
subplot(2,3,1,'xscale','log');
    hold on
    %gather power histograms for ALL bands
    for ix = 1:length(bandmeans)
        tbandpower = amp(:,ix);
        bandpowertsd = tsd((1:length(tbandpower))/lfpsamprate,tbandpower);
        bandpowertsdArray = tsdArray(bandpowertsd);
        alltband = MakeSummedValQfromS(bandpowertsdArray,alltbins);
        alltbandData = Data(alltband);
        [centers_allsecs(ix,:),counts_allsecs(ix,:)] = semilogxhist(alltbandData,nhistbins+1,0);
    end
    % gather broadband power in these time bins
    allbroadband = MakeSummedValQfromS(broadbandpowertsdArray,alltbins);
    allbroadbandData = Data(allbroadband);
    [broadbandcenters_allsecs,broadbandcounts_allsecs] = semilogxhist(allbroadbandData,nhistbins,0);

    %plot each selected band
    for ix = 1:length(idxs)
        tbandidx = idxs(ix);
        plot(centers_allsecs(tbandidx,:),smooth(counts_allsecs(tbandidx,:),numsmoothbins),'color',c(ix,:));
    end
    %plot broadband in black over top
    plot(broadbandcenters_allsecs,smooth(broadbandcounts_allsecs,numsmoothbins),'color','k','linewidth',3)

    axis tight
    title('AllStates')
    
%  wake
subplot(2,3,2,'xscale','log');
    hold on
    %gather power histograms for ALL bands
    for ix = 1:length(bandmeans)
        tbandpower = amp(:,ix);
        bandpowertsd = tsd((1:length(tbandpower))/lfpsamprate,tbandpower);
        bandpowertsdArray = tsdArray(bandpowertsd);
        alltband = MakeSummedValQfromS(bandpowertsdArray,wakebins);
        alltbandData = Data(alltband);
        [centers_wake(ix,:),counts_wake(ix,:)] = semilogxhist(alltbandData,nhistbins+1,0);
    end
    % gather broadband power
    allbroadband = MakeSummedValQfromS(broadbandpowertsdArray,wakebins);
    allbroadbandData = Data(allbroadband);
    [broadbandcenters_wake,broadbandcounts_wake] = semilogxhist(allbroadbandData,nhistbins,0);

    %plot each selected band
    for ix = 1:length(idxs)
        tbandidx = idxs(ix);
        plot(centers_wake(tbandidx,:),smooth(counts_wake(tbandidx,:),numsmoothbins),'color',c(ix,:));
    end
    %plot broadband in black over top
    plot(broadbandcenters_wake,smooth(broadbandcounts_wake,numsmoothbins),'color','k','linewidth',3)

    axis tight
    title('WAKE')

%  nrem
subplot(2,3,3,'xscale','log');
    hold on
    %gather power histograms for ALL bands
    for ix = 1:length(bandmeans)
        tbandpower = amp(:,ix);
        bandpowertsd = tsd((1:length(tbandpower))/lfpsamprate,tbandpower);
        bandpowertsdArray = tsdArray(bandpowertsd);
        alltband = MakeSummedValQfromS(bandpowertsdArray,nrembins);
        alltbandData = Data(alltband);
        [centers_nrem(ix,:),counts_nrem(ix,:)] = semilogxhist(alltbandData,nhistbins+1,0);
    end
    % gather broadband power
    allbroadband = MakeSummedValQfromS(broadbandpowertsdArray,nrembins);
    allbroadbandData = Data(allbroadband);
    [broadbandcenters_nrem,broadbandcounts_nrem] = semilogxhist(allbroadbandData,nhistbins,0);

    %plot each selected band
    for ix = 1:length(idxs)
        tbandidx = idxs(ix);
        plot(centers_nrem(tbandidx,:),smooth(counts_nrem(tbandidx,:),numsmoothbins),'color',c(ix,:));
    end
    %plot broadband in black over top
    plot(broadbandcenters_nrem,smooth(broadbandcounts_nrem,numsmoothbins),'color','k','linewidth',3)

    axis tight
    title('NREM')
    AboveTitle

%  rem
subplot(2,3,4,'xscale','log');
    hold on
    try
        %gather power histograms for ALL bands
        for ix = 1:length(bandmeans)
            tbandpower = amp(:,ix);
            bandpowertsd = tsd((1:length(tbandpower))/lfpsamprate,tbandpower);
            bandpowertsdArray = tsdArray(bandpowertsd);
            alltband = MakeSummedValQfromS(bandpowertsdArray,rembins);
            alltbandData = Data(alltband);
            [centers_rem(ix,:),counts_rem(ix,:)] = semilogxhist(alltbandData,nhistbins+1,0);
        end
        % gather broadband power
        allbroadband = MakeSummedValQfromS(broadbandpowertsdArray,rembins);
        allbroadbandData = Data(allbroadband);
        [broadbandcenters_rem,broadbandcounts_rem] = semilogxhist(allbroadbandData,nhistbins,0);

        %plot each selected band
        for ix = 1:length(idxs)
            tbandidx = idxs(ix);
            plot(centers_rem(tbandidx,:),smooth(counts_rem(tbandidx,:),numsmoothbins),'color',c(ix,:));
        end
        %plot broadband in black over top
        plot(broadbandcenters_rem,smooth(broadbandcounts_rem,numsmoothbins),'color','k','linewidth',3)

        axis tight
    catch
        centers_rem = [];
        counts_rem = []
        broadbandcenters_rem = [];
        broadbandcounts_rem = [];
    end
    title('REM')
    
%  ma
subplot(2,3,5,'xscale','log');
    try
        hold on
        %gather power histograms for ALL bands
        for ix = 1:length(bandmeans)
            tbandpower = amp(:,ix);
            bandpowertsd = tsd((1:length(tbandpower))/lfpsamprate,tbandpower);
            bandpowertsdArray = tsdArray(bandpowertsd);
            alltband = MakeSummedValQfromS(bandpowertsdArray,mabins);
            alltbandData = Data(alltband);
            [centers_ma(ix,:),counts_ma(ix,:)] = semilogxhist(alltbandData,nhistbins+1,0);
        end
        % gather broadband power
        allbroadband = MakeSummedValQfromS(broadbandpowertsdArray,mabins);
        allbroadbandData = Data(allbroadband);
        [broadbandcenters_ma,broadbandcounts_ma] = semilogxhist(allbroadbandData,nhistbins,0);

        %plot each selected band
        for ix = 1:length(idxs)
            tbandidx = idxs(ix);
            plot(centers_ma(tbandidx,:),smooth(counts_ma(tbandidx,:),numsmoothbins),'color',c(ix,:));
        end
        %plot broadband in black over top
        plot(broadbandcenters_ma,smooth(broadbandcounts_ma,numsmoothbins),'color','k','linewidth',3)

        axis tight
    catch
        centers_ma = [];
        counts_ma = []
        broadbandcenters_ma = [];
        broadbandcounts_ma = [];
    end
    title('MA')    
    
subplot(2,3,6);%just for legend
    hold on
    %dummy plots
    for ix = 1:length(idxs)
        tbandidx = idxs(ix);
        plot(centers_allsecs(tbandidx,:),smooth(counts_allsecs(tbandidx,:),numsmoothbins),'color',c(ix,:));
        bandmeannames{ix} = num2str(bandmeans(tbandidx));
    end
    plot(broadbandcenters_allsecs,smooth(broadbandcounts_allsecs,numsmoothbins),'color','k','linewidth',3)    
    bandmeannames{end+1} = [num2str(broadbandgammarange(1)) '-' num2str(broadbandgammarange(2))];
    legend(bandmeannames,'location','northwest')
    set(gca,'visible','off')
    set(findobj('parent',gca,'type','line'),'visible','off')

%% save data
FrequencyBandPowerHistogramsData = v2struct(bandmeans,...
    centers_allsecs,counts_allsecs,centers_wake,counts_wake,centers_nrem,counts_nrem,centers_rem,counts_rem,centers_ma,counts_ma,...
    broadbandcenters_allsecs,broadbandcounts_allsecs,broadbandcenters_wake,broadbandcounts_wake,broadbandcenters_nrem,broadbandcounts_nrem,broadbandcenters_rem,broadbandcounts_rem,broadbandcenters_ma,broadbandcounts_ma,...
    nhistbins,broadbandgammarange,numsmoothbins,lfpsamprate,binwidthsecs);
save(fullfile(basepath,[basename '_FrequencyBandPowerHistogramData']),'FrequencyBandPowerHistogramsData')

%% save figure
MakeDirSaveFigsThere(fullfile(basepath,'GammaPowerRateFigs'),h,'fig')
MakeDirSaveFigsThere(fullfile(basepath,'GammaPowerRateFigs'),h,'png')
