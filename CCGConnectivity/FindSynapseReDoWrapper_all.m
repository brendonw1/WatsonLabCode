function FindSynapseReDoWrapper_all

[names,dirs] = GetDefaultDataset;

for a = 25:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};
    FindSynapseReDoWrapper(basepath,basename);
end
