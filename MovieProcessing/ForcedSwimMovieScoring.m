function ForcedSwimMovieScoring(filename)

% [pathstr,~,~]= fileparts(which(filename));

if ~exist('filename','var')
    d = dir('*.avi');
    filename = d(1).name;
end
% [pathstr,~,~]= fileparts(which(filename));

secondsperchunk = 10;%5; %based on FST protocol
replayspeedup = 1;%fold faster than normal speed to replay

[vid,vidObj] = readvideo(filename);

% framerate = vidObj.FrameRate;
framerate = vidObj.FrameRate;
framesperchunk = secondsperchunk * framerate;
nchunks = floor(length(vid)/framesperchunk);

height = vidObj.Height;
width = vidObj.Width;

for a = 1:nchunks
    startframe(a) = (a-1)*framesperchunk+1;
    endframe(a) = min([length(vid) a*framesperchunk]);
    
%     for b = startframe:endframe
%         tframes(:,:,:,b) = vid(b).cdata;
%     end
%     figure(dfh)
%     subplot(2,2,1)
%     imagesc(uint8(mean(tframes,4)))
%     axis square
%     subplot(2,2,2)
%     imagesc(uint8(std(single(tframes),0,4)))
%     axis square

%     movie(vfh,vid(startframe(a):endframe(a)),1,framerate);
end
RawChunkBehavVals = nan(nchunks,1);

% vfh = figure('KeyReleaseFcn', @KeyPress,'position',[50 100 640 480]);
vfh = figure('KeyReleaseFcn', @KeyPress,'position',[50 100 width+200 height]); % with huge tank
% dfh = figure;
currentchunknum = 1;

chunktbox = uicontrol(vfh,'style','text',...
    'position',[width 420 110 20],...
    'string',['Chunk ' num2str(currentchunknum) '/' num2str(nchunks)]);
behavtbox = uicontrol(vfh,'style','text',...
    'position',[width 390 110 20],...
    'string',['NoScore']);
totalscoredtbox = uicontrol(vfh,'style','text',...
    'position',[width 340 110 20],...
    'string',['0s scored']);

uicontrol(vfh,'style','pushbutton',...
    'position',[width 260 110 20],...
    'string','Climbing',...
    'callback',@SetChunkAsClimbing)
uicontrol(vfh,'style','pushbutton',...
    'position',[width 230 110 20],...
    'string','Swimming',...
    'callback',@SetChunkAsSwimming)
uicontrol(vfh,'style','pushbutton',...
    'position',[width 200 110 20],...
    'string','Immobile',...
    'callback',@SetChunkAsImmobile)
uicontrol(vfh,'style','pushbutton',...
    'position',[width 170 110 20],...
    'string','NoScore',...
    'callback',@SetChunkAsNoScore)

uicontrol(vfh,'style','pushbutton',...
    'position',[width 110 110 20],...
    'string','Last',...
    'callback',@PlayLastMovieChunk)
uicontrol(vfh,'style','pushbutton',...
    'position',[width 80 110 20],...
    'string','Replay',...
    'callback',@ReplayMovieChunk)
uicontrol(vfh,'style','pushbutton',...
    'position',[width 50 110 20],...
    'string','Next',...
    'callback',@PlayNextMovieChunk)

uicontrol(vfh,'style','pushbutton',...
    'position',[width 50 110 20],...
    'string','Finish',...
    'callback',@FinishFunction)

data = v2struct(filename,vfh,chunktbox,behavtbox,totalscoredtbox,...
    vid,secondsperchunk,startframe,endframe,framerate,replayspeedup,...
    currentchunknum,nchunks,RawChunkBehavVals);
guidata(vfh,data);

ReplayMovieChunk(vfh)
1;



function SetChunkAsClimbing(obj,ev)
data = guidata(obj);
v2struct(data);
RawChunkBehavVals(currentchunknum) = 2;
set(vfh,'color',[1 .75 .75])
set(behavtbox,'string','Climbing')
set(totalscoredtbox,'string',[num2str(secondsperchunk*sum(~isnan(RawChunkBehavVals))) 's scored']);
% assignin('base','RawChunkBehavVals',RawChunkBehavVals)
% assignin('base','secondsperchunk',secondsperchunk)
save([filename(1:end-4) '_FSTScoring.mat'],'RawChunkBehavVals','secondsperchunk')
data.RawChunkBehavVals = RawChunkBehavVals;
guidata(vfh,data);

function SetChunkAsSwimming(obj,ev)
data = guidata(obj);
v2struct(data);
RawChunkBehavVals(currentchunknum) = 1;
set(vfh,'color',[.75 .75 1])
set(behavtbox,'string','Swimming')
set(totalscoredtbox,'string',[num2str(secondsperchunk*sum(~isnan(RawChunkBehavVals))) 's scored']);
% assignin('base','RawChunkBehavVals',RawChunkBehavVals)
% assignin('base','secondsperchunk',secondsperchunk)
save([filename(1:end-4) '_FSTScoring.mat'],'RawChunkBehavVals','secondsperchunk')
data.RawChunkBehavVals = RawChunkBehavVals;
guidata(vfh,data);

function SetChunkAsImmobile(obj,ev)
data = guidata(obj);
v2struct(data);
RawChunkBehavVals(currentchunknum) = 0;
set(vfh,'color',[1 1 .75])
set(behavtbox,'string','Immobile')
set(totalscoredtbox,'string',[num2str(secondsperchunk*sum(~isnan(RawChunkBehavVals))) 's scored']);
% assignin('base','RawChunkBehavVals',RawChunkBehavVals)
% assignin('base','secondsperchunk',secondsperchunk)
save([filename(1:end-4) '_FSTScoring.mat'],'RawChunkBehavVals','secondsperchunk')
data.RawChunkBehavVals = RawChunkBehavVals;
guidata(vfh,data);

function SetChunkAsNoScore(obj,ev)
data = guidata(obj);
v2struct(data);
RawChunkBehavVals(currentchunknum) = nan;
set(vfh,'color',[1 1 1])
set(behavtbox,'string','NoScore')
set(totalscoredtbox,'string',[num2str(secondsperchunk*sum(~isnan(RawRawChunkBehavVals))) 's scored']);
% assignin('base','RawChunkBehavVals',RawChunkBehavVals)
% assignin('base','secondsperchunk',secondsperchunk)
save([filename(1:end-4) '_FSTScoring.mat'],'RawChunkBehavVals','secondsperchunk')
data.RawChunkBehavVals = RawRawChunkBehavVals;
guidata(vfh,data);

function PlayLastMovieChunk(obj,ev)
data = guidata(obj);
v2struct(data);
currentchunknum = max([1 currentchunknum - 1]);
% color according to behavioral value of demanded chunk
if RawChunkBehavVals(currentchunknum) == 2
    set(vfh,'color',[1 .75 .75])
    set(behavtbox,'string','Climbing')
elseif RawChunkBehavVals(currentchunknum) == 1
    set(vfh,'color',[.75 .75 1])
    set(behavtbox,'string','Swimming')
elseif RawChunkBehavVals(currentchunknum) == 0
    set(vfh,'color',[1 1 .75])
    set(behavtbox,'string','Immobile')
else
    % elseif isnan(RawChunkBehavVals(currentchunknum))
    set(vfh,'color',[1 1 1])
    set(behavtbox,'string','NoScore')
end
set(chunktbox,'string',['Chunk ' num2str(currentchunknum) '/' num2str(nchunks)])
set(totalscoredtbox,'string',[num2str(secondsperchunk*sum(~isnan(RawChunkBehavVals))) 's scored']);
% save output data
data.currentchunknum = currentchunknum;
guidata(vfh,data);
% play movie
movie(vfh,vid(startframe(currentchunknum):endframe(currentchunknum)),1,framerate*replayspeedup);

function ReplayMovieChunk(obj,ev)
data = guidata(obj);
v2struct(data);
% play movie
movie(vfh,vid(startframe(currentchunknum):endframe(currentchunknum)),1,framerate*replayspeedup);

function PlayNextMovieChunk(obj,ev)
data = guidata(obj);
v2struct(data);
currentchunknum = min([nchunks currentchunknum + 1]);
% color according to behavioral value of demanded chunk
if RawChunkBehavVals(currentchunknum) == 2
    set(vfh,'color',[1 .75 .75])
    set(behavtbox,'string','Climbing')
elseif RawChunkBehavVals(currentchunknum) == 1
    set(vfh,'color',[.75 .75 1])
    set(behavtbox,'string','Swimming')
elseif RawChunkBehavVals(currentchunknum) == 0
    set(vfh,'color',[1 1 .75])
    set(behavtbox,'string','Immobile')
else
    % elseif isnan(RawChunkBehavVals(currentchunknum))
    set(vfh,'color',[1 1 1])
    set(behavtbox,'string','NoScore')
end
set(chunktbox,'string',['Chunk ' num2str(currentchunknum) '/' num2str(nchunks)])
set(totalscoredtbox,'string',[num2str(secondsperchunk*sum(~isnan(RawChunkBehavVals))) 's scored']);
% save output data
data.currentchunknum = currentchunknum;
guidata(vfh,data);
% play movie
movie(vfh,vid(startframe(currentchunknum):endframe(currentchunknum)),1,framerate*replayspeedup);


function KeyPress(f, e)
obj = gcf;
switch lower(e.Key)
    case 'c'
        SetChunkAsClimbing(obj)
    case 's'
        SetChunkAsSwimming(obj)
    case 'i'
        SetChunkAsImmobile(obj)
    case 'n'
        SetChunkAsNoScore(obj)
    case '3'
        SetChunkAsClimbing(obj)
    case '2'
        SetChunkAsSwimming(obj)
    case '1'
        SetChunkAsImmobile(obj)
    case '0'
        SetChunkAsNoScore(obj)
    case 'rightarrow'
        PlayNextMovieChunk(obj)
    case 'r'
        ReplayMovieChunk(obj)
    case 'uparrow'
        ReplayMovieChunk(obj)
    case 'leftarrow'        
        PlayLastMovieChunk(obj)
end


function FinishFunction(obj,ev)
data = guidata(obj);
v2struct(data);

TotalMinToScore = 6;
% 15 for pretest; 5 for official tests (original)
% 6 for mice and rats (modified)
TotalChunksToScore = TotalMinToScore*60/secondsperchunk;

firstchunk = find(~isnan(RawChunkBehavVals),1,'first');
lastchunk = firstchunk+TotalChunksToScore-1;
% UsedChunks = RawChunkBehavVals(firstchunk:lastchunk);
UsedChunks = RawChunkBehavVals(firstchunk+60/secondsperchunk:lastchunk);
% firstchunk+60/5 for rats, firstchunk+120/5 for mice
for a = 1:3;
    BehaviorChunkCounts(a) = sum(UsedChunks==a-1);
end;

figure(vfh)
axes
bar(BehaviorChunkCounts)
set(gca,'XTickLabel',{'Immobile','Swim','Climb'})

% save(fullfile(pathstr,[filename(1:end-4) '_FSTScoring.mat']),'UsedChunks','BehaviorChunkCounts','-append')
save([filename(1:end-4) '_FSTScoring.mat'],'UsedChunks','BehaviorChunkCounts','-append')


%%%%%
% x = [];
% y = [];
% 
% frame = readFrame(vidObj);%frame 1
% read all frames
% display into chunks

% 
% figure;
% imagesc(frame);
% title('1')
% counter = 1;
% totalframes = 1;
% [tx,ty] = ginput;
% x(end+1) = tx;
% y(end+1) = ty;
% 
% while hasFrame(vidObj)
%     frame = readFrame(vidObj);
%     totalframes = totalframes+1;
%     counter = counter+1;
%     if counter == framesBetweenClicks;
%         imagesc(frame)
%         title(num2str(totalframes))
%         
%         [tx,ty] = ginput;
%         if isempty(tx) 
%             tx = 0;
%             ty = 0;
%         end
%         
%         x(end+1) = tx(1);
%         y(end+1) = ty(1);
%         counter = 0;
% %         save('ManualXY','x','y')
%         set (gcf,'userdata',[x' y'])
%     end
% end
% 
% if counter ~= 1%if last slice wasn't already clicked
%     imagesc(frame)
%     [tx,ty] = ginput;
%     x(end+1) = tx;
%     y(end+1) = ty;
% end
% 
% x(x==0) = nan;
% y(y==0) = nan;
% 
% t = 1:totalframes;
% tsampled = 0:framesBetweenClicks,totalframes;
% tsampled(1) = 1;
% 
% x = spline(t,x,tsampled);
% y = spline(t,y,tsampled);
% 
% xy = [x' y'];
% 
% save('ManualXY',x,y)
