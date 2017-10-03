function SpikeTransfer_Per1MinuteICnxnsOnly_all

[names,dirs] = GetDefaultDataset;

for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};
    SpikeTransfer_Per1MinuteICnxnsOnly(basepath,basename);
end
