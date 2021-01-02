function [bw_flood_filling_mask] = FnFloodFillMask(flooding_image, seed_point_linear_index, caFloodingSettings)
%FNFLOODFILLMASK Marks each pixel in the image as included or excluded in a binary mask by flooding outward from a specified point.
%   Goal: Mark each pixel in the image as included or excluded in a binary mask.
        
    % Expand outward from the maximum so long as:
        % They exceed a global threshold (globalThresholding).
        % They don't differ from the current pixel by more than a certain threshold (adaptiveEgocentricNeighborsThresholding)
        % They don't differ from their surrounding pixels by more than a given threshold (adpativeAllocentricNeighborsThresholding)
    
        % Ensure that the additive mask exceeds a certain blob size.
            
		
% Inputs:
%	image: the raw input image to work on.    
%	seed_point_linear_index: The linear index of the point where you wish the operation to start.
%	caFloodingSettings: Settings for flooding. Optional.


%%%+S- caFloodingSettings: Settings for the flood operation
	%- neighbourType - neighbourType the nearest neighbouring pixels to find options: 4, 8
	%- inclusionCriteriaType - inclusionCriteriaType the type of processing to do to detect neighbors. Options: 'globalThresholding','adaptiveEgocentricNeighborsThresholding','adpativeAllocentricNeighborsThresholding'
	%% inclusionCriteriaType Specific fields:
		% 'globalThresholding' only:
			%- globalThresholdValue - globalThresholdValue: specifies the absolute threshold for including neighboring pixels.
%

if ~exist('caFloodingSettings','var')
	% Set up default flooding settings if not specified.
    caFloodingSettings.neighbourType = 8; % Finds the 8 nearest neighbouring pixels.
    caFloodingSettings.inclusionCriteriaType = 'globalThresholding';
end

    flooding_image_size = size(flooding_image);
    
    % tf_was_enqued: used to prevent already enqued indicies from being added back to the queue. Does not indicate processing completion status.
    tf_was_enqued = logical(zeros(flooding_image_size,'int8'));
    
    % tf_is_processing_complete: keeps track of whether the given pixel has already been processed.
    tf_is_processing_complete = logical(zeros(flooding_image_size,'int8'));
    
    bw_flood_filling_mask = logical(zeros(flooding_image_size,'int8'));
    
    [maxima_row_index, maxima_col_index] = ind2sub(size(flooding_image), seed_point_linear_index);
    maxima_value = flooding_image(maxima_row_index, maxima_col_index);
    bw_flood_filling_mask(maxima_row_index, maxima_col_index) = true;
    
	if ~exist('caFloddingSettings','var')
		caFloodingSettings.globalThresholdValue = maxima_value * 0.14;
	end
	
    globalThresholdValue = caFloodingSettings.globalThresholdValue;
    
    % Start a 'locus' pixel that is known to be included in the blob.
    curr_locus_linear_index = seed_point_linear_index;
    
    pending_locus_linear_indicies = [curr_locus_linear_index]; % An n x 1 list of linear indicies for pixels that still remain to be processed.

    is_complete = false;
    while (~is_complete)
        % Update curr_locus_linear_index from pending_locus_linear_indices:
        % TODO:
        curr_locus_was_excluded_from_mask = false;
        was_curr_locus_finished = false; % A specific locus is finished if all of its neighbours are finished. This allows neighbor-dependant processing.
        
        curr_locus_linear_index = pending_locus_linear_indicies(1);
        % Remove it from the array (perhaps to be added back on later if NOT was_curr_locus_finished)
        pending_locus_linear_indicies(1) = [];
        
        [curr_locus_row_index, curr_locus_col_index] = ind2sub(size(flooding_image), curr_locus_linear_index);
        curr_locus_value = flooding_image(curr_locus_row_index, curr_locus_col_index);
        
        % 
        
        % A locus that isn't included in the mask doesn't add its neighbours to the search list.
        if caFloodingSettings.inclusionCriteriaType == 'globalThresholding'
            
            if curr_locus_value > globalThresholdValue
                % It is included in the mask
                bw_flood_filling_mask(curr_locus_row_index, curr_locus_col_index) = true;
                curr_locus_was_excluded_from_mask = false;
%                 was_curr_locus_finished = false; % Not necissarily finished unless its neighbors are. Add it to the end of the list. This isn't needed for this simple globalThresholding case, but might be for others.
                was_curr_locus_finished = true; % Not necissarily finished unless its neighbors are. Add it to the end of the list. This isn't needed for this simple globalThresholding case, but might be for others.
                % This calculation will be repeated many times unfortunately with this setup.
            else
                bw_flood_filling_mask(curr_locus_row_index, curr_locus_col_index) = false;
                curr_locus_was_excluded_from_mask = true;
                was_curr_locus_finished = true;
            end
            
            
        else
            % For other processing types, we'd want to be sure to set:
            % curr_locus_was_excluded_from_mask = false;
            % was_curr_locus_finished = false;
            % when processing can't complete due to waiting on neighbors. This ensures that it can check its neighbors for updated completion.
            error('Not yet implemented')
        end
        
        % If the current locus wasn't specifically excluded from the mask, process its neighbors.
        if ~curr_locus_was_excluded_from_mask
            did_find_incomplete_neighbour = false;
            
            % From the current locus pixel, process each of its adjacent neighboring pixels that haven't been already processed.
            NeighboursLinearInd = findNeighbours(curr_locus_linear_index, flooding_image_size, caFloodingSettings.neighbourType);
            for currNeighbourItemIndex = 1:length(NeighboursLinearInd)
                curr_neighbour_linear_index = NeighboursLinearInd(currNeighbourItemIndex);
                [curr_neighbour_row, curr_neighbour_col] = ind2sub(flooding_image_size, curr_neighbour_linear_index);
                
                % See if neighbor has already been enqueud, if so skip it:
                if tf_was_enqued(curr_neighbour_row, curr_neighbour_col)
                    % Check if this neighbour is complete:
                    if ~tf_is_processing_complete(curr_neighbour_row, curr_neighbour_col)
                        did_find_incomplete_neighbour = true;
                    end
                else
                    % Neighbour hasn't been enqued, add it to the queue to be processed:
                    if ismember(pending_locus_linear_indicies, curr_neighbour_linear_index)
                        error('Index already exists in pending!! WTF?')
                    end
                    
                    pending_locus_linear_indicies(end+1) = curr_neighbour_linear_index;
                    % Mark it as enqued:
                    tf_was_enqued(curr_neighbour_row, curr_neighbour_col) = true;        
                end
                
                
            end % end for neightbors
            
            if ~did_find_incomplete_neighbour
                % If no incomplete neighbours remain, it's done!
                was_curr_locus_finished = true;
            end
            
        end % end if curr_locus_is_included_in_mask
        

        if ~was_curr_locus_finished
            % Add it back on to the end of the array so it can be processed later:
            pending_locus_linear_indicies(end+1) = curr_locus_linear_index;
        else
            % Update the tf_is_processed value.
            tf_is_processing_complete(curr_locus_row_index, curr_locus_col_index) = was_curr_locus_finished;
        end
            
        if isempty(pending_locus_linear_indicies)
            is_complete = true;
            print('Complete!')
        end
    
	end
	
end

