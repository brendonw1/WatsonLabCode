function ProcessedFilesToAnalysisDrive(sourcedir,destdir)
% Moves data that has been clustered to an analysis drive.  Excludes .dats
% except analogin and digitalin, or something named xxx_analogin.dat or 
% xxx_digitalin.dat.  Also excludes hidden folders (aiming at
% excluding .spikedetekt and .klustakwik folders in each shank folder).
%
% Inputs: 
% sourcedir - path to source directory, ie /balrog_zpool/Analysis/c3po_160401
% destdir - path of directory to be copied to, ie /zpool1/c3po/

if ~exist('destdir','var')
    destdir = fullfile('/','zpool1',animalname);
end

if ~exist('destdir','var')
    mkdir(destdir)
end

%rsync uses includes and excludes based on which one it reaches first in
%evaluating the string... so basically it's good to usually put includes
%first if they might conflict with excludes (ie both involve .dat)
rstrbase = '! rsync -avr --include="analogin.dat" --include="*analogin.dat" --include="digitalin.dat" --include="*digitalin.dat" --exclude=".*/" --exclude="*.dat" ';
rstr = [rstrbase sourcedir ' ' destdir];

eval(rstr)
    
        