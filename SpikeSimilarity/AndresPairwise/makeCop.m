function Cop = makeCop(Co);
%function Cop = makeCop(Co);

Cop = [];
n = size(Co, 2)*(size(Co, 2) - 1)/2;
Cop(size(Co, 1), n) = 0;
for i = 1:size(Co, 1)
    Cop(i, :) = makePlaceLatencyVector(Co(i, :));
end