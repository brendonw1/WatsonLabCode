function [videoFile] = ParsePhoOBSVideoFileName(videoFilePath)
%PARSEPHOOBSVIDEOFILENAME Parses the name of a OBS-recorded video file (the format created 7/25/2019 by Pho Hale)
%   Detailed explanation goes

format long g

[videoFile.folder, videoFile.baseFileName, videoFile.fileExtension] = fileparts(videoFilePath);

% BehavioralBox_B00_T%NANOSEC
% _B{BOX_IDENTIFIER_NUMBER}: Box number
% _T{NANOSEC}: Timestamp of file creation 
regex.boxIdentifier = '_B(?<boxID>\d+)';
regex.fulltimeTimestamp = '_T(?<DatePortion>\d+)-(?<TimePortion>\d+)';
regex.allExpressions = [regex.boxIdentifier, regex.fulltimeTimestamp];

tokenNames = regexp(videoFile.baseFileName, regex.allExpressions, 'names');
if ~isempty(tokenNames)
    % Old (Pre 07-22-2020 format)
    videoFile.boxID = tokenNames.boxID;
    temp.combinedVideoDateString = tokenNames.DatePortion + "T" + tokenNames.TimePortion;
    % Convert the string to a datetime (the string is specified in UTC)
    videoFile.dateTime = datetime(temp.combinedVideoDateString,'InputFormat','yyyyMMdd''T''HHmmssSSS','TimeZone','UTC');
    videoFile.dateTime.TimeZone = 'local'; %Convert the datetime to local time
    videoFile.nameFormat = 'HumanReadableTime'; 
else
    % New Format (Post 07-22-2020 nanoseconds format)
    % Contains a 64-bit value representing the number of 100-nanosecond intervals since January 1, 1601 (UTC).
    regex.nanosecondsTimestamp = '_T(?<nanosecondsTimestamp>\d+)';
    regex.allExpressions_NanosecondsFormat = [regex.boxIdentifier, regex.nanosecondsTimestamp];

    tokenNames_NanoSecondsFormat = regexp(videoFile.baseFileName, regex.allExpressions_NanosecondsFormat, 'names');
    if isempty(tokenNames_NanoSecondsFormat)
        error('Could not parse OBS Video file name into either format!!')
    end
    videoFile.boxID = tokenNames_NanoSecondsFormat.boxID;
    videoFile.nanosecondsTimestampString = tokenNames_NanoSecondsFormat.nanosecondsTimestamp;
    videoFile.nanosecondsTimestampValue = sscanf(videoFile.nanosecondsTimestampString, '%lu');
    videoFile.dateTime = datetime(videoFile.nanosecondsTimestampValue,'convertFrom','ntfs','TimeZone','local');
    videoFile.nameFormat = 'Nanoseconds';
end

end

