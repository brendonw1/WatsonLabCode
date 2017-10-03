function [x,y] =  RegressAndFindR2(x,y)

% Finds polynomial regression of x,y data at polynomial of degree n, gives
% fitted y.
% Note that spots where y is NaN are eliminated in both x and y and the
% output x and y will reflect this transformation.

x(isnan(y))=[];
y(isnan(y))=[];

p = polyfit(x,y,1);
y = polyval(p,x);
