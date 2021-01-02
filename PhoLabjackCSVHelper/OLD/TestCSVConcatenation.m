% TestCSVConcatenation
addpath(genpath('HelperFunctions'));
inputFilenameFormatVersion = 2;

rootSearchPath = uigetdir('Select the root data directory');
if isequal(rootSearchPath,0)
    disp('ERROR: You must choose a root directory.')
    return
end

childSearchPaths = {};
childSearchPathIndex = 1;
disp('Select as many folders as you would like, and then press cancel after selection is complete')
childSearchPaths = uigetfile_n_dir(rootSearchPath, 'Select a child data directory ');

% Find the CSV Files in the childSearchPaths
[foundCSVFiles, foundDigitalCSVFiles, foundAnalogCSVFiles] = findCSVFiles(childSearchPaths);

% Sort the files by their creation date
[~,index] = sortrows([foundCSVFiles.datenum].'); foundCSVFiles = foundCSVFiles(index); clear index

%% Find the oldest and newest files
oldestAndNewestFileNames = {foundCSVFiles(1).name, foundCSVFiles(end).name};

%% Build the output filename

fileNameParts = split(oldestAndNewestFileNames,'.');
fileNameComponents = split(fileNameParts(:,:,1),'_');
% Index format: fileNameComponents{1,fileNameIndex,componentIndex}

if (inputFilenameFormatVersion == 1)
    % Version 1 filename format: behavioralBox_470017560_20190606_000
    %fileNameNumberingSuffix = fileNameComponents(1,:,end);
    serialNumbers = fileNameComponents(1,:,2);
    fileDateComponents = fileNameComponents(1,:,3);
    activeDateComponents = fileDateComponents;
    baseNamePrefix = fileNameComponents{1,1,1};
elseif (inputFilenameFormatVersion == 2)
    %% Version 2 filename format: out_file_s{recordingLabjackSerialNumber}_{unix_Epoch_Timestamp}.csv
    serialNumbers = fileNameComponents(1,:,3);
    fileDateComponents = fileNameComponents(1,:,4);
    activeDateComponents = {};
    for i=1:length(fileDateComponents)
        fileDateComponentsAsDatetimes = datetime(str2num(fileDateComponents{1,i}), 'convertFrom','epochtime','TicksPerSecond',1000);
        fileDateComponentsAsDatetimes = fileDateComponentsAsDatetimes - hours(4); % to translate from GMT to Michigan timezone
        fileDateComponentsAsDatetimeStrings = datestr(fileDateComponentsAsDatetimes,'yyyymmdd');
        activeDateComponents{end+1} = fileDateComponentsAsDatetimeStrings;
    end
    
    %activeDateComponents = fileDateComponentsAsDatetimeStrings;
    baseNamePrefix = [fileNameComponents{1,1,1} '_' fileNameComponents{1,1,2}];
end
combinedOutputSuffix = fileNameParts(1,1,2:end);

% Sanity check to make sure they're from the same labjack by checking the serial number
referenceSerialNumber = serialNumbers{1};
serialNumbersMatchTF = strcmp(serialNumbers, referenceSerialNumber);
if ~(sum(serialNumbersMatchTF,'all') == length(serialNumbersMatchTF))
    disp('ERROR: Serial numbers must much for all files!')
    return
end

% Build the combined output date string:
if strcmp(activeDateComponents{1}, activeDateComponents{2})
    combinedOutputDateComponent = activeDateComponents{1}; % If the dates are the same for the oldest and newest file, show only one date
else
    combinedOutputDateComponent = [activeDateComponents{1}, '-', activeDateComponents{2}]; % Otherwise show the date range (dateOldest-dateNewest)
end

combinedNumberOfFiles = length(foundCSVFiles);
combinedOutputFilenameComponents = {baseNamePrefix, referenceSerialNumber, combinedOutputDateComponent};
combinedOutputFilenameComponents(end+1) = {[num2str(combinedNumberOfFiles) 'Combined']};

combinedOutputBasename = join(combinedOutputFilenameComponents, '_');
% this introduces a bug, as the filenames can differ in their non-baseName
% ({'basename.csv', 'basename.bak.csv'} will be merged into 'combinedBasename.csv' when the non-BaseName components are reappended. 

combinedOutputFilenameParts = [combinedOutputBasename; combinedOutputSuffix];
combinedOutputFilenameTemp = join(combinedOutputFilenameParts, '.');
combinedOutputFilename = combinedOutputFilenameTemp{1};
combinedOutputFilepath = fullfile(rootSearchPath, combinedOutputFilename);

% Concatenate the CSV files
[writtenOutputFilePath] = concatenateCSVFiles(foundCSVFiles, combinedOutputFilepath);

disp(['Merged CSV file written out to ', writtenOutputFilePath]);