function Merge2Dats(dat1path,dat2path,outdatpath,dat1NChans,dat2NChans)

%% basic params
bitspersamp = 16;
bytespersamp = bitspersamp/8; % =2

%% Open/Initialize files of interest
fidr1 = fopen(dat1path,'r');
fidr2 = fopen(dat2path,'r');
fidw = fopen(outdatpath,'w+');

%% Check files have same number of samples before proceeding
fseek(fidr1,0,'eof');
filebytes1 = ftell(fidr1);%gives 8bit bytes
filebytes1 = filebytes1/bytespersamp;%convert to 16bit bytes;
numsamps1 = filebytes1/dat1NChans;

fseek(fidr2,0,'eof');
filebytes2 = ftell(fidr2);%gives 8bit bytes
filebytes2 = filebytes2/bytespersamp;%convert to 16bit bytes;
numsamps2 = filebytes2/dat2NChans;

if numsamps1 ~= numsamps2 %if don't match, leave
    error('files have different numbers of samples, maybe check NChannels is correct for each')
    return
end
if ~mod(numsamps1,1)==0 %if a non-integer number
    disp('Non-integer number of samples in file')
end
    
%% Gather samples and write them
fseek(fidr1,0,'bof');
fseek(fidr2,0,'bof');
fseek(fidw,0,'bof');

for a = 1:numsamps1
    samples1 = fread(fidr1,dat1NChans,'int16');
    samples2 = fread(fidr2,dat2NChans,'int16');
    samples = cat(1, samples1, samples2);
    fwrite(fidw,samples,'int16');
end

fclose(fidr1);
fclose(fidr2);
fclose(fidw);