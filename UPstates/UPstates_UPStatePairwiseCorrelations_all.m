function UPstates_UPStatePairwiseCorrelations_all

wsw = 0;
synapses = 0;
spindles = 1;
[names,dirs] = SleepAnalysis_GetDatasetNameDirsFromSleepSessionMatrix(wsw,synapses,spindles);

for a = 9:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};
    h = UPstates_UPStatePairwiseCorrelations(basepath,basename);
    close(h)
end
