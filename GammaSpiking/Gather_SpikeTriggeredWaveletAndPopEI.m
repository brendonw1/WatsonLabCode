function Gather_SpikeTriggeredWaveletAndPopEI(folderpath)

if ~exist('folderpath','var')
    folderpath = fullfile('/','proraid','GammaDataset');
end

%% Get list of datasets
d = getdir(folderpath);
names = {};
dirs = {};
for count = 1:length(d);
    if d(count).isdir
        names{end+1} = d(count).name;
        dirs{end+1} = fullfile(folderpath,d(count).name);
    end
end

%% Variable setup
fs = {'percellspectrum_home_AllT',...
    'percellspectrum_nsmean_AllT',...
    'percellspectrum_neib_AllT',...
    'percellspectrum_neib_Wake',...
    'percellspectrum_neib_Ma',...
    'percellspectrum_neib_Nrem',...
    'percellspectrum_neib_Rem',...
    'percellpopspikesE_AllT',...
    'percellpopspikesE_Wake',...
    'percellpopspikesE_Ma',...
    'percellpopspikesE_Rem',...
    'percellpopspikesE_Nrem',...
    'percellpopspikesI_AllT',...
    'percellpopspikesI_Wake',...
    'percellpopspikesI_Ma',...
    'percellpopspikesI_Rem',...
    'percellpopspikesI_Nrem'};
for nidx = 1:length(fs)
    eval(['out.' fs{nidx} ' = [];'])
end
statenames = {'AllT';'Wake';'Ma';'Nrem';'Rem'};
for nidx = 1:length(statenames)
    eval(['out.percellcounts.' statenames{nidx} '=[];'])
end
out.waves = [];
out.wavemins = [];
out.waveamps = [];
out.eegwavebaselineoffsets = [];
out.eegwavemedians = [];
out.eegwaves = [];
out.sampfreq = [];
out.secbefore = [];
out.secafter = [];
out.bandmeans = {};
out.CellTypes = [];

%% For each data folder
for fidx = 1:length(names)
    basename = names{fidx};
    basepath = dirs{fidx};
    
    load(fullfile(basepath,[basename '_SpikeTriggeredWaveletAndPopEI.mat']))
    t = PerCellWaveletSpectrumData;
    clear PerCellWaveletSpectrumData

    for nidx = 1:length(fs)
        eval(['dnum = ndims(t.' fs{nidx} ');'])
        eval(['out.' fs{nidx} ' = cat(dnum,out.' fs{nidx} ',t.' fs{nidx} ');'])
    end
    
    for nidx = 1:length(statenames)
        eval(['out.percellcounts.' statenames{nidx} ' = cat(2,out.percellcounts.' statenames{nidx} ',t.percellcounts.' statenames{nidx} ');'])
    end
    
    out.waves = cat(2,out.waves,t.waves);
    out.wavemins = cat(2,out.wavemins,t.wavemins);
    out.waveamps = cat(2,out.waveamps,t.waveamps);
    out.eegwavebaselineoffsets = cat(2,out.eegwavebaselineoffsets,t.eegwavebaselineoffsets);
    out.eegwavemedians = cat(2,out.eegwavemedians,t.eegwavemedians);
    out.eegwaves = cat(2,out.eegwaves,t.eegwaves);
    out.sampfreq(fidx) = t.sampfreq;
    out.secbefore(fidx) = t.secbefore;
    out.secafter(fidx) = t.secafter;
    out.bandmeans{fidx} = t.bandmeans;
    out.CellTypes = cat(1,out.CellTypes,t.CellTypes);
end

%% Get some basic params
PerCellWaveletSpectrumData = out;
save(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','GatheredData','PerCellWaveletSpectrumData.mat'),'PerCellWaveletSpectrumData','-v7.3')
1;


