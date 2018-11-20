function KetamineDataset_SpikeStabilityAndConvert(basepath)

if ~exist('baspath','var')
    basepath = cd;
end
baseName = bz_BasenameFromBasepath(basepath);

[S,shank,cellIx] = LoadSpikeData(baseName);
save([baseName,'_SAll.mat'],'S','shank','cellIx')

%load([basename,'_SAll.mat'])

%% Load Bad Cells from manual basename_ClusteringNotes.csv (if exists)
manualbadcells = BadCellsFromClusteringNotes(baseName,shank,cellIx);

%% Look at cellular stability using Mahalanobis distances and total spike energies
SpikingAnalysis_CellStabilityScript
save([basename,'_SStable.mat'],'S','shank','cellIx','numgoodcells','badcells')

%% Convert to buzcode
ConvertSStableToBuzcodeSpikes(basepath)