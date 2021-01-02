function [OutputDeltas, OutputDeltasTimestamps] = ImportPhoLabjackServerAnalogEventsCsvFile(importFilePath, enableDebugPrint, enableDebugPlot)
%IMPORTPHOLABJACKSERVEREVENTSCSVFILE Imports a PhoLabjackServer *ANALOG* .csv file either produced directly by phoBehavioralBoxLabjackController or a combined one exported by LabjackEventsLoader.py
% Automatically combines it with the previously saved compressed events and saves the combined arrays to the 'compressed_analog.mat' file.
% Returns the combined compressed events.
% Created on 2/20/2020 to import my latest .csv format exported by my custom C++ labjack controller phoBehavioralBoxLabjackController.
% Example files:
    %importFilePath = 'C:\Users\halechr\repo\phoPythonVideoFileParser\results\output.csv';
    %importFilePath = 'G:\Google Drive\Modern Behavior Box\Results - Data\Behavioral Box Data\Labjack Data\out_file_s470017560_1562795602881.csv';
    %importFilePath = 'G:\Google Drive\Modern Behavior Box\Results - Data\Behavioral Box Data\Labjack Data\out_file_s470017560_1562601911545.csv';
addpath(genpath('HelperFunctions'));
addpath(genpath('CompressedEventsFormat'));

varNames = {'RunningWheel'};
loadedLabjackData = importPhoLabjackServerAnalogEventsCsvFileHelper(importFilePath);

outputDateTimes = datetime(loadedLabjackData.milliseconds_since_epoch, 'convertFrom','epochtime','TicksPerSecond',1000);
outputDateTimes = outputDateTimes - hours(4); % to translate from GMT to Michigan timezone
% the standard .csv's imported by TestScript have inputs like '{3643827012.79100}'
% labjackData.milliseconds_since_epoch contains: {1561753286966.00}
loadedLabjackData.timestamp = outputDateTimes;

% Negate the logic of the table
diffTable = diff(loadedLabjackData);

% tempOriginalValueMatrix = loadedLabjackData{:,2:10};
% outputEventRows = zeros(size(tempOriginalValueMatrix,1),size(tempOriginalValueMatrix,2));
% positiveIndicies = find(tempOriginalValueMatrix == 0);
% outputEventRows(positiveIndicies) = 1;

% [rowIndicies,colIndicies] = ind2sub(size(tempOriginalValueMatrix),positiveIndicies);

%% Build the OutputDeltasTimestamps:
OutputTest.RunningWheel_Rotate = {};

% fields = fieldnames(OutputTest);
% for i = 1:numel(fields)
%     OutputDeltas.(fields{i}) = rowIndicies(colIndicies == i);
%     OutputDeltasTimestamps.(fields{i}) = outputDateTimes(OutputDeltas.(fields{i}));
% end
% 
% if exist('enableDebugPrint','var')
%     disp(['loaded events from file: ' importFilePath])
%     [counts,total] = PrintCompressedEventsStatus(OutputDeltas, OutputDeltasTimestamps);
% end
% 
% if exist('enableDebugPlot','var')
%     labjackTimeTable = CompressedEvents2Timetable(OutputDeltas, OutputDeltasTimestamps, varNames(1:end-1));
%     binnedEventsTimetable = retime(labjackTimeTable,'daily','sum','IncludedEdge','right');
%     [fig, axH] = PlotBinnedEventsTimetable(binnedEventsTimetable, 'Imported File Port Events: binned daily');
% end
% 
% % Append these events to the other compressed events:
% [OutputDeltas, OutputDeltasTimestamps] = UpdateAndSaveCompressedEvents(OutputDeltas, OutputDeltasTimestamps);

end

