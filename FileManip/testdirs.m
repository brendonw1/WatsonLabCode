function dirs=testdirs(d)%Tells which files in a list inside of a directory are themselves%directories... output, dirs is 1's and 0's, 1 if a name refers to a%directory, 0 if name refers to a simple file.  Input d is from the dir%function.for a=1:length(d);%for each name in the given folder    dirs(a)=d(a).isdir;%record whether or not it is a directoryend