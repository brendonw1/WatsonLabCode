function [reclength] = makeReclength(allspikecells)
    rex = {};
    for i = 1:length(allspikecells)
        rex{i} = max(allspikecells{i});
    end
    
    reclength = max(cell2mat(rex));
end
