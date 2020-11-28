function prepostpercentchg = ConditionedPercentChange(pre,post)
% Simple percentage of change over orignal.  But then some specific 
% operations to handle divisions by 0.
% Brendon Watson 2015

% percent changes... look at linear changes on this
prepostpercentchg = ((post-pre)./pre)*100;
if ~all(isinf(prepostpercentchg))
    prepostpercentchg(prepostpercentchg==Inf) = max(prepostpercentchg(~isinf(prepostpercentchg)));
    prepostpercentchg(prepostpercentchg==-Inf) = min(prepostpercentchg(~isinf(prepostpercentchg)));
else
    prepostpercentchg(prepostpercentchg==Inf) = 100;
    prepostpercentchg(prepostpercentchg==-Inf) = -100;
end