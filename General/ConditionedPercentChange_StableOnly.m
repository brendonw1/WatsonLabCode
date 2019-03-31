function prepostpercentchg = ConditionedPercentChange_StableOnly(pre,post)
% Simple percentage of change over orignal.  But then some specific 
% operations to handle divisions by 0.
% Brendon Watson 2015

% percent changes... look at linear changes on this
prepostpercentchg = ((post-pre)./pre)*100;
if ~all(isinf(prepostpercentchg))
    prepostpercentchg(prepostpercentchg==Inf) = nan;
    prepostpercentchg(prepostpercentchg==-Inf) = nan;
else
    prepostpercentchg(prepostpercentchg==Inf) = nan;
    prepostpercentchg(prepostpercentchg==-Inf) = nan;
end