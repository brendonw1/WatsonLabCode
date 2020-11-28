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
    StateRates.NumIcells(a) = size(t.StateRates.IAllRates,1);
end

StateRates.NumRats = length(unique(StateRates.RatNames));

for a 1:length(StateRates.NumEcells);
    CellSessNum = cat(1,CellSessNum,a*ones(StateRates.NumEcells(a)));
    CellSessCellNum = cat(1,CellSessCellNum,1:StateRates.NumEcells(a));
end

StateRates.CellSessNum = CellSessNum;
StateRates.CellSessCellNum = CellSessCellNum;

MakeDirSaveVarThere('/mnt/brendon4/Dropbox/BW OUTPUT/July2015SleepProject/StateRates',StateRates);