function mn = zeromean(data,dimension)
% like nanmean, but ignores zeros, not nans.  Gives mean of all non-zero
% elements.  Specify dimension if you like with second input (default = 1)
%
% Brendon Watson 2015

if ~exist('dimension','var')
    dimension = 1;
end

mn = sum(data,dimension)./sum(logical(data),1);