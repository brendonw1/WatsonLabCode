function [backup_file_fullpath, status] = MakeBackup(sourceFilePath, backupPrefix, backupSuffix, includeDateInBackupSuffix, relativeBackupDestinationPath)
%MakeBackup Makes a backup of the file specified by sourceFilePath
%   Output File is of the form '{backupPrefix}_{baseName}_{backupSuffix}{'dd-mm-yy-HH:MM'}'

	if ~exist('backupPrefix','var')
		backupPrefix = 'backup';
	end

	if ~exist('backupSuffix','var')
	% 	backupSuffix = '.bak';
		backupSuffix = '';
	end

	if ~exist('includeDateInBackupSuffix','var')
		includeDateInBackupSuffix = true;
	end

	if includeDateInBackupSuffix
		% Get date suffix:
		date_suffix_string = datestr(now, 'dd-mm-yy-HH-MM');
		backupSuffix = [backupSuffix, date_suffix_string];
	end

	[parentSourcePath, baseName, fileExtension] = fileparts(sourceFilePath);

	

	backup_file_basename = sprintf('%s_%s_%s', backupPrefix, baseName, backupSuffix);
	backup_file_name = [backup_file_basename, fileExtension];

	if exist('relativeBackupDestinationPath','var')
		resolved_backupDestinationPath = fullfile(parentSourcePath, relativeBackupDestinationPath);
		if ~exist(resolved_backupDestinationPath,'dir')
			mkdir(resolved_backupDestinationPath);
            %error('relativeBackupDestinationPath specified but does not exist!');
		end
		backup_file_fullpath = fullfile(resolved_backupDestinationPath, backup_file_name);

	else
		backup_file_fullpath = fullfile(parentSourcePath, backup_file_name);

	end

	[status,message,messageId] = copyfile(sourceFilePath, backup_file_fullpath);
	if ~status
		error('File copy from %s to %s failed with message %s', sourceFilePath, backup_file_fullpath, message);
	else
		fprintf('Copied file from %s to %s successfully.\n', sourceFilePath, backup_file_fullpath);
	end
end

