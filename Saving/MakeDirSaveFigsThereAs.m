function MakeDirSaveFigsThereAs(dirpath,fighandles,filetype,filename)

if ~exist('dirpath','var')
    dirpath = cd;
end
if ~exist('fighandles','var')
    fighandles = gcf;
end
if ~exist('filetype','var')
    filetype = 'fig';
end
    if strmatch(filetype(1),'.')
        filetype = filetype(2:end);
    end
if ~exist('','var')
    filename_input = 0;
else
    filename_input = 1;
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
    if filename_input == 0;
        filename = get(fighandles(a),'name');
        if isempty(filename)
            filename = ['Figure' num2str(a)];
        end
        filename = [filename '.' filetype];
    else %already have filename... for now forgetting case of multiple figs input
        if ~strcmp(filename(end-(length(filetype)-1):end),filetype)
            filename = [filename '.' filetype];
        end
    end
        
%     switch filetype
%         case 'eps'
%             epswrite(fighandles(a),fullfile(dirpath,filename))
%         otherwise
            saveas(fighandles(a),fullfile(dirpath,filename),filetype)
%     end
end

