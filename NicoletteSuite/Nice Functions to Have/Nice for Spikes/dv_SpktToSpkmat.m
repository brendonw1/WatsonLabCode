function [spikemat] = dv_SpktToSpkmat(allspikecells,bin)
    reclength = makeReclength(allspikecells);
    spikemat = [];
    
    for i = 1:length(allspikecells)
        spikemat = [spikemat; binSpikes(allspikecells{i},bin,reclength)];
    end
    
    
end
