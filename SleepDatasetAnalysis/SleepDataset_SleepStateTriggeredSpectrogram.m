function SleepDataset_SleepStateTriggeredSpectrogram(statenumber,plotting)

if ~exist('statenumber','var')
    statenumber = 5;%default is REM
end
if ~exist('plotting','var')
    plotting = 0;%boolean for PETH command
end

[names,dirs] = SleepDataset_GetDatasetsDirs_WSWandSynapses;
n = ['PeriSleepSpiking_On_' date];

tssampfreq = 10000;%timebase of the tstoolbox objects used here
binsize = 1;%seconds
beforesample = 100;%seconds
aftersample = 30;%seconds
eventtime = beforesample/binsize;

pethNumBeforeBins = beforesample/binsize;
pethNumAfterBins = aftersample/binsize;

% AvailCells = [];
% rawcounts = [];
% normcounts = [];
% norminterpolatedcounts = [];
% meanperchannel = [];

for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};
    
    warning off
    t = load([fullfile(dirs{a},names{a}) '_Intervals.mat']);
    intervals = t.intervals;
    t = load([fullfile(dirs{a},names{a}) '_GoodSleepInterval.mat']);
    GoodSleepInterval = t.GoodSleepInterval;
%     t = load([fullfile(dirs{a},names{a}) '_WSWEpisodes.mat']);
%     WSEpisodes = t.WSEpisodes;
%     WSBestIdx = t.WSBestIdx;
%     channelanatomy = read_mixed_csv([fullfile(dirs{a},names{a}) '_ChannelAnatomy.csv'],',');
    % read spectrum from .eegstates.mat file
    t = load([fullfile(basepath,basename) '.eegstates.mat']);
    chans = t.StateInfo.Chs;

    warning on

    for b = 1:length(chans)
        channum = chans(b);
        meanthischanspectra = StateTriggeredSpectrogram...
            (statenumber,beforesample,aftersample,channum,intervals,GoodSleepInterval,tssampfreq,basepath,basename);
    end
    
    % get each spectrogram (ie 3)
    % store per recording
    % make new take mean per recording
    % plot per recordng
    % avereage... ?per recording, per event?
    % plot average per region... make region lists per channel somewhere...
    %   then reference that for each taken spectrogram
end
   
