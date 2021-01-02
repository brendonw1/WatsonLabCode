function [combinedOutputFilepath, combinedBodyLines, didUserCancel] = concatenateCSVFiles(csvFilePaths, combinedOutputFilepath, numHeaderLines)
%CONCATENATECSVFILES Concatenates multiple CSV files using a textmode
%technique
%   Detailed explanation goes here
% combinedOutputFilepath: the desired output path
% didUserCancel: true if the user clicked the cancel button, false otherwise.

didUserCancel = false;

% Check the input arguments for optional input arguments
if ~exist('combinedOutputFilepath','var')
     [combinedOutputFilename, combinedOutputParentPath] = uiputfile('*.csv','Save path for combined CSV','Combined.csv');
     if isequal(combinedOutputFilename,0) || isequal(combinedOutputParentPath,0)
       disp('ERROR: User clicked Cancel.')
	   didUserCancel = true;
       combinedOutputFilepath = '';
       return
     else
       combinedOutputFilepath = fullfile(combinedOutputParentPath, combinedOutputFilename);
       %disp(['User selected ',combinedOutputFilepath,' and then clicked Save.'])
    end
end
if ~exist('numHeaderLines','var')
    numHeaderLines = 4;
end
% if nargin > 2
%   numHeaderLines = optionalVarChangeDefaultParam;
% else
%   numHeaderLines = 4;
% end

[combinedOutputParentPath, combinedOutputBasename, combinedOutputFileExtension] = fileparts(combinedOutputFilepath);
combinedOutputFilename = [combinedOutputBasename, combinedOutputFileExtension];

% Set up variables to hold the csv header lines
headerLines = cell(numHeaderLines,1);

% Setup the combined output data
combinedBodyLines = cell(0,1);

numberOfCSVFiles = length(csvFilePaths);

waitbargui_title_string = sprintf('Merging %d files to %s...', numberOfCSVFiles, combinedOutputBasename);
waitbargui_body_string = 'Starting...';
waitbargui_extended_body_string = combinedOutputFilename;
waitbargui_message = {waitbargui_extended_body_string, waitbargui_body_string};
disp(waitbargui_title_string);

%% Create a progress bar
waitBarGUI = waitbar(0,'1','Name',waitbargui_title_string,'WindowStyle','normal','CreateCancelBtn',@cancelButton_callback,'Resize','on', 'SizeChangedFcn',@sizeChanged_callback);
setappdata(waitBarGUI,'canceling',0);

waitBarGUI_Figure_h=findobj(waitBarGUI,'Type','figure');
waitBarGUI_Axes_h = get(waitBarGUI_Figure_h,'currentaxes');
waitBarGUI_title_h = get(waitBarGUI_Axes_h,'title');
waitBarGUI_button_h = findobj(waitBarGUI_Figure_h, 'Tag','TMWWaitbarCancelButton');
waitBarGUI_waitbarControl_h = findobj(waitBarGUI_Figure_h, 'Tag','');

defaultWaitbarGUI.defaultFigurePosition = waitBarGUI.Position; % [left bottom width height]
defaultWaitbarGUI.defaultButtonPosition = waitBarGUI_button_h.Position;
defaultWaitbarGUI.defaultWaitbarControlPosition = waitBarGUI_waitbarControl_h.Position;

% Set the interpreter for the waitbar so underscores are rendered as subscripts.
set(waitBarGUI_title_h,'interpreter','none')

% Set normalized units:
set(waitBarGUI_button_h,'Units','normalized');
set(waitBarGUI_waitbarControl_h,'Units','normalized');

defaultWaitbarGUI.defaultButtonPosition_Normalized = waitBarGUI_button_h.Position;
defaultWaitbarGUI.defaultWaitbarControlPosition_Normalized = waitBarGUI_waitbarControl_h.Position;

% Set initial waitbar message
waitbar(0, waitBarGUI, waitbargui_message)
	
% Adjust waitbar height (make it larger);
% 'Units','pixels','Position',[473,596,670,120]
% defaultWaitbarGUIPosition = waitBarGUI.Position; % [left bottom width height]
% % Default: [495,362.187500189990,470,263.124999620020]
% [495       362.19          270       63.125]

% findobj('Tag','TMWWaitbar');

% % 473,596,270,63
% % Ideal: [473,596,670,120]
% defaultWaitbarGUIPosition(3) = defaultWaitbarGUIPosition(3) + 200; % Width
% defaultWaitbarGUIPosition(4) = defaultWaitbarGUIPosition(4) + 200; % Height

% defaultWaitbarGUI.defaultFigurePosition(3) = 620; % Width
% defaultWaitbarGUI.defaultFigurePosition(4) = 90; % Height
% waitBarGUI.Position = defaultWaitbarGUI.defaultFigurePosition;

waitBarGUI.Position(3) = 620; % Width
waitBarGUI.Position(4) = 90; % Height

% After setting the width, restore the default settings:


%% Process CSV files
for fileIndex = 1:numberOfCSVFiles
    
    % Check for clicked Cancel button in GUI
    if getappdata(waitBarGUI,'canceling')
		if ~didUserCancel
			didUserCancel = true;
			waitbar(0.99, waitBarGUI, 'Canceling...')
		end
        break % Break out of the for loop
    end
    % Update waitbar and message
	waitbargui_body_string = sprintf('\t Processing file %i of %i',fileIndex,numberOfCSVFiles);
	waitbargui_message = {waitbargui_extended_body_string, waitbargui_body_string};
    waitbar((fileIndex/numberOfCSVFiles), waitBarGUI, waitbargui_message)
    
    % Construct the full file path
    currCSVFilePath = fullfile(csvFilePaths(fileIndex).folder, csvFilePaths(fileIndex).name);
    fid = fopen(currCSVFilePath,'r');
    % Get the header information from the first file
    if (fileIndex == 1)
        for lineIndex = 1:numHeaderLines
			headerLines(lineIndex) = {fgetl(fid)}; 
        end
        % Process the header information
        %TODO: verify that the header info hasn't changed between files (so
        %we don't concatinate differnt data
    else
        %read the header lines for non-first files, but throw them away.
        for lineIndex = 1:numHeaderLines
            trash = {fgetl(fid)}; 
        end
    end

    tline = fgetl(fid);
    while ischar(tline)
		if getappdata(waitBarGUI,'canceling')
			didUserCancel = true;
			waitbar(0.99, waitBarGUI, 'Canceling...')
			break % Break while loop, but not the outer for loop execution so we can successfully close the file.
		else
			combinedBodyLines{end+1,1} = tline;
			tline = fgetl(fid);
		end
	end % while ischar(tline)
    fclose(fid); 
end % end for loop

if didUserCancel
	% User canceled. Don't write anything
	fprintf('\t error: User canceled for %s \n', combinedOutputFilepath);
	combinedOutputFilepath = ''; % Clear the output file so it's known that we didn't write to it.
	
	
else
	% Otherwise user didn't cancel:
	numTotalBodyLines = length(combinedBodyLines);
	totalLinesToWrite = numHeaderLines + numTotalBodyLines;
	
	fprintf('\t Writing %d lines to %s...\n', totalLinesToWrite, combinedOutputBasename);
	waitbargui_body_string = sprintf('\t Writing %d lines...', totalLinesToWrite);
	
% 	waitbargui_body_string = sprintf('\t Writing %d lines to %s', totalLinesToWrite, combinedOutputBasename);
% 	disp(waitbargui_body_string);

	waitbargui_message = {waitbargui_extended_body_string, waitbargui_body_string};
	waitbar(0.99, waitBarGUI, waitbargui_message)

	%% Save out to new csv file
	fid = fopen(combinedOutputFilepath,'w');
	% Write header lines
	for lineIndex = 1:numHeaderLines
	%     % Check for clicked Cancel button in GUI
	%     if getappdata(waitBarGUI,'canceling')
	%         disp('User canceled!')
	%         break
	%     end
	%     % Update waitbar and message
	%     waitbar(lineIndex/totalLinesToWrite,waitBarGUI,sprintf('Writing line %i of %i to output file',lineIndex,totalLinesToWrite))
		% Write the line to the file:
		fprintf(fid,'%s\n',headerLines{lineIndex});
	end
	% Write body lines
	for lineIndex = 1:numTotalBodyLines
	%     % Check for clicked Cancel button in GUI
	%     if getappdata(waitBarGUI,'canceling')
	%         disp('User canceled!')
	%         break
	%     end
	%     % Update waitbar and message
	%     writtenLineIndex = (lineIndex + numHeaderLines);
	%     waitbar(writtenLineIndex/totalLinesToWrite,waitBarGUI,sprintf('Writing line %i of %i to output file',writtenLineIndex,totalLinesToWrite))
	
		if getappdata(waitBarGUI,'canceling')
			didUserCancel = true;
			waitbar(0.99, waitBarGUI, 'Will cancel after this file is written...')
		end
		
		% Write the line to the file:
		fprintf(fid,'%s\n',combinedBodyLines{lineIndex});
	end
	fclose(fid);

	fprintf('\t done. File saved to %s \n', combinedOutputFilepath);

end % end if didUserCancel

% Check one more time before closing the prompt if the user pressed cancel.
if getappdata(waitBarGUI,'canceling')
	didUserCancel = true;
	waitbar(0.99, waitBarGUI, 'Canceling...')
end
		
% Delete the waitbar
delete(waitBarGUI)
	
% SizeChangedFcn
	function cancelButton_callback(src_handle, eventData)
		setappdata(gcbf,'canceling',1)
% 		setappdata(gcbf,'canceling',1)
		
	end

	
	function sizeChanged_callback(src_handle, eventData)
% 		setappdata(gcbf,'canceling',1)
% 		setappdata(gcbf,'canceling',1)
		
	end

end


