function [status,interval,index] = InIntervalsBW(times,ints)
% Slower version of FMAToolbox function InIntervals, but without dependence
% on compiled code which sometimes fails.
% 
% InIntervals - Test which values fall in a list of intervals.
%
%  USAGE
%
%    [status,interval,index] = InIntervals(values,intervals,<options>)
%
%    values         values to test (these need not be ordered)
%    intervals      list of (start,stop) pairs
%    <options>      optional list of property-value pairs (see table below)
%
%    =========================================================================
%     Properties    Values
%    -------------------------------------------------------------------------
%     'verbose'     display information about ongoing processing
%                   (default = 'off')
%    =========================================================================
%
%  OUTPUT
%
%    status         logical indices (1 = belongs to one of the intervals,
%                   0 = belongs to none)
%    interval       for each value, the index of the interval to which
%                   it belongs (0 = none)
%    index          for each value, its index in the interval to which
%                   it belongs (0 = none)
%
% Brendon Watson 2015

% allbools = [];
allintids = [];
allidxs = [];

times = times(:);
for a = 1:size(ints,1)
    tbool = times>=ints(a,1) & times<=ints(a,2);
    tintids = a*tbool;
    tidxs = cumsum(tbool);
    tidxs(~tbool) = 0;

    allintids = cat(2,allintids,tintids);
    allidxs = cat(2,allidxs,tidxs);
end

status = logical(sum(allintids,2));
interval = sum(allintids,2);
index = sum(allidxs,2);
