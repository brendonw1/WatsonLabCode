function [SpikeWSSnippets] = WSSnippets_GatherAllSpikeMedians(ep1,ep2)
% Available inputs to specify times around WS:
%         - '5mIn' - gather first 5min IN sleep vs last 5 IN sleep
%         - '5mOut' - gather last 5min wake BEFORE sleep vs first 5 min wake AFTER sleep
%         - 'FLSWS' - gather first vs last SWS episodes
%         - '13SWS' - gather SWS from vs vs last third of sleep
%         - 'WakeBA' - Look at wake before vs wake after
%         - '5mInSWS' - gather first 5min SWS min vs last 5 SWS min
%
% Brendon Watson 2015


if ~exist('ep1','var')
    ep1 = '5mInSWS';
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

% loop throug each dataset... then loop thru and store each 
counter = 0;%for accumulating stats, since I can't get states out before hand
for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};

    cd (basepath)
    spkfname = fullfile(basepath,'WSSnippets',ep1,[basename '_SpikeRateWSSnippets.mat']);
    
%     if exist(spkfname,'file') && exist(synfname,'file') && exist(assfname,'file')
    if exist(spkfname,'file')
        
        SpikeWSSnippets.NumSessions = SpikeWSSnippets.NumSessions + 1;

       %% Get basic info
        bmd = load(fullfile(basepath,[basename '_BasicMetaData.mat']));
        anat = GetChannelAnatomy(basename,bmd.goodeegchannel);
        slashes = strfind(basepath,'/');
        ratname = basepath(slashes(3)+1:slashes(4)-1);
        
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
        SpikeWSSnippets.NumSleepsPerSession(end+1) = 0;

        for b = 1:length(spks.ESpkr)%for each sleep episode
            for c = 1:length(fnspk)
                tfield = fnspk{c};
                if strcmp(tfield(end-3:end),'effs') | strcmp(tfield(end-3:end),'Spkr') | strcmp(tfield(end-3:end),'Spkp')
                    eval(['SpikeWSSnippets.' tfield ' = cat(1,SpikeWSSnippets.' tfield ',spks. ' tfield '{b});'])
                else
                    eval(['SpikeWSSnippets.' tfield ' = cat(1,SpikeWSSnippets.' tfield ',spks. ' tfield '(:,b));'])
                end
            end
        end
    end
end

SpikeWSSnippets.NumRats = length(unique(SpikeWSSnippets.RatNames));
% 
% savestr = ['UPSpindlTemplateData',date];
% 
% if ~exist('/mnt/brendon4/Dropbox/Data/SpindleUPDatasetData/TemplateCorr','dir')
%     mkdir('/mnt/brendon4/Dropbox/Data/SpindleUPDatasetData/TemplateCorr')
% end
% save(fullfile('/mnt/brendon4/Dropbox/Data/SpindleUPDatasetData/TemplateCorr', savestr),'UPSpindlTemplateData')
