function [didSplit] = SplitCombinedCSVToDigitalAndAnalog(curr_import_directory_path, curr_original_file_name)
%SplitCombinedCSVToDigitalAndAnalog Splits erroniously combined digital and analog (running wheel) .CSV files into the new, separate format used just prior to 2/19/2020
%   Detailed explanation goes here

%curr_import_directory_path = 'E:\EventData\EventData\BB02\experiment_00\cohort_00\animal_02\';
%curr_original_file_name = 'out_file_s470019538_1581354045076.csv';
curr_import_path = fullfile(curr_import_directory_path, curr_original_file_name);
backup_parent_path = 'E:\EventData\';
backup_folder_name = 'backups';
mkdir backup_parent_path backup_folder_name
backup_final_dir = fullfile(backup_parent_path, backup_folder_name);

% Detect number of columns to determine which type of file it is:
expected_var_names = ["computerTime", "EIO0", "EIO1", "EIO2", "EIO3", "EIO4", "EIO5", "EIO6", "EIO7", "AIN0"];
opts = detectImportOptions(curr_import_path);
if (isequal(expected_var_names, opts.VariableNames))
    loadedLabjackDataStrings = importPhoLabjackServerEventsCsvFileHelper_LiteralStrings(curr_import_path);
    % Build Digital/Analog Only Outputs:
    loadedLabjackDigitalData = loadedLabjackDataStrings(:,["computerTime", "EIO0", "EIO1", "EIO2", "EIO3", "EIO4", "EIO5", "EIO6", "EIO7"]);
    loadedLabjackAnalogData = loadedLabjackDataStrings(:,["computerTime","AIN0"]);

    % Build Analog Filename of the form "out_file_analog_s470019538_1581621482876.csv":
    [importCombinedFile.folder, importCombinedFile.baseFileName, importCombinedFile.fileExtension] = fileparts(curr_import_path);
    fileNameComponents = split(importCombinedFile.baseFileName,'_');
    analog_fileNameComponents = {fileNameComponents{1:2}, 'analog', fileNameComponents{3:end}};
    analogFileOutputBasename = join(analog_fileNameComponents, '_');
    analogFileOutputBasename = [analogFileOutputBasename{1} '.csv'];
    final_output_analog_file_path = fullfile(curr_import_directory_path, analogFileOutputBasename);

    % Write Files Out to Disk:
    % Save out backup of combined file:
    backup_fileNameComponents = {fileNameComponents{1:2}, 'all', fileNameComponents{3:end}};
    backupFileOutputBasename = join(backup_fileNameComponents, '_');
    backupFileOutputBasename = [backupFileOutputBasename{1} '.bak.csv'];
    final_output_backup_combined_file_path = fullfile(backup_final_dir, backupFileOutputBasename);
    writetable(loadedLabjackDataStrings, final_output_backup_combined_file_path)

    % Save out analog file:
    writetable(loadedLabjackAnalogData, final_output_analog_file_path)

    % Save out digital file with same filename as the current all file
    writetable(loadedLabjackDigitalData, curr_import_path)
    
    didSplit = true;
else
    didSplit = false;
end


end

