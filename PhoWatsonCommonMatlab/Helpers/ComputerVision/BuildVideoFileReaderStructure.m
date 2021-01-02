function [bbvaVideoFile, bbvaCurrFrameSegment] = BuildVideoFileReaderStructure(curr_video_parent_path, curr_video_name)
%BUILDVIDEOFILEREADERSTRUCTURE Builds a bbvaVideoFile and bbvaCurrFrameSegment structure from a video file path and name
%   Detailed explanation goes here

%%%+S- bbvaVideoFile
	%- filename* - filename is the filename with extension
	%- relative_file_path - relative_file_path is a 
	%- basename - basename is a 
	%- extension - extension is a 
	%- full_parent_path - full_parent_path is a 
	%- full_path - full_path is a 
	%- boxID - boxID is a 
	%- parsedDateTime - parsedDateTime is a 
	%- FrameRate - FrameRate is a 
	%- DurationSeconds - DurationSeconds is a 
	%- parsedEndDateTime - parsedEndDateTime is a 
	%- startFrameIndex - startFrameIndex is a 
    %- estimatedEndFrameIndex - estimatedEndFrameIndex is the number of frames estimated by videoReader
		%%% REMOVED?
		% - endFrameIndex - endFrameIndex is a 
		% - frameIndexes - frameIndexes is a 
		% - frameTimestamps - frameTimestamps is a 
	%- num_frames_actually_read - num_frames_actually_read is the number of frames actually read during the getFrame method.
	%- v - v is the VideoReader object to get frames from that video
%

%%%+S- bbvaCurrFrameSegment: This is for batch processing a single video in segments on multiple computers. The block of frames in the current segment: WARNING: the endFrameIndex can be not-reflective of the video's end frame index due to VideoReader estimation errors.
	%- startFrameIndex - startFrameIndex is Absolute video frame to start on
	%- endFrameIndex - endFrameIndex is Absolute video frame to end on
	%- absoluteVideoFrameIndexes - absoluteVideoFrameIndexes is The absolute video indicies corresponding to this segment.
	%- selectedNumberOfFrames - selectedNumberOfFrames
	%- segmentRelativeFrameIndexes - segmentRelativeFrameIndexes is The 1:bbvaCurrFrameSegment.selectedNumberOfFrames indicies for this segment
%


	bbvaVideoFile.filename = curr_video_name;

	bbvaVideoFile.relative_file_path = fullfile(curr_video_parent_path, bbvaVideoFile.filename);
	[~,bbvaVideoFile.basename, bbvaVideoFile.extension] = fileparts(bbvaVideoFile.filename);
	bbvaVideoFile.v = VideoReader(bbvaVideoFile.relative_file_path);
	bbvaVideoFile.full_parent_path = bbvaVideoFile.v.Path;
	bbvaVideoFile.full_path = fullfile(bbvaVideoFile.full_parent_path, bbvaVideoFile.filename);
	[videoFileInfo] = ParsePhoOBSVideoFileName(bbvaVideoFile.full_path);
	bbvaVideoFile.boxID = videoFileInfo.boxID;
	bbvaVideoFile.parsedDateTime = videoFileInfo.dateTime;
	tempVideoReaderInfo = get(bbvaVideoFile.v);
	% Number of video frames per second
	bbvaVideoFile.FrameRate = tempVideoReaderInfo.FrameRate;
	% Length of the file in seconds
	bbvaVideoFile.DurationSeconds = tempVideoReaderInfo.Duration;
	bbvaVideoFile.parsedEndDateTime = bbvaVideoFile.parsedDateTime + seconds(bbvaVideoFile.DurationSeconds);
	bbvaVideoFile.num_frames_actually_read = 0;

	%    Video Frames
	% startFrameIndex = 1;
	% endFrameIndex = v.numFrames;

	% All frames of the video file:
	bbvaVideoFile.startFrameIndex = 1;
	bbvaVideoFile.estimatedEndFrameIndex = bbvaVideoFile.v.numFrames;
	% bbvaVideoFile.endFrameIndex = v.numFrames;
	% bbvaVideoFile.frameIndexes = bbvaVideoFile.startFrameIndex:bbvaVideoFile.endFrameIndex;
	% bbvaVideoFile.frameTimestamps = bbvaVideoFile.parsedDateTime + seconds(bbvaVideoFile.frameIndexes/bbvaVideoFile.FrameRate);


	% The block of frames in the current segment:
	bbvaCurrFrameSegment.startFrameIndex = 1; % Absolute video frame to start on
	bbvaCurrFrameSegment.endFrameIndex = bbvaVideoFile.estimatedEndFrameIndex; % Absolute video frame to end on
	bbvaCurrFrameSegment.absoluteVideoFrameIndexes = bbvaCurrFrameSegment.startFrameIndex:bbvaCurrFrameSegment.endFrameIndex; % The absolute video indicies corresponding to this segment.
	bbvaCurrFrameSegment.selectedNumberOfFrames = length(bbvaCurrFrameSegment.absoluteVideoFrameIndexes);
	bbvaCurrFrameSegment.segmentRelativeFrameIndexes = 1:bbvaCurrFrameSegment.selectedNumberOfFrames; % The 1:bbvaCurrFrameSegment.selectedNumberOfFrames indicies for this segment


end

