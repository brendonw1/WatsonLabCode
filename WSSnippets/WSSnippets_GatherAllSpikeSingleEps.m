function [SpikeWSSnippets] = WSSnippets_GatherAllSpikeSingleEps(ep1,ep2)
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
SpikeWSSnippets.Episode1 = ep1;
SpikeWSSnippets.Episode2 = ep2;
SpikeWSSnippets.SessionNames = {};
SpikeWSSnippets.RatNames = {};
SpikeWSSnippets.Anatomies = {};
SpikeWSSnippets.NumRats = 0;
SpikeWSSnippets.NumSessions = 0;
SpikeWSSnippets.NumSleeps = 0;
SpikeWSSnippets.NumSleepsPerSession = [];

SpikeWSSnippets.NumECells = [];
SpikeWSSnippets.NumICells = [];

SpikeWSSnippets.RatePreSpikesE = [];
SpikeWSSnippets.RatePostSpikesE = [];
SpikeWSSnippets.RatePreSpikesI = [];
SpikeWSSnippets.RatePostSpikesI = [];

% loop throug each dataset... then loop thru and store each 
counter = 0;%for accumulating stats, since I can't get states out before hand
for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};

    cd (basepath)
    spkfname = fullfile(basepath,'WSSnippets',ep1,[basename '_SpikeRateWSSnippets.mat']);
    if exist(spkfname,'file')
        
        SpikeWSSnippets.NumSessions = SpikeWSSnippets.NumSessions + 1;
        
       %% Get basic info
        bmd = load(fullfile(basepath,[basename '_BasicMetaData.mat']));
        anat = GetChannelAnatomy(basename,bmd.goodeegchannel);
        slashes = strfind(basepath,'/');
        ratname = basepath(slashes(3)+1:slashes(4)-1);
        
    %     assignin('base','UPSpindleHalves',UPSpindleHalves)
        SpikeWSSnippets.SessionNames{end+1} = basename;
        SpikeWSSnippets.Anatomies{end+1} = anat;
        SpikeWSSnippets.RatNames{end+1} = ratname;

        %% Load data for this session
        t = load(spkfname);
        spks = t.SpikeRateWSSnippets;

        %% If this is first iteration, declare empty cells so can cat to them
        if a == 1;
            %get spike data
            fnspk = {'ratePreSpikesE','ratePostSpikesE','ratePreSpikesI','ratePostSpikesI',...
                'ESpkr','ESpkp','ESpkcoeffs','ISpkr','ISpkp','ISpkcoeffs'};
            for b = 1:length(fnspk)
                tfield = fnspk{b};
                eval(['SpikeWSSnippets.' tfield ' = [];'])
            end
        end
        
        counter = counter+1;
        numeps = size(spks.preEpoch,2);
        SpikeWSSnippets.NumSleepsPerSession(end+1) = numeps;
        
        for b = 1:numeps%for each sleep episode
            SpikeWSSnippets.RatePreSpikesE = cat(1,SpikeWSSnippets.RatePreSpikesE,spks.ratePreSpikesE(:,b));
            SpikeWSSnippets.RatePostSpikesE = cat(1,SpikeWSSnippets.RatePostSpikesE,spks.ratePostSpikesE(:,b));
            if  spks.anyi
                SpikeWSSnippets.RatePreSpikesI = cat(1,SpikeWSSnippets.RatePreSpikesI,spks.ratePreSpikesI(:,b));
                SpikeWSSnippets.RatePostSpikesI = cat(1,SpikeWSSnippets.RatePostSpikesI,spks.ratePostSpikesI(:,b));
            end

            SpikeWSSnippets.preEpoch{a} = spks.preEpoch;
            SpikeWSSnippets.postEpoch{a} = spks.postEpoch;
            SpikeWSSnippets.preSpikesE{a} = spks.preSpikesE;
            SpikeWSSnippets.postSpikesE{a} = spks.postSpikesE;
            SpikeWSSnippets.preSpikesI{a} = spks.preSpikesI;
            SpikeWSSnippets.postSpikesI{a} = spks.postSpikesI;
            
            for c = 1:length(fnspk)
                tfield = fnspk{c};
                if strcmp(tfield(end-3:end),'effs') || strcmp(tfield(end-3:end),'Spkr') || strcmp(tfield(end-3:end),'Spkp')
                    eval(['SpikeWSSnippets.' tfield ' = cat(1,SpikeWSSnippets.' tfield ',spks. ' tfield '{b});'])
                else
                    if strcmp(tfield(end-6:end),'SpikesI') &&  ~spks.anyi
                        1;
                    else
                        eval(['SpikeWSSnippets.' tfield ' = cat(1,SpikeWSSnippets.' tfield ',spks. ' tfield '(:,b));'])
                    end
                end
            end
            1;    
        end
        SpikeWSSnippets.NumECells(end+1) = size(spks.ratePreSpikesE,1);
        if spks.anyi
            SpikeWSSnippets.NumICells(end+1) = size(spks.ratePreSpikesI,1);
        else
            SpikeWSSnippets.NumICells(end+1) = 0;
        end
    else
        1;
    end
end

SpikeWSSnippets.NumRats = length(unique(SpikeWSSnippets.RatNames));

