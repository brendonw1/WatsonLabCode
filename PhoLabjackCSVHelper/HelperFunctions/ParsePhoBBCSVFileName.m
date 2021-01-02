function [outputArg1,outputArg2] = ParsePhoBBCSVFileName(csvFilePath)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% 'out_file_analog_s470019538_1581709366755.csv'
% 'out_file_s470019538_1581709366755.csv'

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

