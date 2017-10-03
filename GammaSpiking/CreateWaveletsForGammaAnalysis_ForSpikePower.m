function CreateWaveletsForGammaAnalysis_ForSpikePower(basepath)
% Similar to CreateWaveletsForGammaAnalysis, but opens more channels (makes
% sure it has home channels for each spike), slightly fewer bands.  Also
% does things like channel means and non-shanks means.  Much bigger, should
% be considered separate and maybe then deleted or stored away after use.
% Brendon Watson 2017

if ~exist('basepath','var')
    basepath = cd;
end
basename = bz_BasenameFromBasepath(basepath);

par = LoadParameters(fullfile(basepath,[basename '.xml']));
if isfield(par,'SpkGrps');
    Grps = par.SpkGrps;
elseif isfield(par,'spikeGroups')
    for gidx = 1:length(par.spikeGroups.groups)
        Grps(gidx).Channels = par.spikeGroups.groups{gidx};
    end
else
    Grps = par.AnatGrps;    
end

% bmd = load(fullfile(basepath,[basename '_BasicMetaData.mat']));
% par = bmd.Par;
sampfreq = par.lfpSampleRate;

% bandstarts = [0:1:19 20:2:38 40:5:195]';
% bandstops = [1:1:20 22:2:40 45:5:200 ]';
% bands = cat(2,bandstarts,bandstops);
% bandmeans = mean([bandstarts bandstops],2);
% bandmeans = unique(round(logspace(log10(30),log10(625),7)));%30 to 650, log spaced 
bandmeans = unique(round(logspace(log10(1),log10(625),28)));

% notchidxs = (fo>59 & fo<61);
load(fullfile(basepath,[basename,'_MeanWaveforms.mat']),'MeanWaveforms')
if ~isfield(MeanWaveforms,'MaxWaveChannelIdxsB0')
    AddMaxWaveformChanToMeanwaveforms(basepath,basename)
    load(fullfile(basepath,[basename,'_MeanWaveforms.mat']),'MeanWaveforms')
end
chanswmax = unique(MeanWaveforms.MaxWaveChannelIdxsB0);%channels that have some spike w max on them
shankswmax = [];
for cidx = 1:length(chanswmax);
    for sidx = 1:length(Grps)
        if ismember(chanswmax(cidx),Grps(sidx).Channels)
            shankswmax(end+1) = sidx;
            break
        end
    end
end
shankswmax = sort(unique(shankswmax));
chanswmax = chanswmax +1;  %converting to base 1

% Collect all channels to be used as neighbors
load(fullfile(basepath,[basename '_NeighboringShanks.mat']),'neighborShanksEachCell')
load(fullfile(basepath,[basename '_NeighboringShanks.mat']),'neighborShanks')
load(fullfile(basepath,[basename '_ChannelsForGammaAnalysis.mat']),'Shanks')
load(fullfile(basepath,[basename '_ChannelsForGammaAnalysis.mat']),'Channels')
neighborChansEachCell = [];
for nidx = 1:length(neighborShanksEachCell);
    n = neighborShanksEachCell{nidx};
    [~,nnidx] = ismember(n,Shanks);
    neighborChansEachCell =  cat(2,neighborChansEachCell,Channels(nnidx));
end
neighborChansEachCell = unique(neighborChansEachCell);

for nidx = 1:size(neighborShanks,1);%find neighborchannels for each shank
    nsh = neighborShanks{nidx};
    [~,t]=ismember(nsh,Shanks);
    neighborChansEachShank{nidx} = Channels(t);
end

channelsdoneB1 = [];
denom = 0;

%% gather all channels, eliminate bad ones
chanlist = [];
for a = 1:length(Grps);
    chanlist = cat(2, chanlist, Grps(a).Channels+1);
end
badchans = ReadBadChannels(basepath)+1;
badchans = setdiff(badchans,chanswmax);%making sure badchans only includes channels in available list
chanlist(ismember(chanlist,badchans)) = [];

%% gather channels not on each shank
for a = 1:length(Grps);
    nonshankchanslists{a} = chanlist;
    nonshankchanslists{a}(ismember(nonshankchanslists{a}, Grps(a).Channels+1)) = [];
    NonShankDenoms(a) = 0;
end

%% save basic parameters, will append more later as we go
save(fullfile(basepath,[basename,'_WaveletForSpikePower.mat']),'-v7.3','bandmeans','sampfreq')

%% Load each channel and get wavelet transform at specified bands
warning off
for a = 1:length(chanlist)
%     disp(['Starting chan ' num2str(a) ' out of ' num2str(length(chanlist))])
    thischannel = chanlist(a);
    x = LoadBinary(fullfile(basepath,[basename '.lfp']), 'channels', thischannel, 'nChannels',par.nChannels);
    x = single(x);
    [wt,freqlist] = awt_freqlist(x, sampfreq, bandmeans);
    clear x 
    tamp = (real(wt).^2 + imag(wt).^2).^.5;%vector radius
%             tphase = atan(imag(wt)./real(wt));%vector angle
    clear wt
    
    %% save wavelet for each channel... if it had it's own max, otherwise channel is only used for various means
    if ismember(thischannel,chanswmax) 
        tn = ['ampCh' num2str(thischannel)];
        eval([tn ' = tamp;'])
        save(fullfile(basepath,[basename,'_WaveletForSpikePower.mat']),tn,'-append')
        eval(['clear ' tn])
        channelsdoneB1(end+1) = thischannel;
    end    
    
    %% save mean arrays for all all chans (ChannelMean) / all chans off of each shank (NonShankMeans)
    if a == 1;
        ChannelMean = zeros(size(tamp));
        for b = 1:length(Grps);
           eval(['NonShankMeans' num2str(b) ' = zeros(size(tamp));'])
        end
        for b = 1:length(shankswmax);
            tshank = shankswmax(b);
            eval(['ShankNeighborMeans' num2str(tshank) ' = zeros(size(tamp));'])
        end
    end
    
    ChannelMean = ChannelMean + tamp;           
    denom = denom+1;

    % all-nonshank-channels
    for b = 1:length(Grps);
        if ismember(thischannel,nonshankchanslists{b})
           eval(['NonShankMeans' num2str(b) ' = NonShankMeans' num2str(b) '+ tamp;']) 
           NonShankDenoms(b) = NonShankDenoms(b)+1;
        end
    end
    %neighbor-shank-channels
    for b = 1:length(shankswmax)
        tshank = shankswmax(b);
        if ismember(thischannel,neighborChansEachShank{b})
           eval(['ShankNeighborMeans' num2str(tshank) ' = ShankNeighborMeans' num2str(tshank) '+ tamp;']) 
        end
    end

    disp([num2str(a) ' out of ' num2str(length(chanlist)) ' done.'])
end
clear tamp

ChannelMean = ChannelMean/denom;
save(fullfile(basepath,[basename,'_WaveletForSpikePower.mat']),'ChannelMean','-append')

%% Save means of shank-excluded wavelets
for b = 1:length(Grps);
    eval(['NonShankMeans' num2str(b) ' = NonShankMeans' num2str(b) '/NonShankDenoms(b);'])
    save(fullfile(basepath,[basename,'_WaveletForSpikePower.mat']),['NonShankMeans' num2str(b)],'-append')
end
for b = 1:length(shankswmax)
    tshank = shankswmax(b);
    eval(['ShankNeighborMeans' num2str(tshank) ' = ShankNeighborMeans' num2str(tshank) '/length(neighborChansEachShank{b});'])
    save(fullfile(basepath,[basename,'_WaveletForSpikePower.mat']),['ShankNeighborMeans' num2str(tshank)],'-append')
end

save(fullfile(basepath,[basename,'_WaveletForSpikePower.mat']),...
    'channelsdoneB1','neighborShanksEachCell','neighborChansEachCell','neighborChansEachShank','-append')
