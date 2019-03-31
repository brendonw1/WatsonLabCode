function concatenateFiles(outfile,varargin)

if iscell(varargin{1})
    varargin = varargin{1};
end

files = [];
for a = 1:length(varargin)
    files = [files,varargin{a},' '];
end
files = files(1:end-1);

eval(['!cat ',files,' > ',outfile])