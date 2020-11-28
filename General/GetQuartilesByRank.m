function quartidxs = GetQuartilesByRank(vect,ndivs)
% function quartidxs = GetQuartilesByRank(vect)
% Gives labels for which quartile of the input vector each element (of that vector) lies in. 
% Input: vect any vector or matrix
% Output: quartidxs will have values 1:4 to describe which quartile each original
% element goes in. 
% Based on taking each 25% of the ranked values, NOT
% based on falling into a certain percentile of the range.
% Brendon Watson 2015

if ~exist('ndivs','var')
    ndivs = 4;%4 for quartiles
end

vect = vect(:);
idxs = tiedrank(vect);
divisions = round(linspace(0,length(vect),ndivs+1));

%test for conditions where so many in bottom value (ie 0) that they rep
%more than a bin and therefore 
havebottomval = idxs==min(idxs);
idxs(havebottomval) = 0;

quartidxs = nan(length(vect),1);
for a = 1:ndivs
    if a == 1
        quartidxs(idxs>=divisions(a) & idxs<=divisions(a+1)) = a;
    else
        quartidxs(idxs>divisions(a) & idxs<=divisions(a+1)) = a;
    end
end

% chunksz = round(length(vect)/ndivs);
% 
% quartidxs = quartidxs/chunksz;
% quartidxs = ceil(quartidxs);
% 
% quartidxs(quartidxs==0) = 1;
% quartidxs(quartidxs>ndivs) = ndivs;%due to use of "round" in generating chunksz

