function MakeEEGs_SessionsInDirectory(upperpath)
%assumes you are in or pointed to a directory containing subdirectories for
% various recording files from a single session

warning('The function MakeEEGs_SessionsInDirectory is depricated, use MakeLFPs_SessionsInDirectory instead')

MakeLFPs_SessionsInDirectory(upperpath)

    
    