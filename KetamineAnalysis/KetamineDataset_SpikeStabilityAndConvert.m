function KetamineDataset_SpikeStabilityAndConvert(basepath)
% Opens data saved in klusters/neurosuite format, does Watson2016 stability
% exlusion and then imports buzcode style

if ~exist('baspath','var')
    basepath = cd;
end
basename = bz_BasenameFromBasepath(basepath);

[S,shank,cellIx] = LoadSpikeData(basename);
save([basename,'_SAll.mat'],'S','shank','cellIx')

%load([basename,'_SAll.mat'])

%% Load Bad Cells from manual basename_ClusteringNotes.csv (if exists)
manualbadcells = BadCellsFromClusteringNotes(basename,shank,cellIx);

%% Look at cellular stability using Mahalanobis distances and total spike energies
SpikingAnalysis_CellStabilityScript(basepath)
% save([basename,'_SStable.mat'],'S','shank','cellIx','numgoodcells','badcells')

%% Convert to buzcode
ConvertSStableToBuzcodeSpikes(basepath)