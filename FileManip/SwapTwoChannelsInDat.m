cd /mnt/isis3/brendon/Achilles_120413;
fidr = fopen('Achilles_120413-02.dat','r');
fidw = fopen('Achilles_120413-02-swapped.dat','w+');
numchans = 152;
swapchan1 = 150;
swapchan2 = 151;

oldtonewtransform = [1:numchans]';
oldtonewtransform(swapchan1) = swapchan2;
oldtonewtransform(swapchan2) = swapchan1;

bitspersamp = 16;
bytespersamp = bitspersamp/8; % =2


fseek(fidr,0,'eof');
filebytes = ftell(fidr);%gives 8bit bytes
filebytes = filebytes/bytespersamp;%convert to 16bit bytes;
numsamps = filebytes/numchans;

fseek(fidr,0,'bof');
fseek(fidw,0,'bof');

if ~mod(numsamps,1)==0 %if a non-integer number
    disp('Non-integer number of samples in file')
else %otherwise, if integer
    for a = 1:numsamps
    %     startofsamp = ((a-1)*bytespersamp*numchans)+1;
    %     fseek(fidr,'bof',startofsamp);
        samples = fread(fidr,numchans,'int16');
    %     frewind(fidr);

        samples = samples(oldtonewtransform);

        fwrite(fidw,samples,'int16');
%         disp([num2str(a),' out of ',num2str(numsamps)])
    end
end

fclose(fidr);
fclose(fidw);






