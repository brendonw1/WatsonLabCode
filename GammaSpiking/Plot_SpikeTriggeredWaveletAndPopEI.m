function Plot_SpikeTriggeredWaveletAndPopEI(basepath)

if ~exist('basepath','var')
    basepath = cd;
end
basename = bz_BasenameFromBasepath(basepath);

load(fullfile(basepath,[basename '_SpikeTriggeredWaveletAndPopEI']));
v2struct(PerCellWaveletSpectrumData)

%% Plotting waveforms vs impact on spectrum
h2 = plotspectralamplitudesbywaveformsize(percellspectrum_home_AllT,percellspectrum_nsmean_AllT,percellspectrum_neib_AllT,waves,waveamps,eegwaves,bandmeans,sampfreq,basename);
MakeDirSaveFigsThere(fullfile(basepath,'SpikeSpectrumFigs','SpikeTriggeredWaveletsMaxChan'),h2,'fig')
MakeDirSaveFigsThere(fullfile(basepath,'SpikeSpectrumFigs','SpikeTriggeredWaveletsMaxChan'),h2,'png')

%% Per cell plots - broken as of now
percell = 0;
if percell
    h = [];
    ax = [];
    for cidx = 1:size(percellspectrum_home_AllT,3);
        h(end+1) = figure;
        subplot(3,3,1);
            hold on
            plot(waves*1000,'k');
            plot(waves(:,cidx)*1000,'r')
            ylabel('mV')
            title('This wave in red')
    %         ax(end+1) = subplot(3,3,2);
    %             data = percellspectrum_chmean(:,:,a);
    %             sedata = percellpopspikesE(:,a);
    %             sidata = percellpopspikesI(:,a);
    %             plotspectlocal(data,sedata,sidata,secbefore,secafter,sampfreq,bandmeans)
    %             title(['Total, ChannelMean. N=' num2str(percellcounts.all(a))])
        ax(end+1) = subplot(3,3,2);
            data = percellspectrum_nsmean_AllT(:,:,cidx);
            sedata = percellpopspikesE_AllT(:,cidx);
            sidata = percellpopspikesI_AllT(:,cidx);
            plotspectlocal(data,sedata,sidata,secbefore,secafter,sampfreq,bandmeans)
            title(['Total, NonShankMean. N=' num2str(percellcounts.all(cidx))])
        ax(end+1) = subplot(3,3,3);
            data = percellspectrum_home_AllT(:,:,cidx);
            sedata = percellpopspikesE_AllT(:,cidx);
            sidata = percellpopspikesI_AllT(:,cidx);
            plotspectlocal(data,sedata,sidata,secbefore,secafter,sampfreq,bandmeans)
            title(['Total, Home Channel. N=' num2str(percellcounts.all(cidx))])
        ax(end+1) = subplot(3,3,4);
            data = percellspectrum_wake(:,:,cidx);
            sedata = percellpopspikesE_Wake(:,cidx);
            sidata = percellpopspikesI_Wake(:,cidx);
            plotspectlocal(data,sedata,sidata,secbefore,secafter,sampfreq,bandmeans)
            title(['WakeTotal. N=' num2str(percellcounts.wake(cidx))])
    %         ax(end+1) = subplot(3,3,5);
    %             data = percellspectrum_wakemove5(:,:,a);
    %             sedata = percellpopspikesE_wakemove5(:,a);
    %             sidata = percellpopspikesI_wakemove5(:,a);
    %             plotspectlocal(data,sedata,sidata,secbefore,secafter,sampfreq,bandmeans)
    %             title(['WakeMove5. N=' num2str(percellcounts.wakemove5(a))])
    %         ax(end+1) = subplot(3,3,6);
    %             data = percellspectrum_wakenonmove10(:,:,a);
    %             sedata = percellpopspikesE_wakenonmove10(:,a);
    %             sidata = percellpopspikesI_wakenonmove10(:,a);
    %             plotspectlocal(data,sedata,sidata,secbefore,secafter,sampfreq,bandmeans)
    %             title(['WakeNonMove10. N=' num2str(percellcounts.wakenonmove10(a))])
        ax(end+1) = subplot(3,3,7);
            data = percellspectrum_neib_Ma(:,:,cidx);
            sedata = percellpopspikesE_Ma(:,cidx);
            sidata = percellpopspikesI_Ma(:,cidx);
            plotspectlocal(data,sedata,sidata,secbefore,secafter,sampfreq,bandmeans)
            title(['MA. N=' num2str(percellcounts.ma(cidx))])
        ax(end+1) = subplot(3,3,8);
            data = percellspectrum_neib_Nrem(:,:,cidx);
            sedata = percellpopspikesE_Nrem(:,cidx);
            sidata = percellpopspikesI_Nrem(:,cidx);
            plotspectlocal(data,sedata,sidata,secbefore,secafter,sampfreq,bandmeans)
            title(['NREM. N=' num2str(percellcounts.nrem(cidx))])
        ax(end+1) = subplot(3,3,9);
            data = percellspectrum_neib_Rem(:,:,cidx);
            sedata = percellpopspikesE_Rem(:,cidx);
            sidata = percellpopspikesI_Rem(:,cidx);
            plotspectlocal(data,sedata,sidata,secbefore,secafter,sampfreq,bandmeans)
            title(['REM. N=' num2str(percellcounts.rem(cidx))])
        switch CellTypes(cidx);
            case 1
                typestr = 'pE';
            case -1
                typestr = 'pI';
        end            
        AboveTitle([typestr ' cell. ' num2str(Srates(cidx)) 'Hz.'])
        namestr = ['Cell' num2str(cidx) '_' typestr '_' num2str(Srates(cidx)) 'Hz.'];
        set(h(end),'name',namestr)
    end

    MakeDirSaveFigsThere(fullfile(basepath,'SpikeSpectrumFigs','SpikeTriggeredWaveletsMaxChan'),h,'fig')
    MakeDirSaveFigsThere(fullfile(basepath,'SpikeSpectrumFigs','SpikeTriggeredWaveletsMaxChan','PlusMinus1000ms'),h,'png')
    set(ax,'xlim',[-1 1])
    MakeDirSaveFigsThere(fullfile(basepath,'SpikeSpectrumFigs','SpikeTriggeredWaveletsMaxChan','PlusMinus300ms'),h,'png')
    set(ax,'xlim',[-.1 .1])
    MakeDirSaveFigsThere(fullfile(basepath,'SpikeSpectrumFigs','SpikeTriggeredWaveletsMaxChan','PlusMinus100ms'),h,'png')
    set(ax,'xlim',[-.03 .03])
    MakeDirSaveFigsThere(fullfile(basepath,'SpikeSpectrumFigs','SpikeTriggeredWaveletsMaxChan','PlusMinus30ms'),h,'png')
end



function plotspectlocal(data,sedata,sidata,secbefore,secafter,sampfreq,bandmeans)

linefor50 = find(bandmeans<50,1,'last');
linefor150 = find(bandmeans<150,1,'last');

xdata = -secbefore:1/sampfreq:secafter;
ydata = 1:length(bandmeans);
imagesc('XData',xdata,'YData',ydata,'CData',zscore(data)');
axis xy tight
yl = get(gca,'ylim');
hold on; 
plot([0 0],yl,'k')
plot([-secbefore secafter],[linefor50 linefor50],'b')
plot([-secbefore secafter],[linefor150 linefor150],'b')
xlabel('sec')
yticks = get(gca,'YTick');
set(gca,'YTickLabel',bandmeans(yticks))
ylabel('Hz')

%add a new area and plot E and I spiking data
xl = get(gca,'XLim');
windowwidth = abs(diff(yl))*0.3;
y = yl(2);
ylim([yl(1) yl(2)+windowwidth])
rectangle('position',[xl(1) yl(2) diff(xl) windowwidth])
xlim([-.03 .03])


plot(xdata,smooth(yl(2) + windowwidth*bwnormalize(sidata),10),'r')
plot(xdata,smooth(yl(2) + windowwidth*bwnormalize(sedata),10),'g')


function h2 = plotspectralamplitudesbywaveformsize(percellspectrum,percellspectrum_nsmean,percellspectrum_neibmean,waves,waveamps,eegwaves,bandmeans,sampfreq,basename)
secondseitherside = 0.005;
pointsperside_wv = round(secondseitherside*sampfreq);
pointspercell_wv = 2*pointsperside_wv+1 +1;
% pointspercell_max = size(percellspectrum,2);
pointspercell_spk = size(waves,1);
pointspercell_eeg = size(waves,1);

ampsmtx = nan(size(percellspectrum,2), size(percellspectrum,3)*pointspercell_wv);
nsmeanampsmtx = ampsmtx;
spkcatwaves = nan(1,size(percellspectrum,3)*pointspercell_spk);
eegcatwaves = nan(1,size(percellspectrum,3)*pointspercell_eeg);

[waveampssorted,ix] = sort(waveamps);

for a = 1:size(percellspectrum,3);
    %local max channel spectrum per spike
    data = percellspectrum(:,:,ix(a));
    data = data(round(sampfreq-0.005*sampfreq):round(sampfreq+0.005*sampfreq),:);
    data = cat(2,data',zeros(size(percellspectrum,2),1));
    ampsmtx(:,a*pointspercell_wv-pointspercell_wv+1:a*pointspercell_wv) = data;
    ampsmax(a,:) = max(data,[],2)';

    %mean of all non-shank channels... wavelet spectrum per spike
    data = percellspectrum_nsmean(:,:,ix(a));
    data = data(round(sampfreq-0.005*sampfreq):round(sampfreq+0.005*sampfreq),:);
    data = cat(2,data',zeros(size(percellspectrum,2),1));
    nsmeanampsmtx(:,a*pointspercell_wv-pointspercell_wv+1:a*pointspercell_wv) = data;
    nsmeanampsmax(a,:) = max(data,[],2)';

    %mean of channels from neighboring shanks... wavelet spectrum per spike
    data = percellspectrum_neibmean(:,:,ix(a));
    data = data(round(sampfreq-0.005*sampfreq):round(sampfreq+0.005*sampfreq),:);
    data = cat(2,data',zeros(size(percellspectrum,2),1));
    neibmeanampsmtx(:,a*pointspercell_wv-pointspercell_wv+1:a*pointspercell_wv) = data;
    neibmeanampsmax(a,:) = max(data,[],2)';
    
    % grabbing waveforms themselves
    spkcatwaves(1,(a-1)*pointspercell_spk+1 : a*pointspercell_spk) = waves(:,ix(a))';
    eegcatwaves(1,(a-1)*pointspercell_eeg+1 : a*pointspercell_eeg) = eegwaves(:,ix(a))';
end    

ydata = 1:length(bandmeans);
h2 = figure('name',[basename '_SpikeWaveletRawData'],'position',[5 5 1000 800]);
subplot(14,1,1)
    plot(spkcatwaves)
    axis tight
    ylabel('Raw')
    set(gca,'Xtick',[])
subplot(14,1,2)
    plot(eegcatwaves)
    axis tight
    ylabel('EEG')
    set(gca,'Xtick',[])
subplot(14,1,3:6)
    imagesc('YData',ydata,'CData',ampsmtx);
    axis tight
    yticks = get(gca,'YTick');
    set(gca,'YTickLabel',bandmeans(yticks))
    ylabel('Hz')
    ylabel('This channel')
    set(gca,'Xtick',[])
subplot(14,1,7:10)
    imagesc('YData',ydata,'CData',neibmeanampsmtx);
    axis tight
    yticks = get(gca,'YTick');
    set(gca,'YTickLabel',bandmeans(yticks))
    ylabel('Hz')
    ylabel('Neighb shanks')
    set(gca,'Xtick',[])
subplot(14,1,11:14)
    imagesc('YData',ydata,'CData',nsmeanampsmtx);
    axis tight
    yticks = get(gca,'YTick');
    set(gca,'YTickLabel',bandmeans(yticks))
    ylabel('Hz')
    ylabel('Non-shank mean')
    set(gca,'Xtick',[])

% correlate spike size with amplitude sizes
h2(end+1) = figure('name',[basename '_SpikeWaveletMaxChanCorrelation']);
ax = axes;
% cmap = makeColorMap([1 1 .5],[1 0 0],size(percellspectrum,2));
cmap = flipud(RainbowColors(size(percellspectrum,2)+1));
cmap(end-1,:) = [];%not enough difference in red end... added an extra above and taking out row 2
for a = 1:size(percellspectrum,2)
    [~,~,~,Rs(a),~,Ps(a)] = logfit_bw(waveampssorted*1000,ampsmax(:,a),'linear','markercolor',cmap(a,:),'linecolor',cmap(a,:));
    freqlabels{a} = [num2str(bandmeans(a)) 'Hz: r=' num2str(Rs(a)) ' p=' num2str(Ps(a))];
    hold on
end
fitlines = findobj('parent',ax,'tag','fitline');
hl = legend(fitlines,fliplr(freqlabels),'location','northwest');
xlabel('mV')
ylabel('Wavelet power')

% correlate spike size with amplitude sizes
h2(end+1) = figure('name',[basename '_SpikeWaveletNeighborShankChanCorrelation']);
ax = axes;
% cmap = makeColorMap([1 1 .5],[1 0 0],size(percellspectrum,2));
cmap = flipud(RainbowColors(size(percellspectrum,2)+1));
cmap(end-1,:) = [];%not enough difference in red end... added an extra above and taking out row 2
for a = 1:size(percellspectrum,2)
    [~,~,~,Rs(a),~,Ps(a)] = logfit_bw(waveampssorted*1000,neibmeanampsmax(:,a),'linear','markercolor',cmap(a,:),'linecolor',cmap(a,:));
    freqlabels{a} = [num2str(bandmeans(a)) 'Hz: r=' num2str(Rs(a)) ' p=' num2str(Ps(a))];
    hold on
end
fitlines = findobj('parent',ax,'tag','fitline');
hl = legend(fitlines,fliplr(freqlabels),'location','northeast');
xlabel('mV')
ylabel('Wavelet power')


% correlate spike size with amplitude sizes
h2(end+1) = figure('name',[basename '_SpikeWaveletNonShankChanCorrelation']);
ax = axes;
% cmap = makeColorMap([1 1 .5],[1 0 0],size(percellspectrum,2));
cmap = flipud(RainbowColors(size(percellspectrum,2)+1));
cmap(end-1,:) = [];%not enough difference in red end... added an extra above and taking out row 2
for a = 1:size(percellspectrum,2)
    [~,~,~,Rs(a),~,Ps(a)] = logfit_bw(waveampssorted*1000,nsmeanampsmax(:,a),'linear','markercolor',cmap(a,:),'linecolor',cmap(a,:));
    freqlabels{a} = [num2str(bandmeans(a)) 'Hz: r=' num2str(Rs(a)) ' p=' num2str(Ps(a))];
    hold on
end
fitlines = findobj('parent',ax,'tag','fitline');
hl = legend(fitlines,fliplr(freqlabels),'location','northeast');
xlabel('mV')
ylabel('Wavelet power')


