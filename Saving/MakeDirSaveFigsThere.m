function MakeDirSaveFigsThere(dirpath,fighandles,filetype)

if ~exist('filetype','var')
    MakeDirSaveFigsThereAs(dirpath,fighandles)
else
    MakeDirSaveFigsThereAs(dirpath,fighandles,filetype)
end