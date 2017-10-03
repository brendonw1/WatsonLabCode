
function UPSpindleEvenOddData = UPstates_GatherUPSpindleSleepHalfData

wsw = 0;
synapses = 0;
spindles = 1;
[names,dirs] = SleepAnalysis_GetDatasetNameDirsFromSleepSessionMatrix(wsw,synapses,spindles);

%% Declare empty fields
% names, anatomy
UPSpindleEvenOddData.SessionNames = {};
UPSpindleEvenOddData.RatNames = {};
UPSpindleEvenOddData.Anatomies = {};
UPSpindleEvenOddData.NumRats = 0;
UPSpindleEvenOddData.NumSessions = 0;
UPSpindleEvenOddData.NumCells = [];
UPSpindleEvenOddData.NumSleeps = [];
UPSpindleEvenOddData.NumUPs = [];
UPSpindleEvenOddData.NumSpindles = [];
UPSpindleEvenOddData.NumNonSpindleUPs = [];
UPSpindleEvenOddData.NumSpindleUPs = [];
UPSpindleEvenOddData.NumPartSpindleUPs = [];
UPSpindleEvenOddData.NumEarlySpindleUPs = [];
UPSpindleEvenOddData.NumLateSpindleUPs = [];

fn = fieldnames(UPSpindleEvenOddData);
fn = fn(4:end);
nf = length(fn);

% loop throug each dataset... then loop thru and store each 
for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};

    cd (basepath)
    if exist(fullfile('UPstates',[basename '_SpindleUPEvenOddRsAndPs.mat']),'file') && exist(fullfile('UPstates',[basename '_SpindleUPRatesDurations.mat']))
        %% Get basic info
        bmd = load([basename '_BasicMetaData.mat']);
        anat = GetChannelAnatomy(basename,bmd.goodeegchannel);
        slashes = strfind(basepath,'/');
        ratname = basepath(slashes(3)+1:slashes(4)-1);
        
    %     assignin('base','UPSpindleHalves',UPSpindleHalves)
        UPSpindleEvenOddData.SessionNames{end+1} = basename;
        UPSpindleEvenOddData.Anatomies{end+1} = anat;
        UPSpindleEvenOddData.RatNames{end+1} = ratname;
        UPSpindleEvenOddData.NumSessions = UPSpindleEvenOddData.NumSessions + 1;
        UPSpindleEvenOddData.NumSleeps = UPSpindleEvenOddData.NumSleeps;

        %% Load data for this session
        t = load(fullfile('UPstates',[basename '_SpindleUPRatesDurations.mat']));
        u = load(fullfile('UPstates',[basename '_SpindleUPEvenOddRsAndPs.mat']));

        %% If this is first iteration, declare empty cells so can cat to them
        if a == 1;
            fn_rd = fieldnames(t.SpindleUPRatesDurations);
            fn_rp = fieldnames(u.SpindleUPEvenOddRsAndPs);
            for b = 1:length(fn_rd)
                eval(['UPSpindleEvenOddData.' fn_rd{b} ' = [];'])
            end
            for b = 1:length(fn_rp)
                eval(['UPSpindleEvenOddData.' fn_rp{b} ' = [];'])
            end
        end
        
        %% Add some basic counts
        UPSpindleEvenOddData.NumSleeps(end+1) = length(u.SpindleUPEvenOddRsAndPs.r_ue_rate);
        UPSpindleEvenOddData.NumUPs(end+1) = size(t.SpindleUPRatesDurations.AllUPMeanDur,1);
        UPSpindleEvenOddData.NumSpindles(end+1) = size(t.SpindleUPRatesDurations.SpindleMeanDur,1);
        UPSpindleEvenOddData.NumNonSpindleUPs(end+1) = size(t.SpindleUPRatesDurations.NonSpindleUPMeanDur,1);
        UPSpindleEvenOddData.NumSpindleUPs(end+1) = size(t.SpindleUPRatesDurations.SpindleUPMeanDur,1);
        UPSpindleEvenOddData.NumPartSpindleUPs(end+1) = size(t.SpindleUPRatesDurations.PartSpindleUPMeanDur,1);
        UPSpindleEvenOddData.NumEarlySpindleUPs(end+1) = size(t.SpindleUPRatesDurations.EarlySpindleUPMeanDur,1);
        UPSpindleEvenOddData.NumLateSpindleUPs(end+1) = size(t.SpindleUPRatesDurations.LateSpindleUPMeanDur,1);
        
        %% Get means (per session across sleep episodes) of event basic metrics (rate, duration, etc)
        for b = 1:length(fn_rd)
            tfn = fn_rd{b};
            eval(['UPSpindleEvenOddData.' tfn '(end+1) = nanmean(t.SpindleUPRatesDurations.' tfn ');'])
        end
                
        %% Get means (per session across sleep episodes) of event Rs and Ps in 1st vs 2nd half sleep
        for b = 1:length(fn_rp)
            tfn = fn_rp{b};
            eval(['UPSpindleEvenOddData.' tfn '(end+1) = nanmean(u.SpindleUPEvenOddRsAndPs.' tfn ');'])
        end

    end
end

UPSpindleEvenOddData.NumRats = length(unique(UPSpindleEvenOddData.RatNames));

savestr = ['UPSpindleEvenOddData_',date];
save(fullfile('/mnt/brendon4/Dropbox/Data/SpindleUPDatasetData/EvenOdd', savestr),'UPSpindleEvenOddData')
