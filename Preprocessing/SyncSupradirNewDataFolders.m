function SyncSupradirNewDataFolders(sourcedir,destdir)
%only sync's if recording folders don't exist at destination yet


if ~exist('sourcedir','var')
    sourcedir = cd;
end
if ~exist('destdir','var')
    destdir = [fullfile('/mnt/packmouse/userdirs/brendon',animalname),'Raw'];
end

[~,animalname] = fileparts(sourcedir);
sd = getdir(sourcedir);
dd = getdir(destdir);

disp(['SYNCING ' sourcedir ' TO ' destdir])
for a = 1:length(sd)
    if sd(a).isdir
        if strcmp(sd(a).name(1:length(animalname)),animalname)
            tsource = fullfile(sourcedir,sd(a).name);
            tdest = fullfile(destdir,sd(a).name);
            if ~exist(tdest,'dir')
                eval(['mkdir ' tsource])
                rsyncstr = ['! rsync -a ' tsource '/ ' tdest];
                disp(rsyncstr)
                eval(rsyncstr)
                disp(' ')
            end
        end
    end
end