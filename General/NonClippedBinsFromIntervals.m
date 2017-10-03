function binintervals = NonClippedBinsFromIntervals(intervals,binwidth)
% intervals may be intervalSets or [start stop] pairs.  
% binwidth: Single value specifying the width of the bins to generate.  
%       In case of intervalSet type intervals, Binwidth is in seconds,
%       in case of [start stop], binwidth is in same units as intervals
% Brendon Watson 2015

switch class(intervals)
    case 'intervalSet'
        intervals = [Start(intervals,'s') End(intervals,'s')];
    case 'double'
end

binintervals = [];
for a = 1:size(intervals,1);
    tb = intervals(a,1):binwidth:intervals(a,2);
    binstarts = tb(1:end-1)';
    binends = tb(2:end)';
    tb = [binstarts binends];
    binintervals = cat(1,binintervals,tb);
end
