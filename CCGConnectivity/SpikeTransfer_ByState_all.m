function SpikeTransfer_ByState_all

% secondsPerDetectionBin = 0.07;
% secondsPerProjectionBin = 0.07;

[names,dirs] = GetDefaultDataset;

for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};
    SpikeTransfer_ByState(basepath,basename);
%     close(h)
%     copyfile(fullfile(basepath,'FuncSyns',[basename '_FuncSynByState.mat']),['/mnt/brendon4/Dropbox/Dan&Brendon/FuncSynByState/' basename '_FuncSynByState.mat'])
end
