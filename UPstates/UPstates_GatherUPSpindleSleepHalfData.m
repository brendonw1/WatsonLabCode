function UPSpindleSleepHalfData = UPstates_GatherUPSpindleSleepHalfData

wsw = 0;
synapses = 0;
spindles = 1;
[names,dirs] = SleepAnalysis_GetDatasetNameDirsFromSleepSessionMatrix(wsw,synapses,spindles);

%% Declare empty fields
% names, anatomy
UPSpindleSleepHalfData.SessionNames = {};
UPSpindleSleepHalfData.RatNames = {};
UPSpindleSleepHalfData.Anatomies = {};
UPSpindleSleepHalfData.NumRats = 0;
UPSpindleSleepHalfData.NumSessions = 0;
UPSpindleSleepHalfData.NumCells = [];
UPSpindleSleepHalfData.NumSleeps = [];
UPSpindleSleepHalfData.NumUPs = [];
UPSpindleSleepHalfData.NumSpindles = [];
UPSpindleSleepHalfData.NumNonSpindleUPs = [];
UPSpindleSleepHalfData.NumSpindleUPs = [];
UPSpindleSleepHalfData.NumPartSpindleUPs = [];
UPSpindleSleepHalfData.NumEarlySpindleUPs = [];
UPSpindleSleepHalfData.NumLateSpindleUPs = [];

fn = fieldnames(UPSpindleSleepHalfData);
fn = fn(6:end);
nf = length(fn);

% loop throug each dataset... then loop thru and store each 
for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};

    cd (basepath)
    if exist(fullfile('UPstates',[basename '_SpindleUPSleepHalfRsAndPs.mat']),'file') && exist(fullfile('UPstates',[basename '_SpindleUPRatesDurations.mat']))
        %% Get basic info
        bmd = load([basename '_BasicMetaData.mat']);
        anat = GetChannelAnatomy(basename,bmd.goodeegchannel);
        slashes = strfind(basepath,'/');
        ratname = basepath(slashes(3)+1:slashes(4)-1);
        
    %     assignin('base','UPSpindleHalves',UPSpindleHalves)
        UPSpindleSleepHalfData.SessionNames{end+1} = basename;
        UPSpindleSleepHalfData.Anatomies{end+1} = anat;
        UPSpindleSleepHalfData.RatNames{end+1} = ratname;
        UPSpindleSleepHalfData.NumSessions = UPSpindleSleepHalfData.NumSessions + 1;
        UPSpindleSleepHalfData.NumSleeps = UPSpindleSleepHalfData.NumSleeps;

        %% Load data for this session
        t = load(fullfile('UPstates',[basename '_SpindleUPRatesDurations.mat']));
        u = load(fullfile('UPstates',[basename 'SpindleUPSleepHalfRsAndPs.mat']));

        %% If this is first iteration, declare empty cells so can cat to them
        if a == 1;
            fn_rd = fieldnames(t.SpindleUPRatesDurations);
            fn_rp = fieldnames(u.SpindleUPHalfRsAndPs);
            for b = 1:length(fn_rd)
                eval(['SpindleUPSleepHalfData.' fn_rd{b} ' = [];'])
            end
            for b = 1:length(fn_rp)
                eval(['UPSpindleSleepHalfData.' fn_rp{b} ' = [];'])
            end
        end
        
        %% Add some basic counts
        UPSpindleSleepHalfData.NumSleeps(end+1) = length(u.SpindleUPSleepHalfRsAndPs.r_ue_rate);
        UPSpindleSleepHalfData.NumUPs(end+1) = size(t.SpindleUPRatesDurations.AllUPMeanDur,1);
        UPSpindleSleepHalfData.NumSpindles(end+1) = size(t.SpindleUPRatesDurations.SpindleMeanDur,1);
        UPSpindleSleepHalfData.NumNonSpindleUPs(end+1) = size(t.SpindleUPRatesDurations.NonSpindleUPMeanDur,1);
        UPSpindleSleepHalfData.NumSpindleUPs(end+1) = size(t.SpindleUPRatesDurations.SpindleUPMeanDur,1);
        UPSpindleSleepHalfData.NumPartSpindleUPs(end+1) = size(t.SpindleUPRatesDurations.PartSpindleUPMeanDur,1);
        UPSpindleSleepHalfData.NumEarlySpindleUPs(end+1) = size(t.SpindleUPRatesDurations.EarlySpindleUPMeanDur,1);
        UPSpindleSleepHalfData.NumLateSpindleUPs(end+1) = size(t.SpindleUPRatesDurations.LateSpindleUPMeanDur,1);
        
        %% Get means (per session across sleep episodes) of event basic metrics (rate, duration, etc)
        for b = 1:length(fn_rd)
            tfn = fn_rd{b};
            eval(['UPSpindleSleepHalfData.' tfn '(end+1) = nanmean(t.SpindleUPRatesDurations.' tfn ');'])
        end
                
        %% Get means (per session across sleep episodes) of event Rs and Ps in 1st vs 2nd half sleep
        for b = 1:length(fn_rp)
            tfn = fn_rp{b};
            eval(['UPSpindleSleepHalfData.' tfn '(end+1) = nanmean(u.SpindleUPSleepHalfRsAndPs.' tfn ');'])
        end

    end
end

UPSpindleSleepHalfData.NumRats = length(unique(UPSpindleSleepHalfData.RatNames));

savestr = ['UPSpindleSleepHalfData_',date];

save(fullfile('/mnt/brendon4/Dropbox/Data/SpindleUPDatasetData/SleepHalf', savestr),'UPSpindleSleepHalfData')
