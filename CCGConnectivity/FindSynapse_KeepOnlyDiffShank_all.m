function FindSynapse_KeepOnlyDiffShank_all

[names,dirs]=GetDefaultDataset;

texttext = {};

for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};
    cd(basepath)
    
    fs = FindSynapse_KeepOnlyDiffShank(basepath,basename);
    
    %% outputting a text doc of connections
    texttext = cat(1,texttext,['Rat: ' basename]);

    ne = size(fs.ConnectionsE,1);
    ni = size(fs.ConnectionsI,1);
    for a = 1:ne
        s1 = num2str(fs.CellShanks(fs.ConnectionsE(a,1)));
        s2 = num2str(fs.CellShanks(fs.ConnectionsE(a,2)));
        c1 = num2str(fs.CellShankIDs(fs.ConnectionsE(a,1)));
        c2 = num2str(fs.CellShankIDs(fs.ConnectionsE(a,2)));
        
        texttext = cat(1,texttext,['Ecnxn s' s1 ':c' c1 ' to s' s2 ':c' c2]);
    end
    for a = 1:ni
        s1 = num2str(fs.CellShanks(fs.ConnectionsI(a,1)));
        s2 = num2str(fs.CellShanks(fs.ConnectionsI(a,2)));
        c1 = num2str(fs.CellShankIDs(fs.ConnectionsI(a,1)));
        c2 = num2str(fs.CellShankIDs(fs.ConnectionsI(a,2)));
        
        texttext = cat(1,texttext,['Icnxn s' s1 ':c' c1 ' to s' s2 ':c' c2]);
    end

end

filename = '/mnt/brendon4/Dropbox/Jonathan&Brendon/DifferentShankCCGs/PairList.txt';
charcelltotext(texttext,filename)
% write texttext