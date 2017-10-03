function percellsspectrum = SpikeTriggeredWaveletSpectrum(basepath,basename);
% !!See SpikeTriggeredWaveletHighSpectrum.m instead, which is updated version
% Spike triggered wavelets up to high values for full exploration of how
% spikes correlate to lfp spectrum.
% Looks at on-shank vs off shank spectra.

secbefore = 1;
secafter = 1;

if ~exist('basepath','var')
    basepath = cd;
    [~,basename] = fileparts(cd);
end

load(fullfile(basepath,[basename '_WaveletForGamma']))
load(fullfile(basepath,[basename '_SStable']),'S')
load(fullfile(basepath,[basename '_CellIDs']))
load(fullfile(basepath,[basename '-states']))
load(fullfile(basepath,[basename '_Motion']))

%% storing cell types to index matrices later
CellTypes = ones(length(S),1);%Ecells 1
CellTypes(CellIDs.IAll) = -1;%Icells -1

Srates = Rate(S);
binends = 1/sampfreq : 1/sampfreq : size(amp,1)/sampfreq;
binstarts = binends - 1/sampfreq - 1/20000;
bins = intervalSet(binstarts,binends);

%% Grab info and spectrum for each cell
for a = 1:length(S);
    te = CellIDs.EAll(CellIDs.EAll~=a);
    ti = CellIDs.IAll(CellIDs.IAll~=a);
    se = MakeQfromTsd(oneSeries(S(te)),bins);
    se = Data(se)/length(te);
    
    si = MakeQfromTsd(oneSeries(S(ti)),bins);
    si = tsd(Range(si),Data(si)/length(ti));
    si = Data(si)/length(ti);
    
    
    %Grab spikes for this cell
    tc = S{a};
    tc = TimePoints(tc);
    tc(tc<secbefore) = [];
    tc(tc>(length(amp)/sampfreq-secafter)) = [];
    tc_samp = round(tc*sampfreq);

    % set up wavelet accumulation matrices
    all_w = zeros(sampfreq*secbefore+sampfreq*secafter+1,size(amp,2));%blank matrix for each condition
    wake_w = zeros(size(all_w));
    wakemove5_w = zeros(size(all_w));
    wakenonmove10_w = zeros(size(all_w));
    nrem_w = zeros(size(all_w));
    rem_w = zeros(size(all_w));
    ma_w = zeros(size(all_w));

    % set up spike count accumulation matrices
    all_se = zeros(sampfreq*secbefore+sampfreq*secafter+1,1);%blank matrix for each condition
    wake_se = zeros(size(all_se));
    wakemove5_se = zeros(size(all_se));
    wakenonmove10_se = zeros(size(all_se));
    nrem_se = zeros(size(all_se));
    rem_se = zeros(size(all_se));
    ma_se = zeros(size(all_se));
    all_si = zeros(sampfreq*secbefore+sampfreq*secafter+1,1);%blank matrix for each condition
    wake_si = zeros(size(all_si));
    wakemove5_si = zeros(size(all_si));
    wakenonmove10_si = zeros(size(all_si));
    nrem_si = zeros(size(all_si));
    rem_si = zeros(size(all_si));
    ma_si = zeros(size(all_si));

    wakecount = 0;%#of spikes in this group
    wakemove5count = 0;
    wakenonmove10count = 0;
    nremcount = 0;
    remcount = 0;
    macount = 0;
    
    %% For each spike, grab timing and wavelet spectrum (and state)
    idxs = nan(length(tc_samp),sampfreq*secbefore+1+sampfreq*secafter);
    for b = 1:length(tc_samp)% for each spike
%         idxs(b,:) = (tc_samp(b)-sampfreq*secbefore) : (tc_samp(b)+sampfreq*secafter);
%     end
%     idxs = idxs';
%     idxs = idxs(:);
%     
        % grab the wavelets in the range around that spike
        tmtx = amp((tc_samp(b)-sampfreq*secbefore) : (tc_samp(b)+sampfreq*secafter),:);
        all_w = all_w + tmtx;%just track overall per cell spectrum
        
        tspkse = se((tc_samp(b)-sampfreq*secbefore) : (tc_samp(b)+sampfreq*secafter));
        all_se = all_se + tspkse;%just track overall per cell locked rate
        tspksi = si((tc_samp(b)-sampfreq*secbefore) : (tc_samp(b)+sampfreq*secafter));
        all_si = all_si + tspksi;%just track overall per cell locked rate

        %% state-wise spectra
        thisbin = floor(tc(b));% which second bin is this in, note not ceil
        switch states(thisbin)
            case 2
                ma_w = ma_w+tmtx;
                ma_se = ma_se+tspkse;
                ma_si = ma_si+tspksi;
                macount = macount + 1;
            case 3
                nrem_w = nrem_w+tmtx;
                nrem_se = nrem_se+tspkse;
                nrem_si = nrem_si+tspksi;
                nremcount = nremcount + 1;
            case 5
                rem_w = rem_w+tmtx;
                rem_se = rem_se+tspkse;
                rem_si = rem_si+tspksi;
                remcount = remcount + 1;
            case 1
                wake_w = wake_w+tmtx;
                wake_se = wake_se+tspkse;
                wake_si = wake_si+tspksi;
                wakecount = wakecount + 1;
                if motiondata.move5sepochsecs(thisbin)
                    wakemove5_w = wakemove5_w+tmtx;
                    wakemove5_se = wakemove5_se+tspkse;
                    wakemove5_si = wakemove5_si+tspksi;
                    wakemove5count = wakemove5count + 1;
                end
                if motiondata.nonmove10sepochsecs(thisbin)
                    wakenonmove10_w = wakenonmove10_w+tmtx;
                    wakenonmove10_se = wakenonmove10_se+tspkse;
                    wakenonmove10_si = wakenonmove10_si+tspksi;
                    wakenonmove10count = wakenonmove10count + 1;
                end
        end
    end
    all_w = all_w/b;
    wake_w = wake_w/wakecount;
    wakemove5_w = wakemove5_w/wakemove5count;
    wakenonmove10_w = wakenonmove10_w/wakenonmove10count;
    ma_w = ma_w/macount;
    nrem_w = nrem_w/nremcount;
    rem_w = rem_w/remcount;
    
    all_se = all_se/b;
    wake_se = wake_se/wakecount;
    wakemove5_se = wakemove5_se/wakemove5count;
    wakenonmove10_se = wakenonmove10_se/wakenonmove10count;
    ma_se = ma_se/macount;
    nrem_se = nrem_se/nremcount;
    rem_se = rem_se/remcount;
    all_si = all_si/b;
    wake_si = wake_si/wakecount;
    wakemove5_si = wakemove5_si/wakemove5count;
    wakenonmove10_si = wakenonmove10_si/wakenonmove10count;
    ma_si = ma_si/macount;
    nrem_si = nrem_si/nremcount;
    rem_si = rem_si/remcount;


    percellspectrum(:,:,a) = all_w;
    percellspectrum_wake(:,:,a) = wake_w;
    percellspectrum_wakemove5(:,:,a) = wakemove5_w;
    percellspectrum_wakenonmove10(:,:,a) = wakenonmove10_w;
    percellspectrum_ma(:,:,a) = ma_w;
    percellspectrum_nrem(:,:,a) = nrem_w;
    percellspectrum_rem(:,:,a) = rem_w;

    percellpopspikesE(:,a) = all_se;
    percellpopspikesE_wake(:,a) = wake_se;
    percellpopspikesE_wakemove5(:,a) = wakemove5_se;
    percellpopspikesE_wakenonmove10(:,a) = wakenonmove10_se;
    percellpopspikesE_ma(:,a) = ma_se;
    percellpopspikesE_nrem(:,a) = nrem_se;
    percellpopspikesE_rem(:,a) = rem_se;

    percellpopspikesI(:,a) = all_si;
    percellpopspikesI_wake(:,a) = wake_si;
    percellpopspikesI_wakemove5(:,a) = wakemove5_si;
    percellpopspikesI_wakenonmove10(:,a) = wakenonmove10_si;
    percellpopspikesI_ma(:,a) = ma_si;
    percellpopspikesI_nrem(:,a) = nrem_si;
    percellpopspikesI_rem(:,a) = rem_si;
    
    percellcounts.all(a) = b;
    percellcounts.wake(a) = wakecount;
    percellcounts.wakemove5(a) = wakemove5count;
    percellcounts.wakenonmove10(a) = wakenonmove10count;
    percellcounts.ma(a) = macount;
    percellcounts.nrem(a) = nremcount;
    percellcounts.rem(a) = remcount;

    disp(['done with cell ' num2str(a)])
end

save(fullfile(basepath,[basename '_PerCellWaveletSpectrum']),'percellspectrum',...
    'percellspectrum_wake','percellspectrum_wakemove5',...
    'percellspectrum_wakenonmove10','percellspectrum_ma',...
    'percellspectrum_nrem','percellspectrum_rem',...
    'percellpopspikesE','percellpopspikesE_wake',...
    'percellpopspikesE_wakemove5','percellpopspikesE_wakenonmove10',...
    'percellpopspikesE_ma','percellpopspikesE_rem','percellpopspikesE_nrem',...
    'percellpopspikesI','percellpopspikesI_wake',...
    'percellpopspikesI_wakemove5','percellpopspikesI_wakenonmove10',...
    'percellpopspikesI_ma','percellpopspikesI_rem','percellpopspikesI_nrem',...
    'percellcounts',...
    'sampfreq','secbefore','secafter','bandmeans','CellTypes')

plotting = 1;
if plotting
    h = [];
    ax = [];
    for a = 1:size(percellspectrum,3);
        h(end+1) = figure;
        ax(end+1) = subplot(3,3,1);
            data = percellspectrum(:,:,a);
            sedata = percellpopspikesE(:,a);
            sidata = percellpopspikesI(:,a);
            plotspectlocal(data,sedata,sidata,secbefore,secafter,sampfreq,bandmeans)
            title(['Total. N=' num2str(percellcounts.all(a))])
        ax(end+1) = subplot(3,3,4);
            data = percellspectrum_wake(:,:,a);
            sedata = percellpopspikesE_wake(:,a);
            sidata = percellpopspikesI_wake(:,a);
            plotspectlocal(data,sedata,sidata,secbefore,secafter,sampfreq,bandmeans)
            title(['WakeTotal. N=' num2str(percellcounts.wake(a))])
        ax(end+1) = subplot(3,3,5);
            data = percellspectrum_wakemove5(:,:,a);
            sedata = percellpopspikesE_wakemove5(:,a);
            sidata = percellpopspikesI_wakemove5(:,a);
            plotspectlocal(data,sedata,sidata,secbefore,secafter,sampfreq,bandmeans)
            title(['WakeMove5. N=' num2str(percellcounts.wakemove5(a))])
        ax(end+1) = subplot(3,3,6);
            data = percellspectrum_wakenonmove10(:,:,a);
            sedata = percellpopspikesE_wakenonmove10(:,a);
            sidata = percellpopspikesI_wakenonmove10(:,a);
            plotspectlocal(data,sedata,sidata,secbefore,secafter,sampfreq,bandmeans)
            title(['WakeNonMove10. N=' num2str(percellcounts.wakenonmove10(a))])
        ax(end+1) = subplot(3,3,7);
            data = percellspectrum_ma(:,:,a);
            sedata = percellpopspikesE_ma(:,a);
            sidata = percellpopspikesI_ma(:,a);
            plotspectlocal(data,sedata,sidata,secbefore,secafter,sampfreq,bandmeans)
            title(['MA. N=' num2str(percellcounts.ma(a))])
        ax(end+1) = subplot(3,3,8);
            data = percellspectrum_nrem(:,:,a);
            sedata = percellpopspikesE_nrem(:,a);
            sidata = percellpopspikesI_nrem(:,a);
            plotspectlocal(data,sedata,sidata,secbefore,secafter,sampfreq,bandmeans)
            title(['NREM. N=' num2str(percellcounts.nrem(a))])
        ax(end+1) = subplot(3,3,9);
            data = percellspectrum_rem(:,:,a);
            sedata = percellpopspikesE_rem(:,a);
            sidata = percellpopspikesI_rem(:,a);
            plotspectlocal(data,sedata,sidata,secbefore,secafter,sampfreq,bandmeans)
            title(['REM. N=' num2str(percellcounts.rem(a))])
        switch CellTypes(a);
            case 1
                typestr = 'pE';
            case -1
                typestr = 'pI';
        end            
        AboveTitle([typestr ' cell. ' num2str(Srates(a)) 'Hz.'])
        namestr = ['Cell' num2str(a) '_' typestr '_' num2str(Srates(a)) 'Hz.'];
        set(h(end),'name',namestr)
    end
    
    MakeDirSaveFigsThere(fullfile(basepath,'SpikeSpectrumFigs','SpikeTriggeredWavelets'),h,'fig')
    MakeDirSaveFigsThere(fullfile(basepath,'SpikeSpectrumFigs','SpikeTriggeredWavelets','PlusMinus1000ms'),h,'png')
    set(ax,'xlim',[-.3 .3])
    MakeDirSaveFigsThere(fullfile(basepath,'SpikeSpectrumFigs','SpikeTriggeredWavelets','PlusMinus300ms'),h,'png')
    set(ax,'xlim',[-.1 .1])
    MakeDirSaveFigsThere(fullfile(basepath,'SpikeSpectrumFigs','SpikeTriggeredWavelets','PlusMinus100ms'),h,'png')
    set(ax,'xlim',[-.03 .03])
    MakeDirSaveFigsThere(fullfile(basepath,'SpikeSpectrumFigs','SpikeTriggeredWavelets','PlusMinus30ms'),h,'png')
    
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


plot(xdata,smooth(yl(2) + windowwidth*bwnormalize(sidata),10),'r')
plot(xdata,smooth(yl(2) + windowwidth*bwnormalize(sedata),10),'g')
