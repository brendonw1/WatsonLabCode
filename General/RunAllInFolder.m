function RunAllInFolder(textneeded,dirname)
%run all functions/scripts in a folder

if ~exist('dirname','var')
    dirname  = cd;
end
if ~exist('textneeded','var')
    textneeded = '*.m';
end

list    = dir(fullfile(dirname, textneeded));
nFile   = length(list);
success = false(1, nFile);
for k = 1:nFile
  file = list(k).name;
  try
    run(fullfile(dirname, file));
    success(k) = true;
  catch
    fprintf('failed: %s\n', file);
  end
end