function CoeffVarWSSnippets = WSSnippets_GatherPopCoeffVar(ep1,ep2)
% Available inputs to specify times around WS:
%         - '5mIn' - gather first 5min IN sleep vs laedit st 5 IN sleep
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
CoeffVarWSSnippets.SessionNames = {};
CoeffVarWSSnippets.RatNames = {};
CoeffVarWSSnippets.Anatomies = {};
CoeffVarWSSnippets.NumRats = 0;
CoeffVarWSSnippets.NumSessions = 0;
CoeffVarWSSnippets.NumSleeps = 0;
CoeffVarWSSnippets.NumSleepsPerSession = [];

CoeffVarWSSnippets.CoVE_pre =  [];
CoeffVarWSSnippets.CoVlE_pre = [];
CoeffVarWSSnippets.CoVI_pre = [];
CoeffVarWSSnippets.CoVlI_pre = [];
CoeffVarWSSnippets.CoVE_post =  [];
CoeffVarWSSnippets.CoVlE_post = [];
CoeffVarWSSnippets.CoVI_post = [];
CoeffVarWSSnippets.CoVlI_post = [];

CoeffVarWSSnippets.SDE_pre =  [];
CoeffVarWSSnippets.SDlE_pre = [];
CoeffVarWSSnippets.SDI_pre = [];
CoeffVarWSSnippets.SDlI_pre = [];
CoeffVarWSSnippets.SDE_post =  [];
CoeffVarWSSnippets.SDlE_post = [];
CoeffVarWSSnippets.SDI_post = [];
CoeffVarWSSnippets.SDlI_post = [];

% loop throug each dataset... then loop thru and store each 
counter = 0;%for accumulating stats, since I can't get states out before hand
for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};

    cd (basepath)
	ssfname = fullfile(basepath,'WSSnippets',ep1,[basename '_CoeffVarWSSnippets.mat']);
    if exist(ssfname,'file')
        
        CoeffVarWSSnippets.NumSessions = CoeffVarWSSnippets.NumSessions + 1;
        
       %% Get basic info
        bmd = load(fullfile(basepath,[basename '_BasicMetaData.mat']));
        anat = GetChannelAnatomy(basename,bmd.goodeegchannel);
        slashes = strfind(basepath,'/');
        ratname = basepath(slashes(3)+1:slashes(4)-1);
        
    %     assignin('base','UPSpindleHalves',UPSpindleHalves)
        CoeffVarWSSnippets.SessionNames{end+1} = basename;
        CoeffVarWSSnippets.Anatomies{end+1} = anat;
        CoeffVarWSSnippets.RatNames{end+1} = ratname;

        %% Load data for this session
        t = load(ssfname);
        CoeffVars = t.CoeffVarWSSnippets;

        %% If this is first iteration, declare empty cells so can cat to them
        counter = counter+1;
        CoeffVarWSSnippets.NumSleepsPerSession(end+1) = 0;

        if CoeffVars.numWS > 1;
            1;
        end
        
%         for b = 1:CoeffVars.numWS%for each sleep episode
            CoeffVarWSSnippets.CoVE_pre = cat(1,CoeffVarWSSnippets.CoVE_pre,median(CoeffVars.CoVE_pre,2));
            CoeffVarWSSnippets.CoVlE_pre = cat(1,CoeffVarWSSnippets.CoVlE_pre,median(CoeffVars.CoVlE_pre,2));
            CoeffVarWSSnippets.CoVI_pre = cat(1,CoeffVarWSSnippets.CoVI_pre,median(CoeffVars.CoVI_pre,2));
            CoeffVarWSSnippets.CoVlI_pre = cat(1,CoeffVarWSSnippets.CoVlI_pre,median(CoeffVars.CoVlI_pre,2));

            CoeffVarWSSnippets.CoVE_post = cat(1,CoeffVarWSSnippets.CoVE_post,median(CoeffVars.CoVE_post,2));
            CoeffVarWSSnippets.CoVlE_post = cat(1,CoeffVarWSSnippets.CoVlE_post,median(CoeffVars.CoVlE_post,2));
            CoeffVarWSSnippets.CoVI_post = cat(1,CoeffVarWSSnippets.CoVI_post,median(CoeffVars.CoVI_post,2));
            CoeffVarWSSnippets.CoVlI_post = cat(1,CoeffVarWSSnippets.CoVlI_post,median(CoeffVars.CoVlI_post,2));
            
            CoeffVarWSSnippets.SDE_pre = cat(1,CoeffVarWSSnippets.SDE_pre,median(CoeffVars.SDE_pre,2));
            CoeffVarWSSnippets.SDlE_pre = cat(1,CoeffVarWSSnippets.SDlE_pre,median(CoeffVars.SDlE_pre,2));
            CoeffVarWSSnippets.SDI_pre = cat(1,CoeffVarWSSnippets.SDI_pre,median(CoeffVars.SDI_pre,2));
            CoeffVarWSSnippets.SDlI_pre = cat(1,CoeffVarWSSnippets.SDlI_pre,median(CoeffVars.SDlI_pre,2));

            CoeffVarWSSnippets.SDE_post = cat(1,CoeffVarWSSnippets.SDE_post,median(CoeffVars.SDE_post,2));
            CoeffVarWSSnippets.SDlE_post = cat(1,CoeffVarWSSnippets.SDlE_post,median(CoeffVars.SDlE_post,2));
            CoeffVarWSSnippets.SDI_post = cat(1,CoeffVarWSSnippets.SDI_post,median(CoeffVars.SDI_post,2));
            CoeffVarWSSnippets.SDlI_post = cat(1,CoeffVarWSSnippets.SDlI_post,median(CoeffVars.SDlI_post,2));
    else
        1;
    end
end

CoeffVarWSSnippets.NumRats = length(unique(CoeffVarWSSnippets.RatNames));

