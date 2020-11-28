function savefigsasindir(dirpath,fighandles,filetype)
% just because this name is more intuitive to look up than
% MakeDirSaveFigsThereAs

if ~exist('filetype','var')
    filetype = 'fig';
end

MakeDirSaveFigsThereAs(dirpath,fighandles,filetype)
