function [FinalOutputDeltas, FinalOutputDeltasTimestamps,outputFilePath] = SaveCompressedEvents_NoConcatenate(outputFilePath, OutputDeltas, OutputDeltasTimestamps, shouldPrint)
%CONCATENATECOMPRESSEDEVENTS Loads the compressed events file if it exists
%and then concatenates the input to it before writting it back out to disk.
% BW: I believe this adds events from all BB files together, not typically what we want.

%   Detailed explanation goes here
    if ~exist('shouldPrint','var')
       shouldPrint = false; 
    end

    %% Load compressed events from file if it exists:
    preConcat.total = 0;
    preCounts = zeros(numel(fieldnames(OutputDeltasTimestamps)),1);
    
    compressedVarNames = {'OutputDeltas','OutputDeltasTimestamps'};
	
	%use this to replace next commented if/else below - to not concatenate
	FinalOutputDeltas = OutputDeltas;
	FinalOutputDeltasTimestamps = OutputDeltasTimestamps;
%     if ~exist(outputFilename,'file')
        % If the file doesn't currently exist, save the current variables as the file
%         FinalOutputDeltas = OutputDeltas;
%         FinalOutputDeltasTimestamps = OutputDeltasTimestamps;
%     else
%         PreviousCompressedOutputs = load(outputFilename, compressedVarNames{:});
%         if exist('PreviousCompressedOutputs','var')
%            if shouldPrint
%                disp('Loaded file concatenation: ')
%                [preCounts, preConcat.total] = PrintCompressedEventsStatus(PreviousCompressedOutputs.OutputDeltas, PreviousCompressedOutputs.OutputDeltasTimestamps);
%            end
%            % Concatenate the entries with the previously loaded ones
% %            FinalOutputDeltas = [PreviousCompressedOutputs.OutputDeltas OutputDeltas];
% %            FinalOutputDeltasTimestamps = [PreviousCompressedOutputs.OutputDeltasTimestamps OutputDeltasTimestamps];
%            FinalOutputDeltas = ConcatenateStructureFields(1,PreviousCompressedOutputs.OutputDeltas, OutputDeltas);
%            FinalOutputDeltasTimestamps = ConcatenateStructureFields(1,PreviousCompressedOutputs.OutputDeltasTimestamps, OutputDeltasTimestamps);
%         else
%             FinalOutputDeltas = OutputDeltas;
%             FinalOutputDeltasTimestamps = OutputDeltasTimestamps;
%         end 
%     end % end if file exists

    [FinalOutputDeltas, FinalOutputDeltasTimestamps] = EnsureUniqueEntries(FinalOutputDeltas, FinalOutputDeltasTimestamps);
    OutputStruct.OutputDeltas = FinalOutputDeltas;
    OutputStruct.OutputDeltasTimestamps = FinalOutputDeltasTimestamps;
%     if shouldPrint
% %         disp('After concatenation: ')
%         [postCounts, postConcat.total] = PrintCompressedEventsStatus(FinalOutputDeltas, FinalOutputDeltasTimestamps);
%     end
    save(outputFilePath, '-struct', 'OutputStruct');
    if shouldPrint
        [postCounts, postConcat.total] = PrintCompressedEventsStatus(FinalOutputDeltas, FinalOutputDeltasTimestamps);
        totalChanged = postConcat.total - preConcat.total;
        disp(['totals: ' num2str(totalChanged)])
    end
end

