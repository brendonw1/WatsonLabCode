%% USE: Note, if "load" command is at the end of a section then executing that load can subsitute for the entire section (if the data has already been stored to disk)

%% USER ENTRY:
basename = ;
basepath = ;
masterpath = ; 
mastername = ; 

goodshanks = [];%based on numbering from par file
goodeegchannel = ;%eeg channel, base 1
% RecordingFilesForSleep = [];

% AUTO RUN
cd(masterpath)
Par = LoadPar(fullfile(masterpath,[mastername, '.xml']));

RecordingFileIntervals = FileStartStopsToIntervals(mastername);
FileStartStopsToStateEditorEvent(mastername);

cd(basepath)

save([basename '_BasicMetaData.mat']);
% load([basename '_BasicMetaData.mat']);