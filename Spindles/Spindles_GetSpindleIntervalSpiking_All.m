function Ripples_GetSpindleIntervalSpiking_All

[names,dirs] = GetDefaultDataset;

for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};
    Spindles_GetSpindleIntervalSpiking(basepath,basename)
%     temp(basepath,basename)
end



% function temp(basepath,basename)
% %% Redo cell subsets
% cd (basepath)
% t = load([basename '_CellIDs.mat']);
% CellIDs = t.CellIDs;
% 
% filename = fullfile('Spindles',[basename '_SpindleSpikeStats.mat']);
% load(filename);
% isse = SpikeStatsCellSubset(iss,CellIDs.EAll);
% issi = SpikeStatsCellSubset(iss,CellIDs.IAll);
% issed = SpikeStatsCellSubset(iss,CellIDs.EDefinite);
% issid = SpikeStatsCellSubset(iss,CellIDs.IDefinite);
% if ~exist('Spindles','dir')
%     mkdir('Spindles')
% end
% save(filename,'iss','isse','issi','issed','issid');
