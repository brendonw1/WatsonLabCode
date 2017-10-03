function val = percentilevalue(vect,pct)
% Gets the value after sorting vect of the input closest to the percentile
% pct (pct should range 0-100);
% Brendon Watosn 2015

vect = sort(vect);
idx = round(pct/100*length(vect));
idx = max([1 idx]);%so no 0 value idx
val = vect(idx);
