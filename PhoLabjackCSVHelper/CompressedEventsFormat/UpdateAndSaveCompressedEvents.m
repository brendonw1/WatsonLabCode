function [FinalOutputDeltas, FinalOutputDeltasTimestamps] = UpdateAndSaveCompressedEvents(DeltaIdxs, DeltaTimestamps,compresssedFilePath)

%12/2020 I believe this is no longer relevant as it is 1 functional line of
%code, I have now jumped from SaveEventOnlyCompressed.m to
%ConcatenateCompressedEvents.m, taking this out.  - BWatson

%UPDATEANDSAVECOMPRESSEDEVENTS Saves out only the state changes instead of the state at all sample
% points.
%   Refactored from SaveEventOnlyCompressed.m
disp('Updating compressed events representation file....')

% if ~exist('compresssedFilePath','var')
% 	compressedParentPath = 'Output\';
% 	compressedFilename = 'compressed.mat';
% 	compressedFullpath = fullfile(outputParentPath, outputFilename);
% end

% disp('Pre concatenation: ')
% [preCounts, preConcat.total] = PrintCompressedEventsStatus(OutputDeltas, OutputDeltasTimestamps);

%% Perform the concatenation
[FinalOutputDeltas, FinalOutputDeltasTimestamps] = ConcatenateCompressedEvents(compresssedFilePath, DeltaIdxs, DeltaTimestamps, false);

% disp('After concatenation: ')
% [postCounts, postConcat.total] = PrintCompressedEventsStatus(FinalOutputDeltas, FinalOutputDeltasTimestamps);

% changedCounts = postCounts - preCounts;
% totalChanged = sum(changedCounts);
% totalChanged = postConcat.total - preConcat.total;
% disp(['total changed: ' num2str(totalChanged)])
disp('done.')
end

