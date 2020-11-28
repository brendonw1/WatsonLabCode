function [xy,video] = MotionTracking(filename,framesamplerate,subtractromwhat)
% subtracts a mode image from each image in movie, finds any current object
% by where it now is... simply takes the center of mass of any deviations
% from the mode for each frame and makes that the XY of the image.  
% Another option is to subtract each frame

% filename = 'Basler_acA1280-60gc__21790606__20160202_062919760.avi';
% cd /mnt/RawData/c3po/c3po_160202/

if ~exist('subtractromwhat','var');
    mode = 'mode';
end

framerate = 1; %degrades data to 1 frame per second, increase number to increase time resolution
video = LoadResampledMovie(filename,framesamplerate);
switch subtractromwhat
    case 'mode'
        video = ModeSubtractedMovie(video);
    case 'diff'
        video = FrameDiffMovie(video);
end

% F = MovieMatrixToMatlabMovie(video);
video = BinaryThresholdDiffMovie(video);%outputs a 3D b&w videos of blobs of change from whatever the background was

%% get the average XY of the non-background for each image and output that. 
xy = zeros(size(video,3),2);
for a = 1:size(video,3);
    [i,j] = find(video(:,:,a));
    xy(a,:) = [mean(i) mean(j)];
end

