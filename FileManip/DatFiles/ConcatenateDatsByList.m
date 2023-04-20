function ConcatenateDatsByList(datpaths, outputdatpath)
% bz_ConcatenateDats - Concatenate raw .dat files found at a specfied set
% of paths
% 
% ALGORITHM OUTLINE: Takes in a cell array of paths to .dat files to be 
% concatenated.  The concatenation happens via system commands 
% ("cat" command for linux/mac, "copy" command if windows/pc).  Uses
% different assumptions to find and recognize relevant .dats depending on
% the acquisition system.  
% 
% REQUIREMENTS: Will concatenate 
% Works with acquisition systems: Intan  - 
%   1) intan:  
%       - amplifier.dat - int16 file with usually neural data from the
%           headstage
%
%  USAGE
%
%    bz_ConcatenateDats(basepath,deleteoriginaldatsbool,sortFiles)
%
%  INPUTS
%
%   datpaths - Cell array containing entries with strings specifying paths 
%       of .dat files to be concatenated.  Concatenation will occur in the 
%       order the files are specified in this array. 
%   outputpath - path of the new file to be written. 
%
%  OUTPUT
%     Writes a file.  No output variable
%
%
% Copyright (C) 2023 by Brendon Watson


%% Handling inputs
% basic session name and and path
if ~exist('datpaths','var')
    error('Datpaths required')
end
if ~exist('outputdatpath','var')
    outputdatpath = fullfile(cd,'ConcatenatedOutput.dat');
end

%% Get file sizes of all dats to be concatenated (for later check based on resultant file size)
for didx = 1:length(datpaths);
    d = dir(datpaths{didx});
    origdatbytes(didx) = d.bytes;
end

%% Concatenate
if isunix
    cs = strjoin(datpaths);
    catstring = ['! cat ', cs, ' > ',outputdatpath];
elseif ispc  %looking for string like: copy /b file1+file2+file3 targetfile
    if length(datpaths)>1
        for didx = 1:length(datpaths)-1
            datpathsplus{didx} = [datpaths{didx} '+'];
        end
        %Last file string shouldn't end with '+'
        datpathsplus{length(datpaths)} = [datpaths{length(datpaths)}];
    else
        datpathsplus = datpaths;
    end
    cs = strjoin(datpathsplus);
    catstring = ['! copy /b ', cs, ' ',outputdatpath];
end

% action
disp('Concatenating Amplifier Dats... be patient')
eval(catstring)%execute concatention
    
%% Check that size of resultant .dat is equal to the sum of the components
t = dir(outputdatpath);
if t.bytes ~= sum(origdatbytes)
    error('New .dat size not right.  Exiting')
    return
else
    sizecheck.amplifier = true;
    disp('Primary .dats concatenated and size checked')
end


