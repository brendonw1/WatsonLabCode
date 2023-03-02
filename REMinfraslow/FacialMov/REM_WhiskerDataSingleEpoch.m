function [WhiskerData,Params] = ...
    REM_WhiskerDataSingleEpoch(PixelsPerMM,varargin)
%
% [WhiskerData,Params] = REM_WhiskerDataSingleEpoch(PixelsPerMM,varargin)
%
% Converts raw deeplabcut coordinates from whiskers into quantifiable
% data per video frame.
%
% USAGE
%   - Run from CSV and video-containing folder after running
%     REM_DLCcoordsSingleEpoch.
%   - PixelsPerMM: scalar to convert from pixels to millimeters,
%     e.g., 29.08
%   - varargin: please see input parser section
%
% ASSUMPTION
%   - Labels were named as:
%       - Nose: Left, Right.
%       - Face: RostralRostral, Rostral, Caudal, CaudalCaudal
%       - RostralWhisker: ProximalProximal, Proximal, Distal, DistalDistal
%       - CaudalWhisker: ProximalProximal, Proximal, Distal, DistalDistal
%
% OUTPUTS (these are also saved in the folder)
%   - WhiskerData: single-row table for concatenation across episodes
%   - Params: a structure
%	- .PixelsPerMM
%	- .VidFrameRate
%	- .UnitOfLength
%	- .UnitOfSpeed
%
% Bueno-Junior et al. (2023)

%% Input parser
p = inputParser;

% Envelope time window
addParameter(p,'EnvelWindowSec',2,@isnumeric) % s

parse(p,varargin{:})
EnvelWindowSec = p.Results.EnvelWindowSec;



%% Load data, prepare speed parameter
load('DLCcoordsPerEpoch.mat','DLCcoords','Params')
VidFrameRate = Params.VidFrameRate;
VarNames = DLCcoords.Properties.VariableNames;
if ~contains(cell2mat(VarNames),'Whisker')
    error(['No whisker data in this folder: ' pwd]) % if wrong folder, stop
end
DeciSecConversion = 0.1/(1/VidFrameRate); % to calculate speed



%% Divide table into nose/face and whisker data
WhereNoseFace = false(1,numel(VarNames));
WhereRostWhsk = false(1,numel(VarNames));
WhereCaudWhsk = false(1,numel(VarNames));
for ColIdx    = 1:numel(VarNames)
    
    if ...
            contains(VarNames{ColIdx},'Nose') || ...
            contains(VarNames{ColIdx},'Face')
        WhereNoseFace(ColIdx) = true;
    elseif contains(VarNames{ColIdx},'RostralWhisker')
        WhereRostWhsk(ColIdx) = true;
    elseif contains(VarNames{ColIdx},'CaudalWhisker')
        WhereCaudWhsk(ColIdx) = true;
    end
    
    % Use the same loop to delete likelihood columns
    % (assuming well-trained network)
    XYcoords = cell2mat(DLCcoords{1,ColIdx});
    
    % Convert from pixels to unit of length
    DLCcoords{1,ColIdx} = {XYcoords(:,1:2)/PixelsPerMM};
end
NoseFaceCoords = DLCcoords(1,WhereNoseFace);
RostWhskCoords = DLCcoords(1,WhereRostWhsk);
CaudWhskCoords = DLCcoords(1,WhereCaudWhsk);



%% Face and whisker lines for silhouette plotting
NoseFaceArray = cell2mat(permute(table2cell(NoseFaceCoords),[1 3 2]));
RostWhskArray = cell2mat(permute(table2cell(RostWhskCoords),[1 3 2]));
CaudWhskArray = cell2mat(permute(table2cell(CaudWhskCoords),[1 3 2]));
NumFrames     = size(NoseFaceArray,1);
WhiskerData   = cell(NumFrames,1);
for FrameIdx  = 1:NumFrames
    
    % Nose and face silhouette ____________________________________________
    WhiskerData{FrameIdx,1} = permute(NoseFaceArray(FrameIdx,:,:),[3 2 1]);
    
    % Rostral whisker line ________________________________________________
    WhiskerData{FrameIdx,2} = permute(RostWhskArray(FrameIdx,:,:),[3 2 1]);
    
    % Caudal whisker line ________________________________________________
    WhiskerData{FrameIdx,3} = permute(CaudWhskArray(FrameIdx,:,:),[3 2 1]);
end



%% Whisker speed. Whisker labels are redundant, so average them to smooth
% out erratic labeling (which is infrequent if network is well trained). 
WhskDiff  = diff(cat(3,RostWhskArray,CaudWhskArray));
WhskSpeed = cell(1,size(WhskDiff,3));
for LabelIdx = 1:size(WhskDiff,3)
    WhskSpeed{LabelIdx} = [0;hypot(...
        WhskDiff(:,1,LabelIdx),...
        WhskDiff(:,2,LabelIdx))*DeciSecConversion];
end
WhskSpeed = mean(cell2mat(WhskSpeed),2);



%% Envelope for later distribution bimodality analysis
WhskEnvel = envelope(WhskSpeed,VidFrameRate*EnvelWindowSec,'peak');
WhskEnvel(WhskEnvel<0) = NaN; % corrects infrequent artifacts < zero



%% Prepare table
WhiskerData = cell2table([...
    {WhiskerData(:,1)} {WhiskerData(:,2)} {WhiskerData(:,3)}...
    {WhskSpeed} {WhskEnvel}],...
    'VariableNames',{...
    'NoseFaceLines','RostralWhiskerLines','CaudalWhiskerLines',...
    'WhiskerSpeed','WhiskerSpeedEnvelope'});



%% Save
Params.PixelsPerMM  = PixelsPerMM;
Params.VidFrameRate = VidFrameRate;
Params.UnitOfLength = 'mm';
Params.UnitOfSpeed  = 'mm/ds';
save('WhiskerData.mat','WhiskerData','Params')
disp(['saved whisker data in folder: ' pwd])

end
