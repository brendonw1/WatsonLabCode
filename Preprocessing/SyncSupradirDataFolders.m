function SyncSupradirDataFolders(sourcedir,destdir)
% Iteratively calls rsync to synchronize all recordings in a directory to
% a target directory
% Brendon Watson 2016

if ~exist('sourcedir','var')
    sourcedir = cd;
end

[~,animalname] = fileparts(sourcedir);
if ~exist('destdir','var')
    destdir = [fullfile('/balrog_zpool',animalname)];
end
if ~exist('destdir','dir')
    eval(['! mkdir ' destdir])
end

sd = getdir(sourcedir);
dd = getdir(destdir);

disp(['SYNCING ' sourcedir ' TO ' destdir])
for a = 1:length(sd)
    if sd(a).isdir
        if strcmp(sd(a).name(1:length(animalname)),animalname)%if it starts with ~
            existsinsubdir = 0;
            tsource = fullfile(sourcedir,sd(a).name);
            tdest = fullfile(destdir,sd(a).name);
            
            if exist(tdest,'dir')
                existsinsubdir = 1;
            else
                for b = 1:length(dd)%testing to see if it's in a subdirectory like ReadyToCluster for instance... if so don't copy it again
                    if(dd(b).isdir)
                        if exist(fullfile(destdir,dd(b).name,sd(a).name),'dir')
                            existsinsubdir = 1;
                        else
                            existsinsubdir = 0;
                        end
                    end
                end
            end
            
            if existsinsubdir
                disp([tdest ' already exists, not copying that recording'])
            elseif ~existsinsubdir%if it isn't already in a subdir
                if ~exist(tdest,'dir')
                    eval(['mkdir ' tdest])
                end
                rsyncstr = ['! rsync -a ' tsource '/ ' tdest];
                disp(rsyncstr)
                eval(rsyncstr)
                disp(' ')
            end
        end
    end
end