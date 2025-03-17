function BB17181920DatConcatenation(EphysDirPath,OutputDirPath,DatName)
% BB17181920DatConcatenation(EphysDirPath,OutputDirPath,DatName)
% Collects all recordings in Intan-generated subfolders of EphysDirPath, 
% then makes new .dats for each spike group in the files.  Then it
% concatenates all the spike-group dats over time (alphabetical by folder
% name, which should be chronological).
% 
% INPUTS
% EphysDirPath - where the initial Intan-generated data is (default =
% current directory)
% 
% OutputDirPath - Path where newly generated concatenated dats will be
% placed (default = EphysDirName_ConcatenatedGroupDats)
% 
% DatName - default .dat name in original intan folders (Default =
% amplifier.dat)
% 
% Important Notes:
% April 2023: currently requires one .xml per recording folder (ie
% amplifier.xml next to amplifier.dat).  Feel free to change that if
% desired.
% Assumes all recordings have the same groups in them.
%
% Brendon Watson 2023

%% Establish variables 
if ~exist('EphysDirPath','var')
    EphysDirPath = cd;
end

if ~exist('OutputDirPath','var')%set default output location parallel to EphysDirPath
    [~,EphysDirName] = fileparts(EphysDirPath);
    %slashes = strfind(EphysDirPath,'/'); %Linux version
    slashes = strfind(EphysDirPath,'\');
    output = EphysDirPath(1:slashes(end)-1);%cut after last slash to specifiy up one folder
    OutputDirPath = fullfile(output,[EphysDirName, '_ConcatenatedGroupDats']);
end

if ~exist('DatName','var')
    DatName = 'amplifier.dat';
end

if ~exist(OutputDirPath,'dir')
    mkdir(OutputDirPath)
end


%% Will act on all sub-folders in EphysDirPath that have a file called DatName
sds =listallsubdirs(EphysDirPath);
for sidx = length(sds):-1:1 %loop: exclude directories without DatName inside
    filecontents = dir(sds{sidx});
    foundfiles = zeros(1,length(filecontents));%reset each loop
    for fidx = 1:length(filecontents)
        foundfiles(fidx) = strcmp(filecontents(fidx).name,DatName);
    end
    if sum(foundfiles)==0
        sds(sidx) = [];
    end
end

%% Write one .dat for each tetrode/group
for sidx = 1:length(sds)
    markername = fullfile(sds{sidx},'GroupsAsDatsDone.marker');
    if exist(markername,'file')
        disp([sds{sidx} ' already has groups written as dats, skipping'])
    else
        RewriteGroupsAsDats(fullfile(sds{sidx},'amplifier.dat'), 'X:\Ephys\test files exp 4\amplifier.xml')
        disp('done')
    end
end

%% Concatenate dats from each tetrode/group
%Gather numbers of dats/groups
%make a loop indexed over those numbers
%assume all folders have recordings with same groups (xmls).  Can fix later if that's a prob
GroupNameStrings = {};
firstdirpath = sds{1};
d = getdir(firstdirpath);
for didx = 1:length(d)
    stringlocation = strfind(d(didx).name,'amplifier_');
    if stringlocation == 1 & strcmp('.dat',d(didx).name(end-3:end))
        GroupNameStrings{end+1} = d(didx).name;
    end
end
        
%For each datname found in the first folder, concatenate all files w that name from across all folders        
for gidx = 1:length(GroupNameStrings)
%     tdatname = [DatName(1:end-4) '_1.dat'];
    tdatname = GroupNameStrings{gidx};
    
    datpaths = {};
    for sidx = 1:length(sds)
        datpaths{sidx} = fullfile(sds{1},tdatname);
    end
    OutputDatName = fullfile(OutputDirPath, [tdatname(1:end-4) '_Concatenated.dat']);

    ConcatenateDatsByList(datpaths,OutputDatName)
end