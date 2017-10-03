function Gather_WaveletSpectrumByEMGLevel(folderpath)

if ~exist('folderpath','var')
    folderpath = fullfile('/','proraid','GammaDataset');
end

%%
% ndivs = 6;

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


%% For each data folder
for fidx = 1:length(names)
    basename = names{fidx};
    basepath = dirs{fidx};

    load(fullfile(basepath,[basename '_WaveletSpectrumByEMGLevel.mat']))
    t = WaveletSpectrumByEMGData;
    clear WaveletSpectrumByEMGData

    out.WakeSpectra(:,:,fidx) = t.WakeSpectra;
    out.NremSpectra(:,fidx) = t.NremSpectra;
    out.RemSpectra(:,fidx) = t.RemSpectra;
    
    out.bandmeans{fidx} = t.bandmeans;
    out.sampfreq{fidx} = t.sampfreq;
    out.NumDivisions(fidx) = t.NumDivisions;
    out.SecondDivisionIdxs{fidx} = t.SecondDivisionIdxs;
end

%% Get some basic params
GatheredWaveletSpectrumByEMG = out;
save(fullfile(getdropbox,'BW_OUTPUT','GammaSpikingProject','GatheredData','GatheredWaveletSpectrumByEMG.mat'),'GatheredWaveletSpectrumByEMG')
1;


