function [FinalOutputDeltas, FinalOutputDeltasTimestamps] = EnsureUniqueEntries(OutputDeltas, OutputDeltasTimestamps)
%ENSUREUNIQUEENTRIES Makes the entries in OutputDeltas/OutputDeltasTimestamps unique and sorted
%   Detailed explanation goes here
    fields = fieldnames(OutputDeltas);
    % Must iterate through the struct fields and append each array together pairwise
    for i = 1:numel(fields)
        FinalOutputDeltas.(fields{i}) = OutputDeltas.(fields{i});
        FinalOutputDeltasTimestamps.(fields{i}) = OutputDeltasTimestamps.(fields{i});
        % Filter for Repetitions (ensure all entries are unique):
        [UniqueDeltas,UniqueDeltaIndx, ~] = unique(FinalOutputDeltas.(fields{i}));
        [UniqueDeltaTimestamps, UniqueDeltaTimestampIndx, ~] = unique(FinalOutputDeltasTimestamps.(fields{i}));
        numRepeatedDeltas = length(FinalOutputDeltas.(fields{i})) - length(UniqueDeltaIndx);
        numRepeatedDeltaTimestamps = length(FinalOutputDeltasTimestamps.(fields{i})) - length(UniqueDeltaTimestampIndx);
        
        if length(UniqueDeltas) ~= length(UniqueDeltaTimestamps)
%             repeatedDeltas = FinalOutputDeltas.(fields{i});
%             repeatedDeltas(UniqueDeltaIndx) = [];
% %             numRepeatedDeltas = length(repeatedDeltas);
% %             disp('Repeated deltas:')
% %             disp(repeatedDeltas)
%             repeatedDeltaTimestamps = FinalOutputDeltasTimestamps.(fields{i});
%             repeatedDeltaTimestamps(UniqueDeltaTimestampIndx) = [];
% %             numRepeatedDeltaTimestamps = length(repeatedDeltaTimestamps);
% %             disp('Repeated deltaTimestamps:')
% %             disp(repeatedDeltaTimestamps)
%             error('ERROR: the lengths of UniqueDeltas and UniqueDeltaTimestamps differ!')
            warning('the lengths of UniqueDeltas and UniqueDeltaTimestamps differ!')
           
        end
        % Make unique
        %% TODO: currently just using the unique timestamps and allowing the deltas to repeat. Don't even know what the deltas are.
%         FinalOutputDeltas.(fields{i}) = FinalOutputDeltas.(fields{i})(UniqueDeltaIndx);
        FinalOutputDeltas.(fields{i}) = FinalOutputDeltas.(fields{i})(UniqueDeltaTimestampIndx);
        FinalOutputDeltasTimestamps.(fields{i}) = FinalOutputDeltasTimestamps.(fields{i})(UniqueDeltaTimestampIndx);
        % Re-Sort:
        [FinalOutputDeltasTimestamps.(fields{i}),SortedIndicies] = sort(FinalOutputDeltasTimestamps.(fields{i}),'ascend');
        FinalOutputDeltas.(fields{i}) = FinalOutputDeltas.(fields{i})(SortedIndicies);
    end

end

