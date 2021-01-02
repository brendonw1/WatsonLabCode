function [timeString] = SecondsToHumanTimeString(timeSeconds)
%SECONDSTOHUMANTIME Returns a time string in the format 'DD:HH:MM:SS.FFF' from a duration specified in seconds.
	timeString = datestr(timeSeconds/(24*60*60), 'DD:HH:MM:SS.FFF');
end

