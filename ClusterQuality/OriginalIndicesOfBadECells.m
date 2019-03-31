function badOrigIdxs = OriginalIndicesOfBadECells(badSeIxs,basename)

% numbadcells = 8;
% 
% badSeIxs = sort_rate(1:numbadcells);

load([basename '_CellIDs.mat'])
load([basename '_ClusterQualityMeasures.mat'])
load([basename '_SAll.mat'])%should include shank and cellIX

badSStableIxs = CellIDs.EAll(badSeIxs);

[allidxs,origidxsofnondeleted] = AddDeletedIndices(ClusterQualityMeasures.allbadcells,1:length(S));
badOrigIdxs = origidxsofnondeleted(badSStableIxs);


% 
% load([basename '_Intervals.mat'])
% load([basename '_GoodSleepInterval.mat'])
% 
% % disp('Calculated rates of bad cells')
% % StateFR_out(badSeIxs,1)
% 
% for a = 1:length(badSeIxs); 
%     disp(Rate(CompressSpikeTrainsToIntervals(S{badOrigIdxs(a)},intersect(GoodSleepInterval,intervals{1}))));
% end
% 
% for a = 1:length(badSeIxs); 
%     disp(['S:' num2str(shank(badOrigIdxs(a))) '  C:' num2str(cellIx(badOrigIdxs(a)))]);
% end
% 
