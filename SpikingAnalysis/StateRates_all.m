function StateRates_all

[names,dirs]=GetDefaultDataset;

for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};
    cd(basepath)
        
    StateRates(basepath,basename);
    close all
end