function value = sem(matrix,varargin)
% function value = sem(matrix);
% Calculates the standard error of the mean of a sample (sem) from a single
% input.  Uses sem = std/(sqrt(number of samples)).  Tries to work with 2D
% matrices.
% Assumes std and sem are to be taken along dimension 1, unless an extra
% dim input comes in.

dim = 1;
if ~isempty(varargin)
    dim = varargin{1};
end

value = std(matrix,1,dim);%standard dev along dim 1;
numsamples = size(matrix,dim);
value = value/(numsamples)^.5;