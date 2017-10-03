function FindUPsWithSpindles_all

wsw = 0;
synapses = 0;
spindles = 0;
[names,dirs] = SleepAnalysis_GetDatasetNameDirsFromSleepSessionMatrix(wsw,synapses,spindles);

for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};
%     if ~exist(fullfile(basepath,'UPstates',[basename '_UPSpikeStatsE.mat']),'file')
        [~] = FindUPsWithSpindles(basepath,basename);
%     end
end