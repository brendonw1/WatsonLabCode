function [curr_textbox_annotation] = FnAddTitleAsAnnotationText(subplot_handle)
%FNADDTITLEASANNOTATIONTEXT Given an extant subplot_handle, takes the title property and instead creates a textbox annotation positioned near the bottom center of each subplot.
%   Detailed explanation goes here
	TextboxHeight = 0.08; % Hardcoded constant 
	TextboxTextColor = [0.941176470588235 0.941176470588235 0.941176470588235]; % White
	
	% Get the owning parent figure:
	curr_parent_figure = subplot_handle.Parent;
	
	% Recover position to compute where to place the annotation in the parent figure
	curr_position_cell = num2cell(get(subplot_handle,'position'));
	[curr_x_offset, curr_y_offset, percent_width, percent_height] = curr_position_cell{:};
	
	curr_textbox_y_offset = curr_y_offset + TextboxHeight;
	curr_textbox_position = [curr_x_offset curr_textbox_y_offset percent_width TextboxHeight];
        
	% Reads the existing title from the subplot.
	g = get(subplot_handle,'title');
	curr_textbox_title = get(g,'string');
	curr_textbox_text = {curr_textbox_title}; % Can do multiline text by using {'line 1', 'line 2'}

	if ~isempty(curr_textbox_text)
		% Create textbox to draw the title:
		curr_textbox_annotation = annotation(curr_parent_figure,'textbox',curr_textbox_position,'Color',TextboxTextColor,...
			'String',curr_textbox_text,...
			'Interpreter','none',...
			'HorizontalAlignment','center',...
			'FitBoxToText','off',...
			'FontSize',12);

		%% Add background
		set(curr_textbox_annotation, 'FitBoxToText','on',...
			'FaceAlpha',0.6,...
			'BackgroundColor',[0 0 0]);
		
	else
		% No title to render, so don't draw an empty annotation box.
		curr_textbox_annotation = '';
	end
	
end

