function MakeDirSaveThere(dirpath,savefiledir,savedata)

if ~exist(dirpath,'dir')
    mkdir(dirpath)
end

savedataname = inputname(3);
eval([savedataname '= savedata;'])

save(fullfile(dirpath,savefiledir),savedataname);