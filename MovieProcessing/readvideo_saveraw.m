function video = readvideo_saveraw(filename)

vidObj = VideoReader(filename);
video = readFrame(vidObj);%frame 1
while hasFrame(vidObj)
    video(:,:,end+1) = readFrame(vidObj);
end
