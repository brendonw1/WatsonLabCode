function PhySpikeExtraction(dirpath)
%assumes you are in or pointed to a directory containing subdirectories for
% various recording files from a single session


% basic session name and and path
if ~exist('dirpath','var')
    dirpath = cd;
end
[~,basename] = fileparts(dirpath);

% find the first xml with name amplifier.xml
if exist(fullfile(dirpath,[basename,'.xml']),'file')
    disp('.xml already exists in session directory, not overwriting, will use this one')
else
    d = dir(dirpath);
    for a = 1:length(d)
        if d(a).isdir
            if exist(fullfile(dirpath,d(a).name,'amplifier.xml'))
                copyfile(fullfile(dirpath,d(a).name,'amplifier.xml'),fullfile(dirpath,[basename,'.xml']));
                break
            end
        end
    end
    if ~exist(fullfile(dirpath,[basename, '.xml']),'file')
        error ('No good xml found')
        return
    end
end

% find all amplifier.dat paths and cat them to basename.dat in the session
% folder
if exist(fullfile(dirpath,[basename,'.dat']),'file')
    disp('.dat already exists in session directory, not merging subdats')
else
    disp('concatenating .dats')
    d = dir(dirpath);
    datpaths = {};
    datbytes = [];
    for a = 1:length(d)
        if d(a).isdir 
            if length(d(a).name) >= length(basename)
                if strcmp(d(a).name(1:length(basename)-2),basename(1:end-2))
                    if exist(fullfile(dirpath,d(a).name,'amplifier.dat'))
                        % for unclear reasons the command below does not
                        % work with full paths as written... the line below
                        % that is the alternative but requires one to be in
                        % the right supradirectory
%                         datpaths{end+1} = fullfile(dirpath,d(a).name,'amplifier.dat');
                        datpaths{end+1} = fullfile(d(a).name,'amplifier.dat');
                        t = dir(fullfile(dirpath,d(a).name,'amplifier.dat'));
                        datbytes(end+1) = t.bytes;
                    end
                end
            end
        end
    end
    if isempty(datpaths)
        error('No .dats found in subfolders')
        return
    end
    cs = strjoin(datpaths);
    catstring = ['! cat ', cs, ' > ',fullfile(dirpath,[basename,'.dat'])];
    
    % for some reason have to cd to supradirectory 
    origdir = cd;
    cd (dirpath)
    eval([catstring])
    cd (origdir)
    t = dir(fullfile(dirpath,[basename,'.dat']));
    if t.bytes ~= sum(datbytes)
        error('dat size not right')
        return
    end
    
    eval(['! neuroscope ' fullfile(dirpath,[basename,'.dat']) ' &'])
end

%% make probe file 
if exist(fullfile(dirpath,[basename,'.prb']),'file')
    disp('.prb already exists in sessino directory, not creating .prb from .xml')
else    
    makeProbeMapPhy(fullfile(dirpath,basename))
end

%% make params file
if exist(fullfile(dirpath,[basename,'.prm']),'file')
    disp('.prm already exists in session directory, not remaking it')
else
    s = textread('/mnt/packrat/userdirs/brendon/ProcessingFiles/Template.prm','%s','delimiter','\n');
    s{1} = ['filebase = ''' basename ''''];
    par = LoadPar(fullfile(dirpath,[basename,'.xml']));
    s{9} = ['n_channels= ' num2str(par.nChannels) ','];
    
    fid = fopen(fullfile(dirpath,[basename '.prm']),'wt');
    for a = 1:length(s)
        fprintf(fid,[s{a},'\n']);
    end
    fclose(fid);
end

%% Start spike detection via phy
eval(['! source activate phy && phy detect --overwrite ' fullfile(dirpath,[basename '.prm'])])

%% Backup detected data, in case of later errors
! mkdir AfterDetect
! rsync *.kwik AfterDetect/
! rsync *.kwx AfterDetect/
! rsync *.prm AfterDetect/

%% Redistribute spikes across shanks
KwikDistribute(fullfile(dirpath,basename))

%% Make .prm for each shank
s = textread(fullfile(dirpath,[basename '.prm']),'%s','delimiter','\n');
par = LoadPar(fullfile(dirpath,[basename '.xml']));
nshanks = size(par.SpkGrps,2);
for a = 1:nshanks
    s{1} = ['filebase = ''' basename '_sh' num2str(a) ''''];
    fid = fopen(fullfile(dirpath,[basename '_sh' num2str(a) '.prm']),'wt');
    for a = 1:length(s)
        fprintf(fid,[s{a},'\n']);
    end
    fclose(fid);
end

%% Backup distributed data, in case of later errors
! mkdir AfterDistribute
! rsync *.kwik AfterDistribute/
! rsync *.kwx AfterDistribute/
! rsync *.prm AfterDistribute/

%% Clean up amplifier.dat files in subdirectories... but wait til here to make sure everything worked first
t = ['! rm ' dirpath '*/amplifier.dat'];
try
    eval(t)
end

%% Run clustering jobs 
% for a = 1:nshanks
%     eval(['! source activate phy && phy cluster-auto ' fullfile(dirpath,[basename '_sh' num2str(a) '.prm']) ' > ' fullfile(dirpath,['clusterprocess_sh' num2str(a) '.out']) ' & '])
% end


    
    