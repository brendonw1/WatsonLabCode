function [OutputDeltaIdxs, OutputDeltaTimestamps,compresssedFilePath] = SaveEventOnlyCompressed(OutputDeltaIdxs, OutputDeltaTimestamps, inputFilePath)
% function [FinalOutputDeltas, FinalOutputDeltasTimestamps,compresssedFilePath] = SaveEventOnlyCompressed(labjackData,beambreakTransitions,beambreakTransitionsIndicies,inputFilePath)

% Saves out only the state changes instead of the state at all sample
% points to a "compressed events".mat file.

% addpath(genpath('CompressedEventsFormat'));


%% Make one that only saves for this one box
if ~exist('compresssedFilePath','var')
    [tpath,basename] = fileparts(inputFilePath);
    if length(basename)>=8 && strmatch('out_file',basename(1:8))
        compressedbasename = ['compressed_' basename(9:end)];
        compresssedFilePath = fullfile(tpath,compressedbasename);
    else
        error('Do not know how to name or where to save compressed data') %ie if previous files not named according to out_file.... (see above)
        return
    end
end

%% Save all events across all boxes
% if exist ('compresssedFilePath','file')
% 	[FinalOutputDeltas, FinalOutputDeltasTimestamps] = UpdateAndSaveCompressedEvents(OutputDeltas, OutputDeltasTimestamps, compresssedFilePath);
% else
% 	[FinalOutputDeltas, FinalOutputDeltasTimestamps] = UpdateAndSaveCompressedEvents(OutputDeltas, OutputDeltasTimestamps);
% end


%12/2020 commented
% [FinalOutputDeltaIdxs, FinalOutputDeltaTimestamps] = UpdateAndSaveCompressedEvents(OutputDeltaIdxs, OutputDeltaTimestamps, compresssedFilePath);
[OutputDeltaIdxs, OutputDeltaTimestamps] = ConcatenateCompressedEvents(compresssedFilePath, OutputDeltaIdxs, OutputDeltaTimestamps, true);


%change name of compressed.mat to CompressedEvents_AllBoxes.mat