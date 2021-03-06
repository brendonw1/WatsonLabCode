function [export_full_path, import_path] = ImportMatlabPreferences(import_path, should_make_backup)
%ImportMatlabPreferences Imports MATLABs current user preferences from a file created by ExportMatlabPreferences
%   import_path: Optional C-String specifying the exported folder to import from.
%   should_make_backup: Optional logical specifying whether to make a backup of the current preferences. True by default.

if ~exist('import_path','var') % Note the variable name is specified as a C-string
    % Prompt user for folder to export to:
    import_path = uigetdir('','Specify Exported MATLAB Preferences/Settings Folder to import');
end

if ~exist('should_make_backup','var')
    should_make_backup = true;
end
import_contents = fullfile(import_path, '*');

% Use "prefdir" command to get folder that contains all MATLAB settings.
preferences_path = prefdir;

% Backup current preference folder which will be overwritten:
%% TODO:
if should_make_backup
    disp(['Backing up existing MATLAB Preferences (which will be overwritten) to ', export_full_path, '...'])
    ExportMatlabPreferences('', 'AutoGeneratedPrefBackup');
    disp('done.')
end

%% Import from user-specified folder:
disp(['Importing MATLAB Preferences from ', import_path, ' to MATLAB preference folder (', preferences_path, ')...'])
[status,message,messageId] = copyfile(import_contents, preferences_path, 'f');
if status == 0
   warning(['    Error copying files! (ErrorId ', messageId, '); Message: ', message]);
   disp('done. With error.')
else
   disp('done. Restart MATLAB to see the changes.')
end

end

