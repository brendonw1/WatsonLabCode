function DefaultDatasetBasicStats

[names,dirs]=GetDefaultDataset;

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
%
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
NumDOWNstates = 0;
UPDurations = [];
DOWNDurations = [];
NumSpindles = 0;
SpindleIncidence = [];
SpindleDurations = [];
SpindleAmplitudes = [];
SpindleFrequencies = [];
NumAss_100msWakeBIcaE = 0;

RecordingDurations = [];

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
    lastspike = EndTime(oneSeries(s.S),'s');
    
    s = load(fullfile(basepath,[basename '_GoodSleepInterval.mat']));
    gsi = StartEnd(s.GoodSleepInterval,'s');
    gsi(2) = min([gsi(2) lastspike]);%can't be infinite
    RecordingDurations(end+1) = sum(diff(gsi));
    
    s = load(fullfile(basepath,[basename '_SSubtypes.mat']));
    NumECells = NumECells + length(s.Se);
    NumICells = NumICells + length(s.Si);
    NumEDefCells = NumEDefCells + length(s.SeDef);
    NumIDefCells = NumIDefCells + length(s.SiDef);
    ECellsPerRecording(a) = length(s.Se);
    ICellsPerRecording(a) = length(s.Si);

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
    NumDOWNstates = NumDOWNstates + length(length(u.DNInts));
    UPDurations = cat(1,UPDurations,Data(length(u.UPInts,'s')));
    DOWNDurations = cat(1,DOWNDurations,Data(length(u.DNInts,'s')));
    
    sp = load(fullfile(basepath,[basename,'_SpindleData.mat']));
    if a == 16
        1;
    end
    NumSpindles = NumSpindles + size(sp.SpindleData.normspindles,1);
    w = load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']));
        si = size(sp.SpindleData.normspindles,1)/tot_length(w.SleepInts,'s');
    SpindleIncidence = cat(1,SpindleIncidence,si);
    SpindleDurations = cat(1,SpindleDurations,sp.SpindleData.data.duration);
    SpindleAmplitudes = cat(1,SpindleAmplitudes,sp.SpindleData.data.peakAmplitude*1000000);%note conversion to uV
    SpindleFrequencies = cat(1,SpindleFrequencies,sp.SpindleData.data.peakFrequency);
    try %num ica assemblies on just E cells from Waking 100ms bins
        a = load(fullfile(basepath,'Assemblies','WakeBasedICA','AssemblyBasicDataWakeDetect'));
%         NumAss_100msWakeBIcaE = NumAss_100msWakeBIcaE + size(a.AssemblyBasicData.AssemblyActivities,1);
    end
        
end
UniqueRatNames = unique(RatNames,'stable');
NumRats = length(UniqueRatNames);
UniqueAnatomies = unique(Anatomies);
NumUniqueAnatomies = length(UniqueAnatomies);

DefaultDatasetBasicStats = v2struct(RatNames, NumRats,... 
    Anatomies,UniqueAnatomies, NumUniqueAnatomies, ...
    SessionNames,NumSessions,...
    NumECells,NumICells,NumEDefCells,NumIDefCells,...
    NumTotalPairs,NumECnxns,NumICnxns,NumEECnxns,NumEICnxns,NumIECnxns,NumIICnxns,...
    NumUPstates,UPDurations,DOWNDurations,...
    NumSpindles,SpindleIncidence,SpindleDurations,SpindleAmplitudes,SpindleFrequencies,...
    NumAss_100msWakeBIcaE);
%     NumWSEpisodes,...


%% per-rat stats
ECellsPerRat = [];
ICellsPerRat = [];
WSPerRat = [];
SessionsPerRat = [];
lastname = [];
for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};
    cd(basepath)
    bmd = load(fullfile(basepath,[basename '_BasicMetaData.mat']));
    slashes = strfind(basepath,'/');
    ratname = basepath(slashes(3)+1:slashes(4)-1);

    if ~strcmp(lastname,ratname)
        SessionsPerRat(end+1) = 0;
        ECellsPerRat(end+1) = 0;
        ICellsPerRat(end+1) = 0;
        WSPerRat(end+1) = 0;
        lastname = ratname;
    end
    
    SessionsPerRat(end) = SessionsPerRat(end) + 1;
    
    w = load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']));
    WSPerRat(end) = WSPerRat(end) + length(w.WakeSleep);

    s = load(fullfile(basepath,[basename '_SSubtypes.mat']));
    ECellsPerRat(end) = ECellsPerRat(end) + length(s.Se);
    ICellsPerRat(end) = ICellsPerRat(end) + length(s.Si);
end
t = table(UniqueRatNames',SessionsPerRat',WSPerRat',ECellsPerRat',ICellsPerRat');
t.Properties.VariableNames = {'RatName' 'NumSessions' 'NumWakeSleeps' 'NumECells' 'NumICells'};
disp(t)
writetable(t,'/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/OverallStats/PerRatBasicStats.csv')

%% Display overall stats
texttext = {['N Rats = ' num2str(NumRats)];...
    ['N Implants = ' num2str(length(Anatomies))];...
    ['N Recording Sessions = ' num2str(NumSessions)];...
    ['Recording duration mean + SD (s) = ' num2str(mean(RecordingDurations)) ' +- ' num2str(std(RecordingDurations))];...
    ['Recording duration median + SD (s) = ' num2str(median(RecordingDurations)) ' +- ' num2str(std(RecordingDurations))];...
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
    ['N DOWNs = ' num2str(NumDOWNstates)];...
    ['UP duration mean + SD (s) = ' num2str(mean(UPDurations)) ' +- ' num2str(std(UPDurations))];...
    ['UP duration median + SD (s) = ' num2str(median(UPDurations)) ' +- ' num2str(std(UPDurations))];...
    ['DOWN duration mean + SD (s) = ' num2str(mean(DOWNDurations)) ' +- ' num2str(std(DOWNDurations))];...
    ['DOWN duration median + SD (s) = ' num2str(median(DOWNDurations)) ' +- ' num2str(std(DOWNDurations))];...
    [' --------- '];...
    ['N Spindles = ' num2str(NumSpindles)];...
    ['Spindle incidence mean + SD (Hz) = ' num2str(mean(SpindleIncidence)) ' +- ' num2str(std(SpindleIncidence))];...
    ['Spindle incidence median + SD (Hz) = ' num2str(median(SpindleIncidence)) ' +- ' num2str(std(SpindleIncidence))];...
    ['Spindle duration mean + SD (s) = ' num2str(mean(SpindleDurations)) ' +- ' num2str(std(SpindleDurations))];...
    ['Spindle duration median + SD (s) = ' num2str(median(SpindleDurations)) ' +- ' num2str(std(SpindleDurations))];...
    ['Spindle amplitude mean + SD (uV) = ' num2str(mean(SpindleAmplitudes)) ' +- ' num2str(std(SpindleAmplitudes))];...
    ['Spindle amplitude median + SD (uV) = ' num2str(median(SpindleAmplitudes)) ' +- ' num2str(std(SpindleAmplitudes))];...
    ['Spindle frequencies mean + SD (Hz) = ' num2str(mean(SpindleFrequencies)) ' +- ' num2str(std(SpindleFrequencies))];...
    ['Spindle frequencies median + SD (Hz) = ' num2str(median(SpindleFrequencies)) ' +- ' num2str(std(SpindleFrequencies))];...
%     ['N ECellWakeICA100msAssemblies = ' num2str(NumAss_100msWakeBIcaE)];...
    };
h = figure('position',[2 50 560 700],'name','DefaultDatasetBasicStats');    
% Create a uicontrol of type "text"
mTextBox = uicontrol('style','text');
set(mTextBox,'Units','Normalized','Position',[.1 .1 .8 .8])
set(mTextBox,'String',texttext)

%% save data
MakeDirSaveVarThere('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/OverallStats',DefaultDatasetBasicStats)
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

