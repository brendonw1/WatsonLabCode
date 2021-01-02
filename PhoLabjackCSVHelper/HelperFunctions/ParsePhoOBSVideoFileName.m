function [videoFile] = ParsePhoOBSVideoFileName(videoFilePath)
%PARSEPHOOBSVIDEOFILENAME Parses the name of a OBS-recorded video file (the format created 7/25/2019 by Pho Hale)
%   Detailed explanation goes

format long g

% BehavioralBox_B00_T%NANOSEC
% _B{BOX_IDENTIFIER_NUMBER}: Box number
% _T{NANOSEC}: Timestamp of file creation 
regex.boxIdentifier = '_B(?<boxID>\d+)';
regex.nanosecondsTimestamp = '_T(?<DatePortion>\d+)-(?<TimePortion>\d+)';
regex.allExpressions = [regex.boxIdentifier, regex.nanosecondsTimestamp];

[videoFile.folder, videoFile.baseFileName, videoFile.fileExtension] = fileparts(videoFilePath);
tokenNames = regexp(videoFile.baseFileName, regex.allExpressions, 'names');

videoFile.boxID = tokenNames.boxID;
% videoFile.nanosecondsTimestampString = tokenNames.nanosecondsTimestamp;
% videoFile.nanosecondsTimestampValue = sscanf(videoFile.nanosecondsTimestampString, '%lu');
% videoFile.dateTime = datetime(videoFile.nanosecondsTimestampValue/1e9,'convertFrom','posixtime');

temp.combinedVideoDateString = tokenNames.DatePortion + "T" + tokenNames.TimePortion;
% Convert the string to a datetime (the string is specified in UTC)
videoFile.dateTime = datetime(temp.combinedVideoDateString,'InputFormat','yyyyMMdd''T''HHmmssSSS','TimeZone','UTC');
% Convert the datetime to local time
videoFile.dateTime.TimeZone = 'local';


end

