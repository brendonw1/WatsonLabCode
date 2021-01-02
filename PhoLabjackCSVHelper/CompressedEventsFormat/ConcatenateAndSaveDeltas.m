function [FinalOutputDeltaIdxs, FinalOutputDeltaTimestamps, matFilePath] = ConcatenateAndSaveDeltas(DeltaIdxs, DeltaTimestamps, csvFilePath, matFilePath, shouldsave)
% function [FinalOutputDeltas, FinalOutputDeltasTimestamps,compresssedFilePath] = SaveEventOnlyCompressed(labjackData,beambreakTransitions,beambreakTransitionsIndicies,inputFilePath)

% Saves out only the state changes instead of the state at all sample
% points to a "compressed events".mat file.

% addpath(genpath('CompressedEventsFormat'));

%% Make one that only saves for this one box
mpfbool = false;
if exist('matFilePath','var')
    if ~isempty(matFilePath)
        mpfbool = true;
    end
end

if ~mpfbool
    [tpath,basename] = fileparts(csvFilePath);
    if length(basename)>=8 & strmatch('out_file',basename(1:8))
        matbasename = ['compressed_' basename(9:end)];
        matFilePath = fullfile(tpath,[matbasename '.mat']);
    else
        error('Do not know how to name or where to save compressed data') %ie if previous files not named according to out_file.... (see above)
        return
    end
end

if ~exist('shouldsave','var')
    shouldsave = false;
end

% %% Save all events across all boxes
% % if exist ('compresssedFilePath','file')
% % 	[FinalOutputDeltas, FinalOutputDeltasTimestamps] = UpdateAndSaveCompressedEvents(OutputDeltas, OutputDeltasTimestamps, compresssedFilePath);
% % else
% % 	[FinalOutputDeltas, FinalOutputDeltasTimestamps] = UpdateAndSaveCompressedEvents(OutputDeltas, OutputDeltasTimestamps);
% % end
% 
% 
% %12/2020 commented ... incorporated that code below
% % [FinalOutputDeltaIdxs, FinalOutputDeltaTimestamps] = UpdateAndSaveCompressedEvents(OutputDeltaIdxs, OutputDeltaTimestamps, compresssedFilePath);
% [DeltaIdxs, DeltaTimestamps] = ConcatenateCompressedEvents(compresssedFilePath, DeltaIdxs, DeltaTimestamps, true);


if ~exist('shouldPrint','var')
   shouldPrint = true; 
end

%% Load compressed events from file if it exists:
preConcat.total = 0;
preCounts = zeros(numel(fieldnames(DeltaTimestamps)),1);

compressedVarNames = {'DeltaIdxs','DeltaTimestamps'};
if ~exist(matFilePath,'file')% if a previous file doesn't exist yet, we can just save this out
    % If the file doesn't currently exist, save the current variables as the file
    FinalOutputDeltaIdxs = DeltaIdxs;
    FinalOutputDeltaTimestamps = DeltaTimestamps;
else %if a previous file exists, we'll concatenated this data onto the end of it... making sure not to add any redundant data
    PreviousCompressedOutputs = load(matFilePath, compressedVarNames{:});
%         PreviousCompressedOutputs = readtable(outputFilename);
    if exist('PreviousCompressedOutputs','var')%if it wasn't an empty file
       if shouldPrint
           disp('Loaded file concatenation: ')
           [preCounts, preConcat.total] = PrintCompressedEventsStatus(PreviousCompressedOutputs.OutputDeltaIdxs, PreviousCompressedOutputs.OutputDeltaTimestamps);
       end
       % Concatenate the entries with the previously loaded ones
%            FinalOutputDeltaIdxs = [PreviousCompressedOutputs.OutputDeltaIdxs OutputDeltaIdxs];
%            FinalOutputDeltaTimestamps = [PreviousCompressedOutputs.OutputDeltaTimestamps OutputDeltaTimestamps];
       FinalOutputDeltaIdxs = ConcatenateStructureFields(1,PreviousCompressedOutputs.DeltaIdxs, DeltaIdxs);
       FinalOutputDeltaTimestamps = ConcatenateStructureFields(1,PreviousCompressedOutputs.DeltaTimestamps, DeltaTimestamps);
    else
        FinalOutputDeltaIdxs = DeltaIdxs;
        FinalOutputDeltaTimestamps = DeltaTimestamps;
    end 
end % end if file exists

[FinalOutputDeltaIdxs, FinalOutputDeltaTimestamps] = EnsureUniqueEntries(FinalOutputDeltaIdxs, FinalOutputDeltaTimestamps);

if shouldPrint
    disp('After concatenation: ')
    [postCounts, postConcat.total] = PrintCompressedEventsStatus(FinalOutputDeltaIdxs, FinalOutputDeltaTimestamps);
end

if shouldsave
    OutputStruct.DeltaIdxs = FinalOutputDeltaIdxs;
    OutputStruct.DeltaTimestamps = FinalOutputDeltaTimestamps;
    save(matFilePath, '-struct', 'OutputStruct');
    if shouldPrint
        totalChanged = postConcat.total - preConcat.total;
        disp(['total changed: ' num2str(totalChanged)])
    end
end
1;