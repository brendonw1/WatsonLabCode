function actonsubfolders(dirpath,func)
%given a pathway to a directory and the name of a function, this will allow
%one to execute a function string ('func') on each subfolder inside that
%directory.  The function given must take a pathname as an input

list=listallsubdirs(dirpath);%get all subfolders
for a=1:length(list);%for each subfolder pathways
    eval(func);%execute function "func" on the pathname
end