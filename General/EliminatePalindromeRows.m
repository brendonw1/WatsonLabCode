function mtx = EliminatePalindromeRows(mtx)

% [Lia,Locb] = ismember(mtx,fliplr(mtx),'rows');

for a = size(mtx,1):-1:1;
    [loca,locb] = ismember(fliplr(mtx(a,:)),mtx,'rows');
    if locb>0
        mtx(locb,:) = [];
    end
end