function CSVOutputDirectoryPath = BuildAllCombinedCSVs(bbIDs,dataPath,CSVOutputDirectoryPath,CurrentExpt,CurrentCohort)

%% 2/20/2020: Imports new split digital and analog .CSV files output from phoLabjackControllerSoftware and combines them into two independent "Combined CSV"s. One for analog and one for digital.

% addpath(genpath('../HelperFunctions'));

if ~exist('bbIDs','var')
	bbIDs = {'02','04','06','09','12','14','15','16'};
end
if ~exist('dataPath','var')
	dataPath = 'F:\EventData\BB';
end
if ~exist('CSVOutputDirectoryPath','var')
	CSVOutputDirectoryPath = 'F:\Concatenated EventData CSVs';
end
if ~exist('CurrentExpt')
	CurrentExpt = '00';
end
if ~exist('CurrentCohort')
	CurrentCohort = '00';
end


enable_post_combine_copy = true;
analog_path = fullfile(CSVOutputDirectoryPath, 'Analog');
digital_path = fullfile(CSVOutputDirectoryPath, 'Digital');


% For Workstation:
% activePathRoot = 'E:\EventData\EventData\BB';

% For Overseer:
% dataPath = 'F:\EventData\BB';

for i=1:length(bbIDs)
    curr_bbID = bbIDs{i};
    curr_folder = [dataPath, curr_bbID, filesep 'experiment_' CurrentExpt filesep 'cohort_' CurrentCohort filesep 'animal_', curr_bbID];
   
	% Tries to make use of any extant workspace variable 'foundCSVFiles', which contains both analog and digital CSV file information.
%     if ~exist('foundCSVFiles','var')
	if ~exist(curr_folder,'dir')
        rootSearchPath{i} = uigetdir(curr_folder, 'Select the folder containing the CSV data');
        if isequal(rootSearchPath{i},0)
            error('ERROR: You must choose a root directory.')
        end
	else
		% if the variable does exist, use the curr_folder variable as the rootSearchPath.
        rootSearchPath{i} = curr_folder;
	end

    % Find the CSV Files in the childSearchPaths
    [foundCSVFiles{i}, foundDigitalCSVFiles{i}, foundAnalogCSVFiles{i}] = findLabjackCSVFiles({rootSearchPath{i}});
    [writtenOutputFilePath_digital{i}, didUserCancel_Digital] = BuildCombinedCSV(rootSearchPath{i}, foundDigitalCSVFiles{i}, curr_bbID);
	writtenOutputFilePath_digital_file{i}.fullpath = writtenOutputFilePath_digital{i};
	[writtenOutputFilePath_digital_file{i}.filename, writtenOutputFilePath_digital_file{i}.basename, writtenOutputFilePath_digital_file{i}.extension] = FnGetFilenameFromAbsolutePath(writtenOutputFilePath_digital{i});
	
	if ~didUserCancel_Digital
		[writtenOutputFilePath_analog{i}, didUserCancel_Analog] = BuildCombinedCSV(rootSearchPath{i}, foundAnalogCSVFiles{i}, curr_bbID);
		writtenOutputFilePath_analog_file{i}.fullpath = writtenOutputFilePath_analog{i};
		[writtenOutputFilePath_analog_file{i}.filename, writtenOutputFilePath_analog_file{i}.basename, writtenOutputFilePath_analog_file{i}.extension] = FnGetFilenameFromAbsolutePath(writtenOutputFilePath_analog{i});
	else
		writtenOutputFilePath_analog{i} = '';
		didUserCancel_Analog = true;
	end
	
	didUserCancel = didUserCancel_Digital || didUserCancel_Analog;
	if didUserCancel
		disp('Aborting: User canceled')
		break;
	end
end


if enable_post_combine_copy
	if ~exist(analog_path, 'dir')
		mkdir(analog_path)
	end
	if ~exist(digital_path, 'dir')
		mkdir(digital_path)
	end
	
	for i=1:length(writtenOutputFilePath_analog)
		copyfile(writtenOutputFilePath_analog{i}, analog_path);
		copyfile(writtenOutputFilePath_digital{i}, digital_path);
	end
end
