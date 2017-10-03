function UPstates_GetONstateIntervalSpiking(basepath,basename)
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
    ONInts = t.ONInts;

    %% Extract basic UP info
%     UPstarts = Start(ONInts);
%     UPstops = End(ONInts);

    %% load S (spikes)
    t = load([basename '_SStable.mat']);
    S = t.S;

    t = load([basename '_CellIDs.mat']);
    CellIDs = t.CellIDs;

    %%
    filename = fullfile('UPstates',[basename '_ONSpikingPeaks.mat']);
%     if exist(filename,'file')
%         t = load(filename);
%         ONSpkMeansFromFileStart = t.ONSpkMeansFromFileStart;
%     else
        [ONSpkMeansFromONStart,ONSpkMeansFromFileStart] = DetectIntervalPopSpikePeaks(ONInts,S,1);%times relative to start of up
        if ~exist(fullfile(basepath,'UPstates'),'dir')
            mkdir(fullfile(basepath,'UPstates'))
        end
        save(fullfile('UPstates',[basename '_ONSpikingPeaks']),'ONSpkMeansFromONStart','ONSpkMeansFromFileStart');
%     end

%% Extract spike features of each event
    if ~exist('ONstates','dir')
        mkdir('ONstates')
    end
    filename = fullfile('UPstates',[basename '_ONSpikeStatsAll.mat']);
    [iss,s] = SpikeStatsInIntervals(S,ONInts,ONSpkMeansFromFileStart);
    save(fullfile('UPstates',[basename '_ONIntervalRawSpikesA.mat']),'s','-v7.3');
    save(filename,'iss');

    t = load([basename '_CellIDs.mat']);
    isse = SpikeStatsCellSubset(iss,t.CellIDs.EAll);
    filename = fullfile('UPstates',[basename '_ONSpikeStatsE.mat']);
    save(filename,'isse','-v7.3');

    issi = SpikeStatsCellSubset(iss,t.CellIDs.IAll);
    filename = fullfile('UPstates',[basename '_ONSpikeStatsI.mat']);
    save(filename,'issi','-v7.3');

end
