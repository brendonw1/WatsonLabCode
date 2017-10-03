function CellIDMatrix = GatherAllCellClassMatrix

[names,dirs]=GetDefaultDataset;
CellIDMatrix = [];

for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};
    cd(basepath)

%     bmd = load(fullfile(basepath,[basename '_BasicMetaData.mat']));
%     anat = GetChannelAnatomy(basename,bmd.goodeegchannel);
%     slashes = strfind(basepath,'/');
%     ratname = basepath(slashes(3)+1:slashes(4)-1);

    load(fullfile(basepath,[basename '_CellIDs.mat']))
    
    numcells = length(unique([CellIDs.EAll(:);CellIDs.IAll(:)]));
    
    cim = zeros(numcells,6);
    cim(CellIDs.EAll,1) = 1;
    cim(CellIDs.IAll,2) = 1;
    cim(CellIDs.EDefinite,3) = 1;
    cim(CellIDs.IDefinite,4) = 1;
    cim(CellIDs.ELike,5) = 1;
    cim(CellIDs.ILike,6) = 1;

    CellIDMatrix = cat(1,CellIDMatrix,cim);
end


%% save data
% MakeDirSaveVarThere('/mnt/brendon4/DrOverallStats',DefaultDatasetBasicStats)
