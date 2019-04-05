function data = FillInMissingStartEnds(data,firstval,endval)
% 2D array input, num timebins x num cells.   Finds cells that either don't
% have a start value or an end value and extends the value from the nearest
% other point to the start/end.  firstval and endval can be set in from the
% endpoints if you want to exclude actual endpoints from this.
% Brendon Watson 2015

if ~exist('firstval','var')
    firstval = 1;
end
if ~exist('endval','var')
    endval = size(data,1);
end

missingstarts = find(isnan(data(firstval,:)));
missingends = find(isnan(data(endval,:)));

for a = 1:length(missingstarts);
    tidx = missingstarts(a);
    tdata = data(:,tidx);
    fgood = find(~isnan(tdata),1,'first');
    lmissing = fgood - 1;
    tdata(firstval:lmissing) = tdata(fgood);
    data(:,tidx) = tdata;
end

for a = 1:length(missingends);
    tidx = missingends(a);
    tdata = data(:,tidx);
    lgood = find(~isnan(tdata),1,'last');
    fmissing = lgood + 1;
    tdata(fmissing:endval) = tdata(lgood);
    data(:,tidx) = tdata;
end

1;