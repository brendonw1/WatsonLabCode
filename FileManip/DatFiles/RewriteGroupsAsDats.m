function RewriteGroupsAsDats(fullpath, xmlname, outputnamespecifiers)

if ~exist('fullpath','var')
    basepath = cd;
    disp('Assuming current directory is basepath');
    basename = bz_BasenameFromBasepath(basepath);
else
    [basepath, basename]= fileparts(fullpath);
end

if ~exist('xmlname','var')
    % List all .xml files in the current directory
    xmlFiles = dir(fullfile(basepath, '*.xml')); 
    
    % Ensure there is exactly one XML file
    if numel(xmlFiles) == 1
        xmlname = fullfile(basepath, xmlFiles(1).name);  % Get the full path to the XML file
        disp(['Found XML file: ', xmlname]);  % Display the XML file path
    else
        error('There must be exactly one XML file in the current directory. Found %d.', numel(xmlFiles));
    end
end
datname = fullfile(basepath,[basename '.dat']);
markername = fullfile(basepath,'GroupsAsDatsDone.marker');


%% Get channel groups and other info from xml
par = LoadParameters(xmlname);
if par.spikeGroups.nGroups == 0
    for a = 1:length(par.AnatGrps)
        groups{a} = par.AnatGrps(a).Channels;
    end
else
    groups = par.spikeGroups.groups;
end
ngroups = length(groups);

numchans = par.nChannels;
bitspersamp = par.nBits;
bytespersamp = bitspersamp/8; % =2

%% Output dat names
if exist('outputnamespecifiers','var')
    for a = 1:ngroups
        outputdatnames{a} = fullfile(basepath,[basename outputnamespecifiers{a} '.dat']);
    end    
else
    for a = 1:ngroups
        outputdatnames{a} = fullfile(basepath,[basename '_' num2str(a) '.dat']);
    end
end

%% Open dat file
fidr = fopen(datname,'r');
for a = 1:ngroups
    fidw{a} = fopen(outputdatnames{a},'w+');
end

fseek(fidr,0,'eof');
filebytes = ftell(fidr);%gives 8bit bytes
numsamps = filebytes/(numchans*bytespersamp);%convert to 16bit chunks;

if ~mod(filebytes,(numchans*bytespersamp))==0 %if a non-integer number of samples
    str = input('Non-integer number of samples in original file.  Conitnue? y/n: ', 's');
    if ~strcmp('y',lower(str(1)))
        fclose(fidr);
        for a = 1:ngroups
            fclose(fidw{a});
        end        
        return
    end
end

numsamps = floor(numsamps);%account for possible non-integer numbers of samples
fseek(fidr,0,'bof');
for a = 1:numsamps
    if a == 1 || mod(a,100000) == 0
        disp(['Writing sample ' num2str(a) ' out of ' num2str(numsamps) ' to all output files simultaneously'])
    end
    rawsamps = fread(fidr,numchans,'int16');%read numchans number of 16bit chunks - one time sample
    for b = 1:ngroups
        groupsamps = rawsamps(groups{b}+1); %+1 to compensate for 0 count basis in .xml
        fwrite(fidw{b},groupsamps,'int16');
    end
end


fclose(fidr);
for a = 1:ngroups
    fclose(fidw{a});
end

%% Leave marker that job was already done
eval(['!touch ' markername])
