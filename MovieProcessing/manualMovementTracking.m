function [x,y] = manualMovementTracking(filename)

vidObj = VideoReader(filename);
x = [];
y = [];
framesBetweenClicks = 10;

frame = readFrame(vidObj);%frame 1
figure;
imagesc(frame);
title('1')
counter = 1;
totalframes = 1;
[tx,ty] = ginput;
x(end+1) = tx;
y(end+1) = ty;

while hasFrame(vidObj)
    frame = readFrame(vidObj);
    totalframes = totalframes+1;
    counter = counter+1;
    if counter == framesBetweenClicks;
        imagesc(frame)
        title(num2str(totalframes))
        
        [tx,ty] = ginput;
        if isempty(tx) 
            tx = 0;
            ty = 0;
        end
        
        x(end+1) = tx(1);
        y(end+1) = ty(1);
        counter = 0;
%         save('ManualXY','x','y')
        set (gcf,'userdata',[x' y'])
    end
end

if counter ~= 1%if last slice wasn't already clicked
    imagesc(frame)
    [tx,ty] = ginput;
    x(end+1) = tx;
    y(end+1) = ty;
end

x(x==0) = nan;
y(y==0) = nan;

t = 1:totalframes;
tsampled = 0:framesBetweenClicks,totalframes;
tsampled(1) = 1;

x = spline(t,x,tsampled);
y = spline(t,y,tsampled);

xy = [x' y'];

save('ManualXY',x,y)
