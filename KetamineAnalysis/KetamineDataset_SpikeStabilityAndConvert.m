function KetamineDataset_SpikeStabilityAndConvert(basepath)
% <<<<<<< HEAD
% Opens data saved in klusters/neurosuite format, does Watson2016 stability
% exlusion and then imports buzcode style
% =======
% >>>>>>> master

if ~exist('basepath','var')
    basepath = cd;
end
% <<<<<<< HEAD
basename = bz_BasenameFromBasepath(basepath);

[S,shank,cellIx] = LoadSpikeData(basename);
save([basename,'_SAll.mat'],'S','shank','cellIx')
% =======
% baseName = bz_BasenameFromBasepath(basepath);

[S,shank,cellIx] = LoadSpikeData(basename);
save([basename,'_SAll.mat'],'S','shank','cellIx')
% >>>>>>> master

%load([basename,'_SAll.mat'])

%% Load Bad Cells from manual basename_ClusteringNotes.csv (if exists)
% <<<<<<< HEAD
manualbadcells = BadCellsFromClusteringNotes(basename,shank,cellIx);

%% Look at cellular stability using Mahalanobis distances and total spike energies
SpikingAnalysis_CellStabilityScript(basepath)
% save([basename,'_SStable.mat'],'S','shank','cellIx','numgoodcells','badcells')
% =======
manualbadcells = BadCellsFromClusteringNotes(baseName,shank,cellIx);

%% Look at cellular stability using Mahalanobis distances and total spike energies
SpikingAnalysis_CellStabilityScript(basepath)
save([basename,'_SStable.mat'],'S','shank','cellIx','numgoodcells','badcells')
% >>>>>>> master

%% Convert to buzcode
ConvertSStableToBuzcodeSpikes(basepath)