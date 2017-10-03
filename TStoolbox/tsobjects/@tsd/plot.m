function plot(tsd,color)

%  Plots data in a TSD using time as x and data as y.  If time = data (ie
%  for spikes data), plotting is done as a series of points.
%  	
%  	USAGE:
%  	plot(tsd) 
%  	
%  	INPUTS:
%  	tsd - a tsd object
%  	color - plotting color for line, optional
%
%  	OUTPUTS:
%  	[none]
% copyright (c) 2014 Brendon O. Watson


x = Range(tsd,'s');
y = Data(tsd);
if sum(x-y)==0;
    y = zeros(size(x));
    if exist('color','var')
        plot(x,y,'.','color',color)
    else
        plot(x,y,'.')
    end
else
    if exist('color','var')
        plot(x,y,'.','color',color)
    else
        plot(x,y);
    end        
end
