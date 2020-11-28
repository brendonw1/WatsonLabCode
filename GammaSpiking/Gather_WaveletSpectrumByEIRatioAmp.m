function Gather_WaveletSpectrumByEIRatioAmp(folderpath)

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
stateslist = {'all','w','wm','wnm','n','r'};
stateslist_usual = {'AllT','Wake','Nrem','Rem','Ma'};

for stidx = 1:length(stateslist)
    tst = stateslist{stidx};
    eval(['out.meanwavelet_' tst ' = [];'])
end    
out.bandmeans = {};
out.NumEIAmpBins = {};

%% For each data folder
for fidx = 1:length(names)
    basename = names{fidx};
    basepath = dirs{fidx};

    load(fullfile(basepath,[basename '_WaveletSpectrumByEIRatioAmp.mat']))
    t = WaveletSpectrumByEIRatioData;
    clear WaveletSpectrumByEIRatioData

    for stidx = 1:length(stateslist)
        tst = stateslist{stidx};
        eval(['out.meanwavelet_' tst ' = cat(3,out.meanwavelet_' tst ',t.meanwavelet_' tst ');'])
    end    
    out.bandmeans{fidx} = t.bandmeans;
    out.NumEIAmpBins{fidx} = t.NumEIAmpBins;
end

%% Get some basic params
GatheredWaveletSpectrumByEIRatioAmp = out;
save(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','GatheredData','GatheredWaveletSpectrumByEIRatioAmp.mat'),'GatheredWaveletSpectrumByEIRatioAmp')
1;


