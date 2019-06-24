function [phasestats,spkphasesIn] = PhasestatsUsingIndices(spkphases,Index)

% spkNumIn = zeros(size(spkphases));
spkphasesIn = cell(size(spkphases));
for ii = 1:size(spkphases,1)
    for jj = 1:size(spkphases,2)
        for kk = 1:size(spkphases,3)
            spkphasesIn{ii,jj,kk} = spkphases{ii,jj,kk}(Index{ii,jj} & ~isnan(spkphases{ii,jj,kk}));
            if ~isempty(spkphasesIn{ii,jj,kk})
                [~,~,stats] = CircularDistribution(double(spkphasesIn{ii,jj,kk}),'nBins',180);
                phasestats.m(ii,jj,kk) = stats.m;
                phasestats.r(ii,jj,kk) = stats.r;
                phasestats.k(ii,jj,kk) = stats.k;
                phasestats.p(ii,jj,kk) = stats.p;
                phasestats.mode(ii,jj,kk) = stats.mode;
            else
                phasestats.m(ii,jj,kk) = nan;
                phasestats.r(ii,jj,kk) = nan;
                phasestats.k(ii,jj,kk) = nan;
                phasestats.p(ii,jj,kk) = nan;
                phasestats.mode(ii,jj,kk) = nan;
            end
        end
    end
end
