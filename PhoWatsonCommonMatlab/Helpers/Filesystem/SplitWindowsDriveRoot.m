function [DriveRootPart, RemainingPath, isUNCRoot] = SplitWindowsDriveRoot(path)
%SPLITWINDOWSDRIVEROOT Splits the path to get the windows drive root (Z:/) and the remainder of the path ('Main/Test1/aPath/file.tip')

    % '(?:^([A-Z|a-z][:][\\])|^([\\]{2}[A-Z|a-z]+[\\]))(.*)'
    windowsLocalFoldersOnlyExpression = '^(?<root>[A-Z|a-z][:][\\])(?<remainder>.*)';
    windowsUNCPathsOnlyExpression = '^(?<root>[\\]{2}[A-Z|a-z]+[\\])(?<remainder>.*)';
    
    localTokenNames = regexp(path, windowsLocalFoldersOnlyExpression,'names');
    if isempty(localTokenNames)
        
        % Try as a UNC path:
        uncTokenNames = regexp(path, windowsUNCPathsOnlyExpression,'names');
        if isempty(uncTokenNames)
            error('not valid path!')
        else
            % valid UNC path:
            isUNCRoot = true;
            DriveRootPart = localTokenNames.root;
            RemainingPath = localTokenNames.remainder;
        end
    
    else
        % is local
        isUNCRoot = false;
        
        DriveRootPart = localTokenNames.root;
        RemainingPath = localTokenNames.remainder;

    end % end isempty local


