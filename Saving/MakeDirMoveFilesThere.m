function MakeDirMoveFilesThere(dirpath,varargin)
%varargin should contain a list of filenames to move, they will be moved to
%the new dirpath... or can contain a cellstr of names.

slashes = findstr(dirpath,'/');%account for old use assuming that only directory name is input is a new directory name in current path
if isempty(slashes)
    basepath = cd;
    dirpath = fullfile(basepath,dirpath);
end

if ~exist(dirpath,'dir')
    mkdir(dirpath)
end

if iscellstr(varargin{1})
    varargin = varargin{1};
end

for a = 1:length(varargin)
    movefile(varargin{a},fullfile(dirpath,varargin{a}))
end

