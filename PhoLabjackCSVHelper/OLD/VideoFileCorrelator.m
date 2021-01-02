addpath(genpath('HelperFunctions'));
%% Set default datetime display properties (this doesn't affect the values stored, only their display/preview in MATLAB)
datetime.setDefaultFormats('default','yyyy-MM-dd hh:mm:ss.SSS');
time_reference = datenum('1970', 'yyyy');

if ~exist('videoFiles','var')
    [videoFiles.fileName, videoFiles.parentPath, filterindex] = uigetfile('*.avi;*.mp4', 'Select a recorded video file', 'MultiSelect', 'off');
    %uigetdir('C:\Users\watsonlab\Desktop\Behavioral Box Data\Camera Data');
    videoFiles.filePath = fullfile(videoFiles.parentPath,videoFiles.fileName);
end

% Find all video files in the directory
fullSearchPathFilterA = fullfile(videoFiles.parentPath,'*.avi');
%fullSearchPathFilterB = fullfile(videoFiles.parentPath,'*.mp4');
%fullSearchPathFilter = [fullSearchPathFilterA; fullSearchPathFilterB]
videoFilesData = dir(fullSearchPathFilterA);


%% Process video files
for fileIndex = 1:length(videoFilesData)
    % Construct the full file path
    currFilePath = fullfile(videoFiles.parentPath, videoFilesData(fileIndex).name);
    [videoFolder, baseVideoFileName, videoExtension] = fileparts(videoFilesData(fileIndex).name);
    videoNameParts = strsplit(baseVideoFileName,'_'); % Requires no path in videoPath, just filename
    combinedVideoDateString = videoNameParts{2} + "T" + videoNameParts{3};
    %videoDateTime(fileIndex) = datetime(combinedVideoDateString,'InputFormat','yyyyMMdd''T''HHmmssSSS');
    videoFilesData(fileIndex).parsedDateTime = datetime(combinedVideoDateString,'InputFormat','yyyyMMdd''T''HHmmssSSS');
    
    videoFileReader = VideoReader(currFilePath);
    info = get(videoFileReader);
    % Number of video frames per second
    videoFilesData(fileIndex).FrameRate = info.FrameRate;
    % Length of the file in seconds
    videoFilesData(fileIndex).DurationSeconds = info.Duration;
    videoFilesData(fileIndex).parsedEndDateTime = videoFilesData(fileIndex).parsedDateTime + seconds(videoFilesData(fileIndex).DurationSeconds);
    
    %videoFilesData(fileIndex).getRelativeTime = @(absoluteDate) getRelativeTimeInVideoFile(videoFilesData(fileIndex),absoluteDate);
end

% Converts Absolute date to relative date or NaN
%fun1 = @(absoluteDate)  if (isbetween(absoluteDate,videoFilesData(fileIndex).parsedDateTime,videoFilesData(fileIndex).parsedEndDateTime))
    



% fileNameParts = split(fileName,'.');
% fileNameComponents = split(fileNameParts(1),'_');
% fileNameNumberingSuffix = fileNameComponents(end);
% 
% combinedOutputFilenameComponents = fileNameComponents(1:end-1);
% combinedOutputFilenameComponents(end+1) = {'Combined'};
% 
% combinedOutputBasename = join(combinedOutputFilenameComponents, '_');
% combinedOutputSuffix = fileNameParts(2:end);
% combinedOutputFilenameParts = [combinedOutputBasename; combinedOutputSuffix];
% combinedOutputFilenameTemp = join(combinedOutputFilenameParts, '.');
% combinedOutputFilename = combinedOutputFilenameTemp{1};