function NeighbRatios = UPstates_GatherUPSpindleTemplateNeighborhoodData

wsw = 0;
synapses = 0;
spindles = 1;
[names,dirs] = SleepAnalysis_GetDatasetNameDirsFromSleepSessionMatrix(wsw,synapses,spindles);

%% Declare empty fields
% names, anatomy
NeighbRatios.SessionNames = {};
NeighbRatios.RatNames = {};
NeighbRatios.Anatomies = {};
NeighbRatios.NumRats = 0;
NeighbRatios.NumSessions = 0;
NeighbRatios.NumNonSpindleUPs = [];
NeighbRatios.NumSpindleUPs = [];
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
    if exist(fullfile('UPstates',[basename '_NeighborToTemplateAnalysis.mat']),'file')
        %% Get basic info
        bmd = load([basename '_BasicMetaData.mat']);
        anat = GetChannelAnatomy(basename,bmd.goodeegchannel);
        slashes = strfind(basepath,'/');
        ratname = basepath(slashes(3)+1:slashes(4)-1);
        
    %     assignin('base','UPSpindleHalves',UPSpindleHalves)
        NeighbRatios.SessionNames{end+1} = basename;
        NeighbRatios.Anatomies{end+1} = anat;
        NeighbRatios.RatNames{end+1} = ratname;
        NeighbRatios.NumSessions = NeighbRatios.NumSessions + 1;

        %% Load data for this session
        t = load(fullfile('UPstates',[basename '_NeighborToTemplateAnalysis.mat']));

        %% If this is first iteration, declare empty cells so can cat to them
        if a == 1;
            fn = fieldnames(t.NeighbRatios);
            for b = 1:length(fn)
                eval(['NeighbRatios.' fn{b} ' = [];'])
            end
        end
        
        %% Add some basic counts
        NeighbRatios.NumNonSpindleUPs(end+1) = size(t.NeighbRatios.NupNeighRatio,2);
        NeighbRatios.NumSpindleUPs(end+1) = size(t.NeighbRatios.SupNeighRatio,2);
        
        %% Get means (per session across sleep episodes) of event/template correlations (and template-template correlations)
        for b = 1:length(fn)
            tfn = fn{b};
            eval(['NeighbRatios.' tfn '(end+1) = nanmean(t.NeighbRatios.' tfn ');'])
        end

    end
end

NeighbRatios.NumRats = length(unique(NeighbRatios.RatNames));

savestr = ['NeighbRatios',date];

savedir = '/mnt/brendon4/Dropbox/Data/SpindleUPDatasetData/TemplateNeighborhood';

if ~exist(savedir,'dir')
    mkdir(savedir)
end
save(fullfile(savedir, savestr),'NeighbRatios')
