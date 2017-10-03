function mov = MakeMatlabMovieFromVideoReaderObj(obj)
% takes in a VideoReader class object, reads every frame in the movie
% referred to by that object (ie a video file on a disk), then saves into a
% format playable by matlab.  Basically copied from matlab doc.

nFrames = obj.NumberOfFrames;
vidHeight = obj.Height;
vidWidth = obj.Width;

% Preallocate movie structure.
mov(1:nFrames) = ...
    struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),...
           'colormap', []);

% Read one frame at a time.
for k = 1 : nFrames
    mov(k).cdata = read(obj, k);
end


%% Might play it as follows:
% % Size a figure based on the video's width and height.
% hf = figure;
% set(hf, 'position', [150 150 vidWidth vidHeight])
% 
% % Play back the movie once at the video's frame rate.
% movie(hf, mov, 1, xyloObj.FrameRate);