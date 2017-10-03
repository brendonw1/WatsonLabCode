function KetamineDropboxToDrives
%rsyncs Dropbox/Data/KetamineDataset folders to ketamine file basepath
%folders
% B Watson October 2016


folderpath = fullfile(getdropbox,'Data','KetamineDataset');

d = getdir(folderpath);
DrNames = {};
DrDirs = {};
for a = 1:length(d);
    if d(a).isdir
        DrNames{end+1} = d(a).name;
        DrDirs{end+1} = fullfile(folderpath,d(a).name);
    end
end

[KeNames,KeDirs]=GetKetamineDataset;


for a = 1:length(DrNames);%for every dropbox directory
  kidx = strcmp(DrNames{a},KeNames);
  if ~isempty(kidx)
      syncstr = ['!rsync -a ' DrDirs{a} ' ' KeDirs{kidx}];
      disp(syncstr);
      eval(syncstr);
  end
end