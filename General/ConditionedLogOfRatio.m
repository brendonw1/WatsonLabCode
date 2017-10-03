function lor = ConditionedLogOfRatio(numer,denom,conditioningtype)
% Takes log of point-by-point ratios along two vectors... but before hand
% conditions to get rid of spurious Infs/-Infs/NaNs;
% zeros which will result in Infs/-Infs.  Has two alternate ways of 
% preconditioning, see "conditioningtype" below.
% 
% INPUTS 
%   numer and denom:  must have same lengths ratio of numer/denom will be
%        caluculated
%   conditioningtype: 'ratiostage' (default) or 'initialstage'
%       1) 'ratiostage': replace Infs/-Infs in the
%           ratio with the max/min other ratios (and NaNs by 1)
%       2) 'initialstage': remove zeros from initial data, replacing by the
%             minimum non-zero value in either vector
% OUTPUT lor will be of same length as numer & denom
%
% !Uses Log10 not log
%
% Brendon Watson Nov 2014

if ~exist('conditioningtype','var')
    conditioningtype = 'ratiostage';
end

numer = numer(:);
denom = denom(:);


switch conditioningtype
    case 'ratiostage'% condition after ratio taken
        lor = log10(numer./denom);

        maxnoninf = max(lor(~isinf(lor)));
        minnoninf = min(lor(~isinf(lor)));
        
        lor(isnan(lor)) = 1;
        lor(lor==Inf) = maxnoninf;
        lor(lor==-Inf) = minnoninf;

    case 'initialstage'%condition initial data
        minval = min(cat(1,numer(numer>0),denom(denom>0)));

        numer(numer==0) = minval;
        denom(denom==0) = minval;

        lor = log10(numer./denom);
end