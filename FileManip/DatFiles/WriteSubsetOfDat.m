function WriteSubsetOfDat(indatpath,outdatpath,numinitialchans,chanstowrite,startsample,endsample)
% Writes parts of an old .dat to a new .dat.  Assumpiton is an int16-
% formatted file without header or footer and with Neuroscope format 
% (sample number by channel as shown here: https://neuroscope.sourceforge.net/UserManual/data-files.html#:~:text=The%20data%20File,-Generic%20file%20name&text=dat%20for%20the%20raw%20data,data%20stored%20in%20the%20file).
% User can specify which samples numbers to output and which channels.
% 
% INPUTS
% indatpath: File path to the original .dat to copy part of
% outdatpath: File path to write new data to (a new .dat file)
% numinitialchannels: How many channels the original .dat has (can get this
% from .xml file)
% chanstowrite: vector list of channels to output (starts with channel 1,
% not zero like neuroscope)
% startsample: First sample to start writing from.  In sample numbers, not
% seconds
% endsample: Last sample to write - must be after startsample
%
% OUTPUT
% To outdatpath
%
% Defaults: 
% chanstowrite: 1:numinitialchannels
% startsamp: 1
% endsamp:EndOfFile
% 
% Brendon Watson 2021

%Buzsaki/Intan data defaults
bitspersamp = 16;
bytespec = 'int16';
bytespersamp = bitspersamp/8; % =2


% open files
fidr = fopen(indatpath,'r');
fidw = fopen(outdatpath,'w+');

%% Get some basic stats, define numsamps and some default values
fseek(fidr,0,'eof');
filebytes = ftell(fidr);%gives 8bit bytes
filebytes = filebytes/bytespersamp;%convert to 16bit bytes;
numsamps = filebytes/numinitialchans;

if ~exist('chanstowrite')
    chanstowrite = 1:numinitialchans;
end
if ~exist('startsample')
    startsample = 1;
end
if ~exist('endsample')
    numsamps = numsamps-1;
else
    numsamps = endsample-startsample+1;
end

startbyte = startsample*numinitialchans*bytespersamp;

%%
fseek(fidr,startbyte,'bof');
fseek(fidw,0,'bof');

if ~mod(numsamps,1)==0 %if a non-integer number
    disp('Non-integer number of samples specified')
else %otherwise, if integer
    for a = 1:numsamps
    %     startofsamp = ((a-1)*bytespersamp*numchans)+1;
    %     fseek(fidr,'bof',startofsamp);
        readsamples = fread(fidr,numinitialchans,bytespec);
    %     frewind(fidr);
        writesamples = readsamples(chanstowrite);
        
        fwrite(fidw,writesamples,'int16');
        
        if mod (a,1000000) == 0
            disp([num2str(a),' out of ',num2str(numsamps) ' samples written'])
        end
    end
end

fclose(fidr);
fclose(fidw);