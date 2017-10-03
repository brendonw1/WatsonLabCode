function UPstates_DetectDatasetUPstates(basepath,basename)

if ~exist('basepath','var')
    basepath = cd;
    [~,basename,~] = fileparts(cd);
end
cd (basepath)

% if ~exist([basename '_UPDOWNIntervals.mat'],'file')
    %% Review/Create Header

    bmd = load([basename '_BasicMetaData.mat']);
    numchans = bmd.Par.nChannels;
    UPchannel = bmd.UPstatechannel;
    Par = bmd.Par;

    t = load([basename '_SStable.mat']);
    S = t.S;
    shank = t.shank;

    load(fullfile(basepath,[basename '_GoodSleepInterval.mat']),'GoodSleepInterval');
    load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']),'SWSPacketInts');
    okintervals = intersect(SWSPacketInts,GoodSleepInterval);
    
    UPchannelcoshanks = getShanksFromThisChannelAnatomy(UPchannel,basename);
    UPchannelcoS = S(ismember(shank,UPchannelcoshanks));
    
%     try
        [ONInts, OFFInts] = DetectONAndOFFInSWS(UPchannelcoS,okintervals);
        [UPInts, DNInts, ~, ~, GammaInts] = DetectUPAndDOWNInSWS(UPchannelcoS,okintervals,Par.nChannels,UPchannel,basename);
        WriteEventFileFromIntervalSet (UPInts,[basename,'.UPS.evt'])
        WriteEventFileFromIntervalSet (DNInts,[basename,'.DNS.evt'])
        WriteEventFileFromIntervalSet (ONInts,[basename,'.ONS.evt'])
        WriteEventFileFromIntervalSet (OFFInts,[basename,'.OFS.evt'])
        WriteEventFileFromIntervalSet (GammaInts,[basename,'.GMS.evt'])
        save ([basename '_UPDOWNIntervals.mat'], 'UPInts', 'DNInts','ONInts','OFFInts','GammaInts','UPchannel')
%     catch
%         disp(['Unable to properly detect UP states on ' basename])
%     end
% else
%     disp([basename '_UPDOWNIntervals.mat already exists, not re-detecting'])
% end

