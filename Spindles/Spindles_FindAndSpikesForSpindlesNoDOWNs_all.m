function Spindles_FindAndSpikesForSpindlesNoDOWNs_all

wsw = 0;
synapses = 0;
spindles = 1;
[names,dirs] = SleepAnalysis_GetDatasetNameDirsFromSleepSessionMatrix(wsw,synapses,spindles);

for a = 12:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};
    cd (basepath) % too many assumptions inside not to
    FindSpindlesWithDOWNs(basepath,basename);
    Spindles_GetNoDOWNSpindleIntervalSpiking(basepath,basename);%     close(h)
end
