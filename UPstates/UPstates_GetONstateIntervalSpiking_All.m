function UPstates_GetONstateIntervalSpiking_All

[names,dirs] = GetDefaultDataset;

for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};
%     if ~exist(fullfile(basepath,'UPstates',[basename '_UPSpikeStatsE.mat']),'file')
        UPstates_GetONstateIntervalSpiking(basepath,basename)
%         temp(basepath,basename);
%     end
end



% function temp(basepath,basename)
% %% Redo cell subsets
% cd (basepath)
% 
% if exist([basename, '_UPDOWNIntervals.mat'],'file')
%     filename = fullfile('UPstates',[basename '_UPSpikeStatsAll.mat']);
%     load(filename)
%     t = load([basename '_CellIDs.mat']);
% 
%     isse = SpikeStatsCellSubset(iss,t.CellIDs.EAll);
%     filename = fullfile('UPstates',[basename '_UPSpikeStatsE.mat']);
%     save(filename,'isse','-v7.3');
% 
%     issi = SpikeStatsCellSubset(iss,t.CellIDs.IAll);
%     filename = fullfile('UPstates',[basename '_UPSpikeStatsI.mat']);
%     save(filename,'issi','-v7.3');
% 
% end
