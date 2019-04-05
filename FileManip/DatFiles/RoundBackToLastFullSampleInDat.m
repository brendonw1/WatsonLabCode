filename = 'BWRat21_121613-11.dat';
outfile = 'BWRat21_121613-11_cut.dat';
numchans = 62; 

samprate = 20000;
filebitsperbyte = 16;

fidr = fopen(filename,'r');
fseek(fidr,0,'eof');
filebytes = ftell(fidr);%tells 8bit bytes in the file
fclose(fidr)

samplesacquired = filebytes/2/numchans;

if logical(rem(samplesacquired,floor(samplesacquired))) %if non-integer number of samples acquired
    bytestowrite = floor(samplesacquired)*2*numchans;
        
    %use linux "head" command, it will be faster
    eval(['!head -c ' num2str(bytestowrite) ' ' filename ' > ' outfile])
end
    