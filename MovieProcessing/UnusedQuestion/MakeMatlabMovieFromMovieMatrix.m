function mov = MakeMatlabMovieFromMovieMatrix(videomatrix)
% takes in a matricized video (ie from DiffResampledMovie), and saves into a
% format playable by matlab.  Modified from matlab doc.

nFrames = size(videomatrix,4);
vidHeight = size(videomatrix,1);
vidWidth = size(videomatrix,2);

% Preallocate movie structure.
mov(1:nFrames) = ...
    struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),...
           'colormap', []);

% Read one frame at a time.
for k = 1 : nFrames
    mov(k).cdata = videomatrix(:,:,:,k);
end


%% Might play it as follows:
% % Size a figure based on the video's width and height.
% hf = figure;
% set(hf, 'position', [150 150 vidWidth vidHeight])
% 
% % Play back the movie once at the video's frame rate.
% movie(hf, mov, 1, xyloObj.FrameRate);