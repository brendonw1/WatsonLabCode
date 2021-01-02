function [listA_Only, bothLists, listB_Only, phoDiffOutput] = fnDiffCellArrays(listA, listB)
%fnDiffCellArrays Computes the entries that are only in listA, those only in listB, and those common in both lists.
%   Example:
%		listA = {'02','04','06','09','14','15','16'};
%		listB = {'02','04','06','09','12','14','15'};
%	Example Results:
%		listA_Only = {'16'}
%		bothLists = {'02','04','06','09','14','15'}
%		listB_Only = {'12'}
%		phoDiffOutput.listA_Only_OriginalIndicies = [7];
%		phoDiffOutput.bothLists_OriginalIndicies = [1, 1; 2, 2; 3, 3; 4, 4; 5, 6; 6, 7;];
%		phoDiffOutput.listB_Only_OriginalIndicies = [5];



	%%%+S- phoDiffOutput
		%- listA_Only_OriginalIndicies - a list of indicies into the original listA array for the unique elements
		%- listB_Only_OriginalIndicies - a list of indicies into the original listB array for the unique elements
		%- bothLists_OriginalIndicies - a length(bothLists)x2 array containing the index into each of the original lists
	%

	% Values Outputting:
	listA_Only = {};
	bothLists = {};
	listB_Only = {};


	% Indicies Outputting:
	phoDiffOutput.listA_Only_OriginalIndicies = [];
	phoDiffOutput.listB_Only_OriginalIndicies = [];
	phoDiffOutput.bothLists_OriginalIndicies = [];

	% a duplicate of listB that's used to remove entries to increase efficiency
	temp.listB_Working = listB;
	temp.listB_WorkingIndicies = 1:length(listB);

	for i = 1:length(listA)
		was_found = false;
		for jt = 1:length(temp.listB_WorkingIndicies)
			j = temp.listB_WorkingIndicies(jt); % Get the index into the original listB
			if strcmpi(listA{i}, listB{j})
				% If the item is found in both, add it to the common, and skip to the next item
				bothLists{end+1} = listA{i};
				was_found = true;
				break;
			end
		end % End inner for loop over listB items
		if ~was_found
			% If the item wasn't found in listB, it's listA exclusive
			listA_Only{end + 1} = listA{i};
			phoDiffOutput.listA_Only_OriginalIndicies(end + 1) = i;
		else
			phoDiffOutput.bothLists_OriginalIndicies(end + 1, :) = [i, j];
			% Remove the found item from listB to reduce the search time:
% 			listB(j) = [];

			% Remove the index at position jt to reduce the search time on future interations:
			temp.listB_Working(jt) = [];
			temp.listB_WorkingIndicies(jt) = [];
			
		end
	end

	% When all done, the listB_Only items are those that haven't been removed
	listB_Only = temp.listB_Working;
	phoDiffOutput.listB_Only_OriginalIndicies = temp.listB_WorkingIndicies;

end

