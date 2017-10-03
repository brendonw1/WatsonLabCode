function NamesCell = GetResFetCluSpkNames(directory)


NamesCell = {};

d = dir(fullfile(cd,'*.xml'));
for a = 1:length(d);
    NamesCell{end+1} = d(a).name;
end

d = dir(fullfile(cd,'*.res*'));
for a = 1:length(d);
    NamesCell{end+1} = d(a).name;
end

d = dir(fullfile(cd,'*.spk*'));
for a = 1:length(d);
    NamesCell{end+1} = d(a).name;
end

d = dir(fullfile(cd,'*.fet*'));
for a = 1:length(d);
    NamesCell{end+1} = d(a).name;
end

d = dir(fullfile(cd,'*.clu*'));
for a = 1:length(d);
    NamesCell{end+1} = d(a).name;
end