function [dirs,names] = DatasetDropboxSleep

datadir = fullfile(getdropbox,'Data','Sleep');
t = listallsubdirs(datadir);

dirs = {};
names = {};
for a = 1:length(t);
    d = dir(fullfile(t{a},'*_BasicMetaData.mat'));
    if ~isempty(d)
        dirs{end+1} = t{a};
        [~,bname,~] = fileparts(dirs{end});
        bname = load(fullfile(dirs{end},[bname,'_BasicMetaData.mat']),'basename');
        names{end+1} = bname.basename;
    end
end

