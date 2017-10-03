function [SynCounts,h] = CountFuncsynapses_all


[names,dirs]=GetDefaultDataset;

for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};
%      StateRateBins = GatherStateRateBinMatrices(basepath,basename,1,1);

    t = load(fullfile(basepath,[basename '_CellIDs.mat']));
    CellIDs = t.CellIDs;
    t = load(fullfile(basepath,[basename '_funcsynapsesMoreStringent.mat']));
    funcsynapses = t.funcsynapses;

    if a == 1;
        SynCounts = CountFuncsynapses(funcsynapses,CellIDs);
        SynCounts_DS = CountFuncsynapses_DiffShanks(funcsynapses,CellIDs);
    else
        SynCounts = CountFuncsynapses(funcsynapses,CellIDs,SynCounts);
        SynCounts_DS = CountFuncsynapses_DiffShanks(funcsynapses,CellIDs,SynCounts_DS);
    end

%     close(h)
end

h = PlotSynapseCounts(SynCounts);
SynCounts_DS.TotalPairsCompared = SynCounts_DS.DiffShankPairsCompared;
h2 = PlotSynapseCounts(SynCounts_DS);

h = cat(1,h(:),h2(:));

set(h(1),'name','TreeCountsSynCorr_All_Absolute')
set(h(2),'name','TreeCountsSynCorr_All_Percents')
set(h(3),'name','TreeCountsSynCorr_DiffShank_Absolute')
set(h(4),'name','TreeCountsSynCorr_DiffShank_Percents')

MakeDirSaveVarThere('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/FuncSynapses/',SynCounts)
MakeDirSaveVarThere('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/FuncSynapses/',SynCounts_DS)

MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/FuncSynapses/',h,'fig');
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/FuncSynapses/',h,'png');