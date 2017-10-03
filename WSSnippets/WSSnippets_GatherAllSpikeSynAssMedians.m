function [SpikeSynAssWSSnippets] = WSSnippets_GatherAllSpikeSynAssMedians(ep1,ep2)
% Available inputs to specify times around WS:
%         - '5mIn' - gather first 5min IN sleep vs last 5 IN sleep
%         - '5mOut' - gather last 5min wake BEFORE sleep vs first 5 min wake AFTER sleep
%         - 'FLSWS' - gather first vs last SWS episodes
%         - '13SWS' - gather SWS from vs vs last third of sleep
%         - 'WakeBA' - Look at wake before vs wake after
%
% Brendon Watson 2015


if ~exist('ep1','var')
    ep1 = '13sws';
end
if ~exist('ep2','var')
    ep2 = '[]';
end


ws = 1;
synapses = 0;
spindles = 1;
[names,dirs] = SleepAnalysis_GetDatasetNameDirsFromSleepSessionMatrix(ws,synapses,spindles);

%% Declare empty fields
% names, anatomy
SpikeSynAssWSSnippets.SessionNames = {};
SpikeSynAssWSSnippets.RatNames = {};
SpikeSynAssWSSnippets.Anatomies = {};
SpikeSynAssWSSnippets.NumRats = 0;
SpikeSynAssWSSnippets.NumSessions = 0;
SpikeSynAssWSSnippets.NumSleeps = 0;
SpikeSynAssWSSnippets.NumSleepsPerSession = [];
% SpikeSynAssWSSnippets.NumSessionsPerRat = [];

SpikeSynAssWSSnippets.NumECells = [];
SpikeSynAssWSSnippets.NumICells = [];
SpikeSynAssWSSnippets.NumUniqueECells = [];
SpikeSynAssWSSnippets.NumUniqueICells = [];
SpikeSynAssWSSnippets.NumECnxns = [];
SpikeSynAssWSSnippets.NumICnxns = [];
SpikeSynAssWSSnippets.NumUniqueECnxns = [];
SpikeSynAssWSSnippets.NumUniqueICnxns = [];
% SpikeSynAss.NumEECnxns = [];
% SpikeSynAss.NumEICnxns = [];
% SpikeSynAss.NumIECnxns = [];
% SpikeSynAss.NumIICnxns = [];
SpikeSynAssWSSnippets.NumWakeBIAssemblies = [];
SpikeSynAssWSSnippets.NumUniqueWakeBIAssemblies = [];

% 
% fn = fieldnames(UPSpindlTemplateData);
% fn = fn(6:end);
% nf = length(fn);

% loop throug each dataset... then loop thru and store each 
counter = 0;%for accumulating stats, since I can't get states out before hand
for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};

    cd (basepath)
    spkfname = fullfile(basepath,'WSSnippets',ep1,[basename '_SpikeRateWSSnippets.mat']);
    synfname = fullfile(basepath,'WSSnippets',ep1,[basename '_SynCorrWSSnippets.mat']);
    assfname = fullfile(basepath,'WSSnippets',ep1,[basename '_WakeBIAssWSSnippets.mat']);
    
    if exist(spkfname,'file') && exist(synfname,'file') && exist(assfname,'file')

        SpikeSynAssWSSnippets.NumSessions = SpikeSynAssWSSnippets.NumSessions + 1;

       %% Get basic info
        bmd = load(fullfile(basepath,[basename '_BasicMetaData.mat']));
        anat = GetChannelAnatomy(basename,bmd.goodeegchannel);
        slashes = strfind(basepath,'/');
        ratname = basepath(slashes(3)+1:slashes(4)-1);
        
    %     assignin('base','UPSpindleHalves',UPSpindleHalves)
        SpikeSynAssWSSnippets.SessionNames{end+1} = basename;
        SpikeSynAssWSSnippets.Anatomies{end+1} = anat;
        SpikeSynAssWSSnippets.RatNames{end+1} = ratname;

        %% Load data for this session
        t = load(spkfname);
        spks = t.SpikeRateWSSnippets;
        t = load(synfname);
        syns = t.SynCorrWSSnippets;
        t = load(assfname);
        asss = t.WakeBIAssWSSnippets;

        %% If this is first iteration, declare empty cells so can cat to them
        if a == 1;
            %get spike data
            fnspk = {'ratePreSpikesE','ratePostSpikesE','ratePreSpikesI','ratePostSpikesI',...
                'ESpkr','ESpkp','ESpkcoeffs','ISpkr','ISpkp','ISpkcoeffs'};
            for b = 1:length(fnspk)
                tfield = fnspk{b};
                eval(['SpikeSynAssWSSnippets.' tfield ' = [];'])
            end
            
            %get syn corr data
            fnsyn = {'medianPreSynapseRatiosE','medianPostSynapseRatiosE','medianPreSynapseDiffsE','medianPostSynapseDiffsE',...
                    'medianPreSynapseRatiosI','medianPostSynapseRatiosI','medianPreSynapseDiffsI','medianPostSynapseDiffsI',...
                    'EsynRatior','EsynRatiop','EsynRatiocoeffs','EsynDiffr','EsynDiffp','EsynDiffcoeffs',...
                    'IsynRatior','IsynRatiop','IsynRatiocoeffs','IsynDiffr','IsynDiffp','IsynDiffcoeffs'};
            for b = 1:length(fnsyn)
                tfield = fnsyn{b};
                eval(['SpikeSynAssWSSnippets.' tfield ' = [];'])
            end
            
            % get wake-based assembly data
            fnass = {'medianPreWakeBIAss','medianPostWakeBIAss',...
                'WakeBIAssr','WakeBIAssp','WakeBIAsscoeffs'};
            for b = 1:length(fnass)
                tfield = fnass{b};
                eval(['SpikeSynAssWSSnippets.' tfield ' = [];'])
            end
        end
        
        counter = counter+1;
        SpikeSynAssWSSnippets.NumSleepsPerSession(end+1) = 0;

        for b = 1:length(spks.ESpkr)%for each sleep episode
            if b == 2;
                1;
            end
            for c = 1:length(fnspk)
                tfield = fnspk{c};
                if strcmp(tfield(end-3:end),'effs') | strcmp(tfield(end-3:end),'Spkr') | strcmp(tfield(end-3:end),'Spkp')
                    eval(['SpikeSynAssWSSnippets.' tfield ' = cat(1,SpikeSynAssWSSnippets.' tfield ',spks. ' tfield '{b});'])
                else
                    eval(['SpikeSynAssWSSnippets.' tfield ' = cat(1,SpikeSynAssWSSnippets.' tfield ',spks. ' tfield '(:,b));'])
                end
            end
            for c = 1:length(fnsyn)
                tfield = fnsyn{c};
                if strcmp(tfield(end-4:end),'oeffs') | strcmp(tfield(end-4:end),'atior') | strcmp(tfield(end-4:end),'atiop') | strcmp(tfield(end-4:end),'Diffr') | strcmp(tfield(end-4:end),'Diffp')
                    if strcmp(tfield,'IsynDiffcoeffs')
                        1;
                    end
                    eval(['SpikeSynAssWSSnippets.' tfield ' = cat(1,SpikeSynAssWSSnippets.' tfield ',syns. ' tfield '{b});'])
                else
                    eval(['SpikeSynAssWSSnippets.' tfield ' = cat(1,SpikeSynAssWSSnippets.' tfield ',syns. ' tfield '(:,b));'])
                end
            end
            for c = 1:length(fnass)
                tfield = fnass{c};
                if strcmp(tfield(end-4:end),'oeffs') | strcmp(tfield(end-4:end),'BAssr') | strcmp(tfield(end-4:end),'BAssp')
                    eval(['SpikeSynAssWSSnippets.' tfield ' = cat(1,SpikeSynAssWSSnippets.' tfield ',asss. ' tfield '{b});'])
                else
                    eval(['SpikeSynAssWSSnippets.' tfield ' = cat(1,SpikeSynAssWSSnippets.' tfield ',asss. ' tfield '(:,b));'])
                end
            end
            
%             if a == 15
%                 1;
%             end
            
%% Counting total cells, synapses, assemblies samplings over all sleeps
            SpikeSynAssWSSnippets.NumSleeps = SpikeSynAssWSSnippets.NumSleeps + 1;
            SpikeSynAssWSSnippets.NumECells(end+1) = size(spks.ratePreSpikesE,1);
            
            if all(isempty(spks.ISpkr))
                SpikeSynAssWSSnippets.NumICells(end+1) = 0;
            else
                SpikeSynAssWSSnippets.NumICells(end+1) = size(spks.ratePreSpikesI,1);
            end
            
            if all(isnan(syns.medianPreSynapseRatiosE))
                SpikeSynAssWSSnippets.NumECnxns(end+1) = 0;
            else
                SpikeSynAssWSSnippets.NumECnxns(end+1) = size(syns.medianPreSynapseRatiosE,1);
            end
            
            if all(isnan(syns.medianPreSynapseRatiosI))
                SpikeSynAssWSSnippets.NumICnxns(end+1) = 0;
            else
                SpikeSynAssWSSnippets.NumICnxns(end+1) = size(syns.medianPreSynapseRatiosI,1);
            end
            
            if all(isempty(asss.WakeBIAssr))
                SpikeSynAssWSSnippets.NumWakeBIAssemblies(end+1) = 0;
            else
                SpikeSynAssWSSnippets.NumWakeBIAssemblies(end+1) = size(asss.medianPreWakeBIAss,1);
            end
            
            SpikeSynAssWSSnippets.NumSleepsPerSession(end) = SpikeSynAssWSSnippets.NumSleepsPerSession(end) + 1;
        end
%% Counting unique cells, synapses, assemblies
        SpikeSynAssWSSnippets.NumUniqueECells(end+1) = size(spks.ratePreSpikesE,1);
        if all(isempty(spks.ISpkr))
            SpikeSynAssWSSnippets.NumUniqueICells(end+1) = 0;
        else
            SpikeSynAssWSSnippets.NumUniqueICells(end+1) = size(spks.ratePreSpikesI,1);
        end
        
        if all(isnan(syns.medianPreSynapseRatiosE))
            SpikeSynAssWSSnippets.NumUniqueECnxns(end+1) = 0;
        else
            SpikeSynAssWSSnippets.NumUniqueECnxns(end+1) = size(syns.medianPreSynapseRatiosE,1);
        end

        if all(isnan(syns.medianPreSynapseRatiosI))
            SpikeSynAssWSSnippets.NumUniqueICnxns(end+1) = 0;
        else
            SpikeSynAssWSSnippets.NumUniqueICnxns(end+1) = size(syns.medianPreSynapseRatiosI,1);
        end

        if all(isempty(asss.WakeBIAssr))
            SpikeSynAssWSSnippets.NumUniqueWakeBIAssemblies(end+1) = 0;
        else
            SpikeSynAssWSSnippets.NumUniqueWakeBIAssemblies(end+1) = size(asss.medianPreWakeBIAss,1);
        end
    
        
    end
end

SpikeSynAssWSSnippets.NumRats = length(unique(SpikeSynAssWSSnippets.RatNames));
% 
% savestr = ['UPSpindlTemplateData',date];
% 
% if ~exist('/mnt/brendon4/Dropbox/Data/SpindleUPDatasetData/TemplateCorr','dir')
%     mkdir('/mnt/brendon4/Dropbox/Data/SpindleUPDatasetData/TemplateCorr')
% end
% save(fullfile('/mnt/brendon4/Dropbox/Data/SpindleUPDatasetData/TemplateCorr', savestr),'UPSpindlTemplateData')
