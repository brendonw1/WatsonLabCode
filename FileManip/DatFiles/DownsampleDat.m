function DownsampleDat(pathname,inFile,outFile,numchans,pointsratio)
% keep only (1 in pointsratio) points in writing a copy of the dat at
% pathname/inFile

inFile = fullfile(pathname,inFile);
outFile = fullfile(pathname,outFile);
fidr = fopen(inFile,'r');
fidw = fopen(outFile,'w+');

bitspersamp = 16;
bytespersamp = bitspersamp/8; % =2

fseek(fidr,0,'eof');
filebytes = ftell(fidr);%gives 8bit bytes
filebytes = filebytes/bytespersamp;%convert to 16bit bytes;
numsamps = filebytes/numchans;

fseek(fidr,0,'bof');
fseek(fidw,0,'bof');

for a = 1:numsamps
    samples = fread(fidr,numchans,'int16');
    if rem(a,pointsratio)==0
        fwrite(fidw,samples,'int16');
    end
    if a==numsamps
        1;
    end
end

fclose(fidr);
fclose(fidw);






