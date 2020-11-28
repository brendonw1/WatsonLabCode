function UPstates_DetectDatasetUPstates(basepath,UPChannel)

%% Default inputs
if ~exist('basepath','var')
    basepath = cd;
    basename = bz_BasenameFromBasepath(basepath);
end

%% Metadata
sessionInfo = bz_getSessionInfo(basepath);
% numchans = sessionInfo.nChannels;


% %% Choose channel to use for LFP aspect of UP state detection.
% UPChannel = 1; % default
% siname = fullfile(basepath,[basename '.sessionInfo.mat']);
% if isfield(sessionInfo,'LfpAnalysisChannels')
%     if isfield(sessionInfo.LfpAnalysisChannels,'UPChannel');
%         UPChannel = sessionInfo.LfpAnalysisChannels.UPChannel;
%     end
% end

%% Start processing
%     bmd = load([basename '_BasicMetaData.mat']);
%     numchans = bmd.Par.nChannels;
%     UPchannel = bmd.UPstatechannel;
%     Par = bmd.Par;

%get spikes
% t = load([basename '_SStable.mat']);
% S = t.S;
% shank = t.shank;
% spikes = bz_GetSpikes('basepath',basepath);
% shank = spikes.shankID;

% %% Figure out channels in same region or shank as UPchannel.  Use Region if possible
% regionsworked_boolean = 0;
% if isfield(sessionInfo,'region')
% %     try
%         unitidxs = FindUnitsInThisRegion(UPChannel,spikes,sessionInfo);
%         regionsworked_boolean = 1;
% %     end
% end
% if regionsworked_boolean == 0
%     disp('Using spikes from local shank rather than local region because no region info found in sessionInfo.  Add region info to sessionInfo to improve detection.')
%     unitidxs = FindUnitsOnThiShank(UPChannel,spikes,sessionInfo);%function below
% end
% 
% SpikesToUse = [];
% for a = 1:length(unitidxs)
%     SpikesToUse = cat(1,SpikesToUse,spikes.times{unitidxs(a)});
% end
% SpikesToUse = sort(SpikesToUse);
% NumCellsInShank = length(unitidxs);

% %get states
% % load(fullfile(basepath,[basename '_GoodSleepInterval.mat']),'GoodSleepInterval');
% % load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']),'SWSPacketInts');
% % okintervals = intersect(SWSPacketInts,GoodSleepInterval);
% SleepState = bz_LoadStates(basepath,'SleepState');
% okintervals = SleepState.ints.NREMstate;

%     try
%     ONOFFIntervals = getONAndOFFInNREM(basepath);
    UPDOWNIntervals = getUPDOWNStates('basepath',basepath);
    
    WriteEventFileFromTwoColumnEvents (UPDOWNIntervals.UPInts*1000,[basename,'.UPS.evt'])
    WriteEventFileFromTwoColumnEvents (UPDOWNIntervals.DNInts*1000,[basename,'.DNS.evt'])
    WriteEventFileFromTwoColumnEvents (ONOFFIntervals.ONInts*1000,[basename,'.ONS.evt'])
    WriteEventFileFromTwoColumnEvents (ONOFFIntervals.OFFInts*1000,[basename,'.OFS.evt'])
    WriteEventFileFromTwoColumnEvents (UPDOWNIntervals.GammaInts*1000,[basename,'.GMS.evt'])
%     catch
%         disp(['Unable to properly detect UP states on ' basename])
%     end
% else
%     disp([basename '_UPDOWNIntervals.mat already exists, not re-detecting'])
% end


%%


