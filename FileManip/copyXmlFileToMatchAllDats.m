function copyXmlFileToMatchAllDats
% Designed so an xml file which is chosen may be copied to make one with a matching
% name for each dat file in the subdirectories of a chosen folder.

[sourceFileName,sourcePathName,sourceFilterIndex] = uigetfile('.xml','Indicate xml to copy');%get from user the xml to be copied as a template
sourcepath = fullfile(sourcePathName,sourceFileName); 

destdirpath = uigetdir (cd, 'Indicate superdirectory containing all dats to make .xmls for'); 
overwrite = questdlg('overwrite existing .xml files in this directory','Overwrite?','No');

destlist = listallsubdirfiles(destdirpath);%get all files in all subdirectories of the specified destination area


for a = 1:length(destlist);
    [pathstr, name, ext] = fileparts(destlist{a});
    if ~strcmp(name,sourceFileName(1:end-4)) %if it's not the file we're already dealing with
        if strcmp(lower(ext),'.dat') %see if it's a dat... if so...
            copyxml = 1; %set a default status to track with
            potentialxmlname = fullfile(pathstr,[name,'.xml']); %build a filename to see if there is already an xml with the name-to-be
            for b = 1:length(destlist) %go thru and see if there is this file already or not
                if strcmp(potentialxmlname,destlist{b});%if it's there
                    if ~overwrite %and if we're not supposed to overwrite pre-existing xmls
                        copyxml = 0;%set our tracker variable to NOT copy
                    end
                end
                if copyxml%if our tracker tells us to copy an xml to match the current dat
                    copyfile (sourcepath, potentialxmlname);%copy it and name it correctly.
                end
            end
        end
    end
end

