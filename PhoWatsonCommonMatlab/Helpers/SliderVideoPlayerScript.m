%% Opens a video player with a slider that reflects the current playback position:
%% Pho Hale, 3/13/2020

global svp;

% svp: SliderVideoPlayer
% svpSettings.sliderWidth = 100;
% svpSettings.sliderHeight = 23;
% svpSettings.sliderX = 0;
% svpSettings.sliderY = 40;
svpSettings.sliderMajorStep = 0.01;
svpSettings.sliderMinorStep = 0.1;


%% Plot Window:
svp.DataPlot.fig = figure(1);
clf
svp.DataPlot.plotH = plot(frameIndexes, temp);
xlabel('Frame Index');
title('Region Intensity');
xlim([frameIndexes(1), frameIndexes(end)]);
% svp.DataPlot.dualCursor = dualcursor;
dualcursor on;
dualcursor('onlyOneCursor');

% Video Player
% vidPlayCallbacks.PreFrameUpdate = @(~,~) disp('Pre Frame changed!');
% vidPlayCallbacks.PostFrameUpdate = @(~,~) disp('Post Frame changed!');

% svp.vidPlayer = implay(greyscale_frames, v.FrameRate);
svp.vidPlayer = implay(curr_video_file.full_path, v.FrameRate);
spawnPosition = svp.vidPlayer.Parent.Position;
set(svp.vidPlayer.Parent, 'Position',  [180, 300, 867, 883])

% svp.vidPlayer.resi
% svp.vidPlayer.addlistener(vidPlayCallbacks.FrameUpdate);

%% Get the info about the loaded video:
%vidPlayer.DataSource.Controls.CurrentFrame
svp.vidInfo.frameIndexes = frameIndexes;
svp.vidInfo.vidPlaySourceType = svp.vidPlayer.DataSource.Type;
if svp.vidInfo.vidPlaySourceType == "Workspace"
    % Loaded from a workspace variable!
    svp.vidInfo.vidPlaySourceWorkspaceVariableName = svp.vidPlayer.DataSource.Name;
    vidPlaySourceWorkspaceVariableValue = eval(svp.vidInfo.vidPlaySourceWorkspaceVariableName);
    svp.vidInfo.numFrames = length(vidPlaySourceWorkspaceVariableValue);
    svp.vidInfo.currentPlaybackFrame = svp.vidPlayer.DataSource.Controls.CurrentFrame;
elseif svp.vidInfo.vidPlaySourceType == "File"
    svp.vidInfo.vidPlaySourceWorkspaceVariableName = svp.vidPlayer.DataSource.Name;
    svp.vidInfo.numFrames = length(frameIndexes);
    svp.vidInfo.currentPlaybackFrame = svp.vidPlayer.DataSource.Controls.CurrentFrame;
    
else
    % Don't know what to do with videos loaded from disk
    disp("Unhandled type!");
end

%vidPlayer.viewMenuCallback
% guidata(hObject, handles);


%% Slider:
% PreCallBack = @(~,~) disp('Pause the video here');
% PostCallBack = @(~,~)disp('Play the video here');
% svp.Figure = figure();
% Gets the slider position from the video player
svpSettings.sliderWidth = svp.vidPlayer.Parent.Position(3) - 20;
svpSettings.sliderHeight = 23;
svpSettings.sliderX = 5;
svpSettings.sliderY = 40;

% svp.Slider = uicontrol(svp.Figure,'Style','slider',...
svp.Slider = uicontrol(svp.vidPlayer.Parent,'Style','slider',...
                'Min',0,'Max',svp.vidInfo.numFrames,'Value',1,...
                'SliderStep',[svpSettings.sliderMinorStep svpSettings.sliderMajorStep],...
                'Position', [svpSettings.sliderX,svpSettings.sliderY,svpSettings.sliderWidth,svpSettings.sliderHeight]);
          
svp.Slider.Units = "normalized";
addlistener(svp.Slider, 'Value', 'PostSet', @slider_post_update_function);
% addlistener(SliderVideoPlayerSettings.Slider, 'Value', 'PreSet', slider_pre_update_function);

function output_txt = slider_pre_update_function(src, event_obj)
    % ~            Currently not used (empty)
    % event_obj    Object containing event data structure
    % Pause the video here:
    
end

function output_txt = slider_post_update_function(src, event_obj)
    % ~            Currently not used (empty)
    % event_obj    Object containing event data structure
    % Play the video here:
    % Get the frame from the slider:

    % the slider is the frame number from 1 - length, not the currently loaded indexes
    slider_frame = round(event_obj.AffectedObject.Value);

    %updatedFrame = get(svp.Slider,'Value');
%     disp(updatedFrame);
    % Jump to frame:
%     h = findobj('Tag','slider1');
    global svp;
    svp.vidPlayer.DataSource.Controls.jumpTo(slider_frame); % Update the video frame
    final_frame = svp.vidInfo.frameIndexes(1) + slider_frame;
%     dualcursor([1 updatedFrame]);
    dualcursor([final_frame final_frame]);
%     datacursor update;
end