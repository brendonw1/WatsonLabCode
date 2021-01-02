function [edgePointLinearIndicies, bwEdgePoints] = FnFindBoundaryPixels(bwImage)
%FnFindBoundaryPixels Finds the outline of a binary image by tracing across each column until it finds the edge of mask.
%   Detailed explanation goes here

%% Works well except for where there's actual breaks in the mouse.


%% Finds the outline of a binary image by tracing across each column until it finds the edge of mask.
% It iterates over each row from each direction.

imageSize = size(bwImage);

bwEdgePoints = logical(zeros(imageSize,'int8'));
edgePointLinearIndicies = []; % a 

% TODO, IDEA: Could easily keep track of the non-blob edge indicies to find the outlines of the holes and such.

%% TODO, IDEA: Could fill in holes by just replacing everything between the found start and end indicies with white.

numRows = imageSize(1);
numColumns = imageSize(2);

% [trueRowIndicies, trueColumnIndicies] = find(bwImage > 0);


% for rowIndex = 1:numRows
% % 	trueIndicies = find(bwImage > 0);
% 	
% 	% For each row, coming down
% 	if ismember(trueRowIndicies, rowIndex)
% 		
% 	end
% 	
% 
% % 	[maxima_row_index, maxima_col_index] = ind2sub(size(flooding_image), seed_point_linear_index);
% %     maxima_value = flooding_image(maxima_row_index, maxima_col_index);
% 	
% end

shouldPlotDebugResults = true;

%% Naieve implementation:

% Its possible that a given row or column lacks blob start/stop points entirely, or only has one blob point (when it's cut off by an edge for example).
% Horizontal Analysis:
[edgePointLinearIndicies, partial_edgePointIndicies, bwEdgePoints, fbpDebugResults] = FnInternal_SingleDirectionFindBoundaryPixels(bwImage);

% Vertical Analysis: Use the transpose of the image
[~, vertical_edgePointIndicies, vertical_bwEdgePoints, vertical_fbpDebugResults] = FnInternal_SingleDirectionFindBoundaryPixels(bwImage');
% Compute the transpose of the results:
vertical_edgePointIndicies = [vertical_edgePointIndicies(:,2), vertical_edgePointIndicies(:,1)]; % Swap the x and y columns
% Convert the translated edge point indicies to linear indicies:
vertical_bwEdgePoints = vertical_bwEdgePoints';


% Combine the results:
bwEdgePoints = bwEdgePoints | vertical_bwEdgePoints;

if shouldPlotDebugResults
	vertical_fbpDebugResults.partial_bwOffToOnTransitionPoints = vertical_fbpDebugResults.partial_bwOffToOnTransitionPoints';
	vertical_fbpDebugResults.partial_bwOnToOffTransitionPoints = vertical_fbpDebugResults.partial_bwOnToOffTransitionPoints';
	vertical_fbpDebugResults.partial_bwTransitionPoints = vertical_fbpDebugResults.partial_bwTransitionPoints';
	
	% Combine the debug points:
	fbpDebugResults.partial_bwOffToOnTransitionPoints = fbpDebugResults.partial_bwOffToOnTransitionPoints | vertical_fbpDebugResults.partial_bwOffToOnTransitionPoints;
	fbpDebugResults.partial_bwOnToOffTransitionPoints = fbpDebugResults.partial_bwOnToOffTransitionPoints | vertical_fbpDebugResults.partial_bwOnToOffTransitionPoints;
	fbpDebugResults.partial_bwTransitionPoints = fbpDebugResults.partial_bwTransitionPoints | vertical_fbpDebugResults.partial_bwTransitionPoints;
	
	fig = figure();
	h_plots{1} = subplot(2,2,1);
	imshow(fbpDebugResults.partial_bwTransitionPoints)
	title('Transition points')
	
	h_plots{2} = subplot(2,2,2);
	imshow(fbpDebugResults.partial_bwOffToOnTransitionPoints)
	title('Off to On points')
	
	h_plots{3} = subplot(2,2,3);
	imshow(fbpDebugResults.partial_bwOnToOffTransitionPoints)
	title('On to Off points')
	
	h_plots{4} = subplot(2,2,4);
	imshow(bwEdgePoints)
	title('bwEdgePoints')
	
	
	% Update the positions of the plots to remove the padding:
	num_columns = 2;
	num_rows = 2;
	num_plots = num_columns * num_rows;

	percent_height = 1.0/double(num_rows);
	percent_width = 1.0/double(num_columns);

	TextboxHeight = 0.08; % Hardcoded constant 
	TextboxTextColor = [0.941176470588235 0.941176470588235 0.941176470588235]; % White
	
	curr_linear_index = 1;
	for rowIndex=1:num_rows

		for colIndex=1:num_columns

			curr_x_offset = double(colIndex-1) * percent_width;
			curr_y_offset = double(rowIndex-1) * percent_height;
			set(h_plots{curr_linear_index},'position',[curr_x_offset, curr_y_offset, percent_width, percent_height]);

			curr_textbox_y_offset = curr_y_offset + TextboxHeight;
			% Reads the existing title from the subplot.
			g = get(h_plots{curr_linear_index},'title');
			curr_textbox_title = get(g,'string');
			curr_textbox_text = {curr_textbox_title}; % Can do multiline text by using {'line 1', 'line 2'}
			
			% Create textbox to draw the title:
			curr_textbox_annotation = annotation(fig,'textbox',[curr_x_offset curr_textbox_y_offset percent_width TextboxHeight],'Color',TextboxTextColor,...
				'String',curr_textbox_text,...
				'Interpreter','none',...
				'HorizontalAlignment','center',...
				'FitBoxToText','off',...
				'FontSize',12);

			%% Update the linear index:
			curr_linear_index = curr_linear_index + 1;
		end

	end
	drawnow
end


end

function [partial_edgePointLinearIndicies, partial_edgePointIndicies, partial_bwEdgePoints, fbpDebugResults] = FnInternal_SingleDirectionFindBoundaryPixels(bwImage)
	% Does the analysis on one axis from both directions.
	imageSize = size(bwImage);
	numRows = imageSize(1);
	numColumns = imageSize(2);

	partial_bwEdgePoints = logical(zeros(imageSize,'int8'));
	
	% Debugging:
	fbpDebugResults.partial_bwOffToOnTransitionPoints = logical(zeros(imageSize,'int8'));
	fbpDebugResults.partial_bwOnToOffTransitionPoints = logical(zeros(imageSize,'int8'));
	fbpDebugResults.partial_bwTransitionPoints = logical(zeros(imageSize,'int8'));
	
	% fbpDebugResults
	% partial_bwOffToOnTransitionPoints
	% partial_bwOnToOffTransitionPoints
	% partial_bwTransitionPoints
	
	
	partial_edgePointLinearIndicies = []; % an N x 1 matrix of linear indicies 
	partial_edgePointIndicies = []; % an n x 2 matrix of indicies in [x, y] format.


	for rowIndex = 1:numRows

		% For each row, coming down

		curr_row_found_change_col_indicies = [];
		last_value = false;

		% Get the first and list row index of true values, if they exist
		for colIndex = 1:numColumns
			% If we start and the first item is true, we know that's the start point. This is added automatically since we start with last_value == false
			curr_value = bwImage(rowIndex, colIndex);

			did_start_or_end_blob = (last_value ~= curr_value);
	% 		bwEdgePoints(rowIndex, colIndex) = did_start_or_end_blob;
			if did_start_or_end_blob

				% Add any start or end of the blob to the array.
				if (curr_value > 0)
					% Started blob
					curr_row_found_change_col_indicies = [curr_row_found_change_col_indicies, colIndex];
					fbpDebugResults.partial_bwTransitionPoints(rowIndex, colIndex) = true;
					fbpDebugResults.partial_bwOffToOnTransitionPoints(rowIndex, colIndex) = true;
				else
					% Ended blob
					% I suppose if we end the blob, we may want to use the last white point (which was the last point) as opposed to this point, which was the first non-white point. 
					curr_row_found_change_col_indicies = [curr_row_found_change_col_indicies, (colIndex - 1)]; % Using the lst point as opposed to this point.
					% For a singularity, this would result in a duplicate point being added to the array. I think this is okay.
					fbpDebugResults.partial_bwTransitionPoints(rowIndex, colIndex) = true;
					fbpDebugResults.partial_bwOnToOffTransitionPoints(rowIndex, colIndex) = true;
				end

			elseif (colIndex == numColumns)
				if last_value > 0
					% If we get to the end and the last value is still true, that's the end point
					% Add the last column (which is still true) to the array to mark the end of the blob.
					curr_row_found_change_col_indicies = [curr_row_found_change_col_indicies, colIndex];
				end
			end
			last_value = curr_value;

		end


		% Once we're done with the row (we've scanned all columns), figure out where they start and stop.
		if isempty(curr_row_found_change_col_indicies)
			% Row has no blob in it.

		elseif length(curr_row_found_change_col_indicies) == 1
			% Only 1. This implies that we're at a point, like the tip of the ear, that only has one entry.
			knownColIndex = curr_row_found_change_col_indicies(1);
			partial_bwEdgePoints(rowIndex, knownColIndex) = true;
			partial_edgePointIndicies(end+1,:) = [rowIndex, knownColIndex];
			partial_edgePointLinearIndicies(end+1) = sub2ind(imageSize, rowIndex, knownColIndex);


		elseif length(curr_row_found_change_col_indicies) == 2
			% Exactly 2, choose the first and last.
			startColIndex = curr_row_found_change_col_indicies(1); % first
			endColIndex = curr_row_found_change_col_indicies(end); % last

			partial_bwEdgePoints(rowIndex, startColIndex) = true;
			partial_bwEdgePoints(rowIndex, endColIndex) = true;

			partial_edgePointIndicies(end+1,:) = [rowIndex, startColIndex];
			partial_edgePointIndicies(end+1,:) = [rowIndex, endColIndex];
			
			partial_edgePointLinearIndicies(end+1) = sub2ind(imageSize, rowIndex, startColIndex);
			partial_edgePointLinearIndicies(end+1) = sub2ind(imageSize, rowIndex, endColIndex);


		else % Greater than 2, choose first and last only.
			startColIndex = curr_row_found_change_col_indicies(1); % first
			endColIndex = curr_row_found_change_col_indicies(end); % last

			partial_bwEdgePoints(rowIndex, startColIndex) = true;
			partial_bwEdgePoints(rowIndex, endColIndex) = true;

			partial_edgePointIndicies(end+1,:) = [rowIndex, startColIndex];
			partial_edgePointIndicies(end+1,:) = [rowIndex, endColIndex];
			
			partial_edgePointLinearIndicies(end+1) = sub2ind(imageSize, rowIndex, startColIndex);
			partial_edgePointLinearIndicies(end+1) = sub2ind(imageSize, rowIndex, endColIndex);

		end


	end % end for
	
	
end % end function FnInternal_SingleDirectionFindBoundaryPixels(...)
