function HippoDatasetBasicStats

[names,dirs]=GetHippoDataset;

%% Declare empty fields
% names, anatomy
SessionNames = {};
RatNames = {};
Anatomies = {};

NumSessions = 0;
NumRats = 0;
% NumWSEpisodes = 0;
NumRecordedCells = 0;
NumECells = 0;
NumICells = 0;
NumEDefCells = 0;
NumIDefCells = 0;
NumTotalPairs = 0;
NumECnxns = 0;
NumICnxns = 0;
NumEECnxns = 0;
NumEICnxns = 0;
NumIECnxns = 0;
NumIICnxns = 0;
NumDiffShankPairs = 0;
NumDSECnxns = 0;
NumDSICnxns = 0;
NumDSEECnxns = 0;
NumDSEICnxns = 0;
NumDSIECnxns = 0;
NumDSIICnxns = 0;

NumUPstates = 0;
NumSpindles = 0;
NumRipples = 0;
NumAss_100msWakeBIcaE = 0;

% loop throug each dataset... then loop thru and store each 
counter = 0;%for accumulating stats, since I can't get states out before hand
for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};
    cd(basepath)

    bmd = load(fullfile(basepath,[basename '_BasicMetaData.mat']));
    anat = GetChannelAnatomy(basename,bmd.goodeegchannel);
    slashes = strfind(basepath,'/');
    ratname = basepath(slashes(3)+1:slashes(4)-1);
        
%     assignin('base','UPSpindleHalves',UPSpindleHalves)
    SessionNames{end+1} = basename;
    Anatomies{end+1} = anat;
    RatNames{end+1} = ratname;
    
    NumSessions = NumSessions + 1;
    
%     ws = load(fullfile(basepath,[basename '_WSWEpisodes.mat']));
%     NumWSEpisodes = NumWSEpisodes + length(ws.WSEpisodes);
    
    s = load(fullfile(basepath,[basename '_SAll.mat']));
    NumRecordedCells = NumRecordedCells + length(s.S);

    s = load(fullfile(basepath,[basename '_SSubtypes.mat']));
    NumECells = NumECells + length(s.Se);
    NumICells = NumICells + length(s.Si);
    NumEDefCells = NumEDefCells + length(s.SeDef);
    NumIDefCells = NumIDefCells + length(s.SiDef);

    f = load(fullfile(basepath,[basename '_funcsynapsesMoreStringent.mat']));
    NumTotalPairs = NumTotalPairs + numel(f.funcsynapses.CnxnWeightsZ);
    NumECnxns = NumECnxns + size(f.funcsynapses.ConnectionsE,1);
    NumICnxns = NumICnxns + size(f.funcsynapses.ConnectionsI,1);
%     NumEECnxns = NumEECnxns +  size(f.funcsynapses.ConnectionsEE,1);
%     NumEICnxns = NumEICnxns +  size(f.funcsynapses.ConnectionsEI,1);
%     NumIECnxns = NumIECnxns +  size(f.funcsynapses.ConnectionsIE,1);
%     NumIICnxns = NumIICnxns +  size(f.funcsynapses.ConnectionsII,1);

    % different-shank pairs
    [mx,my] = meshgrid(f.funcsynapses.CellShanks);
    ds = mx - my;
    NumDiffShankPairs = NumDiffShankPairs + sum(sum(abs(ds)>0));
    NumDSECnxns = NumDSECnxns + GetNumDiffShankPairs(f.funcsynapses.ConnectionsE,f.funcsynapses.CellShanks);
    NumDSICnxns = NumDSICnxns + GetNumDiffShankPairs(f.funcsynapses.ConnectionsI,f.funcsynapses.CellShanks);
%     NumDSEECnxns = NumDSEECnxns + GetNumDiffShankPairs(f.funcsynapses.ConnectionsEE,f.funcsynapses.CellShanks);
%     NumDSEICnxns = NumDSEICnxns + GetNumDiffShankPairs(f.funcsynapses.ConnectionsEI,f.funcsynapses.CellShanks);
%     NumDSIECnxns = NumDSIECnxns + GetNumDiffShankPairs(f.funcsynapses.ConnectionsIE,f.funcsynapses.CellShanks);
%     NumDSIICnxns = NumDSIICnxns + GetNumDiffShankPairs(f.funcsynapses.ConnectionsII,f.funcsynapses.CellShanks);
    
    
    u = load(fullfile(basepath,[basename '_UPDOWNIntervals.mat']));
    NumUPstates = NumUPstates + length(length(u.UPInts));

    
    sp = load(fullfile(basepath,'Spindles','SpindleData.mat'));
    NumSpindles = NumSpindles + size(sp.SpindleData.normspindles,1);

    t = load(fullfile(basepath,'Ripples','RippleData.mat'));
    NumRipples = NumRipples + size(t.RippleData.ripples,1);

    try %num ica assemblies on just E cells from Waking 100ms bins
        a = load(fullfile(basepath,'Assemblies','WakeBasedICA','AssemblyBasicDataWakeDetect'));
%         NumAss_100msWakeBIcaE = NumAss_100msWakeBIcaE + size(a.AssemblyBasicData.AssemblyActivities,1);
    end
        
end

NumRats = length(unique(RatNames));
UniqueAnatomies = unique(Anatomies);
NumUniqueAnatomies = length(UniqueAnatomies);

RippleDatasetBasicStats = v2struct(RatNames, NumRats,... 
    Anatomies,UniqueAnatomies, NumUniqueAnatomies, ...
    SessionNames,NumSessions,...
    NumECells,NumICells,NumEDefCells,NumIDefCells,...
    NumTotalPairs,NumECnxns,NumICnxns,NumEECnxns,NumEICnxns,NumIECnxns,NumIICnxns,...
    NumUPstates,NumSpindles,NumRipples,NumAss_100msWakeBIcaE);
%     NumWSEpisodes,...



texttext = {['N Rats = ' num2str(NumRats)];...
    ['N Implants = ' num2str(length(Anatomies))];...
    ['N Recording Sessions = ' num2str(NumSessions)];...
%     ['N Wake-Sleeps = ' num2str(sum(NumWSEpisodes))];...
    [' --------- '];...
    ['N Recorded Cells = ' num2str(NumRecordedCells)];...
    ['N Stable Cells = ' num2str(NumECells+NumICells)];...
    [' --------- '];...
    ['N ECells = ' num2str(NumECells)];...
    ['N ECells w ESynCorr = ' num2str(NumEDefCells)];...
    ['N ICells = ' num2str(NumICells)];...
    ['N ICells w ISynCorr = ' num2str(NumIDefCells)];...
%     [' --------- '];...
%     ['N TotalPairsCompared = ' num2str(NumTotalPairs)];...
%     ['N ECnxns = ' num2str(NumECnxns)];...
%     ['N ICnxns = ' num2str(NumICnxns)];...
%     ['N EECnxns = ' num2str(NumEECnxns)];...
%     ['N EICnxns = ' num2str(NumEICnxns)];...
%     ['N IECnxns = ' num2str(NumIECnxns)];...
%     ['N IICnxns = ' num2str(NumIICnxns)];...
%     [' --------- '];...
%     ['N DifferentShankPairsCompared = ' num2str(NumDiffShankPairs)];...
%     ['N DiffShank ECnxns = ' num2str(NumDSECnxns)];...
%     ['N DiffShank ICnxns = ' num2str(NumDSICnxns)];...
%     ['N DiffShank EECnxns = ' num2str(NumDSEECnxns)];...
%     ['N DiffShank EICnxns = ' num2str(NumDSEICnxns)];...
%     ['N DiffShank IECnxns = ' num2str(NumDSIECnxns)];...
%     ['N DiffShank IICnxns = ' num2str(NumDSIICnxns)];...
    [' --------- '];...
    ['N UPs = ' num2str(NumUPstates)];...
    ['N Spindles = ' num2str(NumSpindles)];...
    ['N Ripples = ' num2str(NumRipples)];...
%     ['N ECellWakeICA100msAssemblies = ' num2str(NumAss_100msWakeBIcaE)];...
    };
h = figure('position',[2 50 560 700],'name','RippleDatasetBasicStats');    
% Create a uicontrol of type "text"
mTextBox = uicontrol('style','text');
set(mTextBox,'Units','Normalized','Position',[.1 .1 .8 .8])
set(mTextBox,'String',texttext)

%% save data
MakeDirSaveVarThere('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/OverallStats',RippleDatasetBasicStats)
%% save fig
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/OverallStats',h,'fig')
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/OverallStats',h,'png')


function numdiffshank = GetNumDiffShankPairs(pairslist,cellshanks)

numdiffshank = 0;
if prod(size(pairslist))>0
    for a = 1:size(pairslist,1);
        tpre = pairslist(a,1);
        tpost = pairslist(a,2);
        if cellshanks(tpre)~=cellshanks(tpost)
            numdiffshank = numdiffshank+1;
        end;
    end
end