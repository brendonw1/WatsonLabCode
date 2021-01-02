% Enables the user to "paint" the current plot in a binary fashion to select or deselect pixels.

%% INPUT:
	% The user can press:
		% [Esc]: exit this mode
		% [Spacebar]: toggle between paint and erase modes.
		% [x]: export the selected region
		% [.]: reset the selection (start a new selection). The user is prompted first

		



% See http://undocumentedmatlab.com/articles/enabling-user-callbacks-during-zoom-pan for a workaround while zooming


% iips_State
% global iips_Config;
% global iips_State;

% Reset:
% clear iips_State

[new_iips_Config, new_iips_State] = InteractiveImagePixelSelectionFn();


% TODO: Check if it's still a valid figure and graphics object:
% iips_State.curr_axes
% 

% 
%% Main Update Loop:
	% Let user select a pixel:
% 	[x,y] = ginput(1);
% 	pixel_x = round(x); 
% 	pixel_y = round(y);
	
% end


% while condition loc = get(0, 'CurrentPosition');
%     %// Do something
%     %...
%     %...
%     pause(0.01); %// Pause for 0.01 ms
% end
% 
% 
