function ForcedSwimMovieScoring_Stopwatch(filename)
% based on Brendon's ForcedSwimMovieScoring.m, videofig.m

if ~exist('filename','var')
    d = dir('*.avi');
    filename = d(1).name;
end
[pathstr,~,~]= fileparts(which(filename));

[vid,vidObj] = readvideo(filename);
framerate = vidObj.FrameRate;
height = vidObj.Height;
width = vidObj.Width;
WinWidth = width+200;
num_frames = length(vid);

if exist(fullfile(pathstr,[filename(1:end-4) '_FSTScoring.mat']),'file')
prompt = 'Scoring already started. Load previous scores? (y/n)';
        answer = input(prompt,'s');
        if strcmp(answer,'y')
            load(fullfile(pathstr,[filename(1:end-4) '_FSTScoring.mat']),'RawBehavVals','ScoringStartFrame');
        else 
            RawBehavVals = nan(num_frames,1);
            ScoringStartFrame = 1;
            save(fullfile(pathstr,[filename(1:end-4) '_FSTScoring.mat']),'RawBehavVals','ScoringStartFrame');
        end
else
    RawBehavVals = nan(num_frames,1);
    ScoringStartFrame = 1;
    save(fullfile(pathstr,[filename(1:end-4) '_FSTScoring.mat']),'RawBehavVals','ScoringStartFrame');
end

click = 0;
SkipTime = 0; % seconds
ScoringTime = 300;
big_scroll = 5*framerate; % jump 50 frames if page up/down

f = 1; % current frame
startframe = 0;
endframe = 0;
% ScoringStartFrame = 1;
%%
vfh = figure('KeyReleaseFcn', @KeyPress,'position',[1 1 WinWidth height]);
% ax = gca;
% set(ax,'Position',[0 0 width/(width+200) height]);

%axes for scroll bar
scroll_axes_handle = axes('Parent',vfh, 'Position',[0 0 width/WinWidth 0.03], ...
    'Visible','off', 'Units', 'normalized');
axis([0 1 0 1]);
axis off

%scroll bar
scroll_bar_width = max(1 / num_frames, 0.01);
scroll_handle = patch([0 1 1 0] * scroll_bar_width, [0 0 1 1], [.8 .8 .8], ...
    'Parent',scroll_axes_handle, 'EdgeColor','none', 'ButtonDownFcn', @on_click);

%timer to play video
play_timer = timer('TimerFcn',@play_timer_callback, 'ExecutionMode','fixedRate');

%main drawing axes for video display
video_axes_handle = axes('Position',[0 0.03 width/WinWidth 0.97],'Visible','off');

currenttimebox = uicontrol(vfh,'style','text',...
    'position',[width+45 500 110 20],...
    'string',[ num2str(f/framerate) ' s']);
behavtbox = uicontrol(vfh,'style','text',...
    'position',[width+45 460 110 20],...
    'string',['NoScore']);
totalscoredtbox = uicontrol(vfh,'style','text',...
    'position',[width+45 420 110 20],...
    'string',['0s scored']);
scorewindowbox = uicontrol(vfh,'style','text',...
    'position',[width+45 380 110 20],...
    'string','0 s');
setstartbox = uicontrol(vfh,'style','pushbutton',...
    'position',[width+20 320 160 20],...
    'string','Set as start and skip',...
    'callback',@SetStartAndSkip);
playpausebox = uicontrol(vfh,'style','pushbutton',...
    'position',[width+45 260 110 20],...
    'string','Play',...
    'callback',@play);

uicontrol(vfh,'style','pushbutton',...
    'position',[width+45 200 110 20],...
    'string','Mobile',...
    'callback',@SetAsMobile)
uicontrol(vfh,'style','pushbutton',...
    'position',[width+45 170 110 20],...
    'string','Immobile',...
    'callback',@SetAsImmobile)
uicontrol(vfh,'style','pushbutton',...
    'position',[width+45 140 110 20],...
    'string','NoScore',...
    'callback',@SetAsNoScore)
uicontrol(vfh,'style','pushbutton',...
    'position',[width+45 50 110 20],...
    'string','Finish',...
    'callback',@FinishFunction)

% data = v2struct(filename,vfh,currenttimebox,behavtbox,totalscoredtbox,playpausebox,...
%     setstartbox,vid,startframe,endframe,framerate,...
%     RawBehavVals);
% guidata(vfh,data);

scroll(1);
% ReplayMovieChunk(vfh)
1;


   function on_click(src, event)  %#ok, unused arguments
		if click == 0, return; end
		
		%get x-coordinate of click
% 		set(fig_handle, 'Units', 'normalized');
		click_point = get(scroll_axes_handle, 'CurrentPoint');
% 		set(fig_handle, 'Units', 'pixels');
		x = click_point(1);
		
		%get corresponding frame number
		new_f = floor(1 + x * num_frames);
		
		if new_f < 1 || new_f > num_frames, return; end  %outside valid range
		
		if new_f ~= f,  %don't redraw if the frame is the same (to prevent delays)
			scroll(new_f);
		end
   end


    function KeyPress(src, event)  %#ok, unused arguments
        obj = gcf;
        switch event.Key,  %process shortcut keys
            case 'm'
                SetAsMobile(obj)
            case 'i'
                SetAsImmobile(obj)
            case 'n'
                SetAsNoScore(obj)
            case '2'
                SetAsMobile(obj)
            case '1'
                SetAsImmobile(obj)
            case '0'
                SetAsNoScore(obj)
            case 'leftarrow',
                scroll(f - 1);
            case 'rightarrow',
                scroll(f + 1);
            case 'pageup',
                if f - big_scroll < 1,  %scrolling before frame 1, stop at frame 1
                    scroll(1);
                else
                    scroll(f - big_scroll);
                end
            case 'pagedown',
                if f + big_scroll > num_frames,  %scrolling after last frame
                    scroll(num_frames);
                else
                    scroll(f + big_scroll);
                end
            case 'home',
                scroll(1);
            case 'end',
                scroll(num_frames);
            case 'return',
                play(obj)
            case 'space',
                play(obj)
%             case 'backspace',
%                 play(obj,5/framerate)
        end
    end


    function play(obj,ev)
%         data = guidata(obj);
%         v2struct(data);
        period = 1/framerate;
        %toggle between stoping and starting the "play video" timer
        if strcmp(get(play_timer,'Running'), 'off'),
            set(play_timer, 'Period', period);
            start(play_timer);
            startframe = f;
            set(playpausebox,'string','Pause');
        else
            endframe = f;
            stop(play_timer);
            set(playpausebox,'string','Play');
        end
        set(scorewindowbox,'string',[num2str(startframe/framerate) 's - ' num2str(endframe/framerate) 's']);
%         data.startframe
%         guidata(vfh,data);
    end


    function play_timer_callback(src, event)  %#ok
        %executed at each timer period, when playing the video
        if f < num_frames,
            scroll(f + 1);
        elseif strcmp(get(play_timer,'Running'), 'on'),
            stop(play_timer);  %stop the timer if the end is reached
        end
    end


    function scroll(new_f)
        if nargin == 1,  %scroll to another position (new_f)
            if new_f < 1 || new_f > num_frames,
                return
            end
            f = new_f;
        end
        %convert frame number to appropriate x-coordinate of scroll bar
        scroll_x = (f - 1) / num_frames;
        %move scroll bar to new position
        set(scroll_handle, 'XData', scroll_x + [0 1 1 0] * scroll_bar_width);
        imshow(vid(f).cdata,'Parent',video_axes_handle);
        if RawBehavVals(f) == 1
            set(vfh,'color',[1 .75 .75])
            set(behavtbox,'string','Mobile')
        elseif RawBehavVals(f) == 0
            set(vfh,'color',[1 1 .75])
            set(behavtbox,'string','Immobile')
        else
            set(vfh,'color',[1 1 1])
            set(behavtbox,'string','NoScore')
        end
        set(currenttimebox,'string',[ num2str(f/framerate) ' s']);
%         if strcmp(get(play_timer,'Running'), 'on')
            if f<startframe
                startframe = f;
            else
                endframe = f;
            end
%         else
%             endframe = f;
%             
%         end
        set(scorewindowbox,'string',[num2str(startframe/framerate) 's - ' num2str(endframe/framerate) 's']);
%         set(scorewindowbox,'string',[num2str(startframe/framerate) 's - ' num2str(endframe/framerate) 's']);
        %used to be "drawnow", but when called rapidly and the CPU is busy
        %it didn't let Matlab process events properly (ie, close figure).
        pause(0.001)
    end


    function SetStartAndSkip(obj,ev)
%         data = guidata(obj);
%         v2struct(data);
        if strcmp(get(play_timer,'Running'), 'on'),
            stop(play_timer);  %stop the timer if running before scoring starts
        end
        scroll(f+SkipTime*framerate);
        ScoringStartFrame = f+1;
        set(setstartbox,'string',['Start at ' num2str(f/framerate) 's']);
        save(fullfile(pathstr,[filename(1:end-4) '_FSTScoring.mat']),'ScoringStartFrame','-append');
%         guidata(vfh,data);
    end


    function SetAsMobile(obj,ev)
%         data = guidata(obj);
%         v2struct(data);
        RawBehavVals(startframe:endframe) = 1;
        set(vfh,'color',[1 .75 .75])
        set(behavtbox,'string','Mobile')
        set(totalscoredtbox,'string',[num2str(sum(~isnan(RawBehavVals))/framerate) 's scored']);
        % assignin('base','RawChunkBehavVals',RawChunkBehavVals)
        % assignin('base','secondsperchunk',secondsperchunk)
        save(fullfile(pathstr,[filename(1:end-4) '_FSTScoring.mat']),'RawBehavVals','-append')
%         data.RawBehavVals = RawBehavVals;
%         guidata(vfh,data);
    end


    function SetAsImmobile(obj,ev)
%         data = guidata(obj);
%         v2struct(data);
        RawBehavVals(startframe:endframe) = 0;
        set(vfh,'color',[1 1 .75])
        set(behavtbox,'string','Immobile')
        set(totalscoredtbox,'string',[num2str(sum(~isnan(RawBehavVals))/framerate) 's scored']);
        % assignin('base','RawChunkBehavVals',RawChunkBehavVals)
        % assignin('base','secondsperchunk',secondsperchunk)
        save(fullfile(pathstr,[filename(1:end-4) '_FSTScoring.mat']),'RawBehavVals','-append')
%         data.RawBehavVals = RawBehavVals;
%         guidata(vfh,data);
    end


    function SetAsNoScore(obj,ev)
%         data = guidata(obj);
%         v2struct(data);
        RawBehavVals(startframe:endframe) = nan;
        set(vfh,'color',[1 1 1])
        set(behavtbox,'string','NoScore')
        set(totalscoredtbox,'string',[num2str(sum(~isnan(RawBehavVals))/framerate) 's scored']);
        % assignin('base','RawChunkBehavVals',RawChunkBehavVals)
        % assignin('base','secondsperchunk',secondsperchunk)
        save(fullfile(pathstr,[filename(1:end-4) '_FSTScoring.mat']),'RawBehavVals','-append')
%         data.RawBehavVals = RawBehavVals;
%         guidata(vfh,data);
    end

%     function PlayLastMovieChunk(obj,ev)
%         data = guidata(obj);
%         v2struct(data);
%         currentchunknum = max([1 currentchunknum - 1]);
%         % color according to behavioral value of demanded chunk
%         if RawBehavVals(currentchunknum) == 2
%             set(vfh,'color',[1 .75 .75])
%             set(behavtbox,'string','Climbing')
%         elseif RawBehavVals(currentchunknum) == 1
%             set(vfh,'color',[.75 .75 1])
%             set(behavtbox,'string','Swimming')
%         elseif RawBehavVals(currentchunknum) == 0
%             set(vfh,'color',[1 1 .75])
%             set(behavtbox,'string','Immobile')
%         else
%             % elseif isnan(RawChunkBehavVals(currentchunknum))
%             set(vfh,'color',[1 1 1])
%             set(behavtbox,'string','NoScore')
%         end
%         set(currenttimebox,'string',['Chunk ' num2str(currentchunknum) '/' num2str(nchunks)])
%         set(totalscoredtbox,'string',[num2str(secondsperchunk*sum(~isnan(RawBehavVals))) 's scored']);
%         % save output data
%         data.currentchunknum = currentchunknum;
%         guidata(vfh,data);
%         % play movie
%         movie(vfh,vid(startframe(currentchunknum):endframe(currentchunknum)),1,framerate*replayspeedup);
%     end
% 
%     function ReplayMovieChunk(obj,ev)
%         data = guidata(obj);
%         v2struct(data);
%         % play movie
%         movie(vfh,vid(startframe(currentchunknum):endframe(currentchunknum)),1,framerate*replayspeedup);
%     end
% 
%     function PlayNextMovieChunk(obj,ev)
%         data = guidata(obj);
%         v2struct(data);
%         currentchunknum = min([nchunks currentchunknum + 1]);
%         % color according to behavioral value of demanded chunk
%         if RawBehavVals(currentchunknum) == 2
%             set(vfh,'color',[1 .75 .75])
%             set(behavtbox,'string','Climbing')
%         elseif RawBehavVals(currentchunknum) == 1
%             set(vfh,'color',[.75 .75 1])
%             set(behavtbox,'string','Swimming')
%         elseif RawBehavVals(currentchunknum) == 0
%             set(vfh,'color',[1 1 .75])
%             set(behavtbox,'string','Immobile')
%         else
%             % elseif isnan(RawChunkBehavVals(currentchunknum))
%             set(vfh,'color',[1 1 1])
%             set(behavtbox,'string','NoScore')
%         end
%         set(currenttimebox,'string',['Chunk ' num2str(currentchunknum) '/' num2str(nchunks)])
%         set(totalscoredtbox,'string',[num2str(secondsperchunk*sum(~isnan(RawBehavVals))) 's scored']);
%         % save output data
%         data.currentchunknum = currentchunknum;
%         guidata(vfh,data);
%         % play movie
%         movie(vfh,vid(startframe(currentchunknum):endframe(currentchunknum)),1,framerate*replayspeedup);
%     end


    function FinishFunction(obj,ev)
%         data = guidata(obj);
%         v2struct(data);
        
%         TotalMinToScore = 6;
        % 15 for pretest; 5 for official tests (original)
        % 6 for mice and rats (modified)
%         TotalChunksToScore = TotalMinToScore*60/secondsperchunk;
        
%         firstchunk = find(~isnan(RawBehavVals),1,'first');
%         lastchunk = firstchunk+TotalChunksToScore-1;
        % UsedChunks = RawChunkBehavVals(firstchunk:lastchunk);
        UsedFrames = RawBehavVals(ScoringStartFrame:(ScoringStartFrame+ScoringTime*framerate-1));
        % firstchunk+60/5 for rats, firstchunk+120/5 for mice
        ImmobileTime = sum(UsedFrames==0)/framerate;
        MobileTime = sum(UsedFrames==1)/framerate;
        if find(isnan(UsedFrames),1) %(ImmobileTime+MobileTime) < ScoringTime
            warning([num2str((find(isnan(UsedFrames),1)+ScoringStartFrame-1)/framerate) 's has not been scored']);
            return
        end
        figure(vfh)
        bar_axes_handle = axes('Position',[0.1 0.1 width/WinWidth-0.1 0.8]);
        bar(bar_axes_handle,[ImmobileTime,MobileTime]);
        set(gca,'XTickLabel',{'Immobile','Mobile'})
        
        save(fullfile(pathstr,[filename(1:end-4) '_FSTScoring.mat']),'RawBehavVals','UsedFrames','ImmobileTime','ScoringStartFrame','-append')
    end
end
