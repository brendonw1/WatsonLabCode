function x = solveQuadratic(a, b, c)


x = zeros(2,1);
d = sqrt(b^2 - 4*a*c);
x(1) = ( -b + d ) / (2*a);
x(2) = ( -b - d ) / (2*a);