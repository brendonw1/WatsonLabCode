function WriteSubsetOfDat(indatpath,outdatpath,numinitialchans,chanstowrite,startsample,endsample)

%Buzsaki/Intan data defaults
bitspersamp = 16;
bytespec = 'int16';
bytespersamp = bitspersamp/8; % =2


% open files
fidr = fopen(indatpath,'r');
fidw = fopen(outdatpath,'w+');

%% Get some basic stats and define numsamps
% fseek(fidr,0,'eof');
% filebytes = ftell(fidr);%gives 8bit bytes
% filebytes = filebytes/bytespersamp;%convert to 16bit bytes;
% numsamps = filebytes/numinitialchans;
numsamps = endsample-startsample+1;
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
%         disp([num2str(a),' out of ',num2str(numsamps)])
    end
end

fclose(fidr);
fclose(fidw);