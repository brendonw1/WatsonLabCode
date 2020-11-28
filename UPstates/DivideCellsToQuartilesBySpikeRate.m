function [Sq1, Sq2, Sq3, Sq4] = DivideCellsToQuartilesBySpikeRate(S)

rates = Rate(S);
[sortedrates,sortedidxs] = sort(rates);
cr = cumsum(sortedrates);

bounds = dsearchn(cr,(sum(rates)*.25*[1:4])');

% q1 = sortedidxs(1:bounds(1)-1);
% q2 = sortedidxs(bounds(1):bounds(2)-1);
% q3 = sortedidxs(bounds(2):bounds(3)-1);
% q4 = sortedidxs(bounds(3):bounds(4));

q1idxs = sort(sortedidxs(1:bounds(1)));
q2idxs = sort(sortedidxs(bounds(1):bounds(2)));
q3idxs = sort(sortedidxs(bounds(2):bounds(3)));
q4idxs = sort(sortedidxs(bounds(3):bounds(4)));

Sq1 = S(q1idxs);
Sq2 = S(q2idxs);
Sq3 = S(q3idxs);
Sq4 = S(q4idxs);
