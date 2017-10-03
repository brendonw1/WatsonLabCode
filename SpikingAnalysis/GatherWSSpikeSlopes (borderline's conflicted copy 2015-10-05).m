function Slopes = GatherWSSpikeSlopes

[names,dirs] = GetDefaultDataset;

Slopes.MedianOfNormE = [];
Slopes.MedianOfAbsE = [];
Slopes.MedianOfNormI = [];
Slopes.MedianOfAbsI = [];

for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};

    t = load(fullfile(basepath,[basename '_SpikeRateSlopes.mat']));
    s = t.Slopes;
    
    Slopes.MedianOfNormE = cat(1,Slopes.MedianOfNormE,s.MedianOfNormE);
    Slopes.MedianOfAbsE = cat(1,Slopes.MedianOfAbsE,s.MedianOfAbsE);
    Slopes.MedianOfNormI = cat(1,Slopes.MedianOfNormI,s.MedianOfNormI);
    Slopes.MedianOfAbsI = cat(1,Slopes.MedianOfAbsI,s.MedianOfAbsI);
end
