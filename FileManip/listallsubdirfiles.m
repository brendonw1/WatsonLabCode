function list=listallsubdirfiles(dirpath)unchecked{1}=dirpath;list={};while(~isempty(unchecked));%as long as there is a directory to be checked...    tempfiles = listfiles(unchecked{1}); %get the files in that directory...    list = cat(2,list,tempfiles);%tack them on the list        tempdirs=listdirs(unchecked{1});%now list the directories in that directory    if ~isempty(tempdirs);%if some directories in this directory        unchecked(end+1:end+length(tempdirs))=tempdirs;%tack dir names on the end of the list of unchecked folders    end        unchecked(1)=[];  %now clear the one we just checked off the listend