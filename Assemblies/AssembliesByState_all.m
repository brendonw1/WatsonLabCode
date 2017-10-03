function AssembliesByState_all(secondsPerDetectionBin,secondsPerProjectionBin)

% secondsPerDetectionBin = 0.07;
% secondsPerProjectionBin = 0.07;

wsw = 0;
synapses = 0;
spindles = 1;
[names,dirs] = SleepAnalysis_GetDatasetNameDirsFromSleepSessionMatrix(wsw,synapses,spindles);

for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};
%      StateRateBins = GatherStateRateBinMatrices(basepath,basename,1,1);
    AssembliesByState(basepath,basename,secondsPerDetectionBin,secondsPerProjectionBin);
%     close(h)
end
