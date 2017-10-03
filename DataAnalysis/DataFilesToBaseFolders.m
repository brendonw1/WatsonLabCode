function DataFilesToBaseFolders

[names,dirs] = GetDefaultDataset;

d = dir('*.mat');

% list = [1:13 23:27];
% list2 = 14:22;
for a = 1:length(d)
   underscores = strfind(d(a).name,'_');
   lu = length(underscores);
   basename = d(a).name(1:underscores(lu)-1);
   
   [~,idx] = ismember(basename,names);
   basepath = dirs{idx};
              
   copyfile(d(a).name,basepath)
%    copyfile(d(a).name,fullfile('/mnt/brendon4/Dropbox/Temp', d(a).name))
end