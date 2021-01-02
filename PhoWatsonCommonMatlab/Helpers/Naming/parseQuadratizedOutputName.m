function [bbva_quadratizedParseResults] = parseQuadratizedOutputName(quadratizedName)
%parseQuadratizedOutputName Parses filepath like 'qMuxPair_0_mm-dd-yy'
% Inverse of makeQuadratizedOutputName.m

%%%+S- bbva_quadratizedParseResults
	%- quadratizedGlobalGroupIndex - video_basename_string is string containing the video basename that produced this actigrpahy file
	%- dayDateString - dayDateString is the raw string output
	%- producedDate - producedDate is the parsed date the file was produced
%

[bbva_quadratizedParseResults.folder, bbva_quadratizedParseResults.baseFileName, bbva_quadratizedParseResults.fileExtension] = fileparts(quadratizedName);

regex.prefix = 'qMuxPair';
% regex.baseOutputPrefix = '(?<base_output_prefix>.+)_';
%regex.frameString = 'frames_(?<startFrameIndex>\d+)-(?<endFrameIndex>\d+)_';
regex.idString = '(?<index>\d+)';
%regex.dayDateString = '(?<month>\d{2})-(?<day>\d{2})-(?<year>\d{2})';
regex.dayDateString = '(?<date>\d{2}-\d{2}-\d{2})';

regex.allExpressions = join(regex.prefix, regex.idString, regex.dayDateString,'_');

tokenNames = regexp(bbva_quadratizedParseResults.baseFileName, regex.allExpressions, 'names');

bbva_quadratizedParseResults.quadratizedGlobalGroupIndex = tokenNames.index;
bbva_quadratizedParseResults.dayDateString = tokenNames.date;
bbva_quadratizedParseResults.producedDate = datetime(bbva_quadratizedParseResults.dayDateString,'InputFormat','mm-dd-yy');

% bbva_quadratizedParseResults.month = tokenNames.month;
% bbva_quadratizedParseResults.day = tokenNames.day;
% bbva_quadratizedParseResults.year = tokenNames.year;


end

