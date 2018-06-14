function plotEpochs(epochs)
% Plots start-stop pair epoch periods as a series of horizontal lines
% spanning from start to stop of each individual epoch.  
% INPUTS
% epochs - two-column array.  Column 1 is start point of each epoch, column
% 2 is end point value of each epoch
%
% OUTPUT
% A graphical plot onto an axis
%
% Brendon Watson 2018


for idx = 1:size(epochs,1);
    plot([epochs(idx,1) epochs(idx,2)],[1 1])
    hold on
end