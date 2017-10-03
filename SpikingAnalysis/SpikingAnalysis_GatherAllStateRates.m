function [StateRates] = SpikingAnalysis_GatherAllStateRates
% Brendon Watson 2015

[names,dirs] = GetDefaultDataset;

%% Declare empty fields
% names, anatomy
StateRates.SessionNames = {};
StateRates.RatNames = {};
StateRates.Anatomies = {};
StateRates.NumRats = 0;
StateRates.NumSessions = 0;
StateRates.NumSleeps = 0;
StateRates.SessNumPerECell = [];
StateRates.SessCellNumPerECell = [];
StateRates.SessNumPerICell = [];
StateRates.SessCellNumPerICell = [];

% loop throug each dataset... then loop thru and store each 
for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};

    cd (basepath)
        
    StateRates.NumSessions = StateRates.NumSessions + 1;

   %% Get basic info
    bmd = load(fullfile(basepath,[basename '_BasicMetaData.mat']));
    anat = GetChannelAnatomy(basename,bmd.goodeegchannel);
    slashes = strfind(basepath,'/');
    ratname = basepath(slashes(3)+1:slashes(4)-1);

%     assignin('base','UPSpindleHalves',UPSpindleHalves)
    StateRates.SessionNames{end+1} = basename;
    StateRates.Anatomies{end+1} = anat;
    StateRates.RatNames{end+1} = ratname;

    %% Load data for this session
    t = load(fullfile(basepath,[basename '_StateRates.mat']));



    %% If this is first iteration, declare empty cells so can cat to them
    if a == 1;
        %get spike data
        fn = fieldnames(t.StateRates);
        for b = 1:length(fn)
            tfield = fn{b};
            eval(['StateRates.' tfield ' = [];'])
        end
    end
    for c = 1:length(fn)
        tfield = fn{c};
        eval(['StateRates.' tfield ' = cat(1,StateRates.' tfield ',t.StateRates. ' tfield ');'])
    end
    StateRates.NumEcells(a) = size(t.StateRates.EAllRates,1);
    StateRates.SessNumPerECell = cat(1,StateRates.SessNumPerECell,a*ones(StateRates.NumEcells(a),1));
    StateRates.SessCellNumPerECell = cat(1,StateRates.SessCellNumPerECell,(1:StateRates.NumEcells(a))');

    StateRates.NumIcells(a) = size(t.StateRates.IAllRates,1);
    StateRates.SessNumPerICell = cat(1,StateRates.SessNumPerICell,a*ones(StateRates.NumIcells(a),1));
    StateRates.SessCellNumPerICell = cat(1,StateRates.SessCellNumPerICell,(1:StateRates.NumIcells(a))');
end


StateRates.NumRats = length(unique(StateRates.RatNames));

MakeDirSaveVarThere('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/StateRates',StateRates);