function Ripples_GetRippleIntervalSpiking(basepath,basename)
% 
% wsw = 0;
% synapses = 0;
% Ripples = 1;
% [names,dirs] = SleepAnalysis_GetDatasetNameDirsFromSleepSessionMatrix(wsw,synapses,Ripples);
% 
% for a = 1:length(dirs);
%     disp(['Starting ' names{a}])
%     basename = names{a};
%     basepath = dirs{a};

    %% Review/Create Header
    cd (basepath)

    load(fullfile(basepath,'Ripples','RippleData.mat'),'RippleData')
    ripples = RippleData.ripples;
    %% Extract basic Ripple info
    sp_starts = ripples(:,1);
    sp_peaks = ripples(:,2);
    sp_stops = ripples(:,3);
    sp_ints = intervalSet(10000*sp_starts,10000*sp_stops);

    %% load S (spikes)
    t = load([basename '_SStable.mat']);
    S = t.S;

    t = load([basename '_CellIDs.mat']);
    CellIDs = t.CellIDs;

    %% Extract spike features of each Ripple
    filename = fullfile(basepath,'Ripples',[basename '_RippleSpikeStats.mat']);
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
%         issed = SpikeStatsCellSubset(iss,CellIDs.EDefinite);
%         issid = SpikeStatsCellSubset(iss,CellIDs.IDefinite);
        if ~exist('Ripples','dir')
            mkdir('Ripples')
        end
%         save(filename,'iss','isse','issi','issed','issid');
        save(filename,'iss','isse','issi');
%     end

% end