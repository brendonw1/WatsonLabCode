function IntervalUPRates = RatesDuringSpanofUps(S,UPInts,restrictinginterval)
%Gets spike counts for each cell for UP states within a given span... ie presleep

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
            IntervalUPRates(:,a) = Data(intervalRate(S{a},theseUPs));
        end
    else 
        IntervalUPRates = Data(intervalRate(S,theseUPs));
    end
else
    IntervalUPRates=NaN(1,numcells);
end