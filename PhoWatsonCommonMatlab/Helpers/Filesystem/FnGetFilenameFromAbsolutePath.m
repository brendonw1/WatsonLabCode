function [filename, file_basename, file_extension] = FnGetFilenameFromAbsolutePath(absolutePath)
%FnGetFilenameFromAbsolutePath Takes an absolute path and returns the filename
%   Detailed explanation goes here
[parentPath, file_basename, file_extension] = fileparts(absolutePath);
filename = [file_basename, file_extension];
end

