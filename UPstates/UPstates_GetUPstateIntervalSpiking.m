function UPstates_GetUPstateIntervalSpiking(basepath,basename)
% 

if ~exist('basepath','var')
    [basepath,basename,~] = fileparts(cd);
    basepath = fullfile(basepath,basename);
end
cd(basepath)


%% Review/Create Header
cd (basepath)

if exist([basename, '_UPDOWNIntervals.mat'],'file')
    t = load([basename, '_UPDOWNIntervals']);
    UPInts = t.UPInts;

    %% Extract basic UP info
    UPstarts = Start(UPInts);
    UPstops = End(UPInts);

    %% load S (spikes)
    t = load([basename '_SStable.mat']);
    S = t.S;

    t = load([basename '_CellIDs.mat']);
    CellIDs = t.CellIDs;

    %%
    filename = fullfile('UPstates',[basename '_UPSpikingPeaks.mat']);
%     if exist(filename,'file')
%         t = load(filename);
%         UPSpkMeansFromFileStart = t.UPSpkMeansFromFileStart;
%     else
        [UPSpkMeansFromUPStart,UPSpkMeansFromFileStart] = DetectIntervalPopSpikePeaks(UPInts,S,1);%times relative to start of up
        if ~exist(fullfile(basepath,'UPstates'),'dir')
            mkdir(fullfile(basepath,'UPstates'))
        end
        save(fullfile('UPstates',[basename '_UPSpikingPeaks']),'UPSpkMeansFromUPStart','UPSpkMeansFromFileStart');
%     end

%% Extract spike features of each event
    if ~exist('UPstates','dir')
        mkdir('UPstates')
    end
    filename = fullfile('UPstates',[basename '_UPSpikeStatsAll.mat']);
    [iss,s] = SpikeStatsInIntervals(S,UPInts,UPSpkMeansFromFileStart);
    save(fullfile('UPstates',[basename '_UPIntervalRawSpikesA.mat']),'s','-v7.3');
    save(filename,'iss');

    t = load([basename '_CellIDs.mat']);
    isse = SpikeStatsCellSubset(iss,t.CellIDs.EAll);
    filename = fullfile('UPstates',[basename '_UPSpikeStatsE.mat']);
    save(filename,'isse','-v7.3');

    issi = SpikeStatsCellSubset(iss,t.CellIDs.IAll);
    filename = fullfile('UPstates',[basename '_UPSpikeStatsI.mat']);
    save(filename,'issi','-v7.3');

end
