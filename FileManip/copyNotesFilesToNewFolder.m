function copyNotesFilesToNewFolder
% designed to take .txt notes from raw data subfolders and put them into
% folders with dat files for each day
%
% user indicates directory subdirectories containing files of interest
% (.txt files with proper starts) and those will be copied to another area
% in appropriate subfolders


sourcedirpath = uigetdir('/brendon2','Indicate superdirectory which contains files of interest'); %get name of folder containing all folders where photos are
destdirpath = uigetdir ('/brendon2', 'Inidicate superdirectory containing appropriately named directories for files to move'); %get name of destination folder 

sourcelist = listallsubdirfiles(sourcedirpath);%get all files in all subdirectories of the specified source area

for a = 1:length(sourcelist);
    [pathstr, name, ext] = fileparts(sourcelist{a});
    if strcmp(lower(ext),'.txt')
        if strcmp(name(1:4),'2012')
            x=1;
            destname = name(1:10);
            destpath = fullfile(destdirpath,destname);
            copyfile(sourcelist{a},destpath);
        end
    end
end
