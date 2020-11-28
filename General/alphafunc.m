function out=alphafunc(points,tau);

% function out=alphafunc(tau,points);
% This function evaluates an alpha function with time constant, tau, at
% the input points in the vector "points"

out=points.*exp(-points/tau).*1/tau^2;