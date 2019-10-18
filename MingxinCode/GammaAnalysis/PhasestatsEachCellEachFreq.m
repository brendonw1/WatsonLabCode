function phasestats = PhasestatsEachCellEachFreq(spkphases)

numBins = 180;
for i = 1:size(spkphases,1)
    for j = 1:size(spkphases,2)
        spkphases{i,j} = spkphases{i,j}(~isnan(spkphases{i,j}));
        if ~isempty(spkphases{i,j})
            [~,~,ps]=CircularDistribution(double(spkphases{i,j}),'nBins',numBins);
            phasestats.m(i,j) = mod(ps.m,2*pi);
            phasestats.r(i,j) = ps.r;
            phasestats.k(i,j) = ps.k;
            phasestats.p(i,j) = ps.p;
            phasestats.mode(i,j) = ps.mode;
        else
            phasestats.m(i,j) = NaN;
            phasestats.r(i,j) = NaN;
            phasestats.k(i,j) = NaN;
            phasestats.p(i,j) = NaN;
            phasestats.mode(i,j) = NaN;
        end
    end
end