function [foundCSVFiles] = findCSVFiles(searchPathsCellArray)
%FINDCSVFILES Finds the .CSV files in the provided path or paths
%   searchPathsCellArray: cell array of strings containing the paths to
%   search

    % Iterate through each search path
    for pathI = 1:length(searchPathsCellArray)
        % Find all .csv files in the directory
        fullSearchPathFilter = fullfile(searchPathsCellArray{pathI},'*.csv');
        dirData = dir(fullSearchPathFilter);

        if ~exist('foundCSVFiles','var')
            foundCSVFiles = dirData;
        else
            % Append the new dirData to the end of the previous dirData
            foundCSVFiles = [foundCSVFiles; dirData];
        end

    end

end

