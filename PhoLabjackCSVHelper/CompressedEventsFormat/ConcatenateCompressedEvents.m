function [FinalOutputDeltaIdxs, FinalOutputDeltaTimestamps] = ConcatenateCompressedEvents(outputFilename, DeltaIdxs, DeltaTimestamps, shouldPrint)
%CONCATENATECOMPRESSEDEVENTS Loads the compressed events file if it exists
%and then concatenates the input to it before writting it back out to disk.
%   Detailed explanation goes here
    if ~exist('shouldPrint','var')
       shouldPrint = false; 
    end

    %% Load compressed events from file if it exists:
    preConcat.total = 0;
    preCounts = zeros(numel(fieldnames(DeltaTimestamps)),1);
    
    compressedVarNames = {'OutputDeltaIdxs','OutputDeltaTimestamps'};
    if ~exist(outputFilename,'file')
        % If the file doesn't currently exist, save the current variables as the file
        FinalOutputDeltaIdxs = DeltaIdxs;
        FinalOutputDeltaTimestamps = DeltaTimestamps;
    else
        PreviousCompressedOutputs = load(outputFilename, compressedVarNames{:});
%         PreviousCompressedOutputs = readtable(outputFilename);
        if exist('PreviousCompressedOutputs','var')
           if shouldPrint
               disp('Loaded file concatenation: ')
               [preCounts, preConcat.total] = PrintCompressedEventsStatus(PreviousCompressedOutputs.OutputDeltaIdxs, PreviousCompressedOutputs.OutputDeltaTimestamps);
           end
           % Concatenate the entries with the previously loaded ones
%            FinalOutputDeltaIdxs = [PreviousCompressedOutputs.OutputDeltaIdxs OutputDeltaIdxs];
%            FinalOutputDeltaTimestamps = [PreviousCompressedOutputs.OutputDeltaTimestamps OutputDeltaTimestamps];
           FinalOutputDeltaIdxs = ConcatenateStructureFields(1,PreviousCompressedOutputs.OutputDeltaIdxs, DeltaIdxs);
           FinalOutputDeltaTimestamps = ConcatenateStructureFields(1,PreviousCompressedOutputs.OutputDeltaTimestamps, DeltaTimestamps);
        else
            FinalOutputDeltaIdxs = DeltaIdxs;
            FinalOutputDeltaTimestamps = DeltaTimestamps;
        end 
    end % end if file exists

    [FinalOutputDeltaIdxs, FinalOutputDeltaTimestamps] = EnsureUniqueEntries(FinalOutputDeltaIdxs, FinalOutputDeltaTimestamps);
    OutputStruct.DeltaIdxs = FinalOutputDeltaIdxs;
    OutputStruct.DeltaTimestamps = FinalOutputDeltaTimestamps;
    if shouldPrint
        disp('After concatenation: ')
        [postCounts, postConcat.total] = PrintCompressedEventsStatus(FinalOutputDeltaIdxs, FinalOutputDeltaTimestamps);
    end
    save(outputFilename, '-struct', 'OutputStruct');
    if shouldPrint
        totalChanged = postConcat.total - preConcat.total;
        disp(['total changed: ' num2str(totalChanged)])
    end
end

