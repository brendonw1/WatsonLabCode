function Slopes = GatherWSSpikeSlopes

[names,dirs] = GetDefaultDataset;

Slopes.MedianOfNormE = [];
Slopes.MedianOfAbsE = [];
Slopes.MedianOfNormI = [];
Slopes.MedianOfAbsI = [];

for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};

%     s = SleepSpikerateSlopes(basepath,basename);
    t = load(fullfile(basepath,[basename '_SpikeRateSlopes.mat']));

    Slopes.MedianOfNormE = cat(1,Slopes.MedianOfNormE,t.Slopes.MedianOfNormE);
    Slopes.MedianOfAbsE = cat(1,Slopes.MedianOfAbsE,t.Slopes.MedianOfAbsE);
    Slopes.MedianOfNormI = cat(1,Slopes.MedianOfNormI,t.Slopes.MedianOfNormI);
    Slopes.MedianOfAbsI = cat(1,Slopes.MedianOfAbsI,t.Slopes.MedianOfAbsI);
end
