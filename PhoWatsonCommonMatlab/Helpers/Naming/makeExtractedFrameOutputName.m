function [curr_output_name] = makeExtractedFrameOutputName(pbeExtractedFrame, fallback_resultIndex, fallback_BBIDString)
%MAKEEXTRACTEDFRAMEOUTPUTNAME Builds an output filename without extension for extracted video frames.
%   Detailed explanation goes here

%%%+S- pbeExtractedFrame
	%- image - image is the greyscale image extracted
	%- frameIndex - frameIndex contains the integer frame number it was extracted from, or -1 if it doesn't have one
	%- sourceName - sourceName contains the basename of the video it was extracted from, or '' otherwise.
%

% curr_output_name is built iteratively, depending on what information is available
curr_output_name = 'extractedFrame';
hasUniqueId = false;

	% Frame Index:
	if pbeExtractedFrame.frameIndex > -1
		curr_output_name = [curr_output_name, '_Frame_', num2str(pbeExtractedFrame.frameIndex)];
		hasUniqueId = true;
	end

	% Source Name:
	if ~isempty(pbeExtractedFrame.sourceName)
		curr_output_name = [curr_output_name, '_', pbeExtractedFrame.sourceName];    
	end

	if ~hasUniqueId
		% Do fallback setup:
		if exist('fallbackBBID','var')
			curr_output_name = [curr_output_name, '_BB', fallback_BBIDString];
		end
		if exist('fallback_resultIndex','var')
			curr_output_name = [curr_output_name, '_i', num2str(fallback_resultIndex)];
		end
	end
			
end

