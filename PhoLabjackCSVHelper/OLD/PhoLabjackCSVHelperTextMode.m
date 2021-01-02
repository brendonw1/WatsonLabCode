% Concatenates CSV files exported by labjack into a single data stream.
% This version is faster and more compatible than the other (non-text mode)
% one.

addpath(genpath('HelperFunctions'));
format long g
%% Set default datetime display properties (this doesn't affect the values stored, only their display/preview in MATLAB)
datetime.setDefaultFormats('default','yyyy-MM-dd hh:mm:ss.SSS');

if ~exist('filePath','var')
    [fileName, parentPath, filterindex] = uigetfile('*.csv', 'Select a the first .csv file to merge', 'MultiSelect', 'off');
    filePath = fullfile(parentPath,fileName);
end

% Output options:
% file names are like: behavioralBox_470017560_20190606_000
fileNameParts = split(fileName,'.');
fileNameComponents = split(fileNameParts(1),'_');
fileNameNumberingSuffix = fileNameComponents(end);

combinedOutputFilenameComponents = fileNameComponents(1:end-1);
combinedOutputFilenameComponents(end+1) = {'Combined'};

combinedOutputBasename = join(combinedOutputFilenameComponents, '_');
combinedOutputSuffix = fileNameParts(2:end);
combinedOutputFilenameParts = [combinedOutputBasename; combinedOutputSuffix];
combinedOutputFilenameTemp = join(combinedOutputFilenameParts, '.');
combinedOutputFilename = combinedOutputFilenameTemp{1};
%combinedOutputFilename = 'CombinedText.csv';


combinedOutputFilepath = fullfile(parentPath, combinedOutputFilename);
%delete any extant combined output file so it isn't found when searching
%for .csv files to combine.
delete(combinedOutputFilepath);

% Find all .csv files in the directory
fullSearchPathFilter = fullfile(parentPath,'*.csv');
dirData = dir(fullSearchPathFilter);

% Set up variables to hold the csv header lines
numHeaderLines = 4;
headerLines = cell(numHeaderLines,1);

% Setup the combined output data
combinedBodyLines = cell(0,1);



%% Process CSV files
for fileIndex = 1:length(dirData)
    % Construct the full file path
    %currCSVFilePath(end+1) = {fullfile(parentPath, dirData(fileIndex).name)};
    currCSVFilePath = fullfile(parentPath, dirData(fileIndex).name);
    fid = fopen(currCSVFilePath,'r');
    % Get the header information from the first file
    if (fileIndex == 1)
        for lineIndex = 1:numHeaderLines
         headerLines(lineIndex) = {fgetl(fid)}; 
        end
        % Process the header information
        %TODO: verify that the header info hasn't changed between files (so
        %we don't concatinate differnt data
    else
        %read the header lines for non-first files, but throw them away.
        for lineIndex = 1:numHeaderLines
            trash = {fgetl(fid)}; 
        end
    end

    tline = fgetl(fid);
    while ischar(tline)
        combinedBodyLines{end+1,1} = tline;
        tline = fgetl(fid);
    end

    fclose(fid);
end


% Save out to new csv file
fid = fopen(combinedOutputFilepath,'w');
for lineIndex = 1:numHeaderLines
    fprintf(fid,'%s\n',headerLines{lineIndex});
end
% Write body lines
for lineIndex = 1:length(combinedBodyLines)
    fprintf(fid,'%s\n',combinedBodyLines{lineIndex});
end
fclose(fid);

 
 