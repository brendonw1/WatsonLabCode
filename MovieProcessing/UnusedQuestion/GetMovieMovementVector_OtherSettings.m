function [allthreshvect,frametimes] = GetMovieMovementVector(fbasename,framespersec,ROI)
% function [allthreshvect,frametimes] = GetMovieMovementVector_BWRat20(fbasename,framespersec,ROI)
% Thresholds a movie to detect movement in an .mpg.  Gives a simple number
% per frame quantifying total movement with no direction.
% Uses .tsp file to guide appropriate and MUCH more precise timed
% measurement of movement in a movie, timed relative to a recorded dat.
% 
% INPUTS:
% - fbasename: the "xxx" of "xxx.mpg".  Character string.
% - framespersec: single number, desired frames per sec of output movement data
% - ROI: optional input specifying a rectangular region of interest within 
% which to analyze movement.  If not input, the user will be prompted to
% select a region of interest using a figure/image.  
% Format should be [X1 X2 Y1 Y2].
%
% OUTPUTS:
% - allthreshvect: movements values per frame, based on sum of
% above-threshold pixels found in each frame, after thresholding.
% - frametimes: relative frame times in seconds
% Based on AlignTsp2Whl

% if ~exist(ROI)
%     ROI=[];
% end

if strcmp('.tsp',fbasename(end-3:end)) || strcmp('.mpg',fbasename(end-3:end));
    tspfile = fbasename;
    fbasename = fbasename(1:end-4);
end

movfile = [fbasename '.mpg'];
movfile = fullfile(cd,movfile);%for mmread

tspfile = [fbasename '.tsp'];

% get timestamps and positions from tsp file
if exist(tspfile,'file')
    tspdata=load(tspfile);
else
    error('Couldn''t do anything without the tsp file')
end

%toss positions
tspdata = tspdata(:,1); %timestamps in ms

%Ready to check metafile for .dat start/stop times
EndTimestamp = [];%set these up so can detect if problem with getting them from .meta
StartTimestamp = [];
ChanNum = [];
DatSize = [];

fid=fopen([fbasename '.meta']);
tline= fgetl(fid);
while ischar(tline)
    try
    if strcmp(tline(1:20),'TimeStamp of the end')
        tline=tline(59:end);
        EndTimestamp=sscanf(tline,'%d',1);
    end
    end
    try
    if strcmp(tline(1:22),'TimeStamp of the start')
        tline=tline(61:end);
        StartTimestamp=sscanf(tline,'%d',1);
    end
    end
    try
    if strcmp(tline(1:9),'Number of')
        tline=tline(31:end);
        ChanNum=sscanf(tline,'%d',1);
    end
    end
    try
    if strcmp(tline(1:9),'File size')
        tline=tline(21:end);
        DatSize=sscanf(tline,'%lu',1);
    end
    end
    
    tline= fgetl(fid);
end
fclose(fid);

%making up for problems reading parameters (basically if .meta isn't good,
%but will address one at a time
if isempty(EndTimestamp)
    EndTimestamp = tspdata(end,1);
end
% 
if isempty(StartTimestamp)
    StartTimestamp = tspdata(1,1);
end

if isempty(ChanNum);
    fid=fopen([fbasename '.ini']);
    tline= fgetl(fid);
    while ischar(tline)
        try
        if strcmp(tline(1:14),'ChannelsToSave')
            tline=tline(16:end);
            ChanNum = sum(str2num(tline));
        end
        end
        tline= fgetl(fid);
    end
    fclose(fid);
end

% if isempty(DatSize)
%     DatSize = dir([fbasename,'.dat']);
%     DatSize = DatSize.bytes;
% else
%     DatSize = double(DatSize);
% end



%Calculate file length from dat file sample rat
DatLength=DatSize/(ChanNum*2*20); %Dat file size in ms
TspLength=EndTimestamp-StartTimestamp;  %Unused > problematic if crashesyielding blank .meta filesT

%remove lines from tspdata which has the same timestamp as the previous
%does
repeatingts=find(tspdata(1:end-1,1)==tspdata(2:end,1))+1;
if ~isempty(repeatingts)
    disp('Some frames have same timestamps(!)')
end
% for r=size(repeatingts):-1:1
%     tspdata(repeatingts(r),:)=[];tx=(times-times(1))/1000/60
% end

if isnumeric (framespersec);
    msperoutframe = 1000/framespersec;%since timestamps are in ms
    lasttime = StartTimestamp;
    timestofind = [];
    framenums = [];
    frametimes = [];

    %This is important!... only grabbing frames that ACTUALLY occurrred at
    %particular times in real time... no estimation.  Take the last frame
    %before the time determined.  
    while EndTimestamp>lasttime
       timestofind(end+1) = lasttime+msperoutframe;
       framenums(end+1) = find(tspdata<timestofind(end),1,'last');
       frametimes(end+1) = tspdata(framenums(end));
       lasttime = timestofind(end);
    end
elseif strcmp(framespersec,'all')
    startframe = find(tspdata>StartTimestamp,1,'first');
    stopframe = find(tspdata<EndTimestamp,1,'last');
    framenums = startframe:stopframe;
    frametimes = tspdata(startframe:stopframe);
end

%making sure frames past end of actual movie are not called
tempvid = mmread(movfile,1);
totalmovieframes = 1-tempvid.nrFramesTotal;
overhangframes = find(framenums>totalmovieframes);
framenums(overhangframes)=[];
frametimes(overhangframes) = [];

% calculating actual fps... for use somewhere?
% startframe = find(tspdata>StartTimestamp,1,'first');
% stopframe = find(tspdata<EndTimestamp,1,'last');
% actualfps = round((stopframe-startframe)/(tspdata(stopframe)-tspdata(startframe))*1000);

%setting up to loop through and grab frames to process
numframesout = length(framenums);

chunksz = 500;
numchunks = ceil(numframesout/chunksz);
chunksizes = chunksz*ones(1,numchunks);
chunksizes(end) = rem(numframesout,chunksz);
chunkstops = cumsum(chunksizes);
chunkstarts = [1 cumsum(chunksizes(1:end-1))+1];

allsimplevect = [];
allthreshvect = [];

if ~exist('ROI','var')
    vid(:,:,:,1) = tempvid.frames(1).cdata;
    f = figure;
    imagesc(vid);
    ROI = getrect(gca);
    
    ROI(3) = ROI(1)+ROI(3);%change coords 3 and 4 to locations not diff measures
    ROI(2) = ROI(2)+ROI(4);
    
    ROI(1) = max([ROI(1) 0]);%make sure it's not off the edges
    ROI(2) = max([ROI(2) 0]);
    ROI(3) = min([ROI(3) tempvid.width]);
    ROI(4) = min([ROI(4) tempvid.height]);
    delete(f);
end

for b = 1:numchunks;
% for b = 1:3;
    counter = 0;
    if b~=1
        theseframes = framenums((chunkstarts(b)-5):chunkstops(b));%adding a pad to get rid of strange artifacts at junctions
    else
        theseframes = framenums(chunkstarts(b):chunkstops(b));
    end
           
%     if b == numchunks
        clear diffvideo vid
%     end
%     if exist('ROI')
%         clear diffvideo
%     end
    
    tempvid = mmread(movfile,theseframes);    
    for a = 1:length(theseframes)
%         counter = counter+1;
        vid(:,:,:,a) = tempvid.frames(a).cdata;

        if b==1 && a==1 %skip first frame of chunk 1, nothing to diff
            continue %skip to next frame
        elseif b==1 && a>1%
            diffvideo(:,:,:,a) = vid(:,:,:,a)-vid(:,:,:,a-1);
        elseif b>1 && a==1%if first frame of another chunk, subtract from last frame of last chunk (which was saved)
%             diffvideo(:,:,:,a) = zeros(size(vid(:,:,:,a)));%     figure;
        elseif b>1 && a>1
            diffvideo(:,:,:,a-1) = vid(:,:,:,a)-vid(:,:,:,a-1);
        end
    end
    
    if exist('ROI')
        diffvideo = diffvideo(ROI(1):ROI(2),ROI(3):ROI(4),:,:);
    end
    
    threshdiffmovie = BinaryThresholdDiffMovie(diffvideo);
    threshmovementvector = squeeze(sum(sum(threshdiffmovie,1),2));

%     simplemovementvector = squeeze(sum(sum(sum(abs(vid),1),2),3));

    if b~=1%correcting for padding issue above
        threshmovementvector(1:4) = [];
    end

%     lastframe = vid(:,:,:,end);
    
    allthreshvect = cat(1,allthreshvect,threshmovementvector);
%     allsimplevect = cat(1,allsimplevect,simplemovementvector);
    
    disp(['Chunk # ',num2str(b),' out of ',num2str(numchunks),' done'])
end

frametimes = (frametimes-frametimes(1)+mean(diff(frametimes)))/1000; %referencing frame times, setting first frame to be at timepoint 1