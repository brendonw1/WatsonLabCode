function DataFilesToCorrectFolders

d = dir('*.mat');

[~,cname]=system('hostname');
if strcmp(cname(1:3),'MAC')%if on mac/laptop
    destsupradir = '/path/to/your/data/folder';
else %ie if at lab
    destsupradir = '/mnt/data1/BWData/';
end

for a = 1:length(d)
   underscores = strfind(d(a).name,'_');
   basename = d(a).name(1:underscores(2)-1);
   destpath = fullfile(destsupradir,basename);
   copyfile(d(a).name,destpath)
end