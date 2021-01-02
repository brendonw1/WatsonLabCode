function [ccsv_ParseResults, wasParseSuccessful] = parseCombinedBoxCSVOutputName(combinedOutputFilename)
%CombinedBoxCSVOutputName Inverse of makeCombinedBoxCSVOutputName.
%   INPUTS:
%	combinedOutputFilename: a combined CSV output filename like: out_file_analog_BB02_1582229437527-1594300027249_29_Combined.csv
%		or out_file_BB02_1581354045076-1594300027249_34_Combined.csv

% TODO: make the second datetime parameter optional.

ccsv_ParseResults.wasParseSuccessful = true;
ccsv_ParseResults.isAnalog = false;

%%%+S- ccsv_ParseResults
	%= parentPath - the parent path of the combinedOutputFilename
	%= baseFileName - the basename without extension from the combinedOutputFilename
	%= extension - the file extension from combinedOutputFilename
	%= wasParseSuccessful - true if the filename could successfully be parsed as a combined CSV file.
	%= numSourceFilesMerged - the number of CSV files that were merged to produce the combined file.
	%= bbidString - the behavioral box ID string, of the form '02' for BB02 or '12' for BB12.
	%= bbid - the numeric bbid
	
	%= prefixString - the start of the filename. Typically 'out_file' or 'out_file_analog'
	
	%= isAnalog - a boolean indicating whether or not the file is an analog or digital file.
% 

[ccsv_ParseResults.parentPath, ccsv_ParseResults.baseFileName, ccsv_ParseResults.extension] = fileparts(combinedOutputFilename);

%% Common to both versions:
regex.prefixString = '(?<prefixString>\w+)'; %'out_file'
regex.suffix = 'Combined';
% regex.analog_string = '(?:(?<analog_string>analog)_)?'; % Optional

% '(?<prefixString>\w+)'
% '(?:(?<analog_string>analog)_)'
% (?<prefixString>\w+)(?:(?<analog_string>analog)_)?_BB(?<bbid>\d{2})_(?<earliestDatetimeString>\d{13})(?:-(?<latestDatetimeString>\d{13}))?_(?<numSourceFilesMergedString>\d+)(?<remainder>.*)_Combined
% (?<prefixString>\w+)_BB(?<bbid>\d{2})_(?<earliestDatetimeString>\d{13})(?:-(?<latestDatetimeString>\d{13}))?_(?<numSourceFilesMergedString>\d+)(?<remainder>.*)_Combined


regex.bbidString = 'BB(?<bbidString>\d{2})';
regex.earliestDatetimeString = '(?<earliestDatetimeString>\d{13})'; % '1582229437527'
% regex.latestDatetimeString = '(?:-(?<latestDatetimeString>\d{13}))?'; % '1594300027249' Optional
regex.latestDatetimeString = '(?<latestDatetimeString>\d{13})'; % '1594300027249' Optional
regex.numSourceFilesMergedString = '(?<numSourceFilesMergedString>\d+)'; % '29'

% regex.allExpressions = join({regex.prefixString, regex.analog_string, regex.sourceNameString}, '_');
% regex.allExpressions = regex.allExpressions{1};
regex.allExpressions = [regex.prefixString, '_', regex.bbidString, '_', regex.earliestDatetimeString, '-', regex.latestDatetimeString, '_', regex.numSourceFilesMergedString, '_', regex.suffix];
tokenNames = regexp(ccsv_ParseResults.baseFileName, regex.allExpressions, 'names');

if isempty(tokenNames)
	ccsv_ParseResults.wasParseSuccessful = false;
	ccsv_ParseResults.isAnalog = false;
	ccsv_ParseResults.prefixString = '';
	ccsv_ParseResults.bbidString = '';
	ccsv_ParseResults.bbid = -1;
		
	ccsv_ParseResults.earliestDatetimeString = '';
	ccsv_ParseResults.latestDatetimeString = '';
	
	ccsv_ParseResults.numSourceFilesMergedString = '';
	ccsv_ParseResults.numSourceFilesMerged = -1;
		
else

	if isfield(tokenNames, 'prefixString')
		ccsv_ParseResults.prefixString = tokenNames.prefixString;
	else
		ccsv_ParseResults.prefixString = '';
		ccsv_ParseResults.wasParseSuccessful = false;
	end
	
	if isfield(tokenNames, 'bbidString')
		ccsv_ParseResults.bbidString = tokenNames.bbidString;
		ccsv_ParseResults.bbid = num2str(ccsv_ParseResults.bbidString);
	else
		ccsv_ParseResults.bbidString = '';
		ccsv_ParseResults.bbid = -1;
		ccsv_ParseResults.wasParseSuccessful = false;
	end
		

	if isfield(tokenNames, 'earliestDatetimeString')
		ccsv_ParseResults.earliestDatetimeString = tokenNames.earliestDatetimeString;
	else
		ccsv_ParseResults.earliestDatetimeString = '';
		ccsv_ParseResults.wasParseSuccessful = false;
	end
	
	if isfield(tokenNames, 'latestDatetimeString')
		ccsv_ParseResults.latestDatetimeString = tokenNames.latestDatetimeString;
	else
		ccsv_ParseResults.latestDatetimeString = '';
	end

	if isfield(tokenNames, 'numSourceFilesMergedString')
		ccsv_ParseResults.numSourceFilesMergedString = tokenNames.numSourceFilesMergedString;
		ccsv_ParseResults.numSourceFilesMerged = num2str(ccsv_ParseResults.numSourceFilesMergedString);
	else
		ccsv_ParseResults.numSourceFilesMergedString = '';
		ccsv_ParseResults.numSourceFilesMerged = -1;
		ccsv_ParseResults.wasParseSuccessful = false;
	end
	
	
			
	if ~isempty(ccsv_ParseResults.prefixString)
		% Split prefix string to get suffix
		if contains(ccsv_ParseResults.prefixString, '_analog')
			ccsv_ParseResults.isAnalog = true;
		end
	end

	

end % end if was empty

wasParseSuccessful = ccsv_ParseResults.wasParseSuccessful;

end

