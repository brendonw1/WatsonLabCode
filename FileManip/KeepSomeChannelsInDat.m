origfilename = 'AYA6_day4.dat';
newfilename = 'AYA6_day4_shank2.dat';
if strcmp(origfilename,newfilename)
    error('file names must be different')
end
numchans = 256;
bitspersamp = 16;
bytespersamp = bitspersamp/8; % =2

% what to keep
% keepchannels = [33:64];
shankstokeep = 2;
XMLfile = 'AYA6_day4.xml';
xml = LoadXml(XMLfile);
keepchannels = [];
for a = 1:length(shankstokeep)
    keepchannels = cat(2,xml.SpkGrps(shankstokeep(a)).Channels);
end
keepchannels = keepchannels +1;

% figure out what to remove
allchannels = 1:numchans;
removechannels = setdiff(allchannels,keepchannels);


%go
fidr = fopen(origfilename,'r');
fidw = fopen(newfilename,'w+');

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

        samples(removechannels)=[];

        fwrite(fidw,samples,'int16');
%         disp([num2str(a),' out of ',num2str(numsamps)])
        %h = waitbar(a/length(numsamps));
    end
end

fclose(fidr);
fclose(fidw);