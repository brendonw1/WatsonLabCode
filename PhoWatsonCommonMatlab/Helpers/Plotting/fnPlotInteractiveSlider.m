%% Requires a two cell arrays: x_cells, y_cells
function [FigH, pis] = fnPlotInteractiveSlider(x_cells, y_cells, extant_fig, seriesConfigs)
%FNPLOTINTERACTIVESLIDER figure with an interactive slider that allows you
	% to scroll through multiple series (x vector, y vector pairs) that will be
	% plotted on the plot.

	% x_cells: an N x 1 cell array of series': composed of arrays of doubles.
	% y_cells: an N x 1 cell array of series': composed of arrays of doubles.
	% extant_fig: an existing figure handle you want to plot on.
	% seriesConfigs: an optional pisConfig object used to add labels, etc
	% to plots
	
	%%%+S- pisInfo
		%= NumberOfSeries - constructed from the actual frame index
		%= curr_i - Current series index: i
		%= lim - The global xlim and ylims for all series
	%
	
	%%%+S- pisConfig
		%- xlabel - an N x 1 cell array of charStrings
		%- ylabel - an N x 1 cell array of charStrings
		%- title - an N x 1 cell array of charStrings
		%= additionalDisplayData.mainPlotAxesHandle - holds the plot axes
	%
	
	
	% pisInfo: plotInteractiveSliderInfo:
	
	if ~exist('extant_fig','var')
		% create a new figure
		FigH = figure;
	else
		%clf(extant_fig);
		FigH = extant_fig;
	end

	pisInfo.NumberOfSeries = length(x_cells);
	if (length(y_cells) ~= pisInfo.NumberOfSeries)
		if (length(y_cells{1}) ~= pisInfo.NumberOfSeries)
			% Check and see if its a multi-data series by checking the
			% first item and seeing if it's a
			error('x_cells and y_cells should be cell arrays of the same length. This corresponds to the x_cells{i}, y_cells{i} is the series that will be plotted when the slider is set to i.')
		end
	end
	
	if exist('seriesConfigs','var')
		
		if isfield(seriesConfigs, 'lim')
			[pisInfo.lim] = seriesConfigs.lim; % Use the version passed in.
		else
			[pisInfo.lim] = fnFindSeriesBounds(x_cells, y_cells, false);
		end
		
		
		if isfield(seriesConfigs, 'xlabel')
			if ischar(seriesConfigs.xlabel) % If it's a simple char string
				% Repeat the label for each series
				pisConfig.xlabel = cell(1, pisInfo.NumberOfSeries);
				pisConfig.xlabel(:) = {seriesConfigs.xlabel};
			elseif iscellstr(seriesConfigs.xlabel) % if it's a cell array. Note: Assumes correct length
				if (length(seriesConfigs.xlabel) ~= pisInfo.NumberOfSeries)
					error('Wrong length!')
				end
				pisConfig.xlabel = seriesConfigs.xlabel;
			else
				error('Unknown type for: xlabel')	
			end
		end
		
		if isfield(seriesConfigs, 'ylabel')
			if ischar(seriesConfigs.ylabel) % If it's a simple char string
				% Repeat the label for each series
				pisConfig.ylabel = cell(1, pisInfo.NumberOfSeries);
				pisConfig.ylabel(:) = {seriesConfigs.ylabel};
			elseif iscellstr(seriesConfigs.ylabel) % if it's a cell array. Note: Assumes correct length
				if (length(seriesConfigs.ylabel) ~= pisInfo.NumberOfSeries)
					error('Wrong length!')
				end
				pisConfig.ylabel = seriesConfigs.ylabel;
			else
				error('Unknown type for: ylabel')	
			end
		end
		
		if isfield(seriesConfigs, 'title')
			if ischar(seriesConfigs.title) % If it's a simple char string
				% Repeat the label for each series
				pisConfig.title = cell(1, pisInfo.NumberOfSeries);
				pisConfig.title(:) = {seriesConfigs.title};
			elseif iscellstr(seriesConfigs.title) % if it's a cell array. Note: Assumes correct length
				if (length(seriesConfigs.title) ~= pisInfo.NumberOfSeries)
					error('Wrong length!')
				end
				pisConfig.title = seriesConfigs.title;
			else
				error('Unknown type for: title')	
			end
		end

		if isfield(seriesConfigs, 'legend')
			if iscellstr(seriesConfigs.legend) % If it's a non-nested cell array
				% Repeat the cell array of legend strings for each series (making a cell array of cell arrays)
				pisConfig.legend = cell(1, pisInfo.NumberOfSeries);
				pisConfig.legend(:) = {seriesConfigs.legend};
			elseif iscell(seriesConfigs.legend) % if it's a cell array. Note: Assumes correct length
				if (length(seriesConfigs.legend) ~= pisInfo.NumberOfSeries)
					error('Wrong length!')
				end
				pisConfig.legend = seriesConfigs.legend;
			else
				error('Unknown type for: legend')	
			end
		end
	
	end
	
	% Current index: i
	setappdata(FigH,'curr_i',1); % Set the app data to the initial value:
	pisInfo.curr_i = getappdata(FigH,'curr_i'); % Set the pisInfo.curr_i value from the app data.
	% Update the plots initially.
	update_plots(pisInfo.curr_i);
	
	%% Slider:
    % Gets the slider position from the figure
    pisSettings.sliderWidth = FigH.Position(3) - 20;
    pisSettings.sliderHeight = 23;
    pisSettings.sliderX = 5;
    pisSettings.sliderY = 0;

	maxSliderValue = pisInfo.NumberOfSeries;
	minSliderValue = 1;
	theRange = maxSliderValue - minSliderValue;
	pisSettings.steps = [1/theRange, 10/theRange];

    % svp.Slider = uicontrol(svp.Figure,'Style','slider',...
    pis.Slider = uicontrol(FigH,'Style','slider',...
                    'Min',1,'Max',pisInfo.NumberOfSeries,'Value',pisInfo.curr_i,...
					'SliderStep',pisSettings.steps,...
                    'Position', [pisSettings.sliderX,pisSettings.sliderY,pisSettings.sliderWidth,pisSettings.sliderHeight]);

    pis.Slider.Units = "normalized"; %Change slider units to normalized so that it scales with the video window.
    addlistener(pis.Slider, 'Value', 'PostSet', @slider_post_update_function);

	%% Slider callback function:
	function slider_post_update_function(~, event_obj)
        % ~            Currently not used (empty)
        % event_obj    Object containing event data structure

        % get the current index from the slider
        pisInfo.curr_i = round(event_obj.AffectedObject.Value);
		% Update the app data:
		setappdata(FigH,'curr_i',pisInfo.curr_i);
		% Update the plots now:
		update_plots(pisInfo.curr_i);
	end

	function update_plots(curr_i)
		% Update the plot:
		% Enable Nested Cell Arrays:
		y_data = y_cells{curr_i};

		% Make a single-element cell array if the y_data is only a single series
		if ~iscell(y_data)
			y_data = {y_data}; % Make a single-element cell array
		end
		
		% Loop through the subseries (if there are any) and plot them with hold
		% on.
		numSubSeries = length(y_data);
		hold off
		for j = 1:numSubSeries
			pisConfig.additionalDisplayData.mainPlotAxesHandle = plot(x_cells{curr_i}, y_data{j},'Tag','plotInteractiveSliderMainPlotHandle');
			hold on
		end
		% Do common plotting:
		xlim([pisInfo.lim(1),pisInfo.lim(2)]);
		ylim([pisInfo.lim(3),pisInfo.lim(4)]);
		if isfield(pisConfig, 'xlabel')
			xlabel(pisConfig.xlabel{pisInfo.curr_i});
		end
		if isfield(pisConfig, 'ylabel')
			ylabel(pisConfig.ylabel{pisInfo.curr_i});
		end
		if isfield(pisConfig, 'title')
			title(pisConfig.title{pisInfo.curr_i});
		end
		if isfield(pisConfig, 'legend')
			legend(pisConfig.legend{pisInfo.curr_i});
		end
		
	end

end
