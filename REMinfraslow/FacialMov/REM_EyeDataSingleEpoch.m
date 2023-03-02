function [EyePupilData,Params] = ...
    REM_EyeDataSingleEpoch(PixelsPerMM,varargin)
%
% Converts raw deeplabcut coordinates from eye and pupil into quantifiable
% data per video frame.
%
% USAGE
%   - Run from CSV and video-containing folder after running
%     REM_DLCcoordsSingleEpoch.
%   - PixelsPerMM: scalar to convert from pixels to millimeters,
%     e.g., 161.28
%   - varargin: please see input parser section
%
% ASSUMPTION
%   - Eye and pupil were labeled by eight vertices each, named as:
%     EyeNorth, EyeNorthEast, EyeEast, EyeSouthEast, etc.
%     PupilNorth, PupilNorthEast, PupilEast, PupilSouthEast, etc.
%
% OUTPUTS (these are also saved in the folder)
%   - EyePupilData: single-row table for concatenation across episodes
%   - Params: a structure
%	- .PixelsPerMM
%	- .VidFrameRate
%	- .UnitOfLength
%	- .UnitOfSpeed
%
% Bueno-Junior et al. (2023)

%% Input parser
p = inputParser;

% To filter out rapid movements from eyelid opening and pupil diameter
addParameter(p,'MovMeanSec',5,@isnumeric) % s
% Envelope time window
addParameter(p,'EnvelWindowSec',2,@isnumeric) % s

parse(p,varargin{:})
MovMeanSec     = p.Results.MovMeanSec;
EnvelWindowSec = p.Results.EnvelWindowSec;



%% Load data, prepare speed parameter
load('DLCcoordsPerEpoch.mat','DLCcoords','Params')
VidFrameRate = Params.VidFrameRate;
VarNames = DLCcoords.Properties.VariableNames;
if ~contains(cell2mat(VarNames),'Eye')
    error(['No eye data in this folder: ' pwd]) % if wrong folder, stop
end
DeciSecConversion = 0.1/(1/VidFrameRate); % to calculate speed



%% Divide table into eye and pupil data
WhereEye   = false(1,numel(VarNames));
WherePupil = false(1,numel(VarNames));
for ColIdx = 1:numel(VarNames)
    
    if contains(VarNames{ColIdx},'Eye')
        WhereEye(ColIdx) = true;
    elseif contains(VarNames{ColIdx},'Pupil')
        WherePupil(ColIdx) = true;
    end
    
    % Use the same loop to delete likelihood columns
    % (network assumed well trained)
    XYcoords = cell2mat(DLCcoords{1,ColIdx});
    
    % Convert from pixels to unit of length
    DLCcoords{1,ColIdx} = {XYcoords(:,1:2)/PixelsPerMM};
end
EyeCoords   = DLCcoords(1,WhereEye);
PupilCoords = DLCcoords(1,WherePupil);



%% Octagonal polygons, raw eyelid opening, raw pupil dilation
EyeArray     = cell2mat(permute(table2cell(EyeCoords),[1 3 2]));
PupilArray   = cell2mat(permute(table2cell(PupilCoords),[1 3 2]));
NumFrames    = size(EyeArray,1);
EyePupilData = cell(NumFrames,1);
for FrameIdx = 1:NumFrames
    
    % Eye polygons ________________________________________________________
    OctPolygon = permute(EyeArray(FrameIdx,:,:),[3 2 1]);
    EyePupilData{FrameIdx,1} = [OctPolygon;OctPolygon(1,:)];
    
    % Eyelid separation between north (1) and south (5) labels ____________
    AbsDiff = abs(diff(EyePupilData{FrameIdx,1}([1 5],:),1,1));
    EyePupilData{FrameIdx,2} = hypot(AbsDiff(1),AbsDiff(2));
    
    % Pupil polygons ______________________________________________________
    OctPolygon = permute(PupilArray(FrameIdx,:,:),[3 2 1]);
    EyePupilData{FrameIdx,3} = [OctPolygon;OctPolygon(1,:)];
    
    % Pupil "diameter", distance between east (3) and west (7) labels) ____
    AbsDiff = abs(diff(EyePupilData{FrameIdx,1}([3 7],:),1,1));
    EyePupilData{FrameIdx,4} = hypot(AbsDiff(1),AbsDiff(2));
    
    % Pupil north label (to calculate pupil speed) ________________________
    EyePupilData{FrameIdx,5} = EyePupilData{FrameIdx,3}(1,:);
end



%% Eyeblinks and eyelid separation without eyeblinks
EyelidSep = cell2mat(EyePupilData(:,2));
Eyeblinks = EyelidSep-movmean(EyelidSep,VidFrameRate*MovMeanSec);
EyelidSep = EyelidSep-Eyeblinks;
Eyeblinks = -abs(Eyeblinks);



%% Pupil diameter without rapid movements
PupDiam  = cell2mat(EyePupilData(:,4));
RapidMov = PupDiam-movmean(PupDiam,VidFrameRate*MovMeanSec);
PupDiam  = PupDiam-RapidMov;



%% Pupil speed
PupilDiff  = diff(cell2mat(EyePupilData(:,5)));
PupilSpeed = [0;hypot(...
    PupilDiff(:,1),PupilDiff(:,2))*DeciSecConversion];



%% Envelopes for distribution bimodality analysis
EyeblEnvel = envelope(Eyeblinks,VidFrameRate*EnvelWindowSec,'peak');
EyeblEnvel(EyeblEnvel<0) = NaN; % corrects infrequent artifacts < zero

PupilEnvel = envelope(PupilSpeed,VidFrameRate*EnvelWindowSec,'peak');
PupilEnvel(PupilEnvel<0) = NaN; % corrects infrequent artifacts < zero



%% Prepare table
EyePupilData = cell2table([...
    {EyePupilData(:,1)} {EyelidSep} {Eyeblinks} {EyeblEnvel}...
    {cell2mat(EyePupilData(:,3))} {PupDiam} {PupilSpeed} {PupilEnvel}],...
    'VariableNames',{...
    'EyePolygons','EyelidSeparation','Eyeblinks','EyeblinkEnvelope',...
    'PupilPolygons','PupilDiameter','PupilSpeed','PupilSpeedEnvelope'});



%% Save
Params.PixelsPerMM  = PixelsPerMM;
Params.VidFrameRate = VidFrameRate;
Params.UnitOfLength = 'mm';
Params.UnitOfSpeed  = 'mm/ds';
save('EyePupilData.mat','EyePupilData','Params')
disp(['saved eye and pupil data in folder: ' pwd])

end
