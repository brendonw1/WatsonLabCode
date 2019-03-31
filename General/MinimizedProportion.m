function [postvpreproportion,bad] = MinimizedProportion(pre,post)
% Simple proportion: post/pre.  But then some specific operations to handle
% divisions by 0 or of zero, also handles negatives.
% Brendon Watson 2015

% proportions of original
postvpreproportion = (post./pre);

% 0/0 -> Nan   ... turn to 1 (neutral)
postvpreproportion(isnan(postvpreproportion)) = 1;


good = postvpreproportion>0 & ~isinf(postvpreproportion);
% 0/else -> 0 (prob for geomean)] ... turn to min(elseinmtx)
% negative/anything -> negative... turn to min(elseinmtx)
% if sum(good>0)
%     postvpreproportion(postvpreproportion<=0) = min(postvpreproportion(good));
%     % else/0 -> Inf (prob for anything)... turn to max(elseinmtx)
%     postvpreproportion(postvpreproportion==Inf) = max(postvpreproportion(good));
% end

bad = ~good;
postvpreproportion = postvpreproportion(good);