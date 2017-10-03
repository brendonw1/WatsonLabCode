function [ACGs,allbounds] = ACGByBins(S,binbounds)
% Takes in TSDArray S and series of bin right edges in binbounds, makes a
% histogram of spike-spike inter actions for each cell represented in S.
% Brendon Watson 2015

% if min(binbounds)>0
%     allbounds = [-fliplr(binbounds) 0 binbounds];
% elseif min(binbounds)>0
%     allbounds = [-fliplr(binbounds) binbounds(2:end)];
% else
    allbounds = binbounds;
% end

ACGs = [];
for a = 1:length(S);
    ts = Range(S{a},'s');
    if length(ts)<10000%if small enough just subtract all from all
        [x,y] = meshgrid(ts);
        d = x-y;
        d = d(:);
    else% if spiketrain too long, find spikes in range, then do all-all subtraction
        for b = 1:length(ts)
            tsp = ts(b);
            inrange = abs(tsp-ts) <= max(binbounds);
            irs = tsp(inrange);
            [x,y] = meshgrid(irs);
            d = x-y;
            d = d(:);
        end
    end
    d(d==0) = [];%these are side effect of meshgrid in case of ACG (not CCG)
    ta = histc(d,allbounds);
    ta = ta(:);
    ACGs = cat(1,ACGs,ta');
end
