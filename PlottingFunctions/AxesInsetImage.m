function axh = AxesInsetImage(h,ratio,mtxdata)
% function axh = AxesInsetImage(h,ratio,mxtdata)
% Puts an inset image (axes) into the upper right of the given axes.  
%  INPUTS
%  h = handle of reference axes
%  ratio = Size of inset relative to original plot
%  mtxdata = data to plot, 2d matrix or colormatrix that will plot with
%  imagesc
% 
%  OUTPUTS
%  axh = handle of inset axes

figpos = get(h,'Position');

if length(ratio) == 1;
    newpos = [figpos(1)+(1-ratio)*figpos(3) figpos(2)+(1-ratio)*figpos(4) ratio*figpos(3) ratio*figpos(4)];
elseif length(ratio) == 2;
    newpos = [figpos(1)+(1-ratio(1))*figpos(3) figpos(2)+(1-ratio(1))*figpos(4) ratio(2)*figpos(3) ratio(2)*figpos(4)];
end

axh = axes('Position',newpos);

imagesc(mtxdata);
