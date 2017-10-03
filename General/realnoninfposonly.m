function [x,bad] = realnoninfposonly(x)

a = isnan(x);
b = isinf(x);
c = x<0;

bad = logical(a+b+c);

x(bad) = [];