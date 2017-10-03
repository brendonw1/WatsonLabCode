function IntervalUPCounts = CountsDuringSpanofUps(S,UPInts,restrictinginterval)
%Gets counts for each cell for UP states within a given span... ie presleep

w = whos('S');
if strcmp(w.class,'tsdArray')
    numcells = size(S,1);
    arraybool = 1;
elseif strcmp(w.class,'tsd')
    numcells = 1;
    arraybool = 0;
end

theseUPs = intersect(UPInts,restrictinginterval);
if ~isempty(Start(theseUPs))
    if arraybool
        for a = 1:numcells%for each cell
            IntervalUPCounts(:,a) = Data(intervalCount(S{a},theseUPs));
        end
    else 
        IntervalUPCounts = Data(intervalCount(S,theseUPs));
    end
else
    IntervalUPCounts=NaN(1,numcells);
end