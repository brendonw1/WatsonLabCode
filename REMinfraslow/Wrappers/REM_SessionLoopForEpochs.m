function [ConcatSessions,SamplFreqs] = REM_SessionLoopForEpochs(SessionPaths)
%
% [ConcatSessions,SamplFreqs] = REM_SessionLoopForEpochs(SessionPaths)
%
% Session-specific tables (from REM_EpochLoop) are concatenated into a
% larger table for final quantitative analyses.
%
% This wrapper function can be used as a template.
%
% USAGE
%   - SessionPaths: single-column cell array, each cell with a path. This
%                   can be used to define data subsets (e.g., home cage,
%                   head fixed), ignore bad sessions, etc.
%
% OUTPUTS
%   - ConcatSessions: a table with epochs in rows and variables in columns.
%                     Rows can be sorted based on mouse names, brain
%                     states, epoch durations, etc.
%   - SamplFreqs: a structure with sampling rates in Hz, from physiology
%                 to video data (when present).
%                   
% Bueno-Junior et al. (2023)

%% Go back to this path once finished.
InitPath = pwd;



%% Session loop
ConcatSessions = [];
for SessionIdx = 1:size(SessionPaths,1)
    
    % Enter the folder to use bz_BasenameFromBasepath and potentially do
    % other things there
    cd(SessionPaths{SessionIdx})
    
    load([bz_BasenameFromBasepath(pwd) '.ConcatEpochs.mat'],...
        'ConcatEpochs','SamplFreqs')
    
    ConcatSessions = vertcat(ConcatSessions,ConcatEpochs); %#ok<*AGROW>
end



%% Back to initial path
cd(InitPath)
    
end