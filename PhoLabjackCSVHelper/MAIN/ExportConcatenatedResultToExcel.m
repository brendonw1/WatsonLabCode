% ExportConcatenatedResultToExcel.m
%% 3/19/2020: For each box in bbIDs, imports a modern concatenated "combined" CSV (created by BuildCombinedCSV.m) and exports an excel file.
% Can be ran after 'BuildAllCombinedCSV.m' to export the combined CSVs to excel, or the hardcoded fallback writtenOutputFilePath_digital_filenames or writtenOutputFilePath_analog_filenames can be set manually to filesystem paths, and it will produce the exported Excel files from these.
addpath(genpath('../HelperFunctions'));
addpath(genpath('../CompressedEventsFormat'));


bbIDs = {'02','04','06','09','12','14','15','16'};

% For Workstation:
% activePathRoot = 'E:\EventData\EventData\BB';

% For Overseer:

% should_process_digital: if true, processes the digital events. Otherwise, processes the analog events.
should_process_digital = true;

% Digital Events:
if ~exist('digital_path','var')
	digital_path = 'F:\Concatenated EventData CSVs - 07-15-2020\Digital';
end

if ~exist('writtenOutputFilePath_digital_file','var')
	writtenOutputFilePath_digital_filenames = {'out_file_BB02_1581354045076-1594300027249_34_Combined',
	'out_file_BB04_1581354083044-1583854175239_22_Combined',
	'out_file_BB06_1581359441953-1583854222298_18_Combined',
	'out_file_BB09_1581354110882-1590507348132_16_Combined',
	'out_file_BB12_1581453694747-1583854310089_14_Combined',
	'out_file_BB14_1581354131126-1583854365228_17_Combined',
	'out_file_BB15_1581453818925-1584430140100_15_Combined',
	'out_file_BB16_1581354138682-1594324476174_50_Combined'};
else
	writtenOutputFilePath_digital_filenames_temp = [writtenOutputFilePath_digital_file{:}];
	writtenOutputFilePath_digital_filenames = {writtenOutputFilePath_digital_filenames_temp.basename};
end

%% Analog Events:
if ~exist('analog_path','var')
	analog_path = 'F:\Concatenated EventData CSVs - 07-15-2020\Analog';
end

if ~exist('writtenOutputFilePath_analog_file','var')
	writtenOutputFilePath_analog_filenames = {'out_file_analog_BB02_1582229437527-1594300027249_29_Combined',
	'out_file_analog_BB04_1582229914352-1583854175239_18_Combined',
	'out_file_analog_BB06_1581622159471-1583854222298_13_Combined',
	'out_file_analog_BB09_1582229925250-1590507348132_13_Combined',
	'out_file_analog_BB12_1581622335641-1583854310089_12_Combined',
	'out_file_analog_BB14_1582229944150-1583854365228_15_Combined',
	'out_file_analog_BB15_1581622409718-1584430140100_13_Combined',
	'out_file_analog_BB16_1581622447773-1594324476174_45_Combined'};
else
% 	writtenOutputFilePath_analog_filenames = {writtenOutputFilePath_analog_file{:}.basename};
	writtenOutputFilePath_analog_filenames_temp = [writtenOutputFilePath_analog_file{:}];
	writtenOutputFilePath_analog_filenames = {writtenOutputFilePath_analog_filenames_temp.basename};
end



if should_process_digital
	activePathRoot = digital_path;
	combined_file_names_array = writtenOutputFilePath_digital_filenames;
else
	activePathRoot = analog_path;
	combined_file_names_array = writtenOutputFilePath_analog_filenames;
end
excelExportsSubdirectoryRelativeParentPath = 'ExcelExports';
excelExportsSubdirectoryAbsoluteParentPath.parentPath = fullfile(activePathRoot, excelExportsSubdirectoryRelativeParentPath);
if ~exist(excelExportsSubdirectoryAbsoluteParentPath.parentPath,'dir')
	mkdir(excelExportsSubdirectoryAbsoluteParentPath.parentPath)
end

excelExportsSubdirectoryAbsoluteParentPath.daily = fullfile(excelExportsSubdirectoryAbsoluteParentPath.parentPath, 'Binned Daily');
if ~exist(excelExportsSubdirectoryAbsoluteParentPath.daily,'dir')
	mkdir(excelExportsSubdirectoryAbsoluteParentPath.daily)
end
excelExportsSubdirectoryAbsoluteParentPath.hourly = fullfile(excelExportsSubdirectoryAbsoluteParentPath.parentPath, 'Binned Hourly');
if ~exist(excelExportsSubdirectoryAbsoluteParentPath.hourly,'dir')
	mkdir(excelExportsSubdirectoryAbsoluteParentPath.hourly)
end


varNames = {'Water1_BeamBreak','Water2_BeamBreak','Food1_BeamBreak','Food2_BeamBreak','Water1_Dispense','Water2_Dispense','Food1_Dispense','Food2_Dispense'};

for i=1:length(bbIDs)
    curr_bbID = bbIDs{i};
%     curr_folder = [activePathRoot, curr_bbID, '\experiment_00\cohort_00\animal_', curr_bbID];
    curr_combined_fileName = combined_file_names_array{i};
    curr_combined_filePath = fullfile(activePathRoot, [curr_combined_fileName, '.csv']);

    curr_output_excel_filePath.daily = fullfile(excelExportsSubdirectoryAbsoluteParentPath.daily, [curr_combined_fileName, '_binnedDaily', '.xlsx']);
	curr_output_excel_filePath.hourly = fullfile(excelExportsSubdirectoryAbsoluteParentPath.hourly, [curr_combined_fileName, '_binnedHourly', '.xlsx']);
    
    loadedLabjackData = importPhoLabjackServerEventsCsvFileHelper(curr_combined_filePath);

    outputDateTimes = datetime(loadedLabjackData.milliseconds_since_epoch, 'convertFrom','epochtime','TicksPerSecond',1000);
    outputDateTimes = outputDateTimes - hours(4); % to translate from GMT to Michigan timezone

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

%     disp(['loaded events from file: ' importFilePath])
    [counts,total] = PrintCompressedEventsStatus(OutputDeltas, OutputDeltasTimestamps);

    %labjackTimeTable = CompressedEvents2Timetable(OutputDeltas, OutputDeltasTimestamps, varNames(1:end-1));
    labjackTimeTable = CompressedEvents2Timetable(OutputDeltas, OutputDeltasTimestamps, varNames(1:end));

    % Append these events to the other compressed events:
    % [OutputDeltas, OutputDeltasTimestamps] = UpdateAndSaveCompressedEvents(OutputDeltas, OutputDeltasTimestamps);


    binnedEventsTimetable.daily = retime(labjackTimeTable,'daily','sum','IncludedEdge','right');
    % [fig, axH] = PlotBinnedEventsTimetable(binnedEventsTimetable, 'Imported File Port Events: binned daily');
    % Save to Excel file for Paul:
    writetimetable(binnedEventsTimetable.daily, curr_output_excel_filePath.daily);

    binnedEventsTimetable.hourly = retime(labjackTimeTable,'hourly','sum','IncludedEdge','right');
%     [fig, axH] = PlotBinnedEventsTimetable(binnedEventsTimetable, 'Imported File Port Events: binned hourly');


    % Save to Excel file for Paul:
    writetimetable(binnedEventsTimetable.hourly, curr_output_excel_filePath.hourly);

    disp('done.')



end
