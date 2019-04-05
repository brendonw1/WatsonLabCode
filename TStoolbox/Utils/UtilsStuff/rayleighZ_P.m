function [mu,rayleighP] = rayleighZ(phase);

n = length(phase);

m = 1/n*sum(cos(phase)+i*sin(phase));

mu = angle(m);
Z = n*abs(m)^2;

if n<50
	rayleighP = exp(-Z)*(1+(2*Z-Z^2)/(4*n) -(24*Z - 132*Z^2 + 76*Z^3 - 9*Z^4)/(288*n^2));
else
	rayleighP = exp(-Z);
end