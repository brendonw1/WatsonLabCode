function bool = inttobool(ints,totalpoints)
% Takes a series of start-stop intervals (one row for each int, each row is
% [startpoint stoppoint]) and converts to a boolean with length
% (totalpoints) with zeros by default but 1s wherever points are inside
% "ints".  If totalpoints is not input then length is set by the last point
% in the last int.

warning off

if ~exist('totalpoints','var')
    totalpoints = 1;
end

bool = zeros(1,totalpoints);
for a = 1:size(ints,1);
    bool(round(ints(a,1)):round(ints(a,2))) = 1;
end

