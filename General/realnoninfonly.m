function x = realnoninfonly(x)

x = x(~isnan(x));
x = x(~isinf(x));