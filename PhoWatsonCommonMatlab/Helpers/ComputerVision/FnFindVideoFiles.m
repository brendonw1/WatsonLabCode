function [videoFilesData] = FnFindVideoFiles(rootSearchPath, videoFileExtension)
%FnFindVideoFiles Finds the .mp4 video files in the provided search path, non-recurrsively, and then returns a table containing the file names and their metadata.
%   Called in BatchProcessVideoFileAnalyzer to get the video files

	if ~exist(rootSearchPath,'dir')
		error(rootSearchPath); 
	end

	if ~exist('videoFileExtension','var')
		videoFileExtension = '.mp4';
	end

% 	search_string = '*.mp4';
	search_string = ['*', videoFileExtension];

	% Find all video files in the directory:
	fullSearchPathFilterB = fullfile(rootSearchPath, search_string);
	videoFilesData = dir(fullSearchPathFilterB);

end

