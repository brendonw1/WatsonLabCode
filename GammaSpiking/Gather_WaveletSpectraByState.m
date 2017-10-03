function Gather_WaveletSpectraByState(folderpath)

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
% get stateslist
fidx = 1;
basename = names{fidx};
basepath = dirs{fidx};
load(fullfile(basepath,[basename '_WaveletSpectrumByState.mat']))
t = WaveletSpectrumByState;
clear WaveletSpectrumByState
if isfield(t,'stateslist');
    stateslist = t.stateslist;
else
    stateslist = {'AllT','Wake','WakeMove5','WakeNonmove5','Nrem','Rem','Ma'};
end
for stidx = 1:length(stateslist)
    tst = stateslist{stidx};
    eval(['out.SpectrumFor' tst ' = [];'])
end    
out.stateslist = stateslist;
out.bandmeans = {};

%% For each data folder
for fidx = 1:length(names)
    basename = names{fidx};
    basepath = dirs{fidx};
    load(fullfile(basepath,[basename '_WaveletSpectrumByState.mat']))
    t = WaveletSpectrumByState;
    clear WaveletSpectrumByState

    for stidx = 1:length(stateslist)
        tst = stateslist{stidx};
        if isfield(t,['SpectrumFor' tst])
            eval(['x = t.SpectrumFor' tst ';'])
        else
            x = nan(1,length(t.bandmeans));
        end
        
        eval(['out.SpectrumFor' tst ' = cat(1,out.SpectrumFor' tst ',x);'])
    end    
    out.bandmeans{fidx} = t.bandmeans;
end

%% Get some basic params
GatheredWaveletSpectraByState = out;
save(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','GatheredData','GatheredWaveletSpectraByState.mat'),'GatheredWaveletSpectraByState')
1;


