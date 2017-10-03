function postvpreproportion = ConditionedProportion(pre,post)
% Simple proportion: post/pre.  But then some specific operations to handle
% divisions by 0 or of zero, also handles negatives.
% Brendon Watson 2015

% proportions of original
postvpreproportion = (post./pre);

% 0/0 -> Nan   ... turn to 1 (neutral)
postvpreproportion(isnan(postvpreproportion)) = 1;
postvpreproportion(postvpreproportion==0) = 1;
good = postvpreproportion>0 & ~isinf(postvpreproportion);
% 0/else -> 0 (prob for geomean)] ... turn to min(elseinmtx)
if sum(good>0)
    % else/0 -> Inf (prob for anything)... turn to max(elseinmtx)
    postvpreproportion(postvpreproportion==Inf) = max(postvpreproportion(good));
    % negatives don't work - subdivide by whether the pre or the post was
    % negative:
    % negative/else -> negative... turn to max(elseinmtx), ie got infinitely bigger 
    postvpreproportion(pre<=0 & post>0) = max(postvpreproportion(good));
    % else/negative -> negative... turn to min(elseinmtx), ie got infinitely smaller
    postvpreproportion(pre>0 & post<=0) = min(postvpreproportion(good));
end
