function [svp, svpSettings] = SliderVideoPlayer(svpConfig)
%sliderVideoPlayer Opens a video player with a slider that reflects the current playback position:
%   Pho Hale, 3/17/2020

global svp;
% global svpConfig;

%% Input Argument Parsing:
% defaultHeight = 1;
% defaultUnits = 'inches';
% defaultVideoInputMode = 'file';
% expectedVideoInputModes = {'workspaceVariable','file'};
%    
% defaultVideoFilePath = 'X:\Data\Lezio Pupil 2-21-2020\121201\pupil_deeplabcut\video.avi';
% defaultVideoWorkspaceVariableName = 'greyscale_frames';
% 
% p = inputParser;
% validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
% addRequired(p,'frameRate',validScalarPosNum);
% addParameter(p,'videoInputMode',defaultVideoInputMode, @(x) any(validatestring(x,expectedVideoInputModes)));
% addOptional(p,'videoPath',defaultVideoFilePath,@isstring);
% addOptional(p,'workspaceVariableFramesName',defaultVideoWorkspaceVariableName,@isstring);
% 
% parse(p,frameRate,varargin{:});
% 
% % From input parser:
% svpConfig.VidPlayer.frameRate = p.Results.frameRate;
% 
% % Switch on results of the video input mode:
% if (strcmp(p.Results.videoInputMode, 'file'))
%     % If we're in file mode, we don't need the indicies or anything.
%     if ~exist('v','var')
%         
%     end
% else
%     
% end

enable_dev_testing = true;
if enable_dev_testing
    frameIndexes = 1:1000;
    greyscale_frames = zeros(512,640,length(frameIndexes));
end


if ~exist('svpConfig','var')
   disp("No svpConfig specified! Trying to build one from workspace!")
   %if enable_dev_testing   
   svpConfig.DataPlot.x = frameIndexes;
   
   % Try to find 'v' VideoReader object.
   if ~exist('v','var')
       svpConfig.VidPlayer.frameRate = 20; %Default to 20fps
   else
       svpConfig.VidPlayer.frameRate = v.FrameRate;
   end
   
   if ~exist('greyscale_frames','var')
      % Try to load from workspace variable:
      if ~exist('curr_video_file.full_path','var')
          
          if enable_dev_testing
             
          else
              error('You must specify a video filepath!');
          end
      else
          % Set filepath from curr_video_file variable:
         svpConfig.VidPlayer.videoSource = curr_video_file.full_path; % from file path 
      end
   else
      % Otherwise try to load from URLS:
      svpConfig.VidPlayer.videoSource = greyscale_frames; % From workspace variable
   end

   disp("Done. Continuing.")
end


if ~exist('svp.userAnnotations','var')
   disp("svp.userAnnotations doesn't exist!")
   % Create new userAnnotations:
   svp.userAnnotations.frames = svpConfig.DataPlot.x;
   svp.userAnnotations.numFrames = length(svp.userAnnotations.frames);
   svp.userAnnotations.isMarkedBad = zeros(svp.userAnnotations.numFrames,1,'logical');
   

   [willCreateNew, shouldUseUserAnnotations, returnedFilePath] = userAnnotationsOptionsDialog();
   svpConfig.UserAnnotationsOptions.uaFilepath = returnedFilePath;
   if shouldUseUserAnnotations
		
	if willCreateNew
	   if enable_dev_testing
		outputAbsoluteUniqueVideoIDString = 'dev_testing';             
	   else
		outputAbsoluteUniqueVideoIDString = GenerateAbsoluteVideoIdentifier(svpConfig.VidPlayer.videoSource);
	   end			
		svp.userAnnotations.uaMan = UserAnnotationsManager(outputAbsoluteUniqueVideoIDString, svp.userAnnotations.numFrames, 'Pho', svpConfig.UserAnnotationsOptions.uaFilepath);

		svp.userAnnotations.uaMan.addAnnotationType('BadPupilCenterOffset');
		svp.userAnnotations.uaMan.addAnnotationType('BadPupilSize');
		svp.userAnnotations.uaMan.addAnnotationType('BadEyePolyShape');
		svp.userAnnotations.uaMan.addAnnotationType('BadUnspecified');

		svp.userAnnotations.uaMan.addAnnotationType('UnusualFrame');
		svp.userAnnotations.uaMan.addAnnotationType('EventChange');
		svp.userAnnotations.uaMan.addAnnotationType('NeedsReview');

		svp.userAnnotations.uaMan.addAnnotationType('Log');
		svp.userAnnotations.uaMan.addAnnotationType('AccumulatedListA');

	else
		% Loading existing:
		svp.userAnnotations.uaMan = UserAnnotationsManager.loadFromExistingBackingFile(svpConfig.UserAnnotationsOptions.uaFilepath);

	end
	svpConfig.UserAnnotationsOptions.uaFilepath = svp.userAnnotations.uaMan.BackingFile.fullPath; % Update path in case the user selected a new one

	else
	   %% TODO: disable all the buttons if they don't want annotations:
		error('Not currently implemented!')
	end
   
end



function [willCreateNew, shouldUseUserAnnotations, returnedFilePath] = userAnnotationsOptionsDialog()
	% Asks the user whether to load an existing user annotations file, create a new one, or go on without annotations.
	answer = questdlg('Specify you UserAnnotations options for this video', ...
	'User Annotations Options', ...
	'Load Existing','Create New','No thank you','Load Existing');
	% Handle response
	shouldUseUserAnnotations = true;
	willCreateNew = false;
	switch answer
		case 'Load Existing'
			disp([answer '...'])
		   [file,path] = uigetfile('*.mat','Select an existing user annotations file, or cancel to make a new one');
			if isequal(file,0)
			   disp('User selected Cancel');
			else
			   disp(['User selected ', fullfile(path,file)]);
			   returnedFilePath = fullfile(path,file);
			end
			
		case 'Create New'
			disp([answer '...'])
% 			[file,name,path] = uiputfile('*.mat','User Annotations Backing File',['UAnnotations-', currVideoFileInfo.videoFileIdentifier, '.mat']);
% 			if isequal(file,0) || isequal(path,0)
% 			   error('User clicked Cancel.')
% 			   returnedFilePath = '';
% 			else
% 				returnedFilePath = fullfile(path,file);
% 				
% 			end
			returnedFilePath = ''; % By setting this to empty, the UserAnnotationManager initializer will ask where to create the file
			willCreateNew = true;

		case 'No thank you'
			disp('Skipping user annotations')
			returnedFilePath = '';
			shouldUseUserAnnotations = false;
	end % end switch

end % end function
	



    % Load config:
    svpSettings.shouldAdjustSpawnPosition = false;
    svpSettings.shouldShowPairedFigure = false;
    svpSettings.shouldShowPupilOverlay = true;
    svpSettings.shouldShowEyePolygonOverlay = true;
    
    
    % svp: SliderVideoPlayer
    % svpSettings.sliderWidth = 100;
    % svpSettings.sliderHeight = 23;
    % svpSettings.sliderX = 0;
    % svpSettings.sliderY = 40;
    svpSettings.sliderMajorStep = 0.01;
    svpSettings.sliderMinorStep = 0.1;

    %% Plot Window (optional):
    if (svpSettings.shouldShowPairedFigure)
        svp.DataPlot.fig = figure(1);
        clf
        % svp.DataPlot.plotH = plot(frameIndexes, region_mean_per_frame_smoothed);
        svp.DataPlot.plotH = plot(svpConfig.DataPlot.x, svpConfig.DataPlot.y);
        xlabel('Frame Index');
        title(svpConfig.DataPlot.title);
        xlim([svpConfig.DataPlot.x(1), svpConfig.DataPlot.x(end)]);
        dualcursor on;
        dualcursor('onlyOneCursor');
    end
    
    % Video Player
    svp.vidPlayer = implay(svpConfig.VidPlayer.videoSource, svpConfig.VidPlayer.frameRate);
    
    % Adjust Spawn Position:
    spawnPosition = svp.vidPlayer.Parent.Position;
    % Get spawn size:
    spawnHeight = spawnPosition(4);
    spawnWidth = spawnPosition(3);
    
    hPadding = 60;
    vPadding = 80;
    
    idealSpawnHeight = 512 + vPadding;
    idealSpawnWidth = 640 + hPadding;

    updatedSpawnPosition = spawnPosition;
    
    
    if (spawnHeight < idealSpawnHeight)
        updatedSpawnPosition(4) = idealSpawnHeight;
    end
    
    if (spawnWidth < idealSpawnWidth)
        updatedSpawnPosition(3) = idealSpawnWidth;
    end
        
    if svpSettings.shouldAdjustSpawnPosition
        % Update the spawn positions and sizes:
        updatedSpawnPosition(1) = 180;
        updatedSpawnPosition(2) = 300;
        updatedSpawnPosition(3) = 867;
        updatedSpawnPosition(4) = 883;
        set(svp.vidPlayer.Parent, 'Position',  updatedSpawnPosition);
    else
        %Otherwise just update the spawn sizes:
        set(svp.vidPlayer.Parent, 'Position',  updatedSpawnPosition);
    end
    
    % Update the window title:
    oldName = svp.vidPlayer.Parent.Name;
    svp.vidPlayer.Parent.Name = ['Pho ', oldName]; 
    
    %% Ready to work:
    svp.vidToolbar = findobj(svp.vidPlayer.Parent,'Tag','uimgr.uitoolbar_Playback');
    
%     playbtn = svp.vidToolbar.Children(7);
%     btnPlay = findobj(svp.vidToolbar.Children,'Tag','uimgr.spcpushtool_Play');
%     btnAutoReverse = findobj(svp.vidToolbar.Children,'Tag','uimgr.spcpushtool_AutoReverse');
    btnJumpTo = findobj(svp.vidToolbar.Children,'Tag','uimgr.spcpushtool_JumpTo');
    btnGotoEnd = findobj(svp.vidToolbar.Children,'Tag','uimgr.uipushtool_GotoEnd');
    btnStepFwd = findobj(svp.vidToolbar.Children,'Tag','uimgr.spcpushtool_StepFwd');
    btnFFwd = findobj(svp.vidToolbar.Children,'Tag','uimgr.spcpushtool_FFwd');
    btnPlayPause = findobj(svp.vidToolbar.Children,'Tag','uimgr.spcpushtool_Play');
    btnStop = findobj(svp.vidToolbar.Children,'Tag','uimgr.spcpushtool_Stop');
    btnRewind = findobj(svp.vidToolbar.Children,'Tag','uimgr.spcpushtool_Rewind');
    btnStepBack = findobj(svp.vidToolbar.Children,'Tag','uimgr.uipushtool_StepBack');
    btnGotoStart = findobj(svp.vidToolbar.Children,'Tag','uimgr.spcpushtool_GotoStart');
    
%     buttonNames = {"btnJumpTo","btnGotoEnd","btnStepFwd","btnFFwd","btnPlayPause","btnStop","btnRewind","btnStepBack","btnGotoStart"};
%     buttonCallbacks = {"video_player_btn_JumpTo_callback","video_player_btn_GotoEnd_callback","video_player_btn_StepFwd_callback","video_player_btn_FFwd_callback","video_player_btn_playPause_callback","video_player_btn_Stop_callback","video_player_btn_Rewind_callback","video_player_btn_StepBack_callback","video_player_btn_GotoStart_callback"};
%     
    buttonNames = {"btnJumpTo","btnGotoEnd","btnStepFwd","btnFFwd","btnPlayPause","btnStop","btnRewind","btnStepBack","btnGotoStart"};
    buttonObjs = {btnJumpTo,btnGotoEnd,btnStepFwd,btnFFwd,btnPlayPause,btnStop,btnRewind,btnStepBack,btnGotoStart};
%     buttonCallbacks = {video_player_btn_JumpTo_callback,video_player_btn_GotoEnd_callback,video_player_btn_StepFwd_callback,video_player_btn_FFwd_callback,video_player_btn_playPause_callback,video_player_btn_Stop_callback,video_player_btn_Rewind_callback,video_player_btn_StepBack_callback,video_player_btn_GotoStart_callback};
    buttonCallbacks = {@(hco,ev) video_player_btn_JumpTo_callback(hco,ev); , @(hco,ev)video_player_btn_GotoEnd_callback(hco,ev); , @(hco,ev)video_player_btn_StepFwd_callback(hco,ev); , @(hco,ev)video_player_btn_FFwd_callback(hco,ev); , @(hco,ev)video_player_btn_playPause_callback(hco,ev); , @(hco,ev)video_player_btn_Stop_callback(hco,ev); , @(hco,ev)video_player_btn_Rewind_callback(hco,ev); , @(hco,ev)video_player_btn_StepBack_callback(hco,ev); , @(hco,ev)video_player_btn_GotoStart_callback(hco,ev);};
    
    % Backup the original callback functions.
    for btnIndex = 1:length(buttonNames)
       curr_button_obj = buttonObjs{btnIndex};
       svp.backupCallbacks.(buttonNames{btnIndex}) = curr_button_obj.ClickedCallback;
    end

    for btnIndex = 1:length(buttonNames)
        curr_button_callback_fn = buttonCallbacks{btnIndex};
        curr_button_obj = buttonObjs{btnIndex};
        curr_button_obj.ClickedCallback = @(hco,ev) curr_button_callback_fn(hco,ev);
    end
    
    %% Add a Custom Toolbar to allow marking frames
    svp.vidCustomToolbar = uitoolbar(svp.vidPlayer.Parent,'Tag','uimgr.uitoolbar_PhoCustom');
    

    %% Toggle pupil overlay 
    btn_TogglePupilCircleOverlay_imagePaths = {'HidePupil.png', 'ShowPupil.png'};
    btn_TogglePupilCircleOverlay = uitoggletool(svp.vidCustomToolbar,'Tag','uimgr.uipushtool_TogglePupilCircleOverlay');
    btn_TogglePupilCircleOverlay.CData = iconRead(btn_TogglePupilCircleOverlay_imagePaths{(svpSettings.shouldShowPupilOverlay + 1)});
    btn_TogglePupilCircleOverlay.Tooltip = 'Toggle the pupil circle on or off';
    btn_TogglePupilCircleOverlay.ClickedCallback = @video_player_btn_TogglePupilCircleOverlay_callback;
    
    
    %% Toggle Eye Area overlay:
    btn_ToggleEyePolyOverlay_imagePaths = {'HideEyePoly.png', 'ShowEyePoly.png'};
    btn_ToggleEyePolyOverlay = uitoggletool(svp.vidCustomToolbar,'Tag','uimgr.uipushtool_ToggleEyePolyOverlay');
    btn_ToggleEyePolyOverlay.CData = iconRead(btn_ToggleEyePolyOverlay_imagePaths{(svpSettings.shouldShowEyePolygonOverlay + 1)});
    btn_ToggleEyePolyOverlay.Tooltip = 'Toggle the eye polygon area on or off';
    btn_ToggleEyePolyOverlay.ClickedCallback = @video_player_btn_ToggleEyePolyOverlay_callback;
    
	%% Save User Annotations File
    btn_SaveUserAnnotations = uipushtool(svp.vidCustomToolbar,'Tag','uimgr.uipushtool_SaveUserAnnotations');
    btn_SaveUserAnnotations.CData = iconRead('file_save.png');
    btn_SaveUserAnnotations.Tooltip = 'Save current user annotations out to the pre-specified .MAT file';
    btn_SaveUserAnnotations.ClickedCallback = @video_player_btn_SaveUserAnnotations_callback;
	
	
	%% Frame Buttons:
	
	%% Toggle MarkBad
    btnMarkBad = uipushtool(svp.vidCustomToolbar,'Tag','uimgr.uipushtool_MarkBad');
%     btnMarkBad_imagePaths = {'Warning.png', 'Good.png'};
	btnMarkBad_imagePaths = {'MarkBad.png', 'MarkGood.png'};
    btnMarkBad.CData = iconRead(btnMarkBad_imagePaths{(1)});
    btnMarkBad.Tooltip = 'Mark current frame bad';
    btnMarkBad.ClickedCallback = @video_player_btn_MarkBad_callback;

    %% Log Frame
    btn_LogFrame = uipushtool(svp.vidCustomToolbar,'Tag','uimgr.uipushtool_LogFrame');
    btn_LogFrame.CData = get_matlab_internal_icon('notesicon.gif');
    btn_LogFrame.Tooltip = 'Log current frame out to command window';
    btn_LogFrame.ClickedCallback = @video_player_btn_LogFrame_callback;
	
	
	%% Toggle MarkUnusual
    btnMarkUnusual = uipushtool(svp.vidCustomToolbar,'Tag','uimgr.uipushtool_MarkUnusual');
    btnMarkUnusual_imagePaths = {'MarkUnusual.png', 'ClearUnusual.png'};
    btnMarkUnusual.CData = iconRead(btnMarkUnusual_imagePaths{(1)});
    btnMarkUnusual.Tooltip = 'Mark current frame unusual';
    btnMarkUnusual.ClickedCallback = @video_player_btn_MarkUnusual_callback;
	
	%% Toggle Needs Review
	btnMarkNeedsReview = uipushtool(svp.vidCustomToolbar,'Tag','uimgr.uipushtool_MarkNeedsReview');
	btnMarkNeedsReview_imagePaths = {'MarkNeedsReview.png', 'ClearNeedsReview.png'};
	btnMarkNeedsReview.CData = iconRead(btnMarkNeedsReview_imagePaths{(1)});
	btnMarkNeedsReview.Tooltip = 'Mark current frame NeedsReview';
	btnMarkNeedsReview.ClickedCallback = @video_player_btn_MarkNeedsReview_callback;

		%% Toggle Transition
	btnMarkTransition = uipushtool(svp.vidCustomToolbar,'Tag','uimgr.uipushtool_MarkTransition');
	btnMarkTransition_imagePaths = {'MarkTransition.png', 'ClearTransition.png'};
	btnMarkTransition.CData = iconRead(btnMarkTransition_imagePaths{(1)});
	btnMarkTransition.Tooltip = 'Mark current frame Transition';
	btnMarkTransition.ClickedCallback = @video_player_btn_MarkTransition_callback;

% 	%% Toggle TEMPLATE
% btnMarkTEMPLATE = uipushtool(svp.vidCustomToolbar,'Tag','uimgr.uipushtool_MarkTEMPLATE');
% btnMarkTEMPLATE_imagePaths = {'MarkTEMPLATE.png', 'ClearTEMPLATE.png'};
% btnMarkTEMPLATE.CData = iconRead(btnMarkTEMPLATE_imagePaths{(1)});
% btnMarkTEMPLATE.Tooltip = 'Mark current frame TEMPLATE';
% btnMarkTEMPLATE.ClickedCallback = @video_player_btn_MarkTEMPLATE_callback;
	
	%% Toggle MarkList
	btnMarkList = uipushtool(svp.vidCustomToolbar,'Tag','uimgr.uipushtool_MarkList');
	btnMarkList_imagePaths = {'ListAdd.png', 'ListRemove.png'};
	btnMarkList.CData = iconRead(btnMarkList_imagePaths{(1)});
	btnMarkList.Tooltip = 'Mark current frame list member';
	btnMarkList.ClickedCallback = @video_player_btn_MarkList_callback;
		

    % Options: tool_legend.png
    % Question Mark - Red
    % plottype-hist3.gif
    % GreenXs and RedOs
    % plotpicker-pointfig.png
    % Log:
    % notesicon.gif
	% Save:
	% file_save.png
	% Open:
	% file_open.png
	% New:
	% file_new.png
    % Help:
	% helpicon.gif
	

	
	
    %% Updates the state of the toolbar buttons:
    function video_player_update_custom_toolbar_buttons_appearance()
        curr_video_frame = get_video_frame();
        
        % User Marked Bad:
%         final_is_marked_bad = svp.userAnnotations.isMarkedBad(curr_video_frame);
		
		[~, doesAnnotationExist] = svp.userAnnotations.uaMan.tryGetAnnotation('BadUnspecified', curr_video_frame);
		final_is_marked_bad = doesAnnotationExist;
		
        final_is_marked_bad_index = 0;
        if final_is_marked_bad
           final_is_marked_bad_index = 2;
        else
           final_is_marked_bad_index = 1;
        end
        btnMarkBad.CData = iconRead(btnMarkBad_imagePaths{final_is_marked_bad_index});
% 		btn_LogFrame.CData = iconRead(btn_LogFrame_imagePaths{(svp.userAnnotations.uaMan.DoesAnnotationExist('Log', curr_video_frame) + 1)});        
		
		btnMarkUnusual.CData = iconRead(btnMarkUnusual_imagePaths{(svp.userAnnotations.uaMan.DoesAnnotationExist('UnusualFrame', curr_video_frame) + 1)});
		btnMarkNeedsReview.CData = iconRead(btnMarkNeedsReview_imagePaths{(svp.userAnnotations.uaMan.DoesAnnotationExist('NeedsReview', curr_video_frame) + 1)});
		btnMarkTransition.CData = iconRead(btnMarkTransition_imagePaths{(svp.userAnnotations.uaMan.DoesAnnotationExist('EventChange', curr_video_frame) + 1)});
		btnMarkList.CData = iconRead(btnMarkList_imagePaths{(svp.userAnnotations.uaMan.DoesAnnotationExist('AccumulatedListA', curr_video_frame) + 1)});

% 		btnMarkTEMPLATE.CData = iconRead(btnMarkTEMPLATE_imagePaths{(svp.userAnnotations.uaMan.DoesAnnotationExist('UnusualFrame', curr_video_frame) + 1)});
		
		%% End Per-Frame buttons
		
        % Pupil Overlay
%         if svpSettings.shouldShowPupilOverlay

%         else

%         end
        btn_TogglePupilCircleOverlay.CData = iconRead(btn_TogglePupilCircleOverlay_imagePaths{(svpSettings.shouldShowPupilOverlay + 1)});
        
        
        % Eye Poly
%         if svpSettings.shouldShowEyePolygonOverlay

%         else

%         end
        btn_ToggleEyePolyOverlay.CData = iconRead(btn_ToggleEyePolyOverlay_imagePaths{(svpSettings.shouldShowEyePolygonOverlay + 1)});
        
	end

	% SaveUserAnnotations
	function video_player_btn_SaveUserAnnotations_callback(src, event)
		disp('Saving out to file...')
		svp.userAnnotations.uaMan.saveToBackingFile();
		disp('Done')
		%svp.userAnnotations.uaMan.saveToUserSelectableCopyMat()
		
	end
    
    function video_player_btn_MarkBad_callback(src, event)
        disp('btnMarkBad callback hit!');
        curr_video_frame = get_video_frame();
        
        % Get current user annotations:
%         curr_is_marked_bad = svp.userAnnotations.isMarkedBad(curr_video_frame);
		[~, doesAnnotationExist] = svp.userAnnotations.uaMan.tryGetAnnotation('BadUnspecified', curr_video_frame);
		curr_is_marked_bad = doesAnnotationExist;
		
        updated_is_marked_bad = ~curr_is_marked_bad;
        
        if updated_is_marked_bad
           disp([num2str(curr_video_frame) ' is bad!']);
		   svp.userAnnotations.uaMan.createAnnotation('BadUnspecified', curr_video_frame);
        else
           disp([num2str(curr_video_frame) ' is good!']);
		   svp.userAnnotations.uaMan.removeAnnotation('BadUnspecified', curr_video_frame);
        end
        
        % Set the new annotation value:
%         svp.userAnnotations.isMarkedBad(curr_video_frame) = updated_is_marked_bad;
        
        % Update Display: Ready to be potentially factored out into its own
        % function.
        video_player_update_custom_toolbar_buttons_appearance();
        
    end

    function video_player_btn_LogFrame_callback(src, event)
        disp('btnLogFrame callback hit!');
        curr_video_frame = get_video_frame();
        disp(curr_video_frame);
		isActive = svp.userAnnotations.uaMan.toggleAnnotation('Log', curr_video_frame);
		% TODO: update button from this?
		video_player_update_custom_toolbar_buttons_appearance();
	end

	%% START NEW
	function video_player_btn_MarkUnusual_callback(src, event)
        curr_video_frame = get_video_frame();
		isActive = svp.userAnnotations.uaMan.toggleAnnotation('UnusualFrame', curr_video_frame);
		video_player_update_custom_toolbar_buttons_appearance();
	end

	function video_player_btn_MarkNeedsReview_callback(src, event)
        curr_video_frame = get_video_frame();
		isActive = svp.userAnnotations.uaMan.toggleAnnotation('NeedsReview', curr_video_frame);
		video_player_update_custom_toolbar_buttons_appearance();
	end

	function video_player_btn_MarkTransition_callback(src, event)
        curr_video_frame = get_video_frame();
		isActive = svp.userAnnotations.uaMan.toggleAnnotation('EventChange', curr_video_frame);
		video_player_update_custom_toolbar_buttons_appearance();
	end

	function video_player_btn_MarkList_callback(src, event)
        curr_video_frame = get_video_frame();
		isActive = svp.userAnnotations.uaMan.toggleAnnotation('AccumulatedListA', curr_video_frame);
		video_player_update_custom_toolbar_buttons_appearance();
	end

	%% END NEW


      
    function video_player_btn_TogglePupilCircleOverlay_callback(src, event)
        disp('btnTogglePupilCircleOverlay_callback callback hit!');
        if svpSettings.shouldShowPupilOverlay
           svpSettings.shouldShowPupilOverlay = false;
           disp('    toggled off');
           currAxes = svp.vidPlayer.Visual.Axes;
           hExistingPlot = findobj(currAxes, 'Tag','pupilCirclePlotHandle');
           delete(hExistingPlot) % Remove existing plot
            
        else
           svpSettings.shouldShowPupilOverlay = true;
           disp('    toggled on');
           % TODO: update button icon, refresh displayed plot
        end
        video_player_update_custom_toolbar_buttons_appearance();
        
    end

    function video_player_btn_ToggleEyePolyOverlay_callback(src, event)
        disp('btnToggleEyePolyOverlay callback hit!');
        if svpSettings.shouldShowEyePolygonOverlay
           svpSettings.shouldShowEyePolygonOverlay = false;
           disp('    toggled off');
           currAxes = svp.vidPlayer.Visual.Axes;
           hExistingPlot = findobj(currAxes, 'Tag','eyePolyPlotHandle');
           delete(hExistingPlot) % Remove existing plot
          
        else
           svpSettings.shouldShowEyePolygonOverlay = true;
           disp('    toggled on');
           % TODO: update button icon, refresh displayed plot
        end
        video_player_update_custom_toolbar_buttons_appearance();
	end
    

    %% Get the info about the loaded video:
    svp.vidInfo.frameIndexes = svpConfig.DataPlot.x;
    svp.vidInfo.vidPlaySourceType = svp.vidPlayer.DataSource.Type;
    if svp.vidInfo.vidPlaySourceType == "Workspace"
        % Loaded from a workspace variable!
        svp.vidInfo.vidPlaySourceWorkspaceVariableName = svp.vidPlayer.DataSource.Name;
        
        if strcmp(svp.vidInfo.vidPlaySourceWorkspaceVariableName, '(MATLAB Expression)')
            if enable_dev_testing
                svp.vidInfo.numFrames = length(frameIndexes);
                svp.vidInfo.currentPlaybackFrame = 1;
            else
                error('Workspace variable name was MATLAB Expression, but this is only allowable in dev_testing mode!');
            end
        else
            vidPlaySourceWorkspaceVariableValue = eval(svp.vidInfo.vidPlaySourceWorkspaceVariableName);
            svp.vidInfo.numFrames = length(vidPlaySourceWorkspaceVariableValue);
            svp.vidInfo.currentPlaybackFrame = svp.vidPlayer.DataSource.Controls.CurrentFrame;
        end
        
    elseif svp.vidInfo.vidPlaySourceType == "File"
        svp.vidInfo.vidPlaySourceWorkspaceVariableName = svp.vidPlayer.DataSource.Name;
        svp.vidInfo.numFrames = length(svpConfig.DataPlot.x);
        svp.vidInfo.currentPlaybackFrame = svp.vidPlayer.DataSource.Controls.CurrentFrame;

    else
        % Don't know what to do with videos loaded from disk
        error("Unhandled type!");
    end

    %vidPlayer.viewMenuCallback
    % guidata(hObject, handles);


    %% Slider:
    % svp.Figure = figure();
    % Gets the slider position from the video player
    svpSettings.sliderWidth = svp.vidPlayer.Parent.Position(3) - 20;
    svpSettings.sliderHeight = 23;
    svpSettings.sliderX = 5;
    svpSettings.sliderY = 40;

    % svp.Slider = uicontrol(svp.Figure,'Style','slider',...
    svp.Slider = uicontrol(svp.vidPlayer.Parent,'Style','slider',...
                    'Min',1,'Max',svp.vidInfo.numFrames,'Value',svp.vidInfo.currentPlaybackFrame,...
                    'SliderStep',[svpSettings.sliderMinorStep svpSettings.sliderMajorStep],...
                    'Position', [svpSettings.sliderX,svpSettings.sliderY,svpSettings.sliderWidth,svpSettings.sliderHeight]);

    svp.Slider.Units = "normalized"; %Change slider units to normalized so that it scales with the video window.
    addlistener(svp.Slider, 'Value', 'PostSet', @slider_post_update_function);

	
		
	% When all done, call the update function to ensure the UI is up to date:
	video_player_update_custom_toolbar_buttons_appearance();


%% Button Callbacks: buttonNames = {"btnJumpTo","btnGotoEnd","btnStepFwd","btnFFwd","btnPlayPause","btnStop","btnRewind","btnStepBack","btnGotoStart"};
% Called when the corresponding button is clicked in the video GUI.
    function video_player_btn_JumpTo_callback(hco, ev)
%         disp('jump to button callback hit!');
        svp.backupCallbacks.btnJumpTo(hco, ev);
        update_controls_from_video_playback();
    end

    function video_player_btn_GotoEnd_callback(hco, ev)
%         disp('btnGotoEnd callback hit!');
        svp.backupCallbacks.btnGotoEnd(hco, ev);
        update_controls_from_video_playback();
    end

    function video_player_btn_StepFwd_callback(hco, ev)
%         disp('btnStepFwd callback hit!');
        svp.backupCallbacks.btnStepFwd(hco, ev);
        update_controls_from_video_playback();
    end

    function video_player_btn_FFwd_callback(hco, ev)
%         disp('btnFFwd callback hit!');
        svp.backupCallbacks.btnFFwd(hco, ev);
        update_controls_from_video_playback();
    end

    function video_player_btn_playPause_callback(hco, ev)
%         disp('play/pause button callback hit!');
        svp.backupCallbacks.btnPlayPause(hco, ev);
        update_controls_from_video_playback();
    end

    function video_player_btn_Stop_callback(hco, ev)
%         disp('stop button callback hit!');
        svp.backupCallbacks.btnStop(hco, ev);
        update_controls_from_video_playback();
    end

    function video_player_btn_Rewind_callback(hco, ev)
%         disp('btnRewind callback hit!');
        svp.backupCallbacks.btnRewind(hco, ev);
        update_controls_from_video_playback();
    end

    function video_player_btn_StepBack_callback(hco, ev)
%         disp('btnStepBack callback hit!');
        svp.backupCallbacks.btnStepBack(hco, ev);
        update_controls_from_video_playback();
    end

    function video_player_btn_GotoStart_callback(hco, ev)
%         disp('btnGotoStart callback hit!');
        svp.backupCallbacks.btnGotoStart(hco, ev);
        update_controls_from_video_playback();
    end

%% Helper Functions:
    function slider_frame = video_player_frame_to_slider_frame(video_frame)
        % Video frame is in the range [1,...numVideoFrames]
       relative_frame_offset = (svp.vidInfo.frameIndexes(1) - 1); % The offset is how far the first frame is from one. 
       slider_frame = video_frame - relative_frame_offset;
    end

    function video_frame = slider_frame_to_video_frame(slider_frame)
        relative_frame_offset = (svp.vidInfo.frameIndexes(1) - 1); % The offset is how far the first frame is from one. 
        video_frame = relative_frame_offset + slider_frame;
    end

    function curr_video_frame = get_video_frame()
        curr_video_frame = svp.vidPlayer.DataSource.Controls.CurrentFrame;        
    end

    function update_controls_from_video_playback()
        % Updates the slider and the plot (if it exists) from the current video frame.
        curr_video_frame = get_video_frame();
        curr_slider_frame = video_player_frame_to_slider_frame(curr_video_frame);
        svp.Slider.Value = curr_slider_frame; % Set the slider to the video frame
        if (svpSettings.shouldShowPairedFigure)
            dualcursor([curr_video_frame curr_video_frame]);
		end
		% update the toolbar buttons to reflect the new frame's status.
		video_player_update_custom_toolbar_buttons_appearance();
    end

%% Other UI Callbacks:
    function slider_post_update_function(~, event_obj)
        % ~            Currently not used (empty)
        % event_obj    Object containing event data structure
        % Play the video here:
        % Get the frame from the slider:
    %     updatedFrame = get(event_obj,'NewValue');

        % the slider is the frame number from 1 - length, not the currently loaded indexes
        slider_frame = round(event_obj.AffectedObject.Value);

        % Jump to frame:
        svp.vidPlayer.DataSource.Controls.jumpTo(slider_frame); % Update the video frame
        final_frame = svp.vidInfo.frameIndexes(1) + slider_frame;
        if (svpSettings.shouldShowPairedFigure)
            dualcursor([final_frame final_frame]);
        end
        
        currAxes = svp.vidPlayer.Visual.Axes;
%         hold(currAxes,'on')
%         hold(currAxes,'off')
        if (svpSettings.shouldShowEyePolygonOverlay)
           % Add its eye-bound-polygon:
%             hold on;
%             if (exist('svpConfig.additionalDisplayData.eyePolyPlotHandle', 'var'))
%                 disp('Eye poly handle already exists!')
%             else
%                 disp('Pupil circle handle new!')
%             end
            
            hExistingPlot = findobj(currAxes, 'Tag','eyePolyPlotHandle');
            delete(hExistingPlot) % Remove existing plot
            svpConfig.additionalDisplayData.eyePolyPlotHandle = plot(currAxes, svpConfig.additionalDisplayData.eye_bound_polys{slider_frame},'Tag','eyePolyPlotHandle');
        end

        if (svpSettings.shouldShowPupilOverlay)
            % Add its pupil circle:
%             hold on;
%             if (exist('svpConfig.additionalDisplayData.pupilCirclePlotHandle', 'var'))
%                 disp('Pupil circle handle already exists!')
%             else
%                 disp('Pupil circle handle new!')
%             end
            
            hExistingPupilsPlot = findobj(currAxes, 'Tag','pupilCirclePlotHandle');
            delete(hExistingPupilsPlot) % Remove existing plot
            svpConfig.additionalDisplayData.pupilCirclePlotHandle = viscircles(currAxes, svpConfig.additionalDisplayData.processedFramePupilInfo_Center(slider_frame,:), svpConfig.additionalDisplayData.processedFramePupilInfo_Radius(slider_frame)); 
            svpConfig.additionalDisplayData.pupilCirclePlotHandle.Tag = 'pupilCirclePlotHandle';
            %       hold off;
        end
        
        % Update buttons:
        video_player_update_custom_toolbar_buttons_appearance();
        
    end

    % Called when the play button is clicked in the video GUI.
    function video_player_play_callback(~, event_obj)
        % ~            Currently not used (empty)
        % event_obj    Object containing event data structure
        % Play the video here:
        % Get the frame from the slider:
        % the slider is the frame number from 1 - length, not the currently loaded indexes
        slider_frame = round(event_obj.AffectedObject.Value);

        % Jump to frame:
        svp.vidPlayer.DataSource.Controls.jumpTo(slider_frame); % Update the video frame
        final_frame = svp.vidInfo.frameIndexes(1) + slider_frame;
        if (svpSettings.shouldShowPairedFigure)
            dualcursor([final_frame final_frame]);
        end
        
%         if (svpSettings.shouldShowEyePolygonOverlay)
%            % Add its eye-bound-polygon:
%             hold on;
%             plot(eye_bound_polys{activeFrameIndex})
% 
%             % Add its pupil circle:
%             hold on;
%             h = viscircles(processedFramePupilInfo_Center(activeFrameIndex,:), processedFramePupilInfo_Radius(activeFrameIndex)); 
%         end
        
        video_player_update_custom_toolbar_buttons_appearance();
	end

	%% Helpers:
	function ptImage = get_matlab_internal_icon(filename)
		% Takes an icon name with extension, like 'notesicon.gif'
		filePath = fullfile(matlabroot,'toolbox','matlab','icons', filename);
		[~,~,fileExtension] = fileparts(filename);
		if strcmpi(fileExtension,'.gif')
			[img,map] = imread(filePath);
			ptImage = ind2rgb(img,map);
			
		elseif strcmpi(fileExtension,'.png')
			ptImage = iconRead(filePath);
		else
			warning('Unhandled icon type!')
			[img,map] = imread(filePath);
			ptImage = ind2rgb(img,map);
		end
	end

end

