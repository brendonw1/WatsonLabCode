function SynCorrWSSnippets = WSSnippets_GatherAllSynCorrMedians(ep1)
% Available inputs to specify times around WS:
%         - '5mIn' - gather first 5min IN sleep vs last 5 IN sleep
%         - '5mOut' - gather last 5min wake BEFORE sleep vs first 5 min wake AFTER sleep
%         - 'FLSWS' - gather first vs last SWS episodes
%         - '13SWS' - gather SWS from vs vs last third of sleep
%         - 'WakeB' - Look at wake before 
%         - 'WSSleep' - Look at all of sleep in a given WS episode
%         - 'WSSWS' - Look at all SWS in a given WS episode
%         - 'WWSREM' - Look at all REM in a given WS episode
%         - '5mInSWS' - gather first 5min SWS min vs last 5 SWS min
%
% Brendon Watson 2015


if ~exist('ep1','var')
    ep1 = 'FLSWS';
end
if ~exist('ep2','var')
    ep2 = '[]';
end

[names,dirs] = GetDefaultDataset;

%% Declare empty fields
% names, anatomy
% SynStrWSSnippets.Episode1 = ep1;
% SynStrWSSnippets.Episode2 = ep2;
SynCorrWSSnippets.SessionNames = {};
SynCorrWSSnippets.RatNames = {};
SynCorrWSSnippets.Anatomies = {};
SynCorrWSSnippets.NumRats = 0;
SynCorrWSSnippets.NumSessions = 0;
SynCorrWSSnippets.NumSleeps = 0;
SynCorrWSSnippets.NumSleepsPerSession = [];

SynCorrWSSnippets.NumEPairs = [];
SynCorrWSSnippets.NumIPairs = [];

SynCorrWSSnippets.medianPreSynCorrRatioE =  [];
SynCorrWSSnippets.medianPostSynCorrRatioE = [];
SynCorrWSSnippets.medianPreSynCorrRateChgE = [];
SynCorrWSSnippets.medianPostSynCorrRateChgE = [];

SynCorrWSSnippets.medianPreSynCorrRatioI = [];
SynCorrWSSnippets.medianPostSynCorrRatioI = [];
SynCorrWSSnippets.medianPreSynCorrRateChgI = [];
SynCorrWSSnippets.medianPostSynCorrRateChgI = [];
% loop throug each dataset... then loop thru and store each 
counter = 0;%for accumulating stats, since I can't get states out before hand
for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};

    cd (basepath)
	ssfname = fullfile(basepath,'WSSnippets',ep1,[basename '_SynCorrWSSnippets.mat']);
    if exist(ssfname,'file')
        
        SynCorrWSSnippets.NumSessions = SynCorrWSSnippets.NumSessions + 1;
        
       %% Get basic info
        bmd = load(fullfile(basepath,[basename '_BasicMetaData.mat']));
        anat = GetChannelAnatomy(basename,bmd.goodeegchannel);
        slashes = strfind(basepath,'/');
        ratname = basepath(slashes(3)+1:slashes(4)-1);
        
    %     assignin('base','UPSpindleHalves',UPSpindleHalves)
        SynCorrWSSnippets.SessionNames{end+1} = basename;
        SynCorrWSSnippets.Anatomies{end+1} = anat;
        SynCorrWSSnippets.RatNames{end+1} = ratname;

        %% Load data for this session
        t = load(ssfname);
        syncorrs = t.SynCorrWSSnippets;

        %% If this is first iteration, declare empty cells so can cat to them
        counter = counter+1;
        SynCorrWSSnippets.NumSleepsPerSession(end+1) = 0;

        if syncorrs.numWS > 1;
            1;
        end
        
%         for b = 1:syncorrs.numWS%for each sleep episode
            SynCorrWSSnippets.medianPreSynCorrRatioE = cat(1,SynCorrWSSnippets.medianPreSynCorrRatioE,median(syncorrs.medianPreSynapseRatiosE,2));
            SynCorrWSSnippets.medianPostSynCorrRatioE = cat(1,SynCorrWSSnippets.medianPostSynCorrRatioE,median(syncorrs.medianPostSynapseRatiosE,2));
            SynCorrWSSnippets.medianPreSynCorrRateChgE = cat(1,SynCorrWSSnippets.medianPreSynCorrRateChgE,median(syncorrs.medianPreSynapseDiffsE,2));
            SynCorrWSSnippets.medianPostSynCorrRateChgE = cat(1,SynCorrWSSnippets.medianPostSynCorrRateChgE,median(syncorrs.medianPostSynapseDiffsE,2));

            SynCorrWSSnippets.medianPreSynCorrRatioI = cat(1,SynCorrWSSnippets.medianPreSynCorrRatioI,median(syncorrs.medianPreSynapseRatiosI,2));
            SynCorrWSSnippets.medianPostSynCorrRatioI = cat(1,SynCorrWSSnippets.medianPostSynCorrRatioI,median(syncorrs.medianPostSynapseRatiosI,2));
            SynCorrWSSnippets.medianPreSynCorrRateChgI = cat(1,SynCorrWSSnippets.medianPreSynCorrRateChgI,median(syncorrs.medianPreSynapseDiffsI,2));
            SynCorrWSSnippets.medianPostSynCorrRateChgI = cat(1,SynCorrWSSnippets.medianPostSynCorrRateChgI,median(syncorrs.medianPostSynapseDiffsI,2));

%         end
        
        SynCorrWSSnippets.NumEPairs(end+1) = size(syncorrs.EPairs,1);
        SynCorrWSSnippets.NumIPairs(end+1) = size(syncorrs.IPairs,1);
    else
        1;
    end
end

SynCorrWSSnippets.NumRats = length(unique(SynCorrWSSnippets.RatNames));

