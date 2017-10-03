function MakeDirSaveVarThere(dirpath,savedata,savedataname)
% saves a variable in the specified path (makes the path if it isn't there
% yet).  Default name is the name of the input varible.
% Brendon Watson 2015

if ~exist(dirpath,'dir')
    mkdir(dirpath)
end

if ~exist('savedataname','var')
    savedataname = inputname(2);
end

eval([savedataname '= savedata;'])

save(fullfile(dirpath,savedataname),savedataname);