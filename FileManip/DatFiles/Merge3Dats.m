function MergeDats(datpaths,outdatpath,datNChans)
% merge arbitrary number of dat files sample by sample.  Assumes they are
% all int16.  
% datpaths: character array of paths (relative or global) to dat files to
% merge
% outdatpath: string specifying output file to write merged data to.
% datNChans: vector of number of channels in each files specified in
% datpaths.
%
% Brendon Watson 2016

%% input checks
if length(datpaths) ~= length(datNChans)
    error('mismatch between number of paths and number of channel counts specified')
    return
end
n = length(datpaths);

%% basic params
bitspersamp = 16;
bytespersamp = bitspersamp/8; % =2

%% Open/Initialize files of interest
for a = 1:n
    fidr(a) = fopen(datpaths{a},'r');
end
fidw = fopen(outdatpath,'w+');

%% Check files have same number of samples before proceeding
for a = 1:n
    fseek(fidr(a),0,'eof');
    filebytes(a) = ftell(fidr(a));%gives 8bit bytes
    filebytes(a) = filebytes(a)/bytespersamp;%convert to 16bit bytes;
    numsamps(a) = filebytes(a)/datNChans(a);
end

if sum(abs(diff(numsamps))) %if don't match, leave
    error('files have different numbers of samples, maybe check NChannels is correct for each')
    return
end
nsamps = numsamps(1);
if ~mod(nsamps,1)==0 %if a non-integer number
    disp('Non-integer number of samples in file')
end
    
%% Gather samples and write them
for a = 1:n
    fseek(fidr(a),0,'bof');
end
fseek(fidw,0,'bof');

for x = 1:nsamps
    outsamps = [];
    for a = 1:n
        s = fread(fidr(a),datNChans(a),'int16');
        outsamps = cat(1,outsamps,s);
    end
    fwrite(fidw,outsamps,'int16');
end

%% Finish, close access to files
for a = 1:n
    fclose(fidr(a));
end
fclose(fidw);