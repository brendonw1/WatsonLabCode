%% USE: Note, if "load" command is at the end of a section then executing that load can subsitute for the entire section (if the data has already been stored to disk)

basename = 'Dino_061614';
basepath = '/mnt/brendon6/Dino/Dino_061614';
dropbasepath = fullfile(getdropbox,'Data','KetamineDataset',basename);
if exist(basepath,'dir')
    cd(basepath)
else
    cd(dropbasepath)
end

Par = LoadPar([basename '.xml']);
voltsperunit = VoltsPerUnit(basename,basepath);
% presleepstartstop = [0 13128];%rough manual entry, in seconds
% postsleepstartstop = [15606 Inf];%rough manual entry, in seconds

% To Do
%>> Do StateEditor(basename)
%>> Make a _SpikeGroupAnatomy.csv using gdrive
goodshanks = [1:12];%% Can code this based on spkgroupnums = matchSpkGroupsToAnatGroups(par)
% RecordingFilesForSleep = [1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];%Booleans for each component dat of merged recording

%can be automatically imported from SleepScoreLFP.mat... 
% goodeegchannel = 46; %base 1
if exist(fullfile(basepath,[basename,'_StateScoreMetrics.mat']),'file')
    Thetachannel = load(fullfile(basepath,[basename,'_StateScoreMetrics.mat']),'THchannum'); %Good # of units
    goodeegchannel = load(fullfile(basepath,[basename,'_StateScoreMetrics.mat']),'SWchannum');
elseif exist(fullfile(basepath,[basename,'.eegstates.mat']),'file')
    t  =load(fullfile(basepath,[basename,'.eegstates.mat']),'StateInfo'); %Good # of units
    goodeegchannel = t.StateInfo.Chs(1);
    Thetachannel = t.StateInfo.Chs(2);
else
    goodeegchannel = [];
    Thetachannel = [];
end
clear t


UPstatechannel = goodeegchannel; %Good # of units
Spindlechannel = goodeegchannel; %Superficial cortical is best

Ripplechannel = Thetachannel;

% These are replaced by DatInfo.mat
% RecordingFileIntervals = FileStartStopsToIntervals(basename);
% FileStartStopsToStateEditorEvent(basename);

SaveBasicMetaData