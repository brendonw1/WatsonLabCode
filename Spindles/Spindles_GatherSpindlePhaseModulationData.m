function SpindleModulationData = Spindles_GatherSpindlePhaseModulationData

wsw = 0;
synapses = 0;
spindles = 1;
[names,dirs] = SleepAnalysis_GetDatasetNameDirsFromSleepSessionMatrix(wsw,synapses,spindles);

%% Declare empty fields
% names, anatomy
SpindleModulationData.SessionNames = {};
SpindleModulationData.RatNames = {};
SpindleModulationData.Anatomies = {};
SpindleModulationData.NumRats = 0;
SpindleModulationData.NumSessions = 0;
SpindleModulationData.NumCells = [];
SpindleModulationData.NumECells = [];
SpindleModulationData.NumICells = [];
SpindleModulationData.NumSpindles = [];
SpindleModulationData.spindleband = [];
SpindleModulationData.phasebins = [];

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
    if exist(fullfile('Spindles',[basename '_SpindleModulationData.mat']),'file') && exist(fullfile('UPstates',[basename '_SpindleUPRatesDurations.mat']))
        %% Get basic info
        bmd = load([basename '_BasicMetaData.mat']);
        anat = GetChannelAnatomy(basename,bmd.goodeegchannel);
        slashes = strfind(basepath,'/');
        ratname = basepath(slashes(3)+1:slashes(4)-1);
        
        SpindleModulationData.SessionNames{end+1} = basename;
        SpindleModulationData.Anatomies{end+1} = anat;
        SpindleModulationData.RatNames{end+1} = ratname;
        SpindleModulationData.NumSessions = SpindleModulationData.NumSessions + 1;
        
        %% Load data for this session
        t = load(fullfile('Spindles',[basename '_SpindleModulationData.mat']));

        SpindleModulationData.NumSpindles(end+1) = length(t.SpindleModulationData.sp_starts);
        SpindleModulationData.NumCells(end+1) = size(t.SpindleModulationData.phasedistros,2);
        SpindleModulationData.NumECells(end+1) = size(t.SpindleModulationData.ECells,1);
        SpindleModulationData.NumICells(end+1) = size(t.SpindleModulationData.ICells,1);
 
        %% If this is first iteration, declare empty cells so can cat to them
        if a == 1;
            fn = fieldnames(t.SpindleModulationData);
            for b = 4:length(fn)
                eval(['SpindleModulationData.' fn{b} ' = [];'])
            end
            SpindleModulationData.spindleband = t.SpindleModulationData.spindleband;
            SpindleModulationData.phasebins = t.SpindleModulationData.phasebins;
        end
        
        %% Get means (per session across sleep episodes) of event/template correlations (and template-template correlations)
%         for b = 1:length(fn)
%             tfn = fn{b};
%             eval(['SpindleModulationData.' tfn '(end+1) = nanmean(t.SpindleModulationData.' tfn ');'])
            SpindleModulationData.phasedistros = cat(2,SpindleModulationData.phasedistros,t.SpindleModulationData.phasedistros);
            SpindleModulationData.phasedistros_rawpersec = cat(2,SpindleModulationData.phasedistros,t.SpindleModulationData.phasedistros_rawpersec);
            SpindleModulationData.meanphase = cat(2,SpindleModulationData.meanphase,t.SpindleModulationData.meanphase);
            SpindleModulationData.modsignif = cat(2,SpindleModulationData.modsignif,t.SpindleModulationData.modsignif);
            SpindleModulationData.peaktroughtimes = cat(1,SpindleModulationData.peaktroughtimes,t.SpindleModulationData.peaktroughtimes);
            SpindleModulationData.spikewidthtimes = cat(1,SpindleModulationData.spikewidthtimes,t.SpindleModulationData.spikewidthtimes);
            SpindleModulationData.Rates = cat(2,SpindleModulationData.Rates,t.SpindleModulationData.Rates');

            SpindleModulationData.Ephasedistros = cat(2,SpindleModulationData.Ephasedistros,t.SpindleModulationData.Ephasedistros);
            SpindleModulationData.Ephasedistros_rawpersec = cat(2,SpindleModulationData.Ephasedistros,t.SpindleModulationData.Ephasedistros_rawpersec);
            SpindleModulationData.Emeanphase = cat(2,SpindleModulationData.Emeanphase,t.SpindleModulationData.Emeanphase);
            SpindleModulationData.Emodsignif = cat(2,SpindleModulationData.Emodsignif,t.SpindleModulationData.Emodsignif);
            SpindleModulationData.Epeaktroughtimes = cat(1,SpindleModulationData.Epeaktroughtimes,t.SpindleModulationData.Epeaktroughtimes);
            SpindleModulationData.Espikewidthtimes = cat(1,SpindleModulationData.Espikewidthtimes,t.SpindleModulationData.Espikewidthtimes);
            SpindleModulationData.ERates = cat(2,SpindleModulationData.ERates,t.SpindleModulationData.ERates');

            if ~isempty(t.SpindleModulationData.ICells)
                SpindleModulationData.Iphasedistros = cat(2,SpindleModulationData.Iphasedistros,t.SpindleModulationData.Iphasedistros);
                SpindleModulationData.Iphasedistros_rawpersec = cat(2,SpindleModulationData.Iphasedistros,t.SpindleModulationData.Iphasedistros_rawpersec);
                SpindleModulationData.Imeanphase = cat(2,SpindleModulationData.Imeanphase,t.SpindleModulationData.Imeanphase);
                SpindleModulationData.Imodsignif = cat(2,SpindleModulationData.Imodsignif,t.SpindleModulationData.Imodsignif);
                SpindleModulationData.Ipeaktroughtimes = cat(1,SpindleModulationData.Ipeaktroughtimes,t.SpindleModulationData.Ipeaktroughtimes);
                SpindleModulationData.Ispikewidthtimes = cat(1,SpindleModulationData.Ispikewidthtimes,t.SpindleModulationData.Ispikewidthtimes);
                SpindleModulationData.IRates = cat(2,SpindleModulationData.IRates,t.SpindleModulationData.IRates');
            end
%         end

    end
end

SpindleModulationData = rmfield(SpindleModulationData,'ECells');
SpindleModulationData = rmfield(SpindleModulationData,'ICells');

SpindleModulationData.NumRats = length(unique(SpindleModulationData.RatNames));

savestr = ['SpindleModulationData_',date];

if ~exist('/mnt/brendon4/Dropbox/Data/Spindles/SpindleModulationData','dir')
    mkdir('/mnt/brendon4/Dropbox/Data/Spindles/SpindleModulationData')
end
save(fullfile('/mnt/brendon4/Dropbox/Data/Spindles/SpindleModulationData', savestr),'SpindleModulationData')
