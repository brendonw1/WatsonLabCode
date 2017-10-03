function SpikeTriggeredWaveletAndPopEI(basepath)
% Spike triggered wavelets up to high values for full exploration of how
% spikes correlate to lfp spectrum.
% Looks at on-shank vs off shank spectra.
% More updated than SpikeTriggeredWaveletSpectrum
% State-wise matrices are based on neighbordata


secbefore = 1;
secafter = 1;

if ~exist('basepath','var')
    basepath = cd;
end
basename = bz_BasenameFromBasepath(basepath);

% load(fullfile(basepath,[basename '_WaveletForGamma']))
load(fullfile(basepath,[basename '_SStable']),'S','shank')
load(fullfile(basepath,[basename '_CellIDs']))
load(fullfile(basepath,[basename '-states']))
load(fullfile(basepath,[basename '_Motion']))
load(fullfile(basepath,[basename '_MeanWaveforms']))
load(fullfile(basepath,[basename '_BasicMetaData']))
voltsperunit = bmd.voltsperunit;
Par = bmd.Par;
MeanWaveforms.MaxWaves = MeanWaveforms.MaxWaves*voltsperunit;
load(fullfile(basepath,[basename,'_WaveletForSpikePower.mat']),'bandmeans','sampfreq')

% not loading this, loading non-shank means instead
% load(fullfile(basepath,[basename,'_WaveletForSpikePower.mat']),'ChannelMean')
% ChannelMean = zscore(ChannelMean,[],1);

%gathering shank info for E and I cells
EShank = shank(CellIDs.EAll);
IShank = shank(CellIDs.IAll);

%prepping for loading .eegs per spike
sampsbefore = 16;
sampsafter = 16;
tsampsperwave   = (sampsbefore+sampsafter);
totalch = Par.nChannels;
eeg = memmapfile(fullfile(basepath,[basename '.lfp']),'Format','int16');

w = whos('-file',fullfile(basepath,[basename,'_WaveletForSpikePower.mat']));
for cidx = 1:length(w)
    if length(w(cidx).name)>13
        if strcmp(w(cidx).name(1:13),'NonShankMeans')
            amplen = w(cidx).size(1);
            break
        end
    end
end

%% storing cell types to index matrices later
CellTypes = ones(length(S),1);%Ecells 1
CellTypes(CellIDs.IAll) = -1;%Icells -1

Srates = Rate(S);
binends = 1/sampfreq : 1/sampfreq : amplen/sampfreq;
binstarts = binends - 1/sampfreq - 1/20000;
bins = intervalSet(binstarts,binends);

%% Grab info and spectrum for each cell
priorshank = 0;
for cidx = 1:length(S);%for each cell
    %% Grab spike times for this cell
    tc = S{cidx};
    tc = TimePoints(tc);
    tc(tc<secbefore) = [];
    tc(tc>(amplen/sampfreq-secafter)) = [];
    tc_samp = round(tc*sampfreq);

    wakecount = 0;%#of spikes in this group
%     wakemove5count = 0;
%     wakenonmove10count = 0;
    nremcount = 0;
    remcount = 0;
    macount = 0;

    %% Get actual spike waveforms
    teegwave = MeanWaveforms.MaxWaves(:,cidx);
    wavemins(cidx) = min(teegwave);
    waveamps(cidx) = range(teegwave);
    waves(:,cidx) = teegwave;
    
    %% Set up grabbing spectrum-related info, will loop through per spike later
    % Load channel wavelet data
    tchannum = MeanWaveforms.MaxWaveChannelIdxsB0(cidx)+1;
    tn = ['ampCh' num2str(tchannum)];
    load(fullfile(basepath,[basename,'_WaveletForSpikePower.mat']),tn)
    eval(['amp = ' tn ';']);
    eval(['clear ' tn])
    amp = zscore(amp,[],1);

    % Load wavelets excluding this shank... if not loaded from previous
    % unit (fortunately adjacent units are usually from same shank)
    tshank = shank(cidx);
    if tshank ~= priorshank;
        load(fullfile(basepath,[basename,'_WaveletForSpikePower.mat']),['NonShankMeans' num2str(tshank)])
        eval(['nsMean = NonShankMeans' num2str(tshank) ';'])
        eval(['clear NonShankMeans' num2str(tshank) ';'])
        nsMean = zscore(nsMean,[],1);
    end
        
    % Load wavelets for neighboring shanks...
    if tshank ~= priorshank;
        load(fullfile(basepath,[basename,'_WaveletForSpikePower.mat']),['ShankNeighborMeans' num2str(tshank)])
        eval(['neibMean = ShankNeighborMeans' num2str(tshank) ';'])
        eval(['clear ShankNeighborMeans' num2str(tshank) ';'])
        neibMean = zscore(neibMean,[],1);
    end

    % Load wavelets of all channels combined    
%     load(fullfile(basepath,[basename,'_WaveletForSpikePower.mat']),'ChannelMean')
%     ChannelMean = zscore(ChannelMean,[],1);
    
    % set up wavelet accumulation matrices
    allhomemean_wav = zeros(sampfreq*secbefore+sampfreq*secafter+1,size(amp,2));%blank matrix for each condition
    wake_neib_wav = zeros(size(allhomemean_wav));
%     wakemove5_w = zeros(size(all_w));
%     wakenonmove10_w = zeros(size(all_w));
    nrem_neib_wav = zeros(size(allhomemean_wav));
    rem_neib_wav = zeros(size(allhomemean_wav));
    ma_neib_wav = zeros(size(allhomemean_wav));

%     chmean_w = zeros(size(all_w));
    allnsmean_wav = zeros(size(allhomemean_wav));
    allneibmean_wav = zeros(size(allhomemean_wav));

    % set up spike count accumulation matrices
    all_se = zeros(sampfreq*secbefore+sampfreq*secafter+1,1);%blank matrix for each condition
    wake_se = zeros(size(all_se));
%     wakemove5_se = zeros(size(all_se));
%     wakenonmove10_se = zeros(size(all_se));
    nrem_se = zeros(size(all_se));
    rem_se = zeros(size(all_se));
    ma_se = zeros(size(all_se));
    all_si = zeros(sampfreq*secbefore+sampfreq*secafter+1,1);%blank matrix for each condition
    wake_si = zeros(size(all_si));
%     wakemove5_si = zeros(size(all_si));
%     wakenonmove10_si = zeros(size(all_si));
    nrem_si = zeros(size(all_si));
    rem_si = zeros(size(all_si));
    ma_si = zeros(size(all_si));

    
    %% Set up to grab rates of E and I populations on off-shanks at same times as spikes of this cell, will loop through per spike later
    %get E cells on different shank and i cells on different shank
    te = CellIDs.EAll(EShank~=shank(cidx));
    tse = MakeQfromTsd(oneSeries(S(te)),bins);
    tse = Data(tse)/length(te);
    
    ti = CellIDs.IAll(IShank~=shank(cidx));
    tsi = MakeQfromTsd(oneSeries(S(ti)),bins);
%     si = tsd(Range(si),Data(si)/length(ti));
    tsi = Data(tsi)/length(ti);
    
    %% For each spike, grab timing, wavelet spectrum, E and I pop rates (and state)
    idxs = nan(length(tc_samp),sampfreq*secbefore+1+sampfreq*secafter);
    teegwave = zeros(1,tsampsperwave);
    for b = 1:length(tc_samp)% for each spike
        % grab raw .eeg per wave
        w = eeg.data((double(tc_samp(b))-sampsbefore).*totalch+1:(double(tc_samp(b))+sampsafter).*totalch);
        w=reshape(w,totalch,[]);
        teegwave = teegwave+double(w(tchannum,:));%grab waveform on just the max chan and summate with others from this unit
        
        % grab the home-channel wavelets in the range around that spike
        tmtx = amp((tc_samp(b)-sampfreq*secbefore) : (tc_samp(b)+sampfreq*secafter),:);
        allhomemean_wav = allhomemean_wav + tmtx;%just track overall per cell spectrum
        
        % grab the all-channel-mean wavelets in the range around spike
%         tmtx = ChannelMean((tc_samp(b)-sampfreq*secbefore) : (tc_samp(b)+sampfreq*secafter),:);
%         chmean_w = chmean_w + tmtx;%just track overall per cell spectrum

        % grab the non-shank-mean wavelets in the range around spike
        tmtx = nsMean((tc_samp(b)-sampfreq*secbefore) : (tc_samp(b)+sampfreq*secafter),:);
        allnsmean_wav = allnsmean_wav + tmtx;%just track overall per cell spectrum

        % grab the neighbor-mean wavelets in the range around spike
        tmtx = neibMean((tc_samp(b)-sampfreq*secbefore) : (tc_samp(b)+sampfreq*secafter),:);
        mtxforstates = tmtx;
        allneibmean_wav = allneibmean_wav + tmtx;%just track overall per cell spectrum

        
        % grab spike rates
        tspkse = tse((tc_samp(b)-sampfreq*secbefore) : (tc_samp(b)+sampfreq*secafter));
        all_se = all_se + tspkse;%just track overall per cell locked rate
        tspksi = tsi((tc_samp(b)-sampfreq*secbefore) : (tc_samp(b)+sampfreq*secafter));
        all_si = all_si + tspksi;%just track overall per cell locked rate

        %% state-wise spectra and E/I rates
        thisbin = floor(tc(b));% which second bin is this in, note not ceil
        switch states(thisbin)
            case 2
                ma_neib_wav = ma_neib_wav+mtxforstates;
                ma_se = ma_se+tspkse;
                ma_si = ma_si+tspksi;
                macount = macount + 1;
            case 3
                nrem_neib_wav = nrem_neib_wav+mtxforstates;
                nrem_se = nrem_se+tspkse;
                nrem_si = nrem_si+tspksi;
                nremcount = nremcount + 1;
            case 5
                rem_neib_wav = rem_neib_wav+mtxforstates;
                rem_se = rem_se+tspkse;
                rem_si = rem_si+tspksi;
                remcount = remcount + 1;
            case 1
                wake_neib_wav = wake_neib_wav+mtxforstates;
                wake_se = wake_se+tspkse;
                wake_si = wake_si+tspksi;
                wakecount = wakecount + 1;
%                 if moves(thisbin)
%                     wakemove5_w = wakemove5_w+tmtx;
%                     wakemove5_se = wakemove5_se+tspkse;
%                     wakemove5_si = wakemove5_si+tspksi;
%                     wakemove5count = wakemove5count + 1;
%                 end
%                 if motiondata.nonmove10sepochsecs(thisbin)
%                     wakenonmove10_w = wakenonmove10_w+tmtx;
%                     wakenonmove10_se = wakenonmove10_se+tspkse;
%                     wakenonmove10_si = wakenonmove10_si+tspksi;
%                     wakenonmove10count = wakenonmove10count + 1;
%                 end
        end
    end
    %get mean waveform for eeg
    teegwave = teegwave / length(tc_samp) * voltsperunit;
    eegwavebaselineoffsets(cidx) = mean(teegwave(1:5));
    eegwavemedians(cidx) = median(teegwave);
    eegwaves(:,cidx) = teegwave - eegwavebaselineoffsets(cidx);
    
    % assign state-wise data to matrices
    allhomemean_wav = allhomemean_wav/b;
    wake_neib_wav = wake_neib_wav/wakecount;
%     wakemove5_w = wakemove5_w/wakemove5count;
%     wakenonmove10_w = wakenonmove10_w/wakenonmove10count;
    ma_neib_wav = ma_neib_wav/macount;
    nrem_neib_wav = nrem_neib_wav/nremcount;
    rem_neib_wav = rem_neib_wav/remcount;
    
%     chmean_w = chmean_w/b;
    allnsmean_wav = allnsmean_wav/b;
    allneibmean_wav = allneibmean_wav/b;
    
    all_se = all_se/b;
    wake_se = wake_se/wakecount;
%     wakemove5_se = wakemove5_se/wakemove5count;
%     wakenonmove10_se = wakenonmove10_se/wakenonmove10count;
    ma_se = ma_se/macount;
    nrem_se = nrem_se/nremcount;
    rem_se = rem_se/remcount;
    all_si = all_si/b;
    wake_si = wake_si/wakecount;
%     wakemove5_si = wakemove5_si/wakemove5count;
%     wakenonmove10_si = wakenonmove10_si/wakenonmove10count;
    ma_si = ma_si/macount;
    nrem_si = nrem_si/nremcount;
    rem_si = rem_si/remcount;


    percellspectrum_home_AllT(:,:,cidx) = allhomemean_wav;
    percellspectrum_nsmean_AllT(:,:,cidx) = allnsmean_wav;
    percellspectrum_neib_AllT(:,:,cidx) = allneibmean_wav;

    percellspectrum_neib_Wake(:,:,cidx) = wake_neib_wav;
%     percellspectrum_wakemove5(:,:,a) = wakemove5_w;
%     percellspectrum_wakenonmove10(:,:,a) = wakenonmove10_w;
    percellspectrum_neib_Ma(:,:,cidx) = ma_neib_wav;
    percellspectrum_neib_Nrem(:,:,cidx) = nrem_neib_wav;
    percellspectrum_neib_Rem(:,:,cidx) = rem_neib_wav;
    
%     percellspectrum_chmean(:,:,a) = chmean_w;

    percellpopspikesE_AllT(:,cidx) = all_se;
    percellpopspikesE_Wake(:,cidx) = wake_se;
%     percellpopspikesE_wakemove5(:,a) = wakemove5_se;
%     percellpopspikesE_wakenonmove10(:,a) = wakenonmove10_se;
    percellpopspikesE_Ma(:,cidx) = ma_se;
    percellpopspikesE_Nrem(:,cidx) = nrem_se;
    percellpopspikesE_Rem(:,cidx) = rem_se;

    percellpopspikesI_AllT(:,cidx) = all_si;
    percellpopspikesI_Wake(:,cidx) = wake_si;
%     percellpopspikesI_wakemove5(:,a) = wakemove5_si;
%     percellpopspikesI_wakenonmove10(:,a) = wakenonmove10_si;
    percellpopspikesI_Ma(:,cidx) = ma_si;
    percellpopspikesI_Nrem(:,cidx) = nrem_si;
    percellpopspikesI_Rem(:,cidx) = rem_si;
    
    percellcounts.AllT(cidx) = b;
    percellcounts.Wake(cidx) = wakecount;
%     percellcounts.wakemove5(a) = wakemove5count;
%     percellcounts.wakenonmove10(a) = wakenonmove10count;
    percellcounts.Ma(cidx) = macount;
    percellcounts.Nrem(cidx) = nremcount;
    percellcounts.Rem(cidx) = remcount;

    disp(['done with cell ' num2str(cidx)])
end

%% Clean up and save
clear amp eeg

PerCellWaveletSpectrumData = v2struct(percellspectrum_home_AllT,percellspectrum_neib_Wake,...
    percellspectrum_neib_Ma,percellspectrum_neib_Nrem,percellspectrum_neib_Rem,...
    percellpopspikesE_AllT,percellpopspikesE_Wake,...
    percellpopspikesE_Ma,percellpopspikesE_Rem,percellpopspikesE_Nrem,...
    percellpopspikesI_AllT,percellpopspikesI_Wake,...
    percellpopspikesI_Ma,percellpopspikesI_Rem,percellpopspikesI_Nrem,...
    percellspectrum_nsmean_AllT,percellspectrum_neib_AllT,...
    percellcounts,...
    waves,wavemins,waveamps,...
    eegwavebaselineoffsets,eegwavemedians,eegwaves,...
    sampfreq,secbefore,secafter,bandmeans,CellTypes);
%     percellspectrum_wakemove5,percellspectrum_wakenonmove10,
%     percellpopspikesE_wakemove5,percellpopspikesE_wakenonmove10,...
%     percellpopspikesI_wakemove5,percellpopspikesI_wakenonmove10,...
%     'percellspectrum_chmean',...

save(fullfile(basepath,[basename '_SpikeTriggeredWaveletAndPopEI']),'PerCellWaveletSpectrumData');

%% Plotting per-cell spectra and EI population data
plotting = 0;
if plotting
    Plot_SpikeTriggeredWaveletAndPopEI(basepath)
end



