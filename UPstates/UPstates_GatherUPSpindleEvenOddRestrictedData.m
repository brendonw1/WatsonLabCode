
function UPSpindleEvenOddRestrictedData = UPstates_GatherUPSpindleEvenOddRestrictedData

wsw = 0;
synapses = 0;
spindles = 1;
[names,dirs] = SleepAnalysis_GetDatasetNameDirsFromSleepSessionMatrix(wsw,synapses,spindles);

%% Declare empty fields
% names, anatomy
UPSpindleEvenOddRestrictedData.SessionNames = {};
UPSpindleEvenOddRestrictedData.RatNames = {};
UPSpindleEvenOddRestrictedData.Anatomies = {};
UPSpindleEvenOddRestrictedData.NumRats = 0;
UPSpindleEvenOddRestrictedData.NumSessions = 0;
% UPSpindleEvenOddRestrictedData.NumCells = [];
% UPSpindleEvenOddRestrictedData.NumUPs = [];
% UPSpindleEvenOddRestrictedData.NumSpindles = [];
% UPSpindleEvenOddRestrictedData.NumNonSpindleUPs = [];
% UPSpindleEvenOddRestrictedData.NumSpindleUPs = [];
% UPSpindleEvenOddRestrictedData.NumPartSpindleUPs = [];
% UPSpindleEvenOddRestrictedData.NumEarlySpindleUPs = [];
% UPSpindleEvenOddRestrictedData.NumLateSpindleUPs = [];

% fn = fieldnames(UPSpindleEvenOddData);
% fn = fn(4:end);
% nf = length(fn);

% loop throug each dataset... then loop thru and store each 
for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};

    cd (basepath)
    if exist(fullfile('UPstates',[basename '_SpindleUPEvenOddRsAndPs_Restricted.mat']),'file') && exist(fullfile('UPstates',[basename '_SpindleUPRatesDurations.mat']))
        %% Get basic info
        bmd = load([basename '_BasicMetaData.mat']);
        anat = GetChannelAnatomy(basename,bmd.goodeegchannel);
        slashes = strfind(basepath,'/');
        ratname = basepath(slashes(3)+1:slashes(4)-1);
        
    %     assignin('base','UPSpindleHalves',UPSpindleHalves)
        UPSpindleEvenOddRestrictedData.SessionNames{end+1} = basename;
        UPSpindleEvenOddRestrictedData.Anatomies{end+1} = anat;
        UPSpindleEvenOddRestrictedData.RatNames{end+1} = ratname;
        UPSpindleEvenOddRestrictedData.NumSessions = UPSpindleEvenOddRestrictedData.NumSessions + 1;

        %% Load data for this session
        t = load(fullfile('UPstates',[basename '_SpindleUPEvenOddRsAndPs_Restricted.mat']));

        %% If this is first iteration, declare empty cells so can cat to them
        if a == 1;
            fn = fieldnames(t.SpindleUPEvenOddRsAndPs);
            for b = 1:length(fn)
                eval(['UPSpindleEvenOddRestrictedData.' fn{b} ' = [];'])
            end
        end
        
        %% Add some basic counts
%         UPSpindleEvenOddRestrictedData.NumUPs(end+1) = size(t.SpindleUPEvenOddRsAndPs.AllUPMeanDur,1);
%         UPSpindleEvenOddRestrictedData.NumSpindles(end+1) = size(t.SpindleUPEvenOddRsAndPs.SpindleMeanDur,1);
%         UPSpindleEvenOddRestrictedData.NumNonSpindleUPs(end+1) = size(t.SpindleUPEvenOddRsAndPs.NonSpindleUPMeanDur,1);
%         UPSpindleEvenOddRestrictedData.NumSpindleUPs(end+1) = size(t.SpindleUPEvenOddRsAndPs.SpindleUPMeanDur,1);
%         UPSpindleEvenOddRestrictedData.NumPartSpindleUPs(end+1) = size(t.SpindleUPEvenOddRsAndPs.PartSpindleUPMeanDur,1);
%         UPSpindleEvenOddRestrictedData.NumEarlySpindleUPs(end+1) = size(t.SpindleUPEvenOddRsAndPs.EarlySpindleUPMeanDur,1);
%         UPSpindleEvenOddRestrictedData.NumLateSpindleUPs(end+1) = size(t.SpindleUPEvenOddRsAndPs.LateSpindleUPMeanDur,1);
                        
        %% Get means (per session across sleep episodes) of event Rs and Ps in 1st vs 2nd half sleep
        for b = 1:length(fn)
            tfn = fn{b};
            eval(['UPSpindleEvenOddRestrictedData.' tfn '(end+1) = nanmean(t.SpindleUPEvenOddRsAndPs.' tfn ');'])
        end

    end
end

UPSpindleEvenOddRestrictedData.NumRats = length(unique(UPSpindleEvenOddRestrictedData.RatNames));

savestr = ['UPSpindleEvenOddRestrictedData_',date];
if ~exist('/mnt/brendon4/Dropbox/Data/SpindleUPDatasetData/EvenOddRestricted','dir')
    mkdir('/mnt/brendon4/Dropbox/Data/SpindleUPDatasetData/EvenOddRestricted')
end
save(fullfile('/mnt/brendon4/Dropbox/Data/SpindleUPDatasetData/EvenOddRestricted', savestr),'UPSpindleEvenOddRestrictedData')
