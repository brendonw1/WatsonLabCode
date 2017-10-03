function UPSpindlTemplateData = UPstates_GatherUPSpindleTemplateData

wsw = 0;
synapses = 0;
spindles = 1;
[names,dirs] = SleepAnalysis_GetDatasetNameDirsFromSleepSessionMatrix(wsw,synapses,spindles);

%% Declare empty fields
% names, anatomy
UPSpindlTemplateData.SessionNames = {};
UPSpindlTemplateData.RatNames = {};
UPSpindlTemplateData.Anatomies = {};
UPSpindlTemplateData.NumRats = 0;
UPSpindlTemplateData.NumSessions = 0;
UPSpindlTemplateData.NumCells = [];
UPSpindlTemplateData.NumSleeps = [];
UPSpindlTemplateData.NumUPs = [];
UPSpindlTemplateData.NumSpindles = [];
UPSpindlTemplateData.NumNonSpindleUPs = [];
UPSpindlTemplateData.NumSpindleUPs = [];
UPSpindlTemplateData.NumPartSpindleUPs = [];
UPSpindlTemplateData.NumEarlySpindleUPs = [];
UPSpindlTemplateData.NumLateSpindleUPs = [];
% 
% fn = fieldnames(UPSpindlTemplateData);
% fn = fn(6:end);
% nf = length(fn);

% loop throug each dataset... then loop thru and store each 
for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};

    cd (basepath)
    if exist(fullfile('UPstates',[basename 'SpindleUPTemplateRsAndPs .mat']),'file') && exist(fullfile('UPstates',[basename '_SpindleUPRatesDurations.mat']))
        %% Get basic info
        bmd = load([basename '_BasicMetaData.mat']);
        anat = GetChannelAnatomy(basename,bmd.goodeegchannel);
        slashes = strfind(basepath,'/');
        ratname = basepath(slashes(3)+1:slashes(4)-1);
        
    %     assignin('base','UPSpindleHalves',UPSpindleHalves)
        UPSpindlTemplateData.SessionNames{end+1} = basename;
        UPSpindlTemplateData.Anatomies{end+1} = anat;
        UPSpindlTemplateData.RatNames{end+1} = ratname;
        UPSpindlTemplateData.NumSessions = UPSpindlTemplateData.NumSessions + 1;
        UPSpindlTemplateData.NumSleeps = UPSpindlTemplateData.NumSleeps;

        %% Load data for this session
        t = load(fullfile('UPstates',[basename 'SpindleUPTemplateRsAndPs.mat']));

        %% If this is first iteration, declare empty cells so can cat to them
        if a == 1;
            fn = fieldnames(t.SpindleUPTemplateRsAndPs);
            for b = 1:length(fn)
                eval(['UPSpindlTemplateData.' fn{b} ' = [];'])
            end
        end
        
        %% Add some basic counts
        UPSpindlTemplateData.NumUPs(end+1) = size(t.SpindleUPTemplateRsAndPs.mpc_uVu_r,1);
        UPSpindlTemplateData.NumSpindles(end+1) = size(t.SpindleUPTemplateRsAndPs.mpc_sVu_r,1);
        UPSpindlTemplateData.NumNonSpindleUPs(end+1) = size(t.SpindleUPTemplateRsAndPs.mpc_nsuVu_r,1);
        UPSpindlTemplateData.NumSpindleUPs(end+1) = size(t.SpindleUPTemplateRsAndPs.mpc_suVu_r,1);
        UPSpindlTemplateData.NumPartSpindleUPs(end+1) = size(t.SpindleUPTemplateRsAndPs.mpc_psuVu_r,1);
        UPSpindlTemplateData.NumEarlySpindleUPs(end+1) = size(t.SpindleUPTemplateRsAndPs.mpc_esuVu_r,1);
        UPSpindlTemplateData.NumLateSpindleUPs(end+1) = size(t.SpindleUPTemplateRsAndPs.mpc_lsuVu_r,1);
        
        %% Get means (per session across sleep episodes) of event/template correlations (and template-template correlations)
        for b = 1:length(fn)
            tfn = fn{b};
            eval(['UPSpindlTemplateData.' tfn '(end+1) = nanmean(t.SpindleUPTemplateRsAndPs.' tfn ');'])
        end

    end
end

UPSpindlTemplateData.NumRats = length(unique(UPSpindlTemplateData.RatNames));

savestr = ['UPSpindlTemplateData',date];

if ~exist('/mnt/brendon4/Dropbox/Data/SpindleUPDatasetData/TemplateCorr','dir')
    mkdir('/mnt/brendon4/Dropbox/Data/SpindleUPDatasetData/TemplateCorr')
end
save(fullfile('/mnt/brendon4/Dropbox/Data/SpindleUPDatasetData/TemplateCorr', savestr),'UPSpindlTemplateData')
