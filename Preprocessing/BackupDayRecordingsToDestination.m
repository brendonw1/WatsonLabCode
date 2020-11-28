function BackupDayRecordingsToDestination(datebasename,destdir)
% finds recordings in any recording computer with foldernames matching a
% particular date ('datebasename', such as 'c3po_160202'), and sync's those to single backup
% folder at a specified target destination on the path ('destdir')
% 
% assumes many things including names of servers on the path, assumes a
% subfolder with a name of the animal will exist based on the name before 
% the _ in the datebasename
% Assumed organization:
% /largerfolder/animal/animal_date/subfolders/
% 
% Uses rsync as engine because it is so nice at paying attention to what is
% new and/or in need of update.
% Brendon Watson 2016

%% hardcoded params
sourcepathlist = {'/mnt/Amplipex4D/BW/';... %available recording sites/file source sites
    '/mnt/Amplipex4F/BW/';...
    '/mnt/Amplipex7D/BW/';...
    '/mnt/Amplipex7G/BW/';...
    '/mnt/SurgeryE/BW/'};


%% allow for a list of inputs recording names, or a single
if ~iscellstr(datebasename)
    t = cell(1);
    t{1} = datebasename;
    datebasename = t;
end

for n = 1:length(datebasename)
    tdatebasename = datebasename{n};

%% conditioning inputs
    underscores = strfind(tdatebasename,'_');
    animalname = tdatebasename(1:underscores(1)-1);

    % handle no-input case
    if ~exist('destdir','var')
        tdestdir = fullfile('/balrog_zpool',animalname,tdatebasename);
    else % if input, make sure it's taken care of
        % if destdir lowest level does not have a name matching the source, 
        % make a subdirectory under it matching source recording name
        [~,t] = fileparts(destdir);
        if ~strcmp(t,tdatebasename)
            tdestdir = fullfile(destdir,tdatebasename);
        end
    end

    % make destdir if it does not exist
    if ~exist(tdestdir,'dir')
        mkdir(tdestdir);
    end

%% Pull from all sources, push to specified source
    for a = 1:length(sourcepathlist);

        tpath = fullfile(sourcepathlist{a},animalname,tdatebasename);
        if exist(tpath,'dir')
            % sync all top-level files
            rsyncstr = ['! rsync -ptgo ' tpath '/ ' tdestdir];

            d = getdir(tpath);
            % if folders exist at dest, don't sync... on purpose so that
            % changes and deletions at destinaton aren't overwritten
            for b = 1:length(d);
                if d(b).isdir
                    tdpath = fullfile(tdestdir,d(b).name);
                    if ~exist(tdpath,'dir')%only if corresonding folder doesn't already exist
                        ttpath = fullfile(tpath,d(b).name);
                        rsyncstr = ['! rsync -av ' ttpath '/ ' tdpath];
                        disp(rsyncstr)
                        eval(rsyncstr)
                        disp(' ')
                    end
                end
            end
        end
    end
        
end

try
%     MakeConcatDats_OneSession(tdestdir)
catch
%     disp('concatenation of dats did not happen')
end