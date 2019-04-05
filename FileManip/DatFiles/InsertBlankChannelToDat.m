numchans = 71;
bitspersamp = 16;
bytespersamp = bitspersamp/8; % =2

fidr = fopen('BWRat17_121712-01.dat','r');
fidw = fopen('output.dat','w+');

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

        samples = cat(1, samples, 0);

        fwrite(fidw,samples,'int16');
%         disp([num2str(a),' out of ',num2str(numsamps)])
    end
end

fclose(fidr);
fclose(fidw);