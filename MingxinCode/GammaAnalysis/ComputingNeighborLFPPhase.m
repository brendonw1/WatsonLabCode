function [neighborPhases,cellneighborIdx] = ComputingNeighborLFPPhase(phases,shank,LFPShanks,neighborShanks)

GoodUnitShanks = unique(shank);
neighborPhases = cell(1,length(GoodUnitShanks),1);
% neighborAmp = cell(1,length(GoodUnitShanks));
% h = waitbar(0,'Please wait...');

for i = 1:length(GoodUnitShanks)
    neighbor = neighborShanks{i};
    if length(neighbor)==1
        neighborPhases{i} = phases{LFPShanks==neighbor};
%         neighborAmp{i} = amp{neighbor};
    elseif length(neighbor)==2
        S = sum(cat(3,sin(phases{LFPShanks==neighbor(1)}),sin(phases{LFPShanks==neighbor(2)})),3);
        C = sum(cat(3,cos(phases{LFPShanks==neighbor(1)}),cos(phases{LFPShanks==neighbor(2)})),3);
        neighborPhases{i} = atan2(S, C);
        neighborPhases{i} = mod(neighborPhases{i},2*pi);
%         neighborAmp{i} = mean(cat(3,amp{LFPShanks==neighbor(1)},amp{LFPShanks==neighbor(2)}),3);
    end
%     waitbar(i/length(GoodUnitShanks));
end

for ii = 1:length(shank)
    cellneighborIdx(ii) = find(GoodUnitShanks==shank(ii));
end