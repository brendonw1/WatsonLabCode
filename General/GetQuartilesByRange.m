function quartidxs = GetQuartilesByRange(vect,ndivs)
% function quartidxs = GetQuartilesByRange(vect)
% Gives labels for which quartile of the input vector each element (of that vector) lies in. 
% Input: vect any vector or matrix
% Output: quartidxs will have values 1:4 to describe which quartile each original
% element goes in. 
% Based based on falling into a certain percentile of the range of the
% dataset.  Not based on taking each 25% of the ranked values, NOT
%
% Brendon Watson 2015

if ~exist('ndivs','var')
    ndivs = 4;%4 for quartiles
end
quartidxs = zeros(size(vect));

mx = max(vect);% get max
mn = min(vect);% get min

bounds = linspace(mn,mx,ndivs+1);

for a=1:ndivs
    quartidxs(vect>=bounds(a)&vect<=bounds(a+1)) = a;
end
quartidxs(vect==bounds(end)) = ndivs;

