function [OutputDeltas, OutputDeltasTimestamps] = ImportPhoLabjackServerEventsCsvFile(importFilePath, enableDebugPrint, enableDebugPlot)
%IMPORTPHOLABJACKSERVEREVENTSCSVFILE Imports a PhoLabjackServer .csv file either produced directly by phoBehavioralBoxLabjackController or a combined one exported by LabjackEventsLoader.py
% Automatically combines it with the previously saved compressed events and saves the combined arrays to the 'compressed.mat' file.
% Returns the combined compressed events.
% Created on 7/11/2019 to import my latest .csv format exported by my custom C++ labjack controller (PhoLabjackClockSync or phoBehavioralBoxLabjackController).
% Example files:
    %importFilePath = 'C:\Users\halechr\repo\phoPythonVideoFileParser\results\output.csv';
    %importFilePath = 'G:\Google Drive\Modern Behavior Box\Results - Data\Behavioral Box Data\Labjack Data\out_file_s470017560_1562795602881.csv';
    %importFilePath = 'G:\Google Drive\Modern Behavior Box\Results - Data\Behavioral Box Data\Labjack Data\out_file_s470017560_1562601911545.csv';
addpath(genpath('HelperFunctions'));
addpath(genpath('CompressedEventsFormat'));

varNames = {'Water1_BeamBreak','Water2_BeamBreak','Food1_BeamBreak','Food2_BeamBreak','Water1_Dispense','Water2_Dispense','Food1_Dispense','Food2_Dispense','RunningWheel'};
loadedLabjackData = importPhoLabjackServerEventsCsvFileHelper(importFilePath);

outputDateTimes = datetime(loadedLabjackData.milliseconds_since_epoch, 'convertFrom','epochtime','TicksPerSecond',1000);
outputDateTimes = outputDateTimes - hours(4); % to translate from GMT to Michigan timezone
% the standard .csv's imported by TestScript have inputs like '{3643827012.79100}'
% labjackData.milliseconds_since_epoch contains: {1561753286966.00}


% Negate the logic of the table
tempOriginalValueMatrix = loadedLabjackData{:,2:10};
outputEventRows = zeros(size(tempOriginalValueMatrix,1),size(tempOriginalValueMatrix,2));
positiveIndicies = find(tempOriginalValueMatrix == 0);
outputEventRows(positiveIndicies) = 1;

[rowIndicies,colIndicies] = ind2sub(size(tempOriginalValueMatrix),positiveIndicies);

%% Build the OutputDeltasTimestamps:
OutputTest.Water1_BeamBreak = {};
OutputTest.Water2_BeamBreak = {};
OutputTest.Food1_BeamBreak = {};
OutputTest.Food2_BeamBreak = {};
OutputTest.Water1_Dispense = {};
OutputTest.Water2_Dispense = {};
OutputTest.Food1_Dispense = {};
OutputTest.Food2_Dispense = {};

fields = fieldnames(OutputTest);
for i = 1:numel(fields)
    OutputDeltas.(fields{i}) = rowIndicies(colIndicies == i);
    OutputDeltasTimestamps.(fields{i}) = outputDateTimes(OutputDeltas.(fields{i}));
end

if exist('enableDebugPrint','var')
    disp(['loaded events from file: ' importFilePath])
    [counts,total] = PrintCompressedEventsStatus(OutputDeltas, OutputDeltasTimestamps);
end

if exist('enableDebugPlot','var')
    labjackTimeTable = CompressedEvents2Timetable(OutputDeltas, OutputDeltasTimestamps, varNames(1:end-1));
    binnedEventsTimetable = retime(labjackTimeTable,'daily','sum','IncludedEdge','right');
    [fig, axH] = PlotBinnedEventsTimetable(binnedEventsTimetable, 'Imported File Port Events: binned daily');
end

% Append these events to the other compressed events:
[OutputDeltas, OutputDeltasTimestamps] = UpdateAndSaveCompressedEvents(OutputDeltas, OutputDeltasTimestamps);

end

