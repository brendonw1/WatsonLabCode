function [export_full_path, dest_parent_path] = ExportMatlabPreferences(dest_parent_path, export_filename_prefix)
%EXPORTMATLABPREFERENCES Exports MATLABs current user preferences to a file named 'MatlabPreferencesExport__20160129T161450' in the user-specified path
%   dest_parent_path: Optional C-String specifying the parent folder to expor to.
%   export_filename_prefix: Optional C-string that specifies the start of the filename. Defaults to 'MatlabPreferencesExport'
% 
if ~exist('export_filename_prefix','var')
   export_filename_prefix = 'MatlabPreferencesExport';
end
if ~exist('dest_parent_path','var') % Note the variable name is specified as a C-string
    % Prompt user for folder to export to:
    dest_parent_path = uigetdir('','Specify Parent Folder to export MATLAB Preferences/Settings to');
end
% Use "prefdir" command to get folder that contains all MATLAB settings.
preferences_path = prefdir;
preferences_files = fullfile(preferences_path, '*'); % All files and subdirectories

% copyfile Creates the folder if it doesn't exist
export_name = sprintf('%s_%s', export_filename_prefix, datestr8601);
export_full_path = fullfile(dest_parent_path, export_name);

disp(['Exporting MATLAB Preferences from ', preferences_path, ' to ', export_full_path, '...'])
[status,message,messageId] = copyfile(preferences_files, export_full_path);
if status == 0
   warning(['    Error copying files! (ErrorId ', messageId, '); Message: ', message]); 
end
disp('done.')

% Open the exported directory, windows only:
winopen(dest_parent_path);
end

