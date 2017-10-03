function Compare5minSWSSpectra_all(ep1)

if ~exist('ep1','var')
    ep1 = '5minsws';
end

[names,dirs]=GetDefaultDataset;

for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};

    Compare5minSWSSpectra(basepath,basename,ep1);
    close all
end
