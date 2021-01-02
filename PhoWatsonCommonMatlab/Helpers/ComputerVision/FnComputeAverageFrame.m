function [accumulated_average_frame] = FnComputeAverageFrame(varargin)
%FnComputeAverageFrame Computes the normalized average of several frames
% Accepts either one frame per argument, or a single argument containing a cell array of frames.
numFrameInputs = nargin;

if numFrameInputs == 1
	if iscell(varargin{1})
		framesList = varargin{1};
	else
		error('FnComputeAverageFrame(...) called with only one argument and it is not a list of frames! Why would you take the average of only one item?');
	end
else
	framesList = varargin;
end

% Get the first frame
accumulated_average_frame = framesList{1};

for i=2:(numFrameInputs-1)
	% Get the first frame
	curr_greyscale_frame = framesList{i};

	% Get histogram for the current frame:
	curr_frame_hist = imhist(curr_greyscale_frame);

	% Equalize the Histograms of the current frame and the static reference frame for valid comparisons.
	curr_normalized_static_reference_frame = histeq(accumulated_average_frame, curr_frame_hist);
	
	% Find the mean, and convert it back to a uint8 frame
	accumulated_average_frame = uint8((double(accumulated_average_frame) + double(curr_normalized_static_reference_frame)) ./ 2.0);
	
end


end

