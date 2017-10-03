function MakeDirSaveFigsThereAs(dirpath,fighandles,filetype)

if ~exist('filetype','var')
    filetype = 'fig';
end
if strmatch(filetype(1),'.')
    filetype = filetype(2:end);
end

slashes = findstr(dirpath,'/');%account for old use assuming that only directory name is input is a new directory name in current path
if isempty(slashes)
    basepath = cd;
    dirpath = fullfile(basepath,dirpath);
end

if ~exist(dirpath,'dir')
    mkdir(dirpath)
end

for a = 1:length(fighandles)
    name = get(fighandles(a),'name');
    if isempty(name)
        name = ['Figure' num2str(a)];
    end
    name = [name '.' filetype];
    switch filetype
        case 'eps'
            epswrite(fighandles(a),fullfile(dirpath,name))
        otherwise
            saveas(fighandles(a),fullfile(dirpath,name),filetype)
    end
end

