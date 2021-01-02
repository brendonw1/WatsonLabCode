function [relative_output_bbvaSettings] = makeActigraphyOutputFileName(videoBasename, startFrameIndex, endFrameIndex)
%MAKEACTIGRAPHYOUTPUTFILENAME Summary of this function goes here
%   Detailed explanation goes here

%%%+S- relative_output_bbvaSettings
	%- video_frame_string - video_frame_string is string containing the current frames processed in this segment
	%- final_output_name - final_output_name is the final name of the actigrpahy output file produced by this script
%

% Build the final output info:
video_name_string = videoBasename;
video_frame_string = sprintf("frames_%d-%d", startFrameIndex, endFrameIndex);
frames_data_output_suffix = 'processed_output';
actigraphyFileName = join([frames_data_output_suffix, video_name_string, video_frame_string, ".mat"],"_");

% Final output structure:
relative_output_bbvaSettings.video_frame_string = video_frame_string;
relative_output_bbvaSettings.final_output_name = actigraphyFileName;

end

