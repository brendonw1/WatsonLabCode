function MakeEEGs_OneSession(dirpath)
%assumes you are in or pointed to a subdirectory for a single session

warning('The function MakeEEGs_OneSession is depricated, use MakeLFPs_SessionsInDirectory instead')

MakeLFPs_OneSession(dirpath)
