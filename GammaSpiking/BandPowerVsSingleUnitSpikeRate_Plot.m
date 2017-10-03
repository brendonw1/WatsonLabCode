function h = BandPowerVsSingleUnitSpikeRate_Plot(basepath,BandPowerVsSingleUnitSpikeRateData)

%% handling input variables
if ~exist('basepath','var')
    basepath = cd;
end
basename = bz_BasenameFromBasepath(basepath);

if ~exist('BandPowerVsSingleUnitSpikeRateData','var')
    load(fullfile(basepath,[basename '_BandPowerVsSingleUnitSpikeRateData']))
end
v2struct(BandPowerVsSingleUnitSpikeRateData);

load(fullfile(basepath,[basename '_EMGCorr.mat']))
EM = tsdArray(tsd(EMGCorr(:,1),EMGCorr(:,2)));

%get bin sets if not existant now
binwidthsecs = 1;%!!
if ~exist('AllTbins','var')
    for stidx = 1:length(stateslist)
        tst = stateslist{stidx};
        starts = [];
        ends = [];
        eval(['tSecsIN = StartEnd(' tst 'SecsIS);'])
        for sgidx = 1:size(tSecsIN,1)
            t = tSecsIN(sgidx,:);
            ts = (t(1):binwidthsecs:t(2)-binwidthsecs)';
            te = (t(1)+binwidthsecs:binwidthsecs:t(2))';
            starts = cat(1,starts,ts);
            ends = cat(1,ends,te);
        end
        eval([tst 'bins = intervalSet(starts,ends);'])
        eval(['EM_' tst ' = MakeSummedValQfromS(EM,' tst 'bins);'])%get chunked EMG data out
    end
end

%% Start plotting stuff
h = [];

% plot broadband power and whole-pop rate traces
h(end+1) = figure('name','RawBandPowerAndPopTracesOverlaid','position',[5 5 1200 800]);
subplot(3,2,1)
    hold on;
    plot(zscore(ExampleAllTSePop/numEcells/plotbinwidth)+5,'b');
    plot(zscore(ExampleAllTSiPop/numIcells/plotbinwidth),'r');
    plot(zscore(ExampleAllTBroadBand)-5,'k');
    plot(zscore(Data(EM_AllT))-10,'g');
    axis tight
    title('AllSecs')
subplot(3,2,2)
    hold on;
    plot(zscore(ExampleWakeSePop/numEcells/plotbinwidth)+5,'b');
    plot(zscore(ExampleWakeSiPop/numIcells/plotbinwidth),'r');
    plot(zscore(ExampleWakeBroadBand)-5,'k');
    plot(zscore(Data(EM_Wake))-10,'g');
    axis tight
    title('Wake')
subplot(3,2,3)
    hold on;
    plot(zscore(ExampleNremSePop/numEcells/plotbinwidth)+5,'b');
    plot(zscore(ExampleNremSiPop/numIcells/plotbinwidth),'r');
    plot(zscore(ExampleNremBroadBand)-5,'k');
    plot(zscore(Data(EM_Nrem))-10,'g');
    axis tight
    title('Nrem')
subplot(3,2,4)
    hold on;
    plot(zscore(ExampleRemSePop/numEcells/plotbinwidth)+5,'b');
    plot(zscore(ExampleRemSiPop/numIcells/plotbinwidth),'r');
    plot(zscore(ExampleRemBroadBand)-5,'k');
    plot(zscore(Data(EM_Rem))-10,'g');
    axis tight
    title('Rem')
subplot(3,2,5)
    hold on;
    plot(zscore(ExampleMaSePop/numEcells/plotbinwidth)+5,'b');
    plot(zscore(ExampleMaSiPop/numIcells/plotbinwidth),'r');
    plot(zscore(ExampleMaBroadBand)-5,'k');
    plot(zscore(Data(EM_Ma))-10,'g');
    axis tight
    title('Ma')
subplot(3,2,6);%dummy just for legend
    hold on;
    plot(zscore(ExampleMaSePop/numEcells/plotbinwidth)+5,'b');
    plot(zscore(ExampleMaSiPop/numIcells/plotbinwidth),'r');
    plot(zscore(ExampleMaBroadBand)-5,'k');
    plot(zscore(Data(EM_Ma))-10,'g');
    axis tight
    legend({'E';'I';'BBGamma';'LFP-EMG'},'location','northwest')
    set(gca,'visible','off')
    set(findobj('parent',gca,'type','line'),'visible','off')

%% Simple 1sec bin data correlation by bin
col = RainbowColors(5);
for iidx = 1:2
    if iidx == 1;
        celltype = 'E';
    elseif iidx == 2
        celltype = 'I';
    end
    
    h(end+1) = figure('position',[1 1 1200 800],'Name',['RatePowerByFreqFor' celltype 'Pop']);
    for stidx = 1:length(stateslist)
        tst = stateslist{stidx};
        eval(['thisr = r_All' celltype tst ';'])
        thisr = thisr(1:end-1,:,:);
        thisr = thisr(:,binwidthseclist==1);%1sec bin

        subplot(2,3,stidx)
        if ~isempty(thisr)
            plot(thisr)
            axis tight
            hold on
            xl = xlim(gca);
            plot(xl,[0 0],'k')
            ylim([-0.5 1])
            
            xlabel('Frequency(Hz)')
            xt = round(linspace(1,length(bandmeans),5));
            set(gca,'xtick',xt)
            set(gca,'xticklabel',bandmeans(xt))
            
            ylabel('Rate-Power Corr(r)')
            title(tst,'fontweight','normal')
            
            subplot(2,3,6)
            hold on
            tbidix = (binwidthseclist==plotbinwidth);
            plot(thisr,'color',col(stidx,:),'linewidth',2)
            hold on
            xl = xlim(gca);
            plot(xl,[0 0],'k')
            ylim([-0.5 1])

        end
    end
    subplot(2,3,6)
    legend(stateslist,'location','Southeast')
    title('bands at 1sec')

    AboveTitle({[celltype 'PopVsBands']})
end



    
% correlation plots of Whole-pop E cells vs broadband gamma
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
    title(['Nrem.  r = ' num2str(r) '. p = ' num2str(p) '.'])
subplot(3,2,4)
    try
        [~, ~,~, r, ~, p] = logfit_bw(ExampleRemSePop/numEcells/plotbinwidth,ExampleRemBroadBand,'linear');
        xlabel('E Rate')
        ylabel('BB Gamma')
    end
    title(['Rem.  r = ' num2str(r) '. p = ' num2str(p) '.'])   
subplot(3,2,5)
    try
        [~, ~,~, r, ~, p] = logfit_bw(ExampleMaSePop/numEcells/plotbinwidth,ExampleMaBroadBand,'linear');
        xlabel('E Rate')
        ylabel('BB Gamma')
    end
    title(['Ma.  r = ' num2str(r) '. p = ' num2str(p) '.'])
AboveTitle('E Population')
    
% correlation plots of Whole-pop I cells vs broadband gamma
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
    title(['Nrem.  r = ' num2str(r) '. p = ' num2str(p) '.'])
subplot(3,2,4)
    try
        [~, ~,~, r, ~, p] = logfit_bw(ExampleRemSiPop/numIcells/plotbinwidth,ExampleRemBroadBand,'linear');
        xlabel('I Rate')
        ylabel('BB Gamma')
    end
    title(['Rem.  r = ' num2str(r) '. p = ' num2str(p) '.'])
subplot(3,2,5)
    try
        [~, ~,~, r, ~, p] = logfit_bw(ExampleMaSiPop/numIcells/plotbinwidth,ExampleMaBroadBand,'linear');
        xlabel('I Rate')
        ylabel('BB Gamma')
    end
    title(['Ma.  r = ' num2str(r) '. p = ' num2str(p) '.'])
AboveTitle('I Population')

% Population Se correlate w power as dependent on bin size
h(end+1) = figure('position',[1 1 1000 800],'name','RatePowerByFreqAndBinForEPop');
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
imagesc(r_AllEMa')
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
title_bw('Ma')

subplot(2,3,5)
imagesc(r_AllENrem')
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
title_bw('Nrem')

subplot(2,3,6)
imagesc(r_AllERem')
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
title_bw('Rem')
AboveTitle(['RatePowerByBin+Freq.  For all pE: ' basename])

% Population Si correlate w power as dependent on bin size
h(end+1) = figure('position',[1 1 1000 800],'name','RatePowerByFreqAndBinForIPop');
subplot(2,3,1)
imagesc(r_AllIAllT')
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
imagesc(r_AllIWake')
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

% subplot(2,3,3)
% mesh(r_AllIWake)
% % colormap(jet)
% xlabel('Bin Size (s)')
% ylabel('Frequency(Hz)')
% zlabel('Spike-LFP correlation (R)')
% axis tight
% xt = get(gca,'Xtick');
% set(gca,'XTickLabel',binwidthseclist(xt))
% yt = get(gca,'Ytick');
% set(gca,'YTickLabel',bandmeans(yt))
% title_bw('Wake')

subplot(2,3,4)
imagesc(r_AllIMa')
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
title_bw('Ma')

subplot(2,3,5)
imagesc(r_AllINrem')
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
title_bw('Nrem')

subplot(2,3,6)
imagesc(r_AllIRem')
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
title_bw('Rem')
AboveTitle(['RatePowerByBin+Freq.  For all pI: ' basename])

%% Per-cell plot
col = RainbowColors(5);
% for iidx = 2
for iidx = 1:2
    if iidx == 1;
        celltype = 'E';
        rates = SeRates;
    elseif iidx == 2
        celltype = 'I';
        rates = SiRates;
    end
    
    
    eval(['tcellnum = num' celltype 'cells;'])
    for cidx = 1:tcellnum
        h(end+1) = figure('position',[1 1 1200 800],'Name',['RatePowerByFreqFor' celltype 'Cell' num2str(cidx)]);
        for sidx = 1:5%for each state
            switch sidx
                case 1
                    tstr = 'AllT';
                case 2
                    tstr = 'Wake';
                    eval(['thisr = r_Cells' celltype 'Wake;'])
                case 3
                    tstr = 'Nrem';
                    eval(['thisr = r_Cells' celltype 'Nrem;'])
                case 4
                    tstr = 'Rem';
                    eval(['thisr = r_Cells' celltype 'Rem;'])
                case 5
                    tstr = 'Ma';
                    eval(['thisr = r_Cells' celltype 'Ma;'])
            end
            eval(['thisr = r_Cells',celltype,tstr,';'])
            thisr = thisr(1:end-1,:,:);
            subplot(2,3,sidx)
            if ~isempty(thisr)
                imagesc(squeeze(thisr(:,cidx,:)))
                axis xy

                ylabel('Frequency(Hz)')
                yt = round(linspace(1,length(bandmeans),5));
                set(gca,'ytick',yt)
                set(gca,'yticklabel',bandmeans(yt))
                xlabel('Bin Size (s)')
                xt = get(gca,'xtick');
                set(gca,'XTickLabel',binwidthseclist(xt))
                colorbar
                title(tstr,'fontweight','normal')

                subplot(2,3,6)
                hold on
                tbidix = (binwidthseclist==plotbinwidth);
                plot(thisr(:,cidx,tbidix),'color',col(sidx,:),'linewidth',2)
            end
        end
        subplot(2,3,6)
        axis tight
        xlabel('Frequency(Hz)')
        xt = round(linspace(1,length(bandmeans),5));
        set(gca,'xtick',xt)
        set(gca,'xticklabel',bandmeans(xt))
        ylabel('r')
        legend({'AllT','Wake','Nrem','Rem','Ma'},'location','Southwest')
        title('bands at 1sec')

        if cidx>0
            tr = rates(cidx);
            AboveTitle({['Cell ' celltype ' ' num2str(cidx)];['FR=' num2str(tr)]})
        end
    end
end
    
MakeDirSaveFigsThere(fullfile(basepath,'GammaPowerRateFigs'),h)
MakeDirSaveFigsThere(fullfile(basepath,'GammaPowerRateFigs'),h,'png')



