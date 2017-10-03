function [Score, Npair, ByCell] = makePairCompare(ref, Cop)
%function [Score, Npair] = makePairCompare(ref, Cop)
%ref(template) = 1xn-pairs
%cop = i-eventsXn-Pairs
%both should live in [-1, 0, 1]


Npair = sum(Cop(:, ref ~= 0) ~= 0, 2);

Score = sum(repmat(ref, size(Cop, 1), 1).*Cop, 2)./Npair;

if nargout >= 3
    R1 = repmat(ref, size(Cop, 1), 1).*Cop;
    R1 = R1./repmat(sum(R1 ~= 0, 2)*2, 1, size(R1, 2));
    R1 = R1/size(R1, 1);
    %R1(R1 == 0) = NaN;
    x = max(solveQuadratic(1, -1, -2*(size(Cop, 2))));
    id = [];
    id(2, size(Cop, 2)) = 0;
    c = 1;
    n = 1:x;
 
    for I = 1:(x - 1)
            id(:, c:(c + x - I -1)) = [zeros(1, x - I) + I; n((I + 1):end)];
            c = c + x - I;
    end
    
    ByCell = [];
    ByCell(size(R1, 1), x) = NaN;
    ByCell(:, :) = NaN;
    for I = 1:x
        ByCell(:, I) = sum(R1(:, sum(id == I) == 1), 2);
    end
    
end