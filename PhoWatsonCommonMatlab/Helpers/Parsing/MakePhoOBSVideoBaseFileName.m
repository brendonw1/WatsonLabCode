function [OBSVideoBasename] = MakePhoOBSVideoBaseFileName(boxIdentifier, datetime)
%MakePhoOBSVideoFileName builds an OBS-recorded video style filename (the format created 7/25/2019 by Pho Hale) out of a boxID and a datetime. This function is the inverse of ParsePhoOBSVideoBaseFileName(...) 
%	boxIdentifier: a BBID string '05' for BB05 or '14' for BB14.
%   datetime: a matlab datetime object.

%BehavioralBox_B06_T20200228-2157430477.mkv

format long g

% BehavioralBox_B00_T%NANOSEC
% _B{BOX_IDENTIFIER_NUMBER}: Box number
% _T{NANOSEC}: Timestamp of file creation 

% videoFile.nanosecondsTimestampString = tokenNames.nanosecondsTimestamp;
% videoFile.nanosecondsTimestampValue = sscanf(videoFile.nanosecondsTimestampString, '%lu');
% videoFile.dateTime = datetime(videoFile.nanosecondsTimestampValue/1e9,'convertFrom','posixtime');

% temp.outDateString = datestr(datetime, 'yyyyMMdd''T''HHmmssSSS');
temp.outDateDayString = datestr(datetime, 'yyyymmdd');
% temp.outDateTimeString = datestr(datetime, 'HHmmssSSS');
temp.outDateTimeString = datestr(datetime, 'HHMMSSFFF');


% temp.combinedVideoDateString = tokenNames.DatePortion + "T" + tokenNames.TimePortion;
% % Convert the string to a datetime (the string is specified in UTC)
% videoFile.dateTime = datetime(temp.combinedVideoDateString,'InputFormat','yyyyMMdd''T''HHmmssSSS','TimeZone','UTC');
% % Convert the datetime to local time
% videoFile.dateTime.TimeZone = 'local';


OBSVideoBasename = sprintf('BehavioralBox_B%s_T%s-%s', boxIdentifier, temp.outDateDayString, temp.outDateTimeString);

end

