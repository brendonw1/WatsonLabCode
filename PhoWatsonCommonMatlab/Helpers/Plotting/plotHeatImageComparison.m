function [curr_fig, h_plots, h] = plotHeatImageComparison(varargin)
%PLOTHEATIMAGECOMPARISON Summary of this function goes here
%   Detailed explanation goes here

% Allows one or more phi_config type structures or raw images to plot.

%phi_conifg.image
%phi_config.title
%phi_config.colorMap

num_args = nargin;

phiConfigs = cell([0, 1]); % configs
parsedStringArguments = {};

user_passed_figure_handle = false; % set to true if the user passed in the figure to plot on as the argument.

% Loop through the input arguments:
for i=1:nargin
	curr_arg = varargin{i};
	
	if isgraphics(curr_arg)
		if (isgraphics(curr_arg,'figure') | isgraphics(curr_arg,'uifigure'))
			user_passed_figure_handle = true;
			curr_fig = curr_arg;
		else
			error('Unknown graphics objects passed in! Should be a figure!')
		end
	
	elseif isstruct(curr_arg)
		% Check to make sure it's of type phi_conifg, or at least that it has an image
		if isfield(curr_arg, 'image')			
			% A PhiConfig argument:
			phiConfigs{end+1} = curr_arg;
			
		else
			error('Unknown structure type argument! Should be a phi_conifg struct!');
			
		end
	
	elseif islogical(curr_arg)
		% Treat this logical as a raw binary image mask.
		% Wrap in a new phiConfig.
		new_config.image = int8(curr_arg);
		new_config.colorMap = 'Gray'; % set greyscale colormap
		phiConfigs{end+1} = new_config;
% 		fprintf('Treating argument %d as a raw image.\n', i);
		
	elseif isnumeric(curr_arg)
		% If it's a raw-image passed in:
		% Wrap in a new phiConfig.
		new_config.image = curr_arg;
		phiConfigs{end+1} = new_config;
% 		fprintf('Treating argument %d as a raw image.\n', i);
		
	elseif (ischar(curr_arg) | isStringScalar(curr_arg))
		% See if it's a string-type argument.
		parsedStringArguments =  varargin(i:end);
		break % the rest are string arguments, end execution
	else
		error('Item of wrong form! Should be a phi_conifg struct!');
	end
end

% Parse the string arguments if there are any:
for i = 1:length(parsedStringArguments)
	curr_arg = parsedStringArguments{i};
	if ~(ischar(curr_arg) | isStringScalar(curr_arg))
		error('Invaid string type argument! All strings must be last in the arguments list!')
	end
	%% TODO: parse string arguments:
	fprintf('Warning, ignoring string argument: %s. Feature not implemented! \n', curr_arg);
end


num_image_configs = length(phiConfigs);
num_plots = num_image_configs;

if num_image_configs < 1
	error("Need at least one image config to plot!");
end

% Set up the figure to plot on:
if ~user_passed_figure_handle
	curr_fig = figure(); % Create a new figure.
end
% Clear the passed figure either way.
clf;


percent_width = 1.0/double(num_plots);



% Loop through the image configs:
for i=1:num_image_configs
	curr_config = phiConfigs{i};
	curr_image = curr_config.image;

	h_plots{i} = subplot(1,num_plots,i);
	h{i} = imagesc(h_plots{i}, curr_image);
	
	if isfield(curr_config, 'title')
		title(h_plots{i}, curr_config.title, "Interpreter","none");
	end
	
	if isfield(curr_config, 'colorMap')
		if ~isempty(curr_config.colorMap)
			colormap(h_plots{i}, curr_config.colorMap); 
		end
	end
	set(h_plots{i},'xtick',[])
	set(h_plots{i},'xticklabel',[])
	set(h_plots{i},'ytick',[])
	set(h_plots{i},'yticklabel',[])
	set(h_plots{i},'PlotBoxAspectRatioMode','manual','PlotBoxAspectRatio',[320,256,1]);
	
	colorbar('south')
	
end

% Update the positions of the plots to remove the padding:
for i=1:num_plots
	curr_x_offset = double(i-1) * percent_width;
	set(h_plots{i},'position',[curr_x_offset, 0.0, percent_width, 1.0]);
	
	if isfield(phiConfigs{i}, 'title')
		[curr_textbox_annotation{i}] = FnAddTitleAsAnnotationText(h_plots{i});
	end
	
	
end
drawnow


end


