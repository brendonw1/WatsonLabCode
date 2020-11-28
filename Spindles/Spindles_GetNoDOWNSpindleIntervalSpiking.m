function Spindles_GetNoDOWNSpindleIntervalSpiking(basepath,basename)
% 
% wsw = 0;
% synapses = 0;
% spindles = 1;
% [names,dirs] = SleepAnalysis_GetDatasetNameDirsFromSleepSessionMatrix(wsw,synapses,spindles);
% 
% for a = 1:length(dirs);
%     disp(['Starting ' names{a}])
%     basename = names{a};
%     basepath = dirs{a};


if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

    %% Review/Create Header
    cd (basepath)

    load(fullfile(basepath,'Spindles','SpindleDataNoDOWN.mat'),'SpindleData')
    normspindles = SpindleData.normspindles;
    %% Extract basic spindle info
    sp_starts = normspindles(:,1);
    sp_peaks = normspindles(:,2);
    sp_stops = normspindles(:,3);
    sp_ints = intervalSet(10000*sp_starts,10000*sp_stops);

    %% load S (spikes)
    t = load([basename '_SStable.mat']);
    S = t.S;

    t = load([basename '_CellIDs.mat']);
    CellIDs = t.CellIDs;

    %% Extract spike features of each spindle
    filename = fullfile(basepath,'Spindles',[basename '_SpindleNoDOWNSpikeStats.mat']);
%     if exist(filename,'file')
%         t = load(filename);
%         iss = t.iss;
%         isse = t.isse;
%         issi = t.issi;
%         issed = t.issed;
%         issid = t.issid;
%     else
        iss = SpikeStatsInIntervals(S,sp_ints,sp_peaks);
        isse = SpikeStatsCellSubset(iss,CellIDs.EAll);
        issi = SpikeStatsCellSubset(iss,CellIDs.IAll);
        issed = SpikeStatsCellSubset(iss,CellIDs.EDefinite);
        issid = SpikeStatsCellSubset(iss,CellIDs.IDefinite);
        if ~exist('Spindles','dir')
            mkdir('Spindles')
        end
        save(filename,'iss','isse','issi','issed','issid');
%     end

% end