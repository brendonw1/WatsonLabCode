function RemoveChannelsFromDat(indatpath,outdatpath,numinitialchans,removechannels)
%Reads a .dat file and writes a new output file with certain channels
%removed.
%remove channels is a vector/list, in matlab format of which original
%channels to NOT write, for instance this removes the first 47 channels and
%also channels 60-129 removechannels = [1:47,60:129]... base 1

% indatpath = 'AYA6_day4.dat';
% outdatpath = 'AYA6_day4_shank2.dat';
% numchnuminitialchansans = 256;
% removechannels = [1:47,60:129];

bitspersamp = 16;
bytespersamp = bitspersamp/8; % =2


if strcmp(indatpath,outdatpath)
    error('file names must be different')
end
fidr = fopen(indatpath,'r');
fidw = fopen(outdatpath,'w+');

fseek(fidr,0,'eof');
filebytes = ftell(fidr);%gives 8bit bytes
filebytes = filebytes/bytespersamp;%convert to 16bit bytes;
numsamps = filebytes/numinitialchans;

fseek(fidr,0,'bof');
fseek(fidw,0,'bof');

if ~mod(numsamps,1)==0 %if a non-integer number
    disp('Non-integer number of samples in file')
else %otherwise, if integer
    for a = 1:numsamps
    %     startofsamp = ((a-1)*bytespersamp*numchans)+1;
    %     fseek(fidr,'bof',startofsamp);
        samples = fread(fidr,numinitialchans,'int16');
    %     frewind(fidr);

        samples(removechannels)=[];

        fwrite(fidw,samples,'int16');
%         disp([num2str(a),' out of ',num2str(numsamps)])
        %h = waitbar(a/length(numsamps));
    end
end

fclose(fidr);
fclose(fidw);