function [writtenOutputFilePath, didUserCancel] = BuildCombinedCSV(rootSearchPath, activeCSVFiles, bbIDString)
%BUILDCOMBINEDCSV Builds a combined CSV file by concatenating passed in CSV files (persisting it to disk).
%   Works on both analog and digital CSV files.
%   Written 2/20/2020 to work with current format data.

% should_allow_different_serial_numbers: if true, allows CSVs with
% differing Labjack serial numbers. Also, it outputs a filename containing
% the bbID identifier instead of the labjack serial ID.
should_allow_different_serial_numbers = true;

% Sort the files by their creation date
[~,index] = sortrows([activeCSVFiles.datenum].'); activeCSVFiles = activeCSVFiles(index); clear index

%% Find the oldest and newest files
% oldestAndNewestFileNames = {activeCSVFiles(1).name, activeCSVFiles(end).name};

% %% Build the output filename
% % file names are like: out_file_analog_s470019538_1581354045076.csv
% fileNameParts = split(oldestAndNewestFileNames,'.');
% fileNameComponents = split(fileNameParts(:,:,1),'_');
% % Index format: fileNameComponents{1,fileNameIndex,componentIndex}
% fileNamePrefix = join({fileNameComponents{1,1,1:end-2}}, '_');
% 
% % Sanity check to make sure they're from the same labjack by checking the serial number
% serialNumbers = fileNameComponents(1,:,end-1);
% referenceSerialNumber = serialNumbers{1};
% serialNumbersMatchTF = strcmp(serialNumbers, referenceSerialNumber);
% if ~(sum(serialNumbersMatchTF,'all') == length(serialNumbersMatchTF))
%     if (should_allow_different_serial_numbers) 
%         disp('    WARNING: Serial numbers differ for files!');
%     else
%         warning('    ERROR: Serial numbers must much for all files!')
%         return
%     end
% end
% 
% % Build the combined output date string:
% fileDateComponents = fileNameComponents(1,:,end);
% if strcmp(fileDateComponents{1}, fileDateComponents{end})
%     combinedOutputDateComponent = fileDateComponents{1}; % If the dates are the same for the oldest and newest file, show only one date
% else
%     combinedOutputDateComponent = [fileDateComponents{1}, '-', fileDateComponents{end}]; % Otherwise show the date range (dateOldest-dateNewest)
% end
% 
% combinedNumberOfFiles = length(activeCSVFiles);
% 
% if (should_allow_different_serial_numbers) 
% 	combinedOutputFilenameComponents = {fileNamePrefix{1}, bbIDString, combinedOutputDateComponent};
% else
% 	combinedOutputFilenameComponents = {fileNamePrefix{1}, referenceSerialNumber, combinedOutputDateComponent};
% end
% 
% combinedOutputFilenameComponents(end+1) = {[num2str(combinedNumberOfFiles) '_Combined']};
% 
% combinedOutputBasename = join(combinedOutputFilenameComponents, '_');
% % this introduces a bug, as the filenames can differ in their non-baseName
% % ({'basename.csv', 'basename.bak.csv'} will be merged into 'combinedBasename.csv' when the non-BaseName components are re-appended. 
% combinedOutputSuffix = fileNameParts(1,1,2:end);
% combinedOutputFilenameParts = [combinedOutputBasename; combinedOutputSuffix];
% combinedOutputFilenameTemp = join(combinedOutputFilenameParts, '.');
% combinedOutputFilename = combinedOutputFilenameTemp{1};

combinedNumberOfFiles = length(activeCSVFiles);
[combinedOutputFilename, mccsvSerialNumberInfo, have_common_serial_number] = makeCombinedBoxCSVOutputName(activeCSVFiles(1).name, activeCSVFiles(end).name, combinedNumberOfFiles, bbIDString);
if ~have_common_serial_number
	if (should_allow_different_serial_numbers) 
		disp('    WARNING: Serial numbers differ for files!');
	else
		warning('    ERROR: Serial numbers must much for all files!')
		return
	end
end

% Make output folder
output_combined_folder_name = 'Combined';
output_combined_folder_path = fullfile(rootSearchPath, output_combined_folder_name);

if ~exist(output_combined_folder_path,'dir')
	% Make the 'Combined' output directory if it doesn't exist.
	mkdir(output_combined_folder_path);
end

combinedOutputFilepath = fullfile(output_combined_folder_path, combinedOutputFilename);

% Concatenate the CSV files
% [writtenOutputFilePath] = concatenateCSVFiles(activeCSVFiles, combinedOutputFilepath);
[writtenOutputFilePath, ~, didUserCancel] = concatenateCSVFiles(activeCSVFiles, combinedOutputFilepath);

end

