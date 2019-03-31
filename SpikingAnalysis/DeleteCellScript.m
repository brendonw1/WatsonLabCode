%% starts with changing clustering notes for this cell... then save to basename_ClusteringNotes.csv
%% also must have badshanknumsclunums signifying [shanknum cellIx] of each bad cell... one row for each cell
% this last part is necessary for deleting the relevant funcsynapses

load(fullfile(basepath,[basename '_BasicMetaData']))
load(fullfile(basepath,[basename '_SStable']))
for a = 1:size(badshanknumsclunums,1)
    ts = shank == badshanknumsclunums(a,1);
    tc = cellIx == badshanknumsclunums(a,2);
    OrigStableIdxs(a) = find(ts .* tc);
end

%%
manualbadcells = BadCellsFromClusteringNotes(basename,shank,cellIx);
load(fullfile(basepath,[basename '_SAll.mat']))
load(fullfile(basepath,[basename '_funcsynapsesMoreStringent.mat']))
load(fullfile(basepath,[basename '_Intervals.mat']))
load(fullfile(basepath,[basename '_CellClassificationOutput.mat']))


%% Look at cellular stability using Mahalanobis distances and total spike energies
SpikingAnalysis_CellStabilityScript
save([basename,'_SStable.mat'],'S','shank','cellIx','numgoodcells','badcells')

% load([basename '_ClusterQualityMeasures'])
% load([basename,'_SStable.mat'])
%% Burst Filter to prep for spike transmission
Sbf = burstfilter(S,6);%burst filter at 6ms for looking at connections
save([basename,'_SBurstFiltered.mat'],'Sbf');

%% Funcsynapses... find all connections with the bad cells... 
funcsynapses = DeleteFuncSynapsesOfBadCell(funcsynapses,OrigStableIdxs);
save([basename '_funcsynapsesMoreStringent'],'funcsynapses')

%%
CellClassificationOutput.CellClassOutput(OrigStableIdxs,:) = [];

CellIDs.EDefinite = funcsynapses(1).ECells';%First approximation... will handle special case later
CellIDs.IDefinite = funcsynapses(1).ICells';%inhibitory interactions 
CellIDs.ELike = find((CellClassificationOutput.CellClassOutput(:,4)==1) & (CellClassificationOutput.CellClassOutput(:,5)==0));
CellIDs.ILike = find((CellClassificationOutput.CellClassOutput(:,4)==-1) & (CellClassificationOutput.CellClassOutput(:,5)==0));
CellIDs.EAll = union(CellIDs.EDefinite,CellIDs.ELike);
CellIDs.IAll = union(CellIDs.IDefinite,CellIDs.ILike);

save([basename, '_CellIDs.mat'],'CellIDs')
save([basename,'_CellClassificationOutput.mat'],'CellClassificationOutput')

clear CellClassOutput PyrBoundary SpkWvform_good SpkWvform_goodidx
% load([basename, '_CellIDs.mat'])
% load([basename,'_CellClassificationOutput.mat'])

%% Dividing spikes by cell class (based on S variable above)
[Se,SeDef,SeLike,Si,SiDef,SiLike,SRates,SeRates,SiRates] = MakeSSubtypes(basepath,basename);
% load([basename '_SSubtypes'])

%% Getting binned spike times for all cells combined & for cell types... 10sec bins

[binnedTrains,h] = SpikingAnalysis_PlotPopulationSpikeRates(basename,S,CellIDs,intervals);
SpikingAnalysis_BinnedTrainsForStateEditor(binnedTrains,basename,basepath);

MakeDirSaveFigsThere('RawSpikeRateFigs',h)

%%
StateRates(basepath,basename);
Spindles_GetSpindleIntervalSpiking(basepath,basename);
UPstates_GetUPstateIntervalSpiking(basepath,basename);
