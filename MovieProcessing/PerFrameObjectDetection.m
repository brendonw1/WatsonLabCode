function [allthreshvect,frametimes] = GetMovieMovementVector(fbasename,framespersec,ROI)
% function [allthreshvect,frametimes] = GetMovieMovementVector_BWRat20(fbasename,framespersec,ROI)
% Thresholds a movie to detect movement in an .mpg.  Gives a simple number
% per frame quantifying total movement with no direction.
% Uses .tsp file to guide appropriate and MUCH more precise timed
% measurement of movement in a movie, timed relative to a recorded dat.
% 
% INPUTS:
% - fbasename: the "xxx" of "xxx.mpg"
% - framespersec: desired frames per sec of output movement data
% - ROI: optional input specifying a rectangular region of interest within 
% which to analyze movement.  If not input, the user will be prompted to
% select a region of interest using a figure/image
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
    fbasename = fbasename(1:end-4);
end

movfile = [fbasename '.mpg'];
movfile = fullfile(cd,movfile);%for mmread

tspfile = [fbasename '.tsp'];

% get timestamps and positions from tsp file
if exist(tspfile,'file')
    try
        tspdata=load(tspfile);
    catch
        tspdata = ReadTspByfgetl(tspfile);
    end
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

if isempty(DatSize)
    try
        DatSize = dir([fbasename,'.eeg']);
        DatSize = DatSize(1).bytes;
        DatSize = DatSize*20000/1250;
        if isempty(DatSize)
            DatSize = dir([fbasename,'.lfp']);
            DatSize = DatSize(1).bytes;
            DatSize = DatSize*20000/1250;
        end    
    catch
        disp('No DatSize found in meta or elsewhere')
    end
else
    DatSize = double(DatSize);
end


[tsp,actualfps] = gettsptimes(fbasename);
lastframetime = round(tsp(end)/(1/framespersec))*(1/framespersec);
frametimes = 1/framespersec:(1/framespersec):lastframetime;%generate list of desired frame times
framenums = dsearchn(tsp, frametimes');%find the frames with timestamps closest to these


% %Calculate file length from dat file sample rat
% DatLength=DatSize/(ChanNum*2*20); %Dat file size in ms
% TspLength=EndTimestamp-StartTimestamp;  %Unused > problematic if crashes yielding blank .meta filesT

%remove lines from tspdata which has the same timestamp as the previous
%does
% repeatingts=find(tspdata(1:end-1,1)==tspdata(2:end,1))+1;
% if ~isempty(repeatingts)
%     disp('Some frames have same timestamps(!)')
% end
% % for r=size(repeatingts):-1:1
% %     tspdata(repeatingts(r),:)=[];tx=(times-times(1))/1000/60
% % end
% 
% if isnumeric (framespersec);
%     msperoutframe = 1000/framespersec;%since timestamps are in ms
%     lasttime = StartTimestamp;
%     timestofind = [];
%     framenums = [];
%     frametimes = [];
% 
%     %This is important!... only grabbing frames that ACTUALLY occurrred at
%     %particular times in real time... no estimation.  Take the last frame
%     %before the time determined.  
%     while EndTimestamp>lasttime
%        timestofind(end+1) = lasttime+msperoutframe;
%        framenums(end+1) = find(tspdata<timestofind(end),1,'last');
%        frametimes(end+1) = tspdata(framenums(end));
%        lasttime = timestofind(end);
%     end
% elseif strcmp(framespersec,'all')
%     startframe = find(tspdata>StartTimestamp,1,'first');
%     stopframe = find(tspdata<EndTimestamp,1,'last');
%     framenums = startframe:stopframe;
%     frametimes = tspdata(startframe:stopframe);
% end

%making sure frames past end of actual movie are not called
tempvid = mmread(movfile,1);
totalmovieframes = 1-tempvid.nrFramesTotal(1);
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
padsize = 5; %frames to go backwards at junctions between chunks...corrects for some error

% allsimplevect = [];
allthreshvect = [];

% allow user to manually select a Region of Interest
% if ~exist('ROI','var')
%     vid(:,:,:,1) = tempvid.frames(1).cdata;
%     f = figure;
%     imagesc(vid);
%     title('Select ROI')
%     ROI = SelectROI;
%     delete(f);
% end

for b = 1:numchunks;
% for b = 1:3;
    counter = 0;
    if b~=1
        theseframes = framenums((chunkstarts(b)-padsize):chunkstops(b));%adding a pad to get rid of strange artifacts at junctions
    else
        theseframes = framenums(chunkstarts(b):chunkstops(b));
    end
           
%     if b == numchunks
        clear diffvideo vid
%     end
%     if exist('ROIBounds')
%         clear diffvideo
%     end
    
    tempvid = mmread(movfile,theseframes);    
    for a = 1:length(theseframes)
%         counter = counter+1;
        vid(:,:,:,a) = tempvid.frames(a).cdata;

        if b==1 && a==1 %skip first frame of chunk 1, nothing to diff
            continue %skip to next frame (frame 1 will be zeros)
        elseif b==1 && a>1%
            diffvideo(:,:,:,a) = vid(:,:,:,a)-vid(:,:,:,a-1);
        elseif b>1 && a==1%if first frame of another chunk, subtract from last frame of last chunk (which was saved)
%             diffvideo(:,:,:,a) = zeros(size(vid(:,:,:,a)));%     figure;
        elseif b>1 && a>1
            diffvideo(:,:,:,a-1) = vid(:,:,:,a)-vid(:,:,:,a-1);
        end
    end
    
    if exist('ROI','var')
        diffvideo = diffvideo(ROI(1):ROI(2),ROI(3):ROI(4),:,:);
    end
    
    threshdiffmovie = BinaryThresholdDiffMovie(diffvideo);
    threshmovementvector = squeeze(sum(sum(threshdiffmovie,1),2));

%     simplemovementvector = squeeze(sum(sum(sum(abs(vid),1),2),3));

    if b~=1%correcting for padding issue above
        threshmovementvector(1:(padsize-1)) = [];
    end

%     lastframe = vid(:,:,:,end);
    
    allthreshvect = cat(1,allthreshvect,threshmovementvector);
%     allsimplevect = cat(1,allsimplevect,simplemovementvector);
    
    disp(['Chunk # ',num2str(b),' out of ',num2str(numchunks),' done'])
end

% frametimes = (frametimes-frametimes(1)+mean(diff(frametimes)))/1000; %referencing frame times, setting first frame to be at timepoint 1




function [tsp,actualfps] = gettsptimes(fb)
% Anchors tsp into the timeframe of a dat/eeg recording by anchoring to the
% same time as the start of that electrical recording... using the .meta or
% .meta file
        
if FileExists([fb, '-tsp.mat']);
    tsp = load([fb, '-tsp.mat']);
    tsp = tsp.tsp;
else
    try
        tsp = load([fb, '.tsp']);
    catch
        tsp = ReadTspByfgetl([fb, '.tsp']);
    end
    save([fb, '-tsp.mat'], 'tsp');
    ['Saved TSP mat file'];
end

fid=fopen([fb '.meta']);
tline= fgetl(fid);
while ischar(tline)
    try
        if strcmp(tline(1:20),'TimeStamp of the end')
            tline=tline(59:end);
            EndTimestamp=sscanf(tline,'%s',1);
            EndTimestamp=str2num(EndTimestamp);
        end
    catch
        EndTimestamp = tsp(end,1);
    end
    try
        if strcmp(tline(1:22),'TimeStamp of the start')
            tline=tline(61:end);
            StartTimestamp=sscanf(tline,'%s',1);
            StartTimestamp=str2num(StartTimestamp);
        end
    catch
        StartTimestamp = tsp(1,1);
    end
    try
        if strcmp(tline(1:9),'Number of')
            tline=tline(31:end);
            ChanNum=sscanf(tline,'%s',1);
            ChanNum=str2num(ChanNum);
        end
    catch end
    try
        if strcmp(tline(1:9),'File size')
            tline=tline(21:end);
            DatSize=sscanf(tline,'%s',1);
            DatSize=str2num(DatSize);
        end
    catch end

    tline= fgetl(fid);
end

fclose(fid);

tstampDif = EndTimestamp - StartTimestamp;
datDif = double(DatSize/(ChanNum*2*20));


% calculating actual fps.
tsp = tsp(:,1);
startframe = find(tsp>StartTimestamp,1,'first');
stopframe = find(tsp<EndTimestamp,1,'last');
actualfps = round((stopframe-startframe)/(tsp(stopframe)-tsp(startframe))*1000);

tsp = tsp - StartTimestamp;
tsp = tsp*(datDif/tstampDif);
tsp = tsp/1000;