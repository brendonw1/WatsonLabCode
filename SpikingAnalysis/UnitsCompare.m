function [complist,disagreements,agreements] = UnitsCompare(goodUnitsCurated,goodUnitsDaviolin)
listsize = max([goodUnitsCurated goodUnitsDaviolin]);

complist = zeros(listsize, 3);
disagreements = [];
agreements = [];

complist(:,1) = 1:listsize;  
for i = 1:listsize
    complist(i,2) = ismember(i,goodUnitsCurated);
    complist(i,3) = ismember(i,goodUnitsDaviolin);
    if (complist(i,2)~=complist(i,3))
        disagreements = [disagreements i]; 
    elseif (complist(i,2) == 1)
        agreements = [agreements i];
    end
end

end

