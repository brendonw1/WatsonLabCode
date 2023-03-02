function [DLCcoords,Params] = REM_DLCcoordsSingleEpoch
%
% Extracts deeplabcut CSV into a single-row table representing one
% REM or WAKE epoch (table columns = deeplabcut labels, e.g,. body parts).
% The single-row table is saved in the same folder of the CSV. This output
% is designed as a single row to allow table concatenation using other
% functions.
%
% USAGE
%   - Run from CSV and video-containing folder.
%
% ASSUMPTIONS
%   - Folder contains video and corresponding deeplabcut analysis.
%     See: Nath et al. (2019). Nat Protoc 14.
%     https://doi.org/10.1038/s41596-019-0176-0
%   - Video epochs are based on pre-trimming timestamps, i.e., the sleep
%     scores directly from TheStateEditor.
%
% OUTPUTS (these are also saved in the session folder)
%   - DLCcoords: single-row table for concatenation across episodes
%   - Params: a structure
%	- .VidFrameRate: scalar in Hz
%	- .DataHeaders:  of the three-column matrices
% 
% Bueno-Junior et al. (2023)

%% Find CSV and video files. Make sure there is only one CSV in the folder.
DLCdir = dir;
WhereCSV = false(length(DLCdir),1);
WhereVid = false(length(DLCdir),1);
for DirIdx = 1:length(DLCdir)
    if contains(DLCdir(DirIdx).name,'.csv')
        WhereCSV(DirIdx) = true;
    elseif ...
            contains(DLCdir(DirIdx).name,'.avi') || ...
            contains(DLCdir(DirIdx).name,'.mp4')
        WhereVid(DirIdx) = true;
    end
end

WhereCSV = find(WhereCSV);
if numel(WhereCSV) < 1
    error(['No CSV found in folder: ' pwd])
elseif numel(WhereCSV) > 1
    error(['More than one CSV found in folder: ' pwd])
end



%% Read CSV labels (headers) and CSV data. Delete first column, which has
% just the indices to video frames.
RawDLClabels = readtable(DLCdir(WhereCSV).name);
RawDLClabels = table2array(RawDLClabels(1,2:end));
RawDLCcoords = readmatrix(DLCdir(WhereCSV).name);
RawDLCcoords = RawDLCcoords(:,2:end);



%% Each DLC label is assigned a three-column array:
% X coordinates, Y coordinates and likelihoods (rows are video frames)
DLCcoords = unique(RawDLClabels,'stable');
for UnqLabelIdx = 1:size(DLCcoords,2)
    WhereLabel  = false(1,size(RawDLClabels,2));
    for RawLabelIdx = 1:size(RawDLClabels,2)
        if strcmp(RawDLClabels{RawLabelIdx},DLCcoords{1,UnqLabelIdx})
            WhereLabel(RawLabelIdx) = true;
        end
    end
    DLCcoords{2,UnqLabelIdx} = RawDLCcoords(:,WhereLabel);
end



%% Convert to single-row table.
DLCcoords = array2table(DLCcoords(2,:),'VariableNames',DLCcoords(1,:));



%% Identify video sampling rate. Check if there is a common frame rate if
% multiple videos are present in the folder. Display a warning otherwise.
VidFrameRate = find(WhereVid);
for VidIdx   = 1:numel(VidFrameRate)
    try
        VidObj = VideoReader(...
            DLCdir(VidFrameRate(VidIdx)).name); %#ok<*TNMLP>
        VidFrameRate(VidIdx) = VidObj.FrameRate;
    catch % if VideoReader fails
        VidFrameRate(VidIdx) = NaN;
    end
end
VidFrameRate(isnan(VidFrameRate)) = [];
VidFrameRate = unique(VidFrameRate);

if numel(VidFrameRate) < 1
    VidFrameRate = 'unknown';
elseif numel(VidFrameRate) > 1
    warning(['Different frame rates found in folder: ' ...
        pwd '. Saving anyway.'])
end



%% Save
Params.VidFrameRate = VidFrameRate;
Params.DataHeaders = {'XcoordsInPixels','YcoordsInPixels','Likelihoods'};
save('DLCcoordsPerEpoch.mat','DLCcoords','Params')
disp(['saved DLC coordinates in folder: ' pwd])

end
