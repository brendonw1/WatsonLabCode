function [combinedOutputFilename, mccsv_SerialNumberInfo, have_common_serial_number] = makeCombinedBoxCSVOutputName(oldestFilename, newestFilename, combinedNumberOfFiles, bbIDString)
%MAKECOMBINEDBOXCSVOUTPUTNAME Takes information about the .CSV files that will be being combined to produce an appropriate output filename for the "Combined CSV" for this box. 
%   INPUTS:
%	oldestFilename: oldest .CSV filename to be combined. In the form: out_file_analog_s470019538_1581354045076.csv:
%	newestFilename: most recent .CSV filename to be combined In the form: out_file_analog_s470019538_1581354045076.csv:
%	bbIDString: the behavioral box ID string, of the form '02' for BB02 or '12' for BB12.
%	combinedNumberOfFiles: the number of files to be combined for this box.


% OUTPUTS:
% combinedOutputFilename: a combined CSV output filename like: out_file_analog_BB12_1581622335641-1583854310089_12_Combined.CSV
%%%+S- mccsv_SerialNumberInfo
	%= serialNumbers - a list of serial numbers parsed from the oldestFilename and newestFilename
	%= serialNumbersMatchTF - a boolean list of whether each serial in serialNumbers matches the referenceSerialNumber
	%= referenceSerialNumber - the first serial number that's used as the "refernece" by which to compare all others.
%
% have_common_serial_number: true if the serial numbers in oldestFilename and newestFilename match
	
oldestAndNewestFileNames = {oldestFilename, newestFilename};

%% Build the output filename
% file names are like: out_file_analog_s470019538_1581354045076.csv
fileNameParts = split(oldestAndNewestFileNames,'.');
fileNameComponents = split(fileNameParts(:,:,1),'_');
% Index format: fileNameComponents{1,fileNameIndex,componentIndex}
fileNamePrefix = join({fileNameComponents{1,1,1:end-2}}, '_');

% Sanity check to make sure they're from the same labjack by checking the serial number
mccsv_SerialNumberInfo.serialNumbers = fileNameComponents(1,:,end-1);
mccsv_SerialNumberInfo.referenceSerialNumber = mccsv_SerialNumberInfo.serialNumbers{1};
mccsv_SerialNumberInfo.serialNumbersMatchTF = strcmp(mccsv_SerialNumberInfo.serialNumbers, mccsv_SerialNumberInfo.referenceSerialNumber);
have_common_serial_number = (sum(mccsv_SerialNumberInfo.serialNumbersMatchTF,'all') == length(mccsv_SerialNumberInfo.serialNumbersMatchTF));
% if ~have_common_serial_number
%     if (should_allow_different_serial_numbers) 
%         disp('    WARNING: Serial numbers differ for files!');
%     else
%         warning('    ERROR: Serial numbers must much for all files!')
%         return
%     end
% end

% Build the combined output date string:
fileDateComponents = fileNameComponents(1,:,end);
if strcmp(fileDateComponents{1}, fileDateComponents{end})
    combinedOutputDateComponent = fileDateComponents{1}; % If the dates are the same for the oldest and newest file, show only one date
else
    combinedOutputDateComponent = [fileDateComponents{1}, '-', fileDateComponents{end}]; % Otherwise show the date range (dateOldest-dateNewest)
end


% if (should_allow_different_serial_numbers) 
	% don't include the serial number in the outputs;
	combinedOutputFilenameComponents = {fileNamePrefix{1}, ['BB', bbIDString], combinedOutputDateComponent};
% else
% 	combinedOutputFilenameComponents = {fileNamePrefix{1}, referenceSerialNumber, combinedOutputDateComponent};
% end

combinedOutputFilenameComponents(end+1) = {[num2str(combinedNumberOfFiles) '_Combined']};

combinedOutputBasename = join(combinedOutputFilenameComponents, '_');
% this introduces a bug, as the filenames can differ in their non-baseName
% ({'basename.csv', 'basename.bak.csv'} will be merged into 'combinedBasename.csv' when the non-BaseName components are re-appended. 
combinedOutputSuffix = fileNameParts(1,1,2:end);
combinedOutputFilenameParts = [combinedOutputBasename; combinedOutputSuffix];
combinedOutputFilenameTemp = join(combinedOutputFilenameParts, '.');
combinedOutputFilename = combinedOutputFilenameTemp{1};


end

