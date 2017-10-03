function [paths,names] = GatherSessionPathsAndNames

paths = {};
names = {};

[basepath,basename,dummy] = fileparts(cd);
basepath = fullfile(basepath,basename);
clear dummy

t = load(fullfile(basepath,[basename '_BasicMetaData.mat']));
if isfield(t,'masterpath');
    masterpath = t.masterpath;
    mastername = t.mastername;
else
    masterpath = basepath;
    mastername = basename;
end

d = dir(fullfile(masterpath,[mastername '*']));
for a = length(d):-1:1
    if ~d(a).isdir
        d(a) = [];
    else
        if strcmp(mastername,d(a).name)
            d(a) = [];
        end
    end
end

for a = 1:length(d);
   t = load(fullfile(masterpath,d(a).name,[d(a).name '_BasicMetaData.mat']));
   paths{end+1} = t.basepath;
   names{end+1} = t.basename;
end