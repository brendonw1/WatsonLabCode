function [iips_Config, iips_State] = InteractiveImagePixelSelectionFn(desiredSelectionName)
%INTERACTIVEIMAGEPIXELSELECTIONFN Enables the user to "paint" the current plot in a binary fashion to select or deselect pixels.
%% INPUT:
	% The user can press:
		% [Esc]: exit this mode
		% [Spacebar]: toggle between paint and erase modes.
		% [x]: export the selected region
		% [.]: reset the selection (start a new selection). The user is prompted first
		% [l]: list current selection groups

		
	iips_Config.debugDetail = 10; % A value in the range 0-10, where 0 represents no debug information displayed and 10 represents extremely verboose debug information displayed
	iips_Config.brush_size = 2;
	iips_Config.brush_mode = 'paint'; % 'paint', 'erase'
	iips_Config.update_mode = 'Additive'; % 'Toggle', 'OR', 'Replace', 'Additive'
	iips_Config.overlayAlpha = 0.4;
	
	% Intialization of the iips_State variable

		% Create new state:
		[iips_State] = iips_IntializeWithFigure();
		
		if ~exist('desiredSelectionName','var')
% 			desiredSelectionName = 'NoNameSpecified';
% 			% Selections didn't already exist, creating a new group
% 			disp(['Selections with name ', desiredSelectionName, ' did not already exist in the workspace selections index, so new ones were created.'])
% 			[old_selection] = iips_ResetSelection(desiredSelectionName);
% 			iips_State.current_selection_name = desiredSelectionName;

			iips_State.current_selection_name = 'NoNameSpecified';

			% Build Temporary Structures:
			iips_State.pixel_selection_mask = zeros(iips_State.curr_image_size);

			% % Use our selection mask as the AlphaData for the solid green image. 
			set(iips_State.visualization.overlayHandle, 'AlphaData', (iips_State.pixel_selection_mask .* iips_Config.overlayAlpha)); 
			drawnow

			% Set up interface handling variables:
			iips_State.isMouseBeingPressed = false;
			iips_State.lastHoveredPixel = '';


		else
			% try to load the selection:
			[did_load_successfully] = iips_CompleteLoadSelections(desiredSelectionName);
			if ~did_load_successfully
				% Selections didn't already exist, creating a new group
				disp(['Selections with name ', desiredSelectionName, ' did not already exist in the workspace selections index, so new ones were created.'])
				[old_selection] = iips_ResetSelection(desiredSelectionName, false);
				iips_State.current_selection_name = desiredSelectionName;
			else
				disp(['Selections with name ', desiredSelectionName, ' already exist in the workspace selections index, and were loaded!'])
			end
			
		end
		


		% Set up the mouse moved function:
		set(iips_State.curr_figure, 'WindowButtonDownFcn', @iips_MouseButtonDownFcn);

		% Set up key press function:
		% See https://www.mathworks.com/matlabcentral/answers/320351-re-enable-keypress-capture-when-de-selecting-figure
		
		% This should work in both HG1 and HG2:
		iips_State.hManager = uigetmodemanager(iips_State.curr_figure);
		try
			set(iips_State.hManager.WindowListenerHandles, 'Enable', 'off');  % HG1
		catch
			[iips_State.hManager.WindowListenerHandles.Enabled] = deal(false);  % HG2
		end
		set(iips_State.curr_figure, 'WindowKeyPressFcn', []);
		set(iips_State.curr_figure, 'KeyPressFcn', @iips_KeyPressFcn);

	% Get initial selection output
	iips_GetExportSelectionFcn();
		
	% Print the user key commands
	iips_PrintKeyCommands();
	
	%% Start nested functions:
	
	function [iips_State] = iips_IntializeWithFigure(fig_h, ax_h)
		
		if ~exist('fig_h','var')
			fig_h = gcf;
		end
		
		iips_State.curr_figure = fig_h;
		
		if ~exist('ax_h','var')
% 			get(iips_State.curr_figure,'CurrentAxes')
			allAxesInFigure = findall(iips_State.curr_figure,'type','axes');
			%				axNoLegendsOrColorbars = ax(~ismember(get(ax,'Tag'),{'legend','Colobar'}))
% 						axNoLegendsOrColorbars = allAxesInFigure(~ismember(get(allAxesInFigure,'Tag'),{'legend','Colobar'}))
			for i = 1:length(allAxesInFigure)
				curr_ax_h = allAxesInFigure(i);
				curr_ax_tag = get(curr_ax_h,'Tag');
				% Try to find the main image axes by ignoring all legend, Colorbar, or custom tagged axes
				if ~ismember(curr_ax_tag,{'legend','Colobar','phoCustomAnnotation'})
					ax_h = curr_ax_h;					
				elseif curr_ax_h(ismember(curr_ax_tag, {'phoCustomAnnotation'}))
					% If we find the overlay annotation handle, save it, so we don't needlessly create it again.
					found_overlay_image_handle = curr_ax_h;
				end
			end % end for allAxesInFigure
			
			if ~exist('ax_h','var')
				error('Could not find valid axes in figure!')
			end

		end
		% Set the axes:
		iips_State.curr_axes = ax_h;

		[iips_State.x_extent, iips_State.y_extent, iips_State.curr_image] = getimage(iips_State.curr_axes);
		iips_State.curr_image_size = size(iips_State.curr_image); % [512  640]
		iips_State.current_selection_context = iips_State.curr_axes.Title.String; % Get the context from the current image
		% Graphics only structures:
 
		% Plot the solid green overlay image on the current figure
		if exist('found_green_image_handle','var')
			iips_State.visualization.greenImage = found_overlay_image_handle;
		else
			% Make a truecolor all-green image that's constant, and its opacity is adjusted given the user's selection mask.
			iips_State.visualization.greenImage = cat(3, zeros(iips_State.curr_image_size), ones(iips_State.curr_image_size), zeros(iips_State.curr_image_size));
		
			% Plot a new green image axes
			hold on 
			iips_State.visualization.overlayHandle = imshow(iips_State.visualization.greenImage);
			set(iips_State.visualization.overlayHandle,'Tag','phoCustomAnnotation');
			hold off 
		end
	end
	
	

	%%
	%% Action Handler Functions: 
	
	function iips_KeyPressFcn(fig_obj_handle, eventData)
		% The user can press:
		% [Esc]: exit this mode
		% [Spacebar]: toggle between paint and erase modes.
		% [x]: export the selected region
		% [.]: reset the selection (start a new selection). The user is prompted first
		% [l]: list current selection groups
		
		% Other key ideas:
		% 'end', 
		% 'f13': "print screen" button on mac
		if strcmp(eventData.EventName, 'KeyPress') || strcmp(eventData.EventName, 'WindowKeyPress')
			if strcmp(eventData.Key, 'escape')
				% Stop tracking the mouse
				disp('Ending continuous edit mode!')
				iips_State.isMouseBeingPressed = false;
				fig_obj_handle.WindowButtonMotionFcn = '';
				fig_obj_handle.WindowButtonUpFcn = '';
				
			elseif strcmp(eventData.Key, 'space') | strcmp(eventData.Key, 'e')
				% Toggles between erase and paint mode
				iips_toggleBrushMode();
				
			elseif strcmp(eventData.Key, 'x') | strcmp(eventData.Key, 'p')
				% Exports Selection
				iips_GetExportSelectionFcn();
				disp('Exported current selection to iips_ExportedSelectionOutput variable in workspace!')
				
			elseif strcmp(eventData.Key, 'period') | strcmp(eventData.Key, 'r')
				% Exports Selection
				userPromptForChangingSelection();
				
			elseif strcmp(eventData.Key, 'l')
				% Lists the current groups:
				% Export first before loading:
				iips_GetExportSelectionFcn();
				[did_load_from_workspace_successfully, iips_FinalLoadedAllSelections] = iips_TryGetSelectionList();
				if did_load_from_workspace_successfully
					disp('Current Selection List names:')
					% Loop through and try to find the index of the extant item:
					for i = 1:length(iips_FinalLoadedAllSelections.selectionNames)
						fprintf('\t %s\n', iips_FinalLoadedAllSelections.selectionNames{i});
					end

				else
					disp('Failed to load iips_LoadedSelectionOutput from workspace!')
				end
				
			elseif strcmp(eventData.Key, 'f1')
				iips_PrintKeyCommands();
			
			else 
				if iips_Config.debugDetail > 7
					fprintf('Unhandled key pressed: %s\n', eventData.Key)
				end
			end
		end
	end

	function iips_MouseButtonDownFcn(object, eventData)

		currHoveredPoint = iips_GetCurrentHoveredMouseLocation();
		if ~isempty(currHoveredPoint)
			% Otherwise the pixels are valid and positive:
			
% 			iips_State.isMouseBeingPressed = ~iips_State.isMouseBeingPressed;
% 			iips_State.isMouseBeingPressed = true;
			iips_State.isMouseBeingPressed = false; % TODO: Disabled hover to prevent it
			
			pixel_x = currHoveredPoint(1); 
			pixel_y = currHoveredPoint(2);

			iips_PointSelectionActionFcn(pixel_x, pixel_y);

			% Update the last hovered point
			iips_State.lastHoveredPixel = [pixel_x, pixel_y];
			
			if iips_State.isMouseBeingPressed
				object.WindowButtonMotionFcn = @iips_MouseMovedFcn;
				object.WindowButtonUpFcn = @iips_MouseButtonUpFcn;
			end
			
		end
			


		
	end

	function iips_MouseButtonUpFcn(object, eventData)
		disp('mouseButtonState: up')
% 		disp(eventData)
		iips_State.isMouseBeingPressed = false;
		
		object.WindowButtonMotionFcn = '';
        object.WindowButtonUpFcn = '';
		
	end

	% Gets the position of the plot that user is currently hovering
	function currHoveredPoint = iips_GetCurrentHoveredMouseLocation()
		% currHoveredPoint: [pixel_x, pixel_y] if valid, or [] if not.
		C = iips_State.curr_axes.CurrentPoint;
		% C: [214.447190250508, -9.66113744075824, 4098.01171301401;
		% 214.447190250508, -9.66113744075824, 0]
		
		is_outside_image_width = (C(1,1) > iips_State.curr_image_size(2));
		is_outside_image_height = (C(1,2) > iips_State.curr_image_size(1));
		is_point_position_negative = (C(1,1) < 1) || (C(1,2) < 1);
		
		if (is_point_position_negative || is_outside_image_width || is_outside_image_height)
			% if either point is negative, stop tracking and return
			iips_State.isMouseBeingPressed = false;
			iips_State.curr_figure.WindowButtonMotionFcn = '';
			iips_State.curr_figure.WindowButtonUpFcn = '';
			currHoveredPoint = [];
			return
			
		else
			% Otherwise the pixels are valid and positive:
			pixel_x = round(C(1,1)); 
			pixel_y = round(C(1,2));
			currHoveredPoint = [pixel_x, pixel_y];
			
		end
		
	end

	function iips_MouseMovedFcn(object, eventData)
		
		if ~exist('iips_State','var')
			error('iips_State variable does not exist! This should not be possible!')
		end
			
		% get(0, 'PointerLocation')
% 		C = get(gca, 'CurrentPoint');
% 		C = iips_State.curr_axes.CurrentPoint;
		
		currHoveredPoint = iips_GetCurrentHoveredMouseLocation();
		if ~isempty(currHoveredPoint)
			% Otherwise the pixels are valid and positive:
			pixel_x = currHoveredPoint(1); 
			pixel_y = currHoveredPoint(2);
			
			if ~isempty(iips_State.lastHoveredPixel)
				did_change_hovered_position = (iips_State.lastHoveredPixel ~= [pixel_x, pixel_y]);
			else
				did_change_hovered_position = true;
			end

			if did_change_hovered_position
				if iips_State.isMouseBeingPressed
					iips_PointSelectionActionFcn(pixel_x, pixel_y);
				end

	% 			disp(['Hovered New Position: (X,Y) = (', num2str(pixel_x), ', ',num2str(pixel_y), '): ', mouse_pressed_string])
			end

			% Update the last hovered point
			iips_State.lastHoveredPixel = [pixel_x, pixel_y];
		end

			
		

	end

	%%
	%% Internal Functions: 

	% Prints the static list of key commands
	function iips_PrintKeyCommands()
		fprintf([' Available Key Commands: %s \n',...
				'\t [F1]: print this menu\n',...
				'\t [Esc]: exit this mode\n',...
				'\t [Spacebar]: toggle between paint and erase modes.\n',...
				'\t [x]: export the selected region\n',...
				'\t [.]: reset the selection (start a new selection). The user is prompted first\n',...
				'\t [l]: list current selection groups\n'], '')
	end

	% Toggles between paint and erase mode:
	% TODO: set the cursor appropriately using "object.Pointer = 'circle';"
	function iips_toggleBrushMode()
		if strcmp(iips_Config.brush_mode,'paint')
			disp('Switched to Erase mode')
			iips_Config.brush_mode = 'erase'; % 'paint', 'erase'
			
		elseif strcmp(iips_Config.brush_mode,'erase')
			disp('Switched to Paint mode')
			iips_Config.brush_mode = 'paint'; % 'paint', 'erase'
		else
			error('Invalid iips_Config.brush_mode')
		end
		iips_updatePointer()
	end

	function iips_updatePointer()
		if strcmp(iips_Config.brush_mode,'paint')
			switchfigptr('add', iips_State.curr_figure)
			
		elseif strcmp(iips_Config.brush_mode,'erase')
			switchfigptr('eraser', iips_State.curr_figure)
% 			swtichfigptr % Restore the previous
		else
			error('Invalid iips_Config.brush_mode')
		end
		
	end

	% Performs a complete reset of the selection.
	function [old_selection] = iips_ResetSelection(proposedNewSelectionName, shouldExportPreviousSelection)
		if ~exist('proposedNewSelectionName','var')
			proposedNewSelectionName = 'NoNameSpecified';
		end
		
		if ~exist('shouldExportPreviousSelection','var')
			shouldExportPreviousSelection = true;
		end
		
		if shouldExportPreviousSelection
			disp('Exporting last selection...')
			old_selection = iips_GetExportSelectionFcn();
		else
			old_selection = [];
		end
		
		disp('Resetting selection...')
		iips_State.pixel_selection_mask = zeros(iips_State.curr_image_size);
		% Use our selection mask as the AlphaData for the solid green image. 
		set(iips_State.visualization.overlayHandle, 'AlphaData', (iips_State.pixel_selection_mask .* iips_Config.overlayAlpha)); 
		drawnow
		iips_State.isMouseBeingPressed = false;
		iips_State.lastHoveredPixel = '';
		iips_State.current_selection_name = proposedNewSelectionName;
		iips_State.current_selection_context = iips_State.curr_axes.Title.String; % Get the context from the current image
		iips_GetExportSelectionFcn(); % Update new selection output
		disp('\t done.')
	end

	% The main function that's called when the user selects a point.
	function iips_PointSelectionActionFcn(pixel_x, pixel_y)
		
		pixel_linearIndex = sub2ind(iips_State.curr_image_size, pixel_y, pixel_x);

		% Directly Clicked Pixel: Process and update		
		prev_directly_clicked_pixel_mask_was_selected = iips_State.pixel_selection_mask(pixel_y, pixel_x);
		% Get updated value:
		updated_directly_clicked_pixel_mask_was_selected = getUpdatedPixelValue(iips_Config, prev_directly_clicked_pixel_mask_was_selected);
		% Directly Clicked Pixel: Update pixel mask
		iips_State.pixel_selection_mask(pixel_y, pixel_x) = updated_directly_clicked_pixel_mask_was_selected;

		if iips_Config.brush_size > 1

			% From the current locus pixel, process each of its adjacent neighboring pixels that haven't been already processed.
			curr_NeighboursLinearInd = findNeighbours(pixel_linearIndex, iips_State.curr_image_size, 8); % Finds the 8 nearest neighbouring pixels.
			for currNeighbourItemIndex = 1:length(curr_NeighboursLinearInd)
				curr_neighbour_linear_index = curr_NeighboursLinearInd(currNeighbourItemIndex);
				[curr_neighbour_pixel_y, curr_neighbour_pixel_x] = ind2sub(iips_State.curr_image_size, curr_neighbour_linear_index);

				% Get neighbours previous mask value:
				prev_neighbour_pixel_mask_was_selected = iips_State.pixel_selection_mask(curr_neighbour_pixel_y, curr_neighbour_pixel_x);
				% Replace with Directly Clicked Pixel's updated value:
				updated_neighbour_pixel_mask_was_selected = getUpdatedPixelValue(iips_Config, prev_neighbour_pixel_mask_was_selected, 'Replace', updated_directly_clicked_pixel_mask_was_selected);
				% Update neighbour's value
				iips_State.pixel_selection_mask(curr_neighbour_pixel_y, curr_neighbour_pixel_x) = updated_neighbour_pixel_mask_was_selected;

			end % end for neightbors

		end % end if iips_Config.brush_size > 1	

		% Update the overlay graphic: use our selection mask as the AlphaData for the solid green image. 
		set(iips_State.visualization.overlayHandle, 'AlphaData', (iips_State.pixel_selection_mask .* iips_Config.overlayAlpha));
		drawnow
		
% 		iips_SelectionOutput = iips_GetExportSelectionFcn();
	end



	% Gets the appropriate value to change a given pixel to given the provided settings and previous values:
	function [updatedIsSelected] = getUpdatedPixelValue(iips_Config, prevWasSelected, overrideUpdateMode, extraIsSelectedValue)

		% Valid update modes are: 'Toggle', 'OR', 'Replace', 'Additive'
		% Valid brush modes are: 'paint', 'erase'

		% If the user specified and override, set that as the active update mode. Otherwise use the value in the config:
		if exist('overrideUpdateMode','var')
			active_update_mode = overrideUpdateMode;
		else
			active_update_mode = iips_Config.update_mode;
		end

		% Check the options and get the correct value:
		if strcmp(iips_Config.brush_mode, 'paint')
			% Look at mode to determine what to do:
			if strcmp(active_update_mode, 'Toggle')
				% Simple toggle mode:
				updatedIsSelected = ~prevWasSelected;

			elseif strcmp(active_update_mode, 'OR')
				%% TODO: not quite right. It should set it to the neighbour's updated value, which we don't have a paramater for!
				% Always selects it
				updatedIsSelected = (prevWasSelected | extraIsSelectedValue);

			elseif strcmp(active_update_mode, 'Replace')
				updatedIsSelected = extraIsSelectedValue;

			elseif strcmp(active_update_mode, 'Additive')
				updatedIsSelected = true;
				
			else
				error('invalid active_update_mode!')
			end

		elseif strcmp(iips_Config.brush_mode, 'erase')
			% Always deselect it
			updatedIsSelected = 0;
		else
			error('invalid iips_Config.brush_mode!')
		end

	end


	% Tries to load iips_LoadedSelectionOutput from the iips_ExportedSelectionOutput variable in the base workspace:
	function [did_load_successfully, iips_FinalLoadedAllSelections] = iips_TryGetSelectionList()
		did_load_successfully = false;
		try
		   iips_FinalLoadedAllSelections = evalin('base', 'iips_ExportedSelectionOutput');
		   did_load_successfully = true;
		catch ME
			iips_FinalLoadedAllSelections = {};
			if (strcmp(ME.identifier,'MATLAB:UndefinedFunction'))
			  % Handled exception
			  % iips_ExportedSelectionOutput does not existin base
				disp('iips_ExportedSelectionOutput does not exist in base workspace. Could not load')
				return; % We're done here, just return.
		   else
			   disp('Unhandled exception:')
			   rethrow(ME)
		   end

		end % End try/catch 

	end


	% Tries to load the selection set with the given selectionName from the base workspace
	function [did_load_successfully, loaded_selections, found_extant_selection_index] = iips_TryLoadSelection(selectionName)
		% Tries to load it from the iips_ExportedSelectionOutput variable in the base workspace:
		did_load_successfully = false;
		
		try
		   iips_LoadedSelectionOutput = evalin('base', 'iips_ExportedSelectionOutput');
		catch ME
			loaded_selections = [];
		    found_extant_selection_index = -1;
			if (strcmp(ME.identifier,'MATLAB:UndefinedFunction'))
			  % Handled exception
			  % iips_ExportedSelectionOutput does not existin base
				disp('iips_ExportedSelectionOutput does not exist in base workspace. Could not load')
				return; % We're done here, just return.
		   else
			   disp('Unhandled exception:')
			   rethrow(ME)
		   end

		end 

		
		if exist('iips_LoadedSelectionOutput','var')
			iips_FinalLoadedAllSelections = iips_LoadedSelectionOutput;
			
			% Loop through and try to find the index of the extant item:
			for i = 1:length(iips_FinalLoadedAllSelections.selectionNames)
				if strcmp(iips_FinalLoadedAllSelections.selectionNames{i}, selectionName)
					found_extant_selection_index = i;
					break; % quit searching, we found it.
				end
			end
			
			if ~exist('found_extant_selection_index','var')
				% If we never found a matching index
				loaded_selections = [];
				found_extant_selection_index = -1;
				return; % We're done here, return.
				
			else
				% Otherwise replace the value of the selections at the corresponding index:
				loaded_selections = iips_FinalLoadedAllSelections.selections{found_extant_selection_index};
				did_load_successfully = true;
			end

						
		else
			% Doesn't exist
			disp('iips_ExportedSelectionOutput does not exist in workspace! Could not load it')
			loaded_selections = [];
			found_extant_selection_index = -1;
			return;
		end
		
		
	end

	% Given loadedSelections, updates the display, state, etc to display them.
	function iips_PerformLoadSelections(loadedSelections)
		disp('Loading selections...')
		iips_State.pixel_selection_mask = loadedSelections.selection_mask;
		% Use our selection mask as the AlphaData for the solid green image. 
		set(iips_State.visualization.overlayHandle, 'AlphaData', (iips_State.pixel_selection_mask .* iips_Config.overlayAlpha)); 
		drawnow
		iips_State.isMouseBeingPressed = false;
		iips_State.lastHoveredPixel = '';
		iips_State.current_selection_name = loadedSelections.name;
		iips_State.current_selection_context = iips_State.curr_axes.Title.String; % Get the context from the current image
% 		iips_SelectionOutput = iips_GetExportSelectionFcn(); % Update new selection output
		disp('\t done.')
	end

	% Wraps iips_TryLoadSelection and iips_PerformLoadSelections to try to load the selections with the given selectionName and update the interface
	function [did_load_successfully] = iips_CompleteLoadSelections(selectionName)
		[did_load_successfully, loaded_selections, found_extant_selection_index] = iips_TryLoadSelection(selectionName);
		if ~did_load_successfully
			disp(['Failed to load selections with name: ', selectionName]);
			return
			
		else
			% Double-check to make sure the selections are valid for this file:
			if ~strcmp(iips_State.current_selection_context, loaded_selections.image)
				error('The selection context differs for the current figure and the .image data contained in the loaded selections! Are you sure these selections were made from this image? Aborting!');
				did_load_successfully = false;
			end

			disp(['Successfully loaded selections with name: ', selectionName]);			
			iips_PerformLoadSelections(loaded_selections);
		
		end % end if ~did_load_successfully
		
	end

	% Exports the given selection to the workspace:
	function iips_SelectionOutput = iips_GetExportSelectionFcn()
				
		% Print list of currently selected pixels:
		iips_SelectionOutput.name = iips_State.current_selection_name;
		iips_SelectionOutput.image = iips_State.current_selection_context;
		iips_SelectionOutput.selection_mask = iips_State.pixel_selection_mask;
		iips_SelectionOutput.selected_linear_indicies = find(iips_State.pixel_selection_mask == 1);
		
		num_selections = length(iips_SelectionOutput.selected_linear_indicies);
		
		% Initialize outputs
		iips_SelectionOutput.locations = zeros([num_selections, 2]);
		iips_SelectionOutput.pixel_values = zeros([num_selections, 1], 'uint8');
	
		for i = 1:num_selections
			curr_selected_linear_index = iips_SelectionOutput.selected_linear_indicies(i);
			[curr_selected_pixel_y, curr_selected_pixel_x] = ind2sub(iips_State.curr_image_size, curr_selected_linear_index);

			%% Add to the output arrays:
			iips_SelectionOutput.locations(i,:) = [curr_selected_pixel_x, curr_selected_pixel_y];
			iips_SelectionOutput.pixel_values(i) = iips_State.curr_image(curr_selected_pixel_y, curr_selected_pixel_x);
			
		end % end for num_selections
		
		% Exports the iips_SelectionOutput to the base workspace
		
		% Tries to load it from the base workspace:
		
		try
		   iips_ExportedSelectionOutput = evalin('base', 'iips_ExportedSelectionOutput');
		catch ME
			%disp('Unrecognized function or variable');
		   if (strcmp(ME.identifier,'MATLAB:UndefinedFunction'))
			  % Handled exception
			  % iips_ExportedSelectionOutput does not existin base
			  disp('iips_ExportedSelectionOutput does not exist in base workspace. Creating it!')
				
		   else
			   disp('Unhandled exception:')
			   rethrow(ME)
			   
		   end

		end % end try/catch

		if exist('iips_ExportedSelectionOutput','var')
			iips_FinalAllSelectionsOutput = iips_ExportedSelectionOutput;
			
			% Loop through and try to find the index of the extant item:
			for i = 1:length(iips_FinalAllSelectionsOutput.selectionNames)
				if strcmp(iips_FinalAllSelectionsOutput.selectionNames{i}, iips_SelectionOutput.name)
					found_extant_selection_index = i;
					break; % quit searching, we found it.
				end
			end
			
			if ~exist('found_extant_selection_index','var')
				% If we never found a matching index, add a new one to the end of the arrays:
				iips_FinalAllSelectionsOutput.selectionNames{end+1} = iips_SelectionOutput.name;
				iips_FinalAllSelectionsOutput.selections{end+1} = iips_SelectionOutput;
			else
				% Otherwise replace the value of the selections at the corresponding index:
				iips_FinalAllSelectionsOutput.selections{found_extant_selection_index} = iips_SelectionOutput;
				
			end

						
		else
			% Doesn't exist
			disp('iips_ExportedSelectionOutput does not exist in workspace! Creating a new struct from it!')
			iips_FinalAllSelectionsOutput.selectionNames = {iips_SelectionOutput.name}; % New cell array containing only name
			iips_FinalAllSelectionsOutput.selections = {iips_SelectionOutput};
			
		end
		
		% Build the map for the output file, overwritting any extant one.
		iips_FinalAllSelectionsOutput.nameToIndexMap = containers.Map(iips_FinalAllSelectionsOutput.selectionNames', 1:length(iips_FinalAllSelectionsOutput.selectionNames));
		
		assignin('base','iips_ExportedSelectionOutput', iips_FinalAllSelectionsOutput);
		%disp('Exported current selection to iips_ExportedSelectionOutput variable in workspace!')
	
	end


	% Prompts the user to reset selection, and handles the response
	% If the name the user enters already exists in the selections list, it is loaded instead of creating a new one.
	function userPromptForChangingSelection()
		
		[willChangeSelections, proposedGroupName] = userResetConfirmationOptionsDialog();
		if ~willChangeSelections
			disp('Continuing.')
			return
		else
			disp(['Changing selection, proposed selection name: ' proposedGroupName]);
			
			[did_load_successfully] = iips_CompleteLoadSelections(proposedGroupName);
			if ~did_load_successfully
				% Selections didn't already exist, creating a new group
				disp(['Selections with name ', proposedGroupName, ' did not already exist in the workspace selections index, so new ones were created.'])
				[old_selection] = iips_ResetSelection(proposedGroupName);
				iips_State.current_selection_name = proposedGroupName;
			else
				disp(['Selections with name ', proposedGroupName, ' already exist in the workspace selections index, and were loaded!'])
			end
			
		end
		
	end


	function [willChangeSelections, newGroupName] = userResetConfirmationOptionsDialog()
		% Asks the user whether to load an existing user annotations file, create a new one, or go on without annotations.
		prompt = {'Enter name for selections group:'};
		answer = inputdlg(prompt);
		
		% Handle response
		newGroupName = answer{1};

		if ~isempty(newGroupName)
			willChangeSelections = true;
		else
			% The user canceled!
			disp('The user canceled reset dialog! Continuing with current selection!')
			willChangeSelections = false;
			return
		end

	end % end function

end