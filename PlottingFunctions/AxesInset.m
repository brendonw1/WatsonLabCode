function axh = AxesInsetBars(h,ratio)
% function axh = AxesInsetBars(h,ratio,color,xdata,ydata)
% Puts an inset bar plot (axes) into the upper right of the given axes.  
%  INPUTS
%  h = handle of reference axes
%  ratio = Size of inset relative to original plot
%  color = color of bars
%  data = data to plot
% 
%  OUTPUTS
%  axh = handle of inset axes


figpos = get(h,'Position');
newpos = [figpos(1)+(1-ratio)*figpos(3) figpos(2)+(1-ratio)*figpos(4) ratio*figpos(3) ratio*figpos(4)];
axh = axes('Position',newpos);
% 
% bar(xdata,ydata,'FaceColor',color,'EdgeColor',color)
% axis tight
