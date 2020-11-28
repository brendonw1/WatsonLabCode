function PlotGathered_SpikeTriggeredWaveletAndPopEI

load(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','GatheredData','PerCellWaveletSpectrumData.mat'))
saveloc = fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','SpikeTriggeredWavelets','DatasetMeans');

v2struct(PerCellWaveletSpectrumData);

% t = PerCellWaveletSpectrumData;
%plot mean-over-cells correlations across bands - spectrogram-like
celltypeslist = {'E','I'};
stateslist = {'AllT','Wake','Nrem','Rem','Ma'};
lfpsourcelist = {'home','nsmean','neib'};
ECellIdxs = CellTypes==1;
ICellIdxs = CellTypes==-1;
sampsperspec = size(percellspectrum_home_AllT,1);
baseints = [[1 round(sampsperspec*0.2)]; [round(sampsperspec*.8) sampsperspec]];

%% start plots
h = [];
ax = [];
for iidx = 1:length(celltypeslist)
    celltype = celltypeslist{iidx};

    h(end+1) = figure('name',[celltype 'CellAverageSpectra']);
    for lidx = 1:3
        tlfps = lfpsourcelist{lidx};

        eval(['tSpect = nanmean(percellspectrum_' tlfps '_AllT(:,:,' celltype 'CellIdxs),3);'])
        eval(['tEspikes = nanmean(percellpopspikesE_AllT(:,' celltype 'CellIdxs),2);'])
        eval(['tIspikes = nanmean(percellpopspikesI_AllT(:,' celltype 'CellIdxs),2);'])

        ax(end+1) = subplot(2,3,lidx);
        plotspectlocal(tSpect,tEspikes,tIspikes,secbefore(1),secafter(1),sampfreq(1),bandmeans{1},baseints)
        colorbar
        title(tlfps)
    end
    for stidx = 2:4
        tst = stateslist{stidx};

        eval(['tSpect = nanmean(percellspectrum_neib_' tst '(:,:,' celltype 'CellIdxs),3);'])
        eval(['tEspikes = nanmean(percellpopspikesE_' tst '(:,' celltype 'CellIdxs),2);'])
        eval(['tIspikes = nanmean(percellpopspikesI_' tst '(:,' celltype 'CellIdxs),2);'])

        ax(end+1) = subplot(2,3,stidx-1+3);
        plotspectlocal(tSpect,tEspikes,tIspikes,secbefore(1),secafter(1),sampfreq(1),bandmeans{1},baseints)
        colorbar
        title(tst)
    end
    AboveTitle([celltype '-Triggered Averages'])
end

%Vary zooms and save
set(ax,'xlim',[-1 1])
set(h(1),'name',['ECellAverageSpectra_PlusMinus1000ms'])
set(h(2),'name',['ICellAverageSpectra_PlusMinus1000ms'])
MakeDirSaveFigsThere(fullfile(saveloc,'SpikeTriggeredWaveletsAndEI'),h,'fig')
MakeDirSaveFigsThere(fullfile(saveloc,'SpikeTriggeredWaveletsAndEI'),h,'png')

set(ax,'xlim',[-.3 .3])
set(h(1),'name',['ECellAverageSpectra_PlusMinus300ms'])
set(h(2),'name',['ICellAverageSpectra_PlusMinus300ms'])
MakeDirSaveFigsThere(fullfile(saveloc,'SpikeTriggeredWaveletsAndEI'),h,'png')

set(ax,'xlim',[-.1 .1])
set(h(1),'name',['ECellAverageSpectra_PlusMinus100ms'])
set(h(2),'name',['ICellAverageSpectra_PlusMinus100ms'])
MakeDirSaveFigsThere(fullfile(saveloc,'SpikeTriggeredWaveletsAndEI'),h,'png')

set(ax,'xlim',[-.03 .03])
set(h(1),'name',['ECellAverageSpectra_PlusMinus30ms'])
set(h(2),'name',['ICellAverageSpectra_PlusMinus30ms'])
MakeDirSaveFigsThere(fullfile(saveloc,'SpikeTriggeredWaveletsAndEI'),h,'png')
    
set(ax,'xlim',[-.01 .01])
set(h(1),'name',['ECellAverageSpectra_PlusMinus10ms'])
set(h(2),'name',['ICellAverageSpectra_PlusMinus10ms'])
MakeDirSaveFigsThere(fullfile(saveloc,'SpikeTriggeredWaveletsAndEI'),h,'png')

close h


%% Plotting waveforms vs impact on spectrum
[h2,SizeVsBandPowerRPS] = plotspectralamplitudesbywaveformsize(percellspectrum_home_AllT,percellspectrum_nsmean_AllT,percellspectrum_neib_AllT,waves,waveamps,eegwaves,bandmeans{1},sampfreq(1));
MakeDirSaveFigsThere(fullfile(saveloc,'CorrsOfSpikeAmpVsBandDisturbance'),h,'fig')
MakeDirSaveFigsThere(fullfile(saveloc,'CorrsOfSpikeAmpVsBandDisturbance'),h,'png')

%% Save one more variable
PerCellWaveletSpectrumData.SizeVsBandPowerRPS = SizeVsBandPowerRPS;
save(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','GatheredData','PerCellWaveletSpectrumData.mat'),'PerCellWaveletSpectrumData','-v7.3')


function plotspectlocal(spectdata,sedata,sidata,secbefore,secafter,sampfreq,bandmeans,baseints)

linefor50 = find(bandmeans<50,1,'last');
linefor180 = find(bandmeans<180,1,'last');

xdata = -secbefore:1/sampfreq:secafter;
ydata = 1:length(bandmeans);

% may just zscore or may zscore to a particular interval
% specttoshow = zscore(spectdata)';
specttoshow = ZScoreToInt(spectdata,baseints)';

imagesc('XData',xdata,'YData',ydata,'CData',specttoshow);
%normalize to baseline

axis xy tight
yl = get(gca,'ylim');
hold on; 
plot([-secbefore secafter],[linefor50 linefor50],'b')
plot([-secbefore secafter],[linefor180 linefor180],'b')
xlabel('sec')
ylabel('Hz')
% xlim([-.03 .03])

%add a new area and plot E and I spiking data
xl = get(gca,'XLim');
windowwidth = abs(diff(yl))*0.3;
yltot = yl;
yltot(2) =  yl(2)+windowwidth;
ylim([yltot])
rectangle('position',[xl(1) yl(2) diff(xl) windowwidth])
plot([0 0],yltot,'k')

set(gca,'ytick',1:length(bandmeans))
set(gca,'YTickLabel',bandmeans)

plot(xdata,smooth(yl(2) + windowwidth*bwnormalize(sidata),10),'r')
plot(xdata,smooth(yl(2) + windowwidth*bwnormalize(sedata),10),'g')


function [h,RPSs] = plotspectralamplitudesbywaveformsize(percellspectrum,percellspectrum_nsmean,percellspectrum_neib,waves,waveamps,eegwaves,bandmeans,sampfreq)
secondseitherside = 0.005;
pointsperside_wv = round(secondseitherside*sampfreq);
pointspercell_wv = 2*pointsperside_wv+1 +1;
% pointspercell_max = size(percellspectrum,2);
pointspercell_spk = size(waves,1);
pointspercell_eeg = size(waves,1);

ampsmtx = nan(size(percellspectrum,2), size(percellspectrum,3)*pointspercell_wv);
nsmeanampsmtx = ampsmtx;
% spkcatwaves = nan(1,size(percellspectrum,3)*pointspercell_spk);
% eegcatwaves = nan(1,size(percellspectrum,3)*pointspercell_eeg);

[waveampssorted,ix] = sort(waveamps);

for a = 1:size(percellspectrum,3);
    %local max channel spectrum per spike
    t = percellspectrum(:,:,ix(a));
    t = t(round(sampfreq-0.005*sampfreq):round(sampfreq+0.005*sampfreq),:);
    t = cat(2,t',zeros(size(percellspectrum,2),1));
    ampsmtx(:,a*pointspercell_wv-pointspercell_wv+1:a*pointspercell_wv) = t;
    ampsmax(a,:) = max(t,[],2)';

    %mean of all non-shank channels... wavelet spectrum per spike
    t = percellspectrum_nsmean(:,:,ix(a));
    t = t(round(sampfreq-0.005*sampfreq):round(sampfreq+0.005*sampfreq),:);
    t = cat(2,t',zeros(size(percellspectrum,2),1));
    nsmeanampsmtx(:,a*pointspercell_wv-pointspercell_wv+1:a*pointspercell_wv) = t;
    nsmeanampsmax(a,:) = max(t,[],2)';

    %mean of channels from neighboring shanks... wavelet spectrum per spike
    t = percellspectrum_neib(:,:,ix(a));
    t = t(round(sampfreq-0.005*sampfreq):round(sampfreq+0.005*sampfreq),:);
    t = cat(2,t',zeros(size(percellspectrum,2),1));
    neibmeanampsmtx(:,a*pointspercell_wv-pointspercell_wv+1:a*pointspercell_wv) = t;
    neibmeanampsmax(a,:) = max(t,[],2)';
    
    % grabbing waveforms themselves
%     spkcatwaves(1,(a-1)*pointspercell_spk+1 : a*pointspercell_spk) = waves(:,ix(a))';
%     eegcatwaves(1,(a-1)*pointspercell_eeg+1 : a*pointspercell_eeg) = eegwaves(:,ix(a))';
end    

%% Plot raw waves and their spectra
% ydata = 1:length(bandmeans);
% h2 = figure('name',[basename '_SpikeWaveletRawData'],'position',[5 5 1000 800]);
% subplot(14,1,1)
%     plot(spkcatwaves)
%     axis tight
%     ylabel('Raw')
%     set(gca,'Xtick',[])
% subplot(14,1,2)
%     plot(eegcatwaves)
%     axis tight
%     ylabel('EEG')
%     set(gca,'Xtick',[])
% subplot(14,1,3:6)
%     imagesc('YData',ydata,'CData',ampsmtx);
%     axis tight
%     yticks = get(gca,'YTick');
%     set(gca,'YTickLabel',bandmeans(yticks))
%     ylabel('Hz')
%     ylabel('This channel')
%     set(gca,'Xtick',[])
% subplot(14,1,7:10)
%     imagesc('YData',ydata,'CData',neibmeanampsmtx);
%     axis tight
%     yticks = get(gca,'YTick');
%     set(gca,'YTickLabel',bandmeans(yticks))
%     ylabel('Hz')
%     ylabel('Neighb shanks')
%     set(gca,'Xtick',[])
% subplot(14,1,11:14)
%     imagesc('YData',ydata,'CData',nsmeanampsmtx);
%     axis tight
%     yticks = get(gca,'YTick');
%     set(gca,'YTickLabel',bandmeans(yticks))
%     ylabel('Hz')
%     ylabel('Non-shank mean')
%     set(gca,'Xtick',[])


%find universal scaling
1;
yl_h = [min(min(ampsmax)) max(max(ampsmax))];
yl_n = [min(min(neibmeanampsmax)) max(max(neibmeanampsmax))];
yl_nm = [min(min(nsmeanampsmax)) max(max(nsmeanampsmax))];
yl = cat(1,yl_h,yl_n,yl_nm);
yl = [min(yl(:,1)) max(yl(:,2))];
%start plotting
h = [];
% correlate spike size with amplitude sizes
h = figure('name',['SpikeWaveletMaxChanCorrelation'],'position',[10 5 1000 1000]);
ax = axes;
% cmap = makeColorMap([1 1 .5],[1 0 0],size(percellspectrum,2));
cmap = flipud(RainbowColors(size(percellspectrum,2)+1));
cmap(end-1,:) = [];%not enough difference in red end... added an extra above and taking out row 2
for a = 1:size(percellspectrum,2)
    [HomeSs(a),~,~,HomeRs(a),~,HomePs(a)] = logfit_bw(waveampssorted*1000,ampsmax(:,a),'linear','markercolor',cmap(a,:),'linecolor',cmap(a,:));
    freqlabels{a} = [num2str(bandmeans(a)) 'Hz: slope=' num2str(HomeSs(a)) ' r=' num2str(HomeRs(a)) ' p=' num2str(HomePs(a))];
    hold on
end
ylim(yl)
fitlines = findobj('parent',ax,'tag','fitline');
legend(fitlines,fliplr(freqlabels),'location','northwest');
xlabel('mV')
ylabel('Wavelet power')

% correlate spike size with amplitude sizes
h(end+1) = figure('name',['SpikeWaveletNeighborShankChanCorrelation'],'position',[10 5 1000 1000]);
ax = axes;
% cmap = makeColorMap([1 1 .5],[1 0 0],size(percellspectrum,2));
cmap = flipud(RainbowColors(size(percellspectrum,2)+1));
cmap(end-1,:) = [];%not enough difference in red end... added an extra above and taking out row 2
for a = 1:size(percellspectrum,2)
    [NeibSs(a),~,~,NeibRs(a),~,NeibPs(a)] = logfit_bw(waveampssorted*1000,neibmeanampsmax(:,a),'linear','markercolor',cmap(a,:),'linecolor',cmap(a,:));
    freqlabels{a} = [num2str(bandmeans(a)) 'Hz: slope=' num2str(NeibSs(a)) ' r=' num2str(NeibRs(a)) ' p=' num2str(NeibPs(a))];
    hold on
end
ylim(yl)
fitlines = findobj('parent',ax,'tag','fitline');
legend(fitlines,fliplr(freqlabels),'location','northeast');
xlabel('mV')
ylabel('Wavelet power')


% correlate spike size with amplitude sizes
h(end+1) = figure('name',['SpikeWaveletNonShankChanCorrelation'],'position',[10 5 1000 1000]);
ax = axes;
% cmap = makeColorMap([1 1 .5],[1 0 0],size(percellspectrum,2));
cmap = flipud(RainbowColors(size(percellspectrum,2)+1));
cmap(end-1,:) = [];%not enough difference in red end... added an extra above and taking out row 2
for a = 1:size(percellspectrum,2)
    [NonShankSs(a),~,~,NonShankRs(a),~,NonShankPs(a)] = logfit_bw(waveampssorted*1000,nsmeanampsmax(:,a),'linear','markercolor',cmap(a,:),'linecolor',cmap(a,:));
    freqlabels{a} = [num2str(bandmeans(a)) 'Hz: slope=' num2str(NonShankSs(a)) ' r=' num2str(NonShankRs(a)) ' p=' num2str(NonShankPs(a))];
    hold on
end
ylim(yl)
fitlines = findobj('parent',ax,'tag','fitline');
legend(fitlines,fliplr(freqlabels),'location','northeast');
xlabel('mV')
ylabel('Wavelet power')

RPSs = v2struct(HomeSs,HomeRs,HomePs,...
    NeibSs,NeibRs,NeibPs,...
    NonShankSs,NonShankRs,NonShankPs);
