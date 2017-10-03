function ROI = SelectROI
% Very simple function to allow a user to select a rectangular region of
% interest over an open figure/image by dragging a box with the mouse.  

waitforbuttonpress
point1 = get(gcf,'CurrentPoint'); % button down detected
rect = [point1(1,1) point1(1,2) 1 1];
ROI = rbbox(rect);
% ROI = dragrect(rect);

