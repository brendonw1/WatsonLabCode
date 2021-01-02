function [foundCSVFiles, foundDigitalCSVFiles, foundAnalogCSVFiles] = findLabjackCSVFiles(searchPathsCellArray)
%findLabjackCSVFiles Finds the analog and digital Labjack .CSV output files in the provided path or paths
%   searchPathsCellArray: cell array of strings containing the paths to search

    analog_pattern = "_analog_";
    combined_pattern = "Combined";
    
    % Iterate through each search path
    for pathI = 1:length(searchPathsCellArray)
        % Find all .csv files in the directory
        fullSearchPathFilter = fullfile(searchPathsCellArray{pathI},'*.csv');
        dirData = dir(fullSearchPathFilter);
        % Doesn't returned "combined" CSV files that have been generated from the .csv's in this path.
        TF_combined = contains({dirData.name}', combined_pattern);
        dirData = dirData(~TF_combined);
        
        TF = contains({dirData.name}', analog_pattern);
        dirData_Digital = dirData(~TF);
        dirData_Analog = dirData(TF);
        
		% OK TODO: don't we want to check the existing workspace variables for 'foundCSVFiles' so it isn't overwritten? foundCSVFiles would not exist within the function scope in any case.
			% Update: it's looking for 'foundCSVFiles' variables within the function scope from previous iterations of this loop.
        if ~exist('foundCSVFiles','var')
			% If this is the first iteration of the loop, create the variables.
            foundCSVFiles = dirData;
            foundDigitalCSVFiles = dirData_Digital;
            foundAnalogCSVFiles = dirData_Analog;
        else
            % Otherwise append the new dirData to the end of the previous dirData
            foundCSVFiles = [foundCSVFiles; dirData];
            foundDigitalCSVFiles = [foundDigitalCSVFiles; dirData_Digital];
            foundAnalogCSVFiles = [foundAnalogCSVFiles; dirData_Analog];
        end

    end

end

