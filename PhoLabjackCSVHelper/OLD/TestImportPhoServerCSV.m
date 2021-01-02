addpath(genpath('CompressedEventsFormat'));

% Imports a PhoLabjackServer .csv file exported by LabjackEventsLoader.py
% Created on 7/11/2019 to import my latest .csv format exported by my custom C++ labjack controller (PhoLabjackClockSync or phoBehavioralBoxLabjackController).

%importFilePath = 'C:\Users\halechr\repo\phoPythonVideoFileParser\results\output.csv';
%importFilePath = 'G:\Google Drive\Modern Behavior Box\Results - Data\Behavioral Box Data\Labjack Data\out_file_s470017560_1562795602881.csv';
%importFilePath = 'G:\Google Drive\Modern Behavior Box\Results - Data\Behavioral Box Data\Labjack Data\out_file_s470017560_1562601911545.csv';
% importFilePath = 'C:\Users\halechr\Desktop\EventData\BB02\experiment_00\cohort_00\animal_02\out_file_s470019538_1581354045076.csv';
% importFilePath = 'C:\Users\halechr\Desktop\EventData\BB04\experiment_00\cohort_00\animal_04\out_file_s470019337_1581354083044.csv';
%importFilePath = 'C:\Users\halechr\Desktop\EventData\BB06\experiment_00\cohort_00\animal_06\out_file_s470019522_1581359441953.csv';
% importFilePath = 'E:\EventData\EventData\BB12\experiment_00\cohort_00\animal_12\out_file_s470019347_1581453694747.csv';
importFilePath = 'F:\EventData\BB02\experiment_00\cohort_00\animal_02\Combined\out_file_02_1581354045076-1583854145743_32_Combined.csv';


% [OutputDeltas, OutputDeltasTimestamps] = ImportPhoLabjackServerEventsCsvFile(importFilePath);

%varNames = {'Water1_BeamBreak','Water2_BeamBreak','Food1_BeamBreak','Food2_BeamBreak','Water1_Dispense','Water2_Dispense','Food1_Dispense','Food2_Dispense','RunningWheel'};
varNames = {'Water1_BeamBreak','Water2_BeamBreak','Food1_BeamBreak','Food2_BeamBreak','Water1_Dispense','Water2_Dispense','Food1_Dispense','Food2_Dispense'};
loadedLabjackData = importPhoLabjackServerEventsCsvFileHelper(importFilePath);

outputDateTimes = datetime(loadedLabjackData.milliseconds_since_epoch, 'convertFrom','epochtime','TicksPerSecond',1000);
outputDateTimes = outputDateTimes - hours(4); % to translate from GMT to Michigan timezone
% the standard .csv's imported by TestScript have inputs like '{3643827012.79100}'
% labjackData.milliseconds_since_epoch contains: {1561753286966.00}

% Output Datetimes not working


% Negate the logic of the table
tempOriginalValueMatrix = loadedLabjackData{:,2:9};
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

disp(['loaded events from file: ' importFilePath])
[counts,total] = PrintCompressedEventsStatus(OutputDeltas, OutputDeltasTimestamps);

%labjackTimeTable = CompressedEvents2Timetable(OutputDeltas, OutputDeltasTimestamps, varNames(1:end-1));
labjackTimeTable = CompressedEvents2Timetable(OutputDeltas, OutputDeltasTimestamps, varNames(1:end));
% binnedEventsTimetable = retime(labjackTimeTable,'daily','sum','IncludedEdge','right');
% [fig, axH] = PlotBinnedEventsTimetable(binnedEventsTimetable, 'Imported File Port Events: binned daily');

binnedEventsTimetable = retime(labjackTimeTable,'hourly','sum','IncludedEdge','right');
[fig, axH] = PlotBinnedEventsTimetable(binnedEventsTimetable, 'Imported File Port Events: binned hourly');

% Append these events to the other compressed events:
% [OutputDeltas, OutputDeltasTimestamps] = UpdateAndSaveCompressedEvents(OutputDeltas, OutputDeltasTimestamps);

% Save to Excel file for Paul:
writetimetable(binnedEventsTimetable,['Output/', 'test.xlsx']);

disp('done.')

