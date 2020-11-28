function WaveletSpectraByEMGLevel(basepath)
% Individual cells correlated against various frequency bands.  Each cell
% vs each band.  Also population and broadband data used too.
% Brendon Watson 2017

%% Constants
NumDivisions = 6;

%% Input handling
if ~exist('basepath','var')
    basepath = cd;
end
basename = bz_BasenameFromBasepath(basepath);

if ~exist('plotting','var')
    plotting = 0;
end

%% Loading up
load(fullfile(basepath,[basename '_WaveletForGamma.mat']),'amp')
load(fullfile(basepath,[basename '_WaveletForGamma.mat']),'bandmeans')
load(fullfile(basepath,[basename '_WaveletForGamma.mat']),'sampfreq')
load(fullfile(basepath,[basename '-states.mat']))
load(fullfile(basepath,[basename '_Motion']),'motiondata')

%restrict to good sleep interval, always thus far has been a single
%start-stop interval
load(fullfile(basepath,[basename '_GoodSleepInterval.mat']))
states((1:length(states))>GoodSleepInterval.timePairFormat(2)) = [];
states((1:length(states))<GoodSleepInterval.timePairFormat(1)) = [];

%get divisions (like GetQuartileIdxs, but some subindexing)


WakeIdxs = states==1;
NremIdxs = states==3;
RemIdxs = states==5;

%% Wake
emgtouse = motiondata.motion;
emgtouse(~WakeIdxs) = nan;
WakeEmg = motiondata.motion(WakeIdxs);
subidxs = GetQuartilesByRank(WakeEmg,NumDivisions);
SecondDivisionIdxs = nan(length(emgtouse),1);

for a = 1:NumDivisions
    tvals = WakeEmg(subidxs==a);
    tmax = max(tvals);
    tmin = min(tvals);
    if ~isempty(tmin) && ~isempty(tmax)
        SecondDivisionIdxs(emgtouse>tmin & emgtouse<=tmax) = a;
    end
end

%resampling out to sampfreq (from 1Hz)
WakeSampidxs = nan(size(amp,1),1);
for sidx = 1:length(SecondDivisionIdxs)
    WakeSampidxs([((sidx-1)*sampfreq)+1]:sidx*sampfreq) = SecondDivisionIdxs(sidx);
end

%go grab the average spectrum for each rank group of samples
for stidx = 1:NumDivisions
    theseidxs = WakeSampidxs==stidx;
    thisspectrum = mean(amp(theseidxs,:),1);

    %save
    WaveletSpectrumByEMGData.WakeSpectra(stidx,:) = thisspectrum;
end

%% NREM
%resampling out to sampfreq (from 1Hz)
NremSampidxs = zeros(size(amp,1),1);
tgood = find(NremIdxs==1);
for sidx = 1:length(tgood)
    NremSampidxs([((tgood(sidx)-1)*sampfreq)+1]:(tgood(sidx)*sampfreq)) = 1;
end
theseidxs = NremSampidxs==1;
WaveletSpectrumByEMGData.NremSpectra = mean(amp(theseidxs,:),1);

%% REM
%resampling out to sampfreq (from 1Hz)
RemSampidxs = zeros(size(amp,1),1);
tgood = find(RemIdxs==1);
for sidx = 1:length(tgood)
    RemSampidxs([((tgood(sidx)-1)*sampfreq)+1]:(tgood(sidx)*sampfreq)) = 1;
end
theseidxs = RemSampidxs==1;
WaveletSpectrumByEMGData.RemSpectra = mean(amp(theseidxs,:),1);


%% save
WaveletSpectrumByEMGData.bandmeans = bandmeans;
WaveletSpectrumByEMGData.sampfreq = sampfreq;
WaveletSpectrumByEMGData.NumDivisions = NumDivisions;
WaveletSpectrumByEMGData.SecondDivisionIdxs = SecondDivisionIdxs;

save(fullfile(basepath,[basename '_WaveletSpectrumByEMGLevel']),'WaveletSpectrumByEMGData','-v7.3')
1;
%% plot