function UPstates_DetectAllDatasetUPstates

[names,dirs] = GetDefaultDataset;

for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};

    UPstates_DetectDatasetUPstates(basepath,basename)    
end