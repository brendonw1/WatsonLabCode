function MakeConcatDats_OneSession(dirpath)
%assumes you are in or pointed to a directory containing subdirectories for
% various recording files from a single session


% basic session name and and path
if ~exist('dirpath','var')
    dirpath = cd;
end

[~,basename] = fileparts(dirpath);
disp(basename);

%if no xml, put one in the main path.
if ~exist(fullfile(dirpath,[basename,'.xml']),'file')
    d = dir(dirpath);
    for a = 1:length(d)
        if d(a).isdir 
            if length(d(a).name) >= length(basename)
                if strcmp(d(a).name(1:length(basename)-2),basename(1:end-2))
                    if exist(fullfile(dirpath,d(a).name,'amplifier.xml'))
                        disp(['copying xml from subfolder ' fullfile(dirpath,d(a).name)])
                        copyfile(fullfile(dirpath,d(a).name,'amplifier.xml'),fullfile(dirpath,[basename '.xml']))
                        break
                    end
                end
            end
        end
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
    recordingbytes = [];
    recordingnames = {};
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
                        recordingbytes(end+1) = t.bytes;
                        recordingnames{end+1} = d(a).name;
                    end
                end
            end
        end
    end
    if isempty(datpaths)
        disp('No .dats found in subfolders')
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
    if t.bytes ~= sum(recordingbytes)
        error('dat size not right')
        return
    end

    save(fullfile(dirpath,[basename '_DatInfo.mat']),'recordingbytes','recordingnames')

    %% Clean up amplifier.dat files in subdirectories... but wait til here to make sure everything worked first
    t = ['! rm ' dirpath '/*/amplifier.dat'];
    try
        eval(t)
    end
    eval(['! neuroscope ' fullfile(dirpath,[basename,'.dat']) ' &'])
end

    