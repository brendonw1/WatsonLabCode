function [fig, h_plot, h] = plotHeatImage(image, imageTitle)
%PLOTHEATIMAGE Plots an image in a heatmap-like style. Can be used for visualization of image changes, etc. 
%   Detailed explanation goes here

fig = figure();
h_plot = gca;
h = imagesc(h_plot, image);
if exist('imageTitle','var')
	title(h_plot, imageTitle,"Interpreter","none");
end
set(h_plot,'xtick',[])
set(h_plot,'xticklabel',[])
set(h_plot,'ytick',[])
set(h_plot,'yticklabel',[])
set(h_plot,'PlotBoxAspectRatioMode','manual','PlotBoxAspectRatio',[320,256,1]);
drawnow   

end

