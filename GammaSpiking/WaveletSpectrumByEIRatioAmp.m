function WaveletSpectrumByEIRatioAmp(basepath)
% Spectrum by Different EIRatio bins... in different states for a single
% recording

NumEIAmpBins = 10;
MinMoveSecs = 5;
MinNonmoveSecs = 5;

if ~exist('basepath','var')
    basepath = cd;
end
basename = bz_BasenameFromBasepath(basepath);


load(fullfile(basepath,[basename '_WaveletForGamma']))
if ~exist(fullfile(basepath,[basename '_EIRatio_Bin1Smooth1.mat']),'file')
    disp('Generating EIRatio, 1sec bins')
    EIRatioData = EIRatio(1,1,basepath,basename);
    disp('... finished')
else
    load(fullfile(basepath,[basename '_EIRatio_Bin1Smooth1.mat']))
end
EI = EIRatioData.ZPCEI;
load(fullfile(basepath,[basename '-states']),'states')

%find movement or non-movement of at least 5 sec consecutive
load(fullfile(basepath,[basename '_Motion']),'motiondata')
moves = continuousabove2_v2(motiondata.thresholdedsecs,0.5,MinMoveSecs,Inf);
moves = inttobool(moves,length(motiondata.thresholdedsecs));
nonmoves = continuousbelow2(motiondata.thresholdedsecs,0.5,MinNonmoveSecs,Inf);
nonmoves = inttobool(nonmoves,length(motiondata.thresholdedsecs));


adder = 1/sampfreq;
databinstarts = EIRatioData.bincentertimes-(0.5*EIRatioData.binwidthsecs)+adder;
databinends = EIRatioData.bincentertimes+(0.5*EIRatioData.binwidthsecs);

%% grab starts and ends of each state
statestartends = cat(2,0,logical(abs(diff(states))));
statestarts = cat(1,1,find(statestartends)');
if statestarts(end) == length(states)
    statestarts(end) = [];
end
statestarts = statestarts + adder;
if statestarts(1) ~= 1+adder;%make sure statestarts(1) = 0
    statestarts = cat(1,0,statestarts);
else
    statestarts(1) = 0;
end

stateends = cat(1,1,find(statestartends)');
if stateends(1) == 1
    stateends(1) = [];
end
if stateends(end) ~= length(states)
    stateends = cat(1,stateends,length(states));
end

statestartends = cat(2,statestarts,stateends);
clear statestarts stateends

%% Grab values for whole timeseries, regardless of state
pointsperbin = EIRatioData.binwidthsecs*sampfreq;
numbins = floor(size(amp,1)/pointsperbin);

% reshape to make bin-sized chunks
if size(amp,1)>pointsperbin*numbins
    amp(pointsperbin*numbins+1:end,:) = [];
    EI = EI(1:end-1);
    databinstarts = databinstarts(1:end-1);
    databinends = databinends(1:end-1);    
end
amp = zscore(amp,[],1);
amp2 = reshape(amp,pointsperbin,numbins,size(amp,2));

[bincounts,edges,idxs] = histcounts(EI,NumEIAmpBins);%bin EI values

meanwavelet_all = nan(length(bandmeans),NumEIAmpBins);%blank array
for a = 1:NumEIAmpBins
    tidxs = find(idxs==a);
    meanwavelet_all(:,a) = squeeze(mean(mean(amp2(:,tidxs,:),2),1));
end
clear amp2

%% Find EI bins with consistent internal state
% regardless of whether EI bins are bigger or state bins are bigger

% do a big inInterval of all starts on all bins... get idx of each start
[~,intidx_s] = InIntervalsBW(databinstarts,statestartends);
% do a big inInterval of all ends on all bins... get idx of each end
[~,intidx_e] = InIntervalsBW(databinends,statestartends);
    
startstopbinmatch = ~logical(abs([intidx_s-intidx_e]));%whether start state and end state of each EI bin are same

binsforwake = [];
binsforwakem = [];
binsforwakenm = [];
binsfornrem = [];
binsforrem = [];
for a = 1:length(EI)
    if databinends(a) < length(states)
        tstates = states(databinends(a));
%         tstates = states(databinstarts(a):databinends(a));
        if startstopbinmatch(a) %if full EI bin is in the same state bin
%         if ~abs(sum(diff(tstates)))%if there were no state changes, use this epoch
            switch tstates(1)
                case 1
                    binsforwake(end+1) = a;
                    if moves(databinends(a))
                        binsforwakem(end+1) = a;
                    end
                    if nonmoves(databinends(a))
                        binsforwakenm(end+1) = a;
                    end
                case 3
                    binsfornrem(end+1) = a;
                case 5
                    binsforrem(end+1) = a;
            end
%         else
%             disp(a);
        end
    end
end

% get EI bins for each state chunk
EI_w = EI(binsforwake);
EI_wm = EI(binsforwakem);
EI_wnm = EI(binsforwakenm);
EI_n = EI(binsfornrem);
EI_r = EI(binsforrem);

% get corresponding wavelet spectrogram chunks for each state,
% corresponding to each bin called for and saved for EI
binstarts_w = round(databinstarts(binsforwake)*sampfreq);
binends_w = round(databinends(binsforwake)*sampfreq);
binstarts_wm = round(databinstarts(binsforwakem)*sampfreq);
binends_wm = round(databinends(binsforwakem)*sampfreq);
binstarts_wnm = round(databinstarts(binsforwakenm)*sampfreq);
binends_wnm = round(databinends(binsforwakenm)*sampfreq);
binstarts_n = round(databinstarts(binsfornrem)*sampfreq);
binends_n = round(databinends(binsfornrem)*sampfreq);
binstarts_r = round(databinstarts(binsforrem)*sampfreq);
binends_r = round(databinends(binsforrem)*sampfreq);

amp_w = zeros(binends_w(1)-binstarts_w(1)+1,length(bandmeans),length(binstarts_w));
amp_n = zeros(binends_w(1)-binstarts_w(1)+1,length(bandmeans),length(binstarts_n));
amp_r = zeros(binends_w(1)-binstarts_w(1)+1,length(bandmeans),length(binstarts_r));

for a = 1:length(binstarts_w);
    amp_w(:,:,a) = amp(binstarts_w(a):binends_w(a),:);
end
for a = 1:length(binstarts_n);
    amp_n(:,:,a) = amp(binstarts_n(a):binends_n(a),:);
end
for a = 1:length(binstarts_r);
    amp_r(:,:,a) = amp(binstarts_r(a):binends_r(a),:);
end

if ~isempty(binends_wm)
    amp_wm = zeros(binends_wm(1)-binstarts_wm(1)+1,length(bandmeans),length(binstarts_wm));
    for a = 1:length(binstarts_wm);
        amp_wm(:,:,a) = amp(binstarts_wm(a):binends_wm(a),:);
    end
else
    amp_wm = [];
end

if ~isempty(binends_wnm)
    amp_wnm = zeros(binends_wnm(1)-binstarts_wnm(1)+1,length(bandmeans),length(binstarts_wnm));
    for a = 1:length(binstarts_wnm);
        amp_wnm(:,:,a) = amp(binstarts_wnm(a):binends_wnm(a),:);
    end
else
    amp_wnm = [];
end
clear amp

% Rank EI Ratio into nbins, grab spectrum for each EI bin
[bincounts_w,edges_w,idxs_w] = histcounts(EI_w,NumEIAmpBins);
meanwavelet_w = nan(length(bandmeans),NumEIAmpBins);
for a = 1:NumEIAmpBins
    tidxs = find(idxs_w==a);
    meanwavelet_w(:,a) = squeeze(mean(mean(amp_w(:,:,tidxs),3),1));
end

[bincounts_wm,edges_wm,idxs_wm] = histcounts(EI_wm,NumEIAmpBins);
meanwavelet_wm = nan(length(bandmeans),NumEIAmpBins);
if ~isempty(binends_wm)
    for a = 1:NumEIAmpBins
        tidxs = find(idxs_wm==a);
        meanwavelet_wm(:,a) = squeeze(mean(mean(amp_wm(:,:,tidxs),3),1));
    end
end

if ~isempty(binends_wnm)
    [bincounts_nmw,edges_nmw,idxs_wnm] = histcounts(EI_wnm,NumEIAmpBins);
    meanwavelet_wnm = nan(length(bandmeans),NumEIAmpBins);
    for a = 1:NumEIAmpBins
        tidxs = find(idxs_wnm==a);
        meanwavelet_wnm(:,a) = squeeze(mean(mean(amp_wnm(:,:,tidxs),3),1));
    end
end

[bincounts_n,edges_n,idxs_n] = histcounts(EI_n,NumEIAmpBins);
meanwavelet_n = nan(length(bandmeans),NumEIAmpBins);
for a = 1:NumEIAmpBins
    tidxs = find(idxs_n==a);
    meanwavelet_n(:,a) = squeeze(mean(mean(amp_n(:,:,tidxs),3),1));
end

[bincounts_r,edges_r,idxs_r] = histcounts(EI_r,NumEIAmpBins);
meanwavelet_r = nan(length(bandmeans),NumEIAmpBins);
for a = 1:NumEIAmpBins
    tidxs = find(idxs_r==a);
    meanwavelet_r(:,a) = squeeze(mean(mean(amp_r(:,:,tidxs),3),1));
end

WaveletSpectrumByEIRatioData = v2struct(NumEIAmpBins,bandmeans,meanwavelet_all,meanwavelet_w,meanwavelet_wm,meanwavelet_wnm,meanwavelet_n,meanwavelet_r);
save(fullfile(basepath,[basename '_WaveletSpectrumByEIRatioAmp']),'WaveletSpectrumByEIRatioData')

%% plotting   
h = figure('position',[5 5 800 600],'name','WaveletSpectrumByEIRatio');

subplot(2,3,1)
imagesc(meanwavelet_w);
axis xy;
yticks = get(gca,'YTick');
set(gca,'YTickLabel',bandmeans(yticks))
xlabel('Low -> High EIRatio')
title('Wake')

subplot(2,3,2)
imagesc(meanwavelet_wm);
axis xy;
yticks = get(gca,'YTick');
set(gca,'YTickLabel',bandmeans(yticks))
xlabel('Low -> High EIRatio')
title('Wake_Move5')

subplot(2,3,3)
imagesc(meanwavelet_wnm);
axis xy;
yticks = get(gca,'YTick');
set(gca,'YTickLabel',bandmeans(yticks))
xlabel('Low -> High EIRatio')
title('Wake_Nonmove5')

subplot(2,3,4)
imagesc(meanwavelet_n);
axis xy;
yticks = get(gca,'YTick');
set(gca,'YTickLabel',bandmeans(yticks))
xlabel('Low -> High EIRatio')
title('nonREM')

subplot(2,3,5)
imagesc(meanwavelet_r);
axis xy;
yticks = get(gca,'YTick');
set(gca,'YTickLabel',bandmeans(yticks))
xlabel('Low -> High EIRatio')
title('REM')

subplot(2,3,6)
imagesc(meanwavelet_all);
axis xy;
yticks = get(gca,'YTick');
set(gca,'YTickLabel',bandmeans(yticks))
xlabel('Low -> High EIRatio')
title('All states')


MakeDirSaveFigsThere(fullfile(basepath,'SpikeSpectrumFigs'),h,'fig')
MakeDirSaveFigsThere(fullfile(basepath,'SpikeSpectrumFigs'),h,'png')

1;

