function Assemblies_CrossStateZscoreMeans_all

secondsperbin = 1;

wsw = 0;
synapses = 0;
spindles = 1;
[names,dirs] = SleepAnalysis_GetDatasetNameDirsFromSleepSessionMatrix(wsw,synapses,spindles);

for a = 12:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};
%      StateRateBins = GatherStateRateBinMatrices(basepath,basename,1,1);
    Assemblies_CrossStateZscoreMeans(basepath,basename,secondsperin);
    close all
end
