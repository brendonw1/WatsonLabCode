function savesDLCpupil

% Makes DeepLabCut-tracked pupil and eyelid ready for analysis. Label
% coordinates from readCSVfromDLC.m are organized into
% pupil/eyelid-dedicated structures (fields are explained below). The
% function assumes octagonal labeling around pupil and eyelid
% (i.e., eight vertices each).
%
%
%
% USAGE ___________________________________________________________________
% Set working directory with labelCoords.mat and run.
%
%
%
% OUTPUT __________________________________________________________________
% Two structures: pupilFrames and eyelidFrames
%
% - .polygon:     Vector of cells (number of cells is the number of frames).
%                 Each cell contains DeepLabCut labels in dimension 1, and
%                 X and Y coordinates in columns 1 and 2 respectively.
%
% - .area:        A vector with polygon area across frames.
%
% - .centroid:    A pair of columns with X and Y centroid coordinates
%                 (pupil only).
%
% - .velocity:    speed of pupil centroid movements (can be used as an
%                 additional marker of REM sleep epochs).
%
%
%
% LSBuenoJr _______________________________________________________________



%% Octagonal labeling around pupil and eyelid (this is how LSBuenoJr
% decided to train the network)
numPupilLabels  = 8;
numEyelidLabels = 8;


%% Loads data, creates blank structures (except .velocity, which is created
% at the end as it depends on centroid data).
load('labelCoords.mat','labelCoords')

labelCoords          = struct2cell(labelCoords);
pupilFrames.polygon  = cell(length(labelCoords{1}),1);
pupilFrames.area     = zeros(length(labelCoords{1}),1);
pupilFrames.centroid = zeros(length(labelCoords{1}),2);

eyelidFrames.polygon = cell(length(labelCoords{1}),1);
eyelidFrames.area    = zeros(length(labelCoords{1}),1);



%% Populates structures.
pupilData     = reshape(cell2mat(...
    labelCoords(1:numPupilLabels)),...
    length(pupilFrames.polygon),numPupilLabels*2);
eyelidData    = reshape(cell2mat(...
    labelCoords(numPupilLabels+1:end)),...
    length(eyelidFrames.polygon),numEyelidLabels*2);

pupilXcoords  = pupilData(:,1:numPupilLabels)';
pupilYcoords  = pupilData(:,numPupilLabels+1:end)';
eyelidXcoords = eyelidData(:,1:numEyelidLabels)';
eyelidYcoords = eyelidData(:,numEyelidLabels+1:end)';

for i         = 1:length(pupilFrames.polygon)
    
    pupilFrames.polygon{i}    = [...
        pupilXcoords(:,i) pupilYcoords(:,i);...
        pupilXcoords(1,i) pupilYcoords(1,i)];
    
    pupilFrames.area(i)       = polyarea(...
        pupilFrames.polygon{i}(:,1),pupilFrames.polygon{i}(:,2));
    
    [x,y,~] = xycentroid(...
        pupilFrames.polygon{i}(:,1),pupilFrames.polygon{i}(:,2));
    pupilFrames.centroid(i,:) = [x y];
    
    eyelidFrames.polygon{i}   = [...
        eyelidXcoords(:,i) eyelidYcoords(:,i);...
        eyelidXcoords(1,i) eyelidYcoords(1,i)];
    
    eyelidFrames.area(i)      = polyarea(...
        eyelidFrames.polygon{i}(:,1),eyelidFrames.polygon{i}(:,2));
end

pupilFrames.velocity = hypot(...
    diff(pupilFrames.centroid(:,1)),...
    diff(pupilFrames.centroid(:,2)))./50; % 50 ms, given 20 Hz frames

save('polygonFrames.mat','pupilFrames','eyelidFrames')



end