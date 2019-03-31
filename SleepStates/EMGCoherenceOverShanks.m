function EMGCorr = EMGCoherenceOverShanks(basepath,basename)
% Based on Erik Schomburg's work and code.  Grabs channels and calculates
% their correlations in the 300-600Hz band over sliding windows of 0.5sec.
% Channels are automatically selected and are a combination first channels
% on each shank nomintated in "goodshanks" (not using directly adjacent
% shanks, they must be at least 2 shanks away.  Also using my hippocampal 
% "Thetachannel"s for each recording.  Mean pairwise correlations are used
% for each time point.
% 
% Adapted 2015 Brendon Watson

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);basepath = cd;
end

%get basics about eeg/lfp file
eegloc = findsessioneeglfpfile(basepath,basename);
bmd = load(fullfile(basepath,[basename '_BasicMetaData.mat']));
Fs = bmd.Par.lfpSampleRate; % Hz, LFP sampling rate
nChannels = bmd.Par.nChannels;
nShanks = bmd.Par.AnatGrps;
specialChannelb1 = bmd.Thetachannel;%base 1
specialChannelb0 = specialChannelb1-1;%base 0 for comparisons to things in par


xcorr_halfwindow_s = 0.5;%specified in s
% downsampleFs = 125;
% downsampleFactor = round(Fs/downsampleFs);
binScootS = 0.5;
binScootSamps = Fs*binScootS;
corrChunkSz = 20;%for batch-processed correlations

%% Get anatomical locations of each shank
ShankAnatomyList = ShankAnatomies(basepath,basename);
for a = 1:length(bmd.goodshanks)
    for b = 1:length(ShankAnatomyList)
        if bmd.goodshanks(a) == ShankAnatomyList(b).ShankNumber
            shankanats{a} = ShankAnatomyList(b).ShankAnatomy;
        end
    end
    if length(shankanats)<a
        disp(['no match for shank ' a])
    end
end
% >>> will have to manually nominate extra channels for every recording



%% Determine channels, read data in
% Use anatomy info for each shank to pick out shanks to pairwise compare.  
% Optimally in different regions of brain.  If in same region they cannot 
% be directly adjacent.  One channel for each shank.

% Initially... just do first one from every other shank... maybe if refine
% can do it based on poor spike yield

% with special channel - make sure if a group is used and it has special in it, special is used.
% Also make sure if special channel group is not already used, use it.

xcorr_chs = [];
lastanat = '';
% AnatShankSite = {};
for a = 1:length(bmd.goodshanks)%every other shank
    tsnum = bmd.goodshanks(a);
    thisanat = shankanats{a};
    if strcmp(thisanat,lastanat)
        lastanat = '';%this makes it so every other shank is used
        continue
    else %if this is a new shank or new anatomy, do correlation
        if ismember(specialChannelb0,bmd.Par.SpkGrps(a).Channels)
            tch = find(bmd.Par.SpkGrps(a).Channels==specialChannelb0);
        else
            tch = 1;
        end
        xcorr_chs(end+1) = bmd.Par.SpkGrps(a).Channels(1)+1;%correct for base 0/1 difference
        lastanat = thisanat;
%         AnatShankSite{end+1} = strcat(thisanat,'_Shank',num2str(tsnum),'_Site',num2str(tch));
    end
end

if ~ismember(specialChannelb1, xcorr_chs) 
    xcorr_chs(end+1) = specialChannelb1;
end

% xcorr_chs = [1 10];


%% Read and filter channel
% read channel
% [eeg,o] = LoadBinary_bw(eegloc, xcorr_chs, nChannels);
eeg = readmulti(eegloc, nChannels, xcorr_chs) * bmd.voltsperunit*1000; %read and convert to mV    
% Filter first in high frequency band to remove low-freq physiologically
% correlated LFPs (e.g., theta, delta, SPWs, etc.)
xcorr_freqband = [275 300 600 625]; % Hz
eeg = filtsig_in(eeg, Fs, xcorr_freqband);

% eeg = downsample(eeg,downsampleFactor);

%% xcorr 'strength' is the summed correlation coefficients between channel
% pairs for a sliding window of 25 ms
xcorr_window_samps = round(xcorr_halfwindow_s*Fs);
xcorr_window_inds = -xcorr_window_samps:xcorr_window_samps;%+- that number of ms in samples

% xcorr 'strength' is the averaged correlation coefficients between channel
% old version... single correlation calculated at once
% % pairs for a sliding window of 25 ms
% xcorr_window_samps = round(xcorr_window_s*Fs);
% xcorr_window_inds = -xcorr_window_samps:xcorr_window_samps;%+- that number of ms in samples
% 
% numbins = (size(eeg,1) - xcorr_window_samps*2)/binScootSamps;
% xcorrStrength = zeros(numbins, 1);
% binind = 0;
% for i=(1+xcorr_window_inds(end)):binScootSamps:(size(eeg,1)-xcorr_window_inds(end))
%     binind = binind+1;
%     for j=1:(length(xcorr_chs)-1)
%         for k=(j+1):length(xcorr_chs)
%             s1 = eeg(i + xcorr_window_inds, j);
%             s2 = eeg(i + xcorr_window_inds, k);
%             tmp = corrcoef(s1,s2);
%             xcorrStrength(binind) = xcorrStrength(binind) + tmp(1,2);
%         end
%     end
% end
% xcorrStrength = xcorrStrength/(length(xcorr_chs)*(length(xcorr_chs)-1)/2);


% new version... batches of correlation calculated at once
timestamps = (1+xcorr_window_inds(end)):binScootSamps:(size(eeg,1)-xcorr_window_inds(end));
numbins = length(timestamps);
EMGCorr = zeros(numbins, 1);
% tic
for j=1:(length(xcorr_chs)-1)
    for k=(j+1):length(xcorr_chs)
        c1 = [];
        c2 = [];
        binind = 0;
        binindstart = 1;
        for i = timestamps
            binind = binind+1;
            s1 = eeg(i + xcorr_window_inds, j);
            s2 = eeg(i + xcorr_window_inds, k);
            c1 = cat(2,c1,s1);
            c2 = cat(2,c2,s2);
            if size(c1,2) == corrChunkSz || i == timestamps(end)
                binindend = binind;
                tmp = corr(c1,c2);
                tmp = diag(tmp);
                EMGCorr(binindstart:binindend) = EMGCorr(binindstart:binindend) + tmp;
                c1 = [];
                c2 = [];
                binindstart = binind+1;
            end
        end
    end
end
% toc

EMGCorr = EMGCorr/(length(xcorr_chs)*(length(xcorr_chs)-1)/2);

% save...
EMGCorr = cat(2,timestamps'/Fs,EMGCorr);
ChannelsCompared = xcorr_chs;
% EMGCorrData = v2struct(EMGCorr,ChannelsCompared,AnatShankSite);
EMGCorrData = v2struct(EMGCorr,ChannelsCompared);
save(fullfile(basepath,[basename,'_EMGCorr.mat']),'EMGCorr');


function [filt_sig, Filt] = filtsig_in(sig, Fs, filtband_or_Filt)
% [filt_sig, Filt] = filtsig(sig, dt_ms, filtband_or_Filt)
%
% Created by: Erik Schomburg, 2011

if isnumeric(filtband_or_Filt)
    h  = fdesign.bandpass(filtband_or_Filt(1), filtband_or_Filt(2), filtband_or_Filt(3), filtband_or_Filt(4), ...
        60, 1, 60, Fs);
    Filt = design(h, 'butter', 'MatchExactly', 'passband');
else
    Filt = filtband_or_Filt;
end

if ~isempty(sig)
    if iscell(sig)
        filt_sig = cell(size(sig));
        for i=1:length(sig(:))
            filt_sig{i} = filter(Filt, sig{i});
            filt_sig{i} = filter(Filt, filt_sig{i}(end:-1:1));
            filt_sig{i} = filt_sig{i}(end:-1:1);
        end
    elseif ((size(sig,1) > 1) && (size(sig,2) > 1))
        filt_sig = zeros(size(sig));
        for i=1:size(filt_sig,2)
            filt_sig(:,i) = filter(Filt, sig(:,i));
            filt_sig(:,i) = filter(Filt, filt_sig(end:-1:1,i));
            filt_sig(:,i) = filt_sig(end:-1:1,i);
        end
    else
        filt_sig = filter(Filt, sig);
        filt_sig = filter(Filt, filt_sig(end:-1:1));
        filt_sig = filt_sig(end:-1:1);
    end
else
    filt_sig = [];
end

