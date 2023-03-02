function [ConcatREM,ConcatWAKE] = REM_SessionLoopForCFC(SessionPaths)
%
% [ConcatREM,ConcatWAKE] = REM_SessionLoopForCFC(SessionPaths)
%
% Session-specific tables (from REM_MultiChannelMultiEpochCFC) are
% concatenated into larger tables for final quantitative analyses.
%
% This wrapper function can be used as a template.
%
% USAGE
%   - SessionPaths: single-column cell array, each cell with a path. This
%                   can be used to define data subsets (e.g., home cage,
%                   head fixed), ignore bad sessions, etc.
%
% OUTPUTS
%   - ConcatREM/WAKE: tables whose data cells contain 3D matrices:
%                     channels x infraslow categories x sessions.
%                   
% Bueno-Junior et al. (2023)

%% Go back to this path once finished.
InitPath = pwd;



%% Session loop
ConcatREM  = [];
ConcatWAKE = [];
for SessionIdx = 1:size(SessionPaths,1)
    
    % Enter the folder to use bz_BasenameFromBasepath and potentially do
    % other things there
    cd(SessionPaths{SessionIdx})
    
    load([bz_BasenameFromBasepath(pwd) '.FullCFCanalysis_REM.mat'],...
        'CFCmeasAllChn')
    VarNames = CFCmeasAllChn.Properties.VariableNames;
    CFCmeasAllChn = table2cell(CFCmeasAllChn);
    
    ConcatREM = cat(3,ConcatREM,CFCmeasAllChn); %#ok<*AGROW>
    
    load([bz_BasenameFromBasepath(pwd) '.FullCFCanalysis_WAKE.mat'],...
        'CFCmeasAllChn')
    CFCmeasAllChn = table2cell(CFCmeasAllChn);
    
    ConcatWAKE = cat(3,ConcatWAKE,CFCmeasAllChn);
end



%% 3D marices: channel x infraslow categories x sessions
for RowIdx = 1:size(ConcatREM,1)
    for ColIdx = 2:3
        ConcatREM{RowIdx,ColIdx,1}  = cell2mat(ConcatREM(RowIdx,ColIdx,:));
        ConcatWAKE{RowIdx,ColIdx,1} = cell2mat(ConcatWAKE(RowIdx,ColIdx,:));
    end
end
ConcatREM  = cell2table(ConcatREM(:,:,1),'VariableNames',VarNames);
ConcatWAKE = cell2table(ConcatWAKE(:,:,1),'VariableNames',VarNames);


%% Back to initial path
cd(InitPath)
    
end