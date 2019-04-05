function MakeSSubtypes_all

[names,dirs]=GetDefaultDataset;

for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};
    cd(basepath)
        
    [Se,SeDef,SeLike,Si,SiDef,SiLike,SRates,SeRates,SiRates] = MakeSSubtypes(basepath,basename);
    close all
end


