function InterpolateDat(pathname,inFile,outFile,numchans,pointsratio)
% interpolate (1 in pointsratio) points in writing a copy of the dat at
% pathname/inFile

fidr = fopen(fullfile(pathname,inFile),'r');
fidw = fopen(fullfile(pathname,outFile),'w+');

bitspersamp = 16;
bytespersamp = bitspersamp/8; % =2
blocksz = 1e6;

fseek(fidr,0,'eof');
filebytes = ftell(fidr);%gives 8bit bytes
filebytes = filebytes/bytespersamp;%convert to 16bit bytes;
numsamps = filebytes/numchans;

interptype = 'linear';
numpriorpoints = 1;
% interptype = 'spline';
% numpriorpoints = 1;%with splines might need to change numpriorpoints...
% but then need to change timepoints too or at least how outsamps is gotten

fseek(fidr,0,'bof');
fseek(fidw,0,'bof');

numblocks = floor(numsamps/blocksz);
blocklengths = blocksz*ones(1,numblocks);
if logical(rem(numsamps,blocksz));
    numblocks = numblocks+1;
    blocklengths = cat(2,blocklengths,rem(numsamps,blocksz));
end

for a = 1:numblocks
    outsamps = [];
    thisblocklen = blocklengths(a);
    if a ~=1
        %take an overhang sample from the previous chunk, so interpolation
        %can work on that interval (priorpoints)
        priorpoints = origsamples(:,end-(numpriorpoints-1)); 
        origsamples = fread(fidr,numchans*thisblocklen,'int16');
        origsamples = reshape(origsamples,[numchans,thisblocklen]);
        origsamples = cat(2,priorpoints,origsamples);
    else
        origsamples = fread(fidr,numchans*thisblocklen,'int16');
        origsamples = reshape(origsamples,[numchans,thisblocklen]);
    end
    
    origtimes = pointsratio*(1:size(origsamples,2))-1;
    interptimes = 1:pointsratio*(size(origsamples,2));
    interptimes(origtimes) = [];
    interptimes(end) = [];
    interpsamples = interp1(origtimes,origsamples',interptimes,interptype);
    interpsamples = interpsamples';

    if a~=1
        %now clean up/get rid of overhang point from beginning
        origsamples(:,1) = [];
        origtimes(1) = [];
        interptimes = interptimes-1;
        origtimes = origtimes-1;
    end
    
    %combine original and interpolated
    outsamps(:,origtimes) = origsamples;
    outsamps(:,interptimes) = interpsamples;
    outsamps = outsamps(:);
    
    fwrite(fidw,outsamps,'int16');
    
    if a==numblocks
        1;
    end
end

fclose(fidr);
fclose(fidw);






