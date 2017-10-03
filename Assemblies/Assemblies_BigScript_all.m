function Assemblies_BigScript_all

[names,dirs] = GetDefaultDataset;

for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};
    Assemblies_BigScript(basepath,basename);
    close all
end
