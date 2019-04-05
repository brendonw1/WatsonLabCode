function badOrigIdxs = OriginalIndicesOfBadICells(badSiIxs,basename)

% numbadcells = 8;
% 
% badSeIxs = sort_rate(1:numbadcells);

load([basename '_CellIDs.mat'])
load([basename '_ClusterQualityMeasures.mat'])
load([basename '_Intervals.mat'])
load([basename '_SAll.mat'])%should include shank and cellIX
load([basename '_GoodSleepInterval.mat'])

badSStableIxs = CellIDs.IAll(badSiIxs);

[allidxs,origidxsofnondeleted] = AddDeletedIndices(ClusterQualityMeasures.allbadcells,1:length(S));
badOrigIdxs = origidxsofnondeleted(badSStableIxs);

% disp('Calculated rates of bad cells')
% StateFR_out(badSeIxs,1)

% for a = 1:length(badSiIxs); 
%     disp(Rate(S{badOrigIdxs(a)},intersect(GoodSleepInterval,intervals{1})));
% end

for a = 1:length(badSiIxs); 
    disp(['S:' num2str(shank(badOrigIdxs(a))) '  C:' num2str(cellIx(badOrigIdxs(a)))]);
end

