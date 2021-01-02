% Concatenates CSV files exported by labjack into a single data stream.
addpath(genpath('HelperFunctions'));
format long g
%% Set default datetime display properties (this doesn't affect the values stored, only their display/preview in MATLAB)
datetime.setDefaultFormats('default','yyyy-MM-dd hh:mm:ss.SSS');

if ~exist('filePath','var')
    [fileName, parentPath, filterindex] = uigetfile('*.csv', 'Select a the first .csv file to merge', 'MultiSelect', 'off');
    filePath = fullfile(parentPath,fileName);
end

% Output options:
combinedOutputFilename = 'Combined.csv';
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
combinedOutputData = [];



%% Process CSV files
for fileIndex = 1:length(dirData)
    % Construct the full file path
    %currCSVFilePath(end+1) = {fullfile(parentPath, dirData(fileIndex).name)};
    currCSVFilePath = fullfile(parentPath, dirData(fileIndex).name);
    
    % Get the header information from the first file
    if (fileIndex == 1)
        %opts = detectImportOptions(currCSVFilePath);
        %csvHeaderContents = readmatrix(currCSVFilePath,'NumHeaderLines',0,'OutputType','string');
        fid = fopen(currCSVFilePath,'r');
        for lineIndex = 1:numHeaderLines
         headerLines(lineIndex) = {fgetl(fid)}; 
        end
        fclose(fid);
 
        % Process the header information
        %TODO: verify that the header info hasn't changed between files (so
        %we don't concatinate differnt data
    end
    % readmatrix automatically skips the header rows
    currCSVContents = readmatrix(currCSVFilePath,'NumHeaderLines',4);
    % put the new file's data under the previous data
    combinedOutputData = [combinedOutputData; currCSVContents];
end


% Save out to new csv file
fid = fopen(combinedOutputFilepath,'w');
for lineIndex = 1:numHeaderLines
    fprintf(fid,'%s\n',headerLines{lineIndex});
end
fclose(fid);
% write the data to the file:
%write data to end of file
dlmwrite(combinedOutputFilepath,combinedOutputData,'precision','%1.3f','-append');

 
 