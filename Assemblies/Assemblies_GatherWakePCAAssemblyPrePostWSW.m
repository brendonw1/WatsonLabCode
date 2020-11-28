function WakePCAEAssembliesPrePostSleep = Assemblies_GatherWakePCAAssemblyPrePostWSW

wsw = 1;
synapses = 0;
spindles = 1;
[names,dirs] = SleepAnalysis_GetDatasetNameDirsFromSleepSessionMatrix(wsw,synapses,spindles);

%% Declare empty fields
% names, anatomy
WakePCAEAssembliesPrePostSleep.SessionNames = {};
WakePCAEAssembliesPrePostSleep.RatNames = {};
WakePCAEAssembliesPrePostSleep.Anatomies = {};
WakePCAEAssembliesPrePostSleep.NumRats = 0;
WakePCAEAssembliesPrePostSleep.NumSessions = 0;
WakePCAEAssembliesPrePostSleep.NumSleeps = 0;
WakePCAEAssembliesPrePostSleep.NumAssemblies = 0;

noncatfields = {'basename','basepath','WSWEpisodes','GoodSleepInterval'};


% loop throug each dataset... then loop thru and store each 
for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};

    cd (basepath)
    
    if exist(fullfile(basepath,'Assemblies',[basename '_WakePCAEAssembliesPrePostSleep.mat']),'file')
        %% Get basic info
        bmd = load([basename '_BasicMetaData.mat']);
        anat = GetChannelAnatomy(basename,bmd.goodeegchannel);
        slashes = strfind(basepath,'/');
        ratname = basepath(slashes(3)+1:slashes(4)-1);
        
    %     assignin('base','UPSpindleHalves',UPSpindleHalves)
        WakePCAEAssembliesPrePostSleep.SessionNames{end+1} = basename;
        WakePCAEAssembliesPrePostSleep.Anatomies{end+1} = anat;
        WakePCAEAssembliesPrePostSleep.RatNames{end+1} = ratname;
        WakePCAEAssembliesPrePostSleep.NumSessions = WakePCAEAssembliesPrePostSleep.NumSessions + 1;

        %% Load data for this session
        t = load(fullfile(basepath,'Assemblies',[basename '_WakePCAEAssembliesPrePostSleep.mat']));

        %% If this is first iteration, declare empty cells so can cat to them
        if a == 1;
            fn = fieldnames(t.WakePCAEAssembliesPrePostSleep);
            for b = 1:length(fn)
                if ~ismember(fn{b},noncatfields)
                    eval(['WakePCAEAssembliesPrePostSleep.' fn{b} ' = [];'])
                end
            end
        end
        
        
        %% Add some basic counts
        WakePCAEAssembliesPrePostSleep.NumSleeps = WakePCAEAssembliesPrePostSleep.NumSleeps + length(length(t.WakePCAEAssembliesPrePostSleep.WSWEpisodes{1}));
        WakePCAEAssembliesPrePostSleep.NumAssemblies = WakePCAEAssembliesPrePostSleep.NumAssemblies + t.WakePCAEAssembliesPrePostSleep.numUniqueEAssemblies;
        
        %% Get means (per session across sleep episodes) of event/template correlations (and template-template correlations)
        for b = 1:length(fn)
            if ~ismember(fn{b},noncatfields)
                tfn = fn{b};
                eval(['WakePCAEAssembliesPrePostSleep.' tfn ' = cat(1,WakePCAEAssembliesPrePostSleep.' tfn ',t.WakePCAEAssembliesPrePostSleep.' tfn ');'])
            end
        end

    end
end

WakePCAEAssembliesPrePostSleep.NumRats = length(unique(WakePCAEAssembliesPrePostSleep.RatNames));

savestr = ['WakePCAEAssembliesPrePostSleep',date];

if ~exist('/mnt/brendon4/Dropbox/Data/Assemblies/WakePCABeforeAfterSleep','dir')
    mkdir('/mnt/brendon4/Dropbox/Data/Assemblies/WakePCABeforeAfterSleep')
end
save(fullfile('/mnt/brendon4/Dropbox/Data/Assemblies/WakePCABeforeAfterSleep', savestr),'WakePCAEAssembliesPrePostSleep')
