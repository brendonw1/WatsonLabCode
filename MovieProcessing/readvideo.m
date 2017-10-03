function [video,vidObj] = readvideo(filename)
% Assumes 24bit RGB
% Brendon Watson 2016

vidObj = VideoReader(filename);
vidHeight = vidObj.Height;
vidWidth = vidObj.Width;

video = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),...
    'colormap',[]);
% video = readFrame(vidObj);%frame 1

k = 1;
while hasFrame(vidObj)
    video(k).cdata = readFrame(vidObj);
    k = k+1;
end
