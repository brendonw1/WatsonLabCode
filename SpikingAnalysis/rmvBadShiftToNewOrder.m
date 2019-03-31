function mtx = rmvBadShiftToNewOrder(mtx,badclus,remaining,cnv)
%For use with ...SeparateShanks script, incuding cleanfuncsynapses

mtx(any(ismember(mtx, badclus),2),:)=[];
for a = 1:size(mtx,1)
    for b = 1:size(mtx,2)
        idx = find(mtx(a,b)==remaining);
        if ~isempty(idx)
            mtx(a,b) = cnv(idx);
        end
    end
end
