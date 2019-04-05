%% Assumes you have run through "SpikingAnalysis_BigScript_Sleep.m"
% Assumes you are in the master folder for a given recording

%% get basename and basepath from CD
clear
[basepath,basename,dummy] = fileparts(cd);
basepath = fullfile(basepath,basename);
clear dummy

%% Make folders for Anatomical Regions

ChannelAnatomyFileFromSpikeGroupAnatomy(basename)

% Make subdirectory for each anatomical region
tx = read_mixed_csv([basename '_SpikeGroupAnatomy.csv'],',');
for a = 2:size(tx,1);
    txx{a-1} = tx{a,2};
end
anatregions = unique(txx);
for a = 1:length(anatregions)
    if ~exist([basename,'_',anatregions{a}],'dir')
        mkdir([basename,'_',anatregions{a}])
    end
end    


%% Choose anatomical folder
basepath = uigetdir(basepath,'Choose Anatomy-Specific Folder');
[masterpath,basename]=fileparts(basepath);
[dummy,mastername] = fileparts(masterpath); 
cd(basepath)

%% Get Anatomical region text/tag
t = strfind(basename,'_');
thisanatomy = basename(t(end)+1:end);

%% Load shank-anatomical data and restrict "goodshanks" accordingly
tx = read_mixed_csv(fullfile(masterpath,[mastername '_SpikeGroupAnatomy.csv']),',');
anatshanks = [];
for a = 2:size(tx,1);
    if strcmp(tx{a,2},thisanatomy);
        anatshanks(end+1) = str2num(tx{a,1});
    end
end
t = load(fullfile(masterpath,[mastername '_BasicMetaData.mat']));
ts = t.goodshanks;
goodshanks = intersect(ts,anatshanks);
disp([thisanatomy ' = Groups: ' num2str(goodshanks)])

%% Voltage info
% t = load(fullfile(masterpath,[mastername '_BasicMetaData.mat']));
voltsperunit = t.voltsperunit;

%% RecordingFilesForSleep
try 
    RecordingFilesForSleep = t.RecordingFilesForSleep;
end

%% Prompt for GoodEEGChannel
% open(fullfile(masterpath,[mastername,'_ChannelAnatomy.csv']))

goodeegchannel = inputdlg(['Enter Good EEG channel from groups: ' num2str(goodshanks)],'Pick Channel',1,num2str(goodeegchannel));
goodeegchannel = str2num(goodeegchannel{1});

%% Create Header
headername = [basename,'_Header.m'];
% if ~exist(headername,'file')
%     w = which('SpikingAnalysis_SeparateShanks_Header.m');% copy an example header here to edit
%     copyfile(w,headername);
% end
% edit(fullfile(masterpath,[mastername '_Header.m']))
% edit(headername)
% 
% cd(masterpath)
% open([mastername,'_SpikeGroupAnatomy.csv'])
% open([mastername,'_ChannelAnatomy.csv'])
% cd(basepath)

% disp('USE THIS:')
headerout = {};
headerout{end+1} = ['basename = ''' basename ''';'];
headerout{end+1} = ['basepath = ''' basepath ''';'];
headerout{end+1} = ['masterpath = ''' masterpath ''';'];
headerout{end+1} = ['mastername = ''' mastername ''';'];
headerout{end+1} = '';
headerout{end+1} = ['goodshanks = [' num2str(goodshanks) '];'];
headerout{end+1} = ['goodeegchannel = ' num2str(goodeegchannel) ';'];
headerout{end+1} = '';
headerout{end+1} = 'Par = LoadPar(fullfile(masterpath,[mastername, ''.xml'']));';
headerout{end+1} = '';
headerout{end+1} = 'RecordingFileIntervals = FileStartStopsToIntervals(fullfile(masterpath,mastername));';
try 
    headerout{end+1} = ['RecordingFilesForSleep = ''' RecordingFilesForSleep ''';'];
end
headerout{end+1} = 'FileStartStopsToStateEditorEvent(fullfile(masterpath,mastername));';
headerout{end+1} = '';
headerout{end+1} = ['voltsperunit = ''' voltsperunit ''';'];
headerout{end+1} = '';
headerout{end+1} = 'save([basename ''_BasicMetaData.mat''],''basename'',''basepath'',''masterpath'',''mastername'',''goodshanks'',''goodeegchannel'',''Par'',''RecordingFileIntervals'',''voltsperunit'');';

% cd(basepath)
% fid = fopen(headername,'w');

dlmcell(headername,headerout,'delimiter','\n')


%% Use header to create basic recording info from human-entered header file info
run(headername);
% load([basename '_BasicMetaData.mat']);
clear a t gs dummy headername headerout tx


%% Make a file of which anatomical site each channel was in (based on a csv made in gdrive by hand)
copyfile(fullfile(masterpath,[mastername '_ChannelAnatomy.csv']),[basename '_ChannelAnatomy.csv'])
copyfile(fullfile(masterpath,[mastername '_SpikeGroupAnatomy.csv']),[basename '_SpikeGroupAnatomy.csv'])
% ChannelAnatomyFileFromSpikeGroupAnatomy(basename)

%% Store an interval with start/stop of time with acceptable sleep
% gf = find(RecordingFilesForSleep);
% if length(gf) == 1;
%     GoodSleepInterval = subset(RecordingFileIntervals,gf);
% else
%     GoodSleepInterval = subset(RecordingFileIntervals,gf(1));
%     for a = 2:length(gf);
%         GoodSleepInterval = timeSpan(cat(GoodSleepInterval, subset(RecordingFileIntervals,gf(a))));
%     end
% end
% save([basename '_GoodSleepInterval'],'GoodSleepInterval')
copyfile(fullfile(masterpath,[mastername '_GoodSleepInterval.mat']),[basename '_GoodSleepInterval.mat'])
load([basename '_GoodSleepInterval'])


%% Load AllSpikes, confine to proper shanks
% [S,shank,cellIx] = LoadSpikeData(basename,goodshanks);
% save([basename,'_SAll.mat'],'S','shank','cellIx')
% 
% %load([basename,'_SAll.mat'])
copyfile(fullfile(masterpath,[mastername '_SAll.mat']),[basename '_SAll.mat'])
load([basename '_SAll'])

cluqualifications = ismember(shank,goodshanks);
goodclus = find(cluqualifications);
badclus = find(~cluqualifications);
[dummy,cnv] = sort(goodclus);
% save([basename,'_ConversionMtxs'],'goodclus','badclus','cnv')

S = S(goodclus);
shank = shank(goodclus);
cellIx = cellIx(goodclus);
clear cluqualifications

save([basename,'_SAll.mat'],'S','shank','cellIx')

%% Load StableSpikes, confine to proper shanks
copyfile(fullfile(masterpath,[mastername '_SStable.mat']),[basename '_SStable.mat'])
load([basename '_SStable'])

cluqualifications = ismember(shank,goodshanks);
goodclus = find(cluqualifications);
badclus = find(~cluqualifications);
[dummy,cnv] = sort(goodclus);
save([basename,'_ConversionMtxs'],'goodclus','badclus','cnv')

S = S(goodclus);
shank = shank(goodclus);
cellIx = cellIx(goodclus);
clear cluqualifications

save([basename,'_SStable'],'S','shank','cellIx')

%% Burst filter
Sbf = burstfilter(S,6);%burst filter at 6ms for looking at connections
save([basename,'_SBurstFiltered.mat'],'Sbf');

%% Get connectivity
% funcsynapses = FindSynapseWrapper(S,shank,cellIx);
copyfile(fullfile(masterpath,[mastername '_funcsynapsesMoreStringent.mat']),[basename '_funcsynapsesMoreStringent.mat'])
load([basename '_funcsynapsesMoreStringent'])
funcsynapses = cleanfuncsynapses(funcsynapses,badclus);
save([basename '_funcsynapsesMoreStringent'],'funcsynapses')

if ~isempty(funcsynapses.ConnectionsE) | ~isempty(funcsynapses.ConnectionsI)
    FindSynapse_ReviewOutput(funcsynapses, 'funcsynapses');% a gui-ish means to allow users to review all connections and nominate bad ones with clicks on axes
end

if ~isempty(funcsynapses.ZeroLag.EPairs) | ~isempty(funcsynapses.ZeroLag.IPairs)
    h = figure('Visible','Off','Name','BWWaitFig');
    waitfor(h,'Name','DELETEMENOW')
    delete(h)

    FindSynapse_ReviewZeroAndWide(funcsynapses, 'funcsynapses');% a gui-ish means to allow users to review all connections and nominate bad ones with clicks on axes
end

%% Pause here to allow for review of funcsynapses figures

%save wide/zero lag figs
if ~exist(fullfile(basepath,'ZeroLagAndWideFigs'),'dir')
    mkdir(fullfile(basepath,'ZeroLagAndWideFigs'))
end
cd(fullfile(basepath,'ZeroLagAndWideFigs'))
saveallfigsas('fig')
cd(basepath)
% 
% %save edited connectivity figs
% d = dir('ConnectionsPresynCell*.fig');
% if ~exist(fullfile(basepath,'ConnectionFigs'),'dir')
%     mkdir(fullfile(basepath,'ConnectionFigs'))
% end
% temppath = (fullfile(basepath,'ConnectionFigs'));
% for a = 1:length(d)
%     movefile(d(a).name,fullfile(temppath,d(a).name))
% end

save([basename '_funcsynapsesMoreStringent'],'funcsynapses')
close all
% load([basename,'_funcsynapses.mat']);


%% Classify cells (get raw waveforms first)
copyfile(fullfile(masterpath,[mastername '_CellIDs.mat']),[basename '_CellIDs.mat'])
load([basename '_CellIDs'])
% CellIDs.EDefinite = rmvBadShiftToNewOrder(CellIDs.EDefinite',badclus,goodclus,cnv);
% CellIDs.EDefinite = CellIDs.EDefinite';
% CellIDs.IDefinite = rmvBadShiftToNewOrder(CellIDs.IDefinite',badclus,goodclus,cnv);
% CellIDs.IDefinite = CellIDs.IDefinite';
CellIDs.EDefinite = rmvBadShiftToNewOrder1D(CellIDs.EDefinite,badclus,goodclus,cnv);
CellIDs.IDefinite = rmvBadShiftToNewOrder1D(CellIDs.IDefinite,badclus,goodclus,cnv);
CellIDs.ELike = rmvBadShiftToNewOrder1D(CellIDs.ELike,badclus,goodclus,cnv);
CellIDs.ILike = rmvBadShiftToNewOrder1D(CellIDs.ILike,badclus,goodclus,cnv);
CellIDs.EAll = rmvBadShiftToNewOrder1D(CellIDs.EAll,badclus,goodclus,cnv);
CellIDs.IAll = rmvBadShiftToNewOrder1D(CellIDs.IAll,badclus,goodclus,cnv);
save([basename, '_CellIDs.mat'],'CellIDs')

copyfile(fullfile(masterpath,[mastername '_CellClassificationOutput.mat']),[basename '_CellClassificationOutput.mat'])
load([basename '_CellClassificationOutput'])
CellClassificationOutput.CellClassOutput(badclus,:)=[];
save([basename, '_CellClassificationOutput.mat'],'CellClassificationOutput')

% generate figure
x = CellClassificationOutput.CellClassOutput(:,2);%trough to peak in ms
y = CellClassificationOutput.CellClassOutput(:,3);%width in ms of wavelet representing largest feature of spike complex... ie the full trough including to the tip of the peak

xx = [0 0.8];
yy = [2.4 0.4];
m = diff( yy ) / diff( xx );
b = yy( 1 ) - m * xx( 1 );  % y = ax+b

h = figure('name',[basename 'SpikeProperties']);
xlabel('Trough-To-Peak Time (ms)')
ylabel('Wave width (via inverse frequency) (ms)')
JustPlotCellIDs([x,y], CellIDs.EDefinite, CellIDs.IDefinite, CellIDs.ELike, CellIDs.ILike, m,b)

if ~exist(fullfile(basepath,'CellClassificationFigs'),'dir')
    mkdir(fullfile(basepath,'CellClassificationFigs'))
end
cd(fullfile(basepath,'CellClassificationFigs'))
saveas(h,get(h,'name'),'fig')
cd(basepath)

close (h)
% load([basename, '_CellIDs.mat'])
% load([basename,'_CellClassificationOutput.mat'])

%% Dividing spikes by cell class (based on S variable above)
Se = S(CellIDs.EAll);
SeDef = S(CellIDs.EDefinite);
SeLike = S(CellIDs.ELike);
Si = S(CellIDs.IAll);
SiDef = S(CellIDs.IDefinite);
SiLike = S(CellIDs.ILike);
SRates = Rate(S);
SeRates = Rate(Se);
SiRates = Rate(Si);

save([basename '_SSubtypes'],'Se','SeDef','SeLike','Si','SiDef','SiLike','SRates','SeRates','SiRates')
% load([basename '_Subtypes'])


%% Sleep score, get and keep intervals
% statefilename = [basename '-states.mat'];
% load(statefilename,'states') %gives states, a vector of the state at each second

copyfile(fullfile(masterpath,[mastername '.eegstates.mat']),[basename '.eegstates.mat'])
copyfile(fullfile(masterpath,[mastername '-states.mat']),[basename '-states.mat'])
copyfile(fullfile(masterpath,[mastername '_Intervals.mat']),[basename '_Intervals.mat'])
load([basename '_Intervals'])


%% Get intervals useful for Sleep Analysis... sleep minimum = 20min, wake min = 6min
copyfile(fullfile(masterpath,[mastername '_WSWEpisodes.mat']),[basename '_WSWEpisodes.mat'])
load([basename '_WSWEpisodes'])

% %% Get Peri-Event Time Histograms
% sleepstart = Start(subset(WSEpisodes{WSBestIdx},2))/10000;
% [tstarts, SleepStartCounts] = PETH (S, sleepstart , 360, 600, 10, 0);%these based on sleep min of 20min, wake of 6min
% save([basename '_SpikePETHs'],'SleepStartCounts')


%% Detect UP and Down states
% t = load(fullfile(masterpath,[mastername '_BasicMetaData.mat']));
% same = 0;
% 
% %check if the googeegchannel is the same as was already run in the master
% %file
% if t.goodeegchannel == goodeegchannel
%     same = 1;
% end
% if ~same %... or if it's in the same group
%    for a = goodshanks
%       tc = Par.SpkGrps(a).Channels;
%       if sum(tc == t.goodeegchannel)
%          same = 1;
%          break
%       end
%    end
% end
%     
% if same %if was same or in same spiking group, just grab the already-detected UP/DOWNS
%     disp('Keep Detected UP/DOWN States')
%     copyfile(fullfile(masterpath,[mastername '_UPDOWNIntervals.mat']),[basename '_UPDOWNIntervals.mat'])
%     load([basename '_UPDOWNIntervals.mat'])
% else
    disp('Re-Detect UP/DOWN States')
    try
        cd(masterpath)
        [UPInts, DNInts] = DetectUPAndDOWNInSWS(S,intervals,Par.nChannels,goodeegchannel,mastername);
        cd(basepath)
        WriteEventFileFromIntervalSet (UPInts,[basename,'.UPS.evt'])
        WriteEventFileFromIntervalSet (DNInts,[basename,'.DNS.evt'])
        save ([basename '_UPDOWNIntervals.mat'], 'UPInts', 'DNInts','goodeegchannel')
    catch
        cd(basepath)
        copyfile(fullfile(masterpath,[mastername '_UPDOWNIntervals.mat']),[basename '_UPDOWNIntervals.mat'])
        load([basename '_UPDOWNIntervals.mat'])
    end
% end
% clear t same
    
%% Getting binned spike times for all cells combined & for cell types... 10sec bins

[binnedTrains,h] = SpikingAnalysis_PlotPopulationSpikeRates(basename,S,CellIDs,intervals);
SpikingAnalysis_BinnedTrainsForStateEditor(binnedTrains,basename);

%save fig
if ~exist(fullfile(basepath,'RawSpikeRateFigs'),'dir')
    mkdir(fullfile(basepath,'RawSpikeRateFigs'))
end
cd(fullfile(basepath,'RawSpikeRateFigs'))
name = get(h,'name');
saveas(h,name,'fig')
cd(basepath)

%%
StateRates(basepath,basename);
% SpindleDetectWrapper(basepath,basename);
Spindles_GetSpindleIntervalSpiking(basepath,basename);
UPstates_GetUPstateIntervalSpiking(basepath,basename);
