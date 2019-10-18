function PlotBandCorrelation
basepath = cd;
[~,basename] = fileparts(cd);

load(fullfile(basepath,[basename '_BandPhaseLockingData30-200Hz_lfp55.mat']),'bandphase');

bandnums = length(bandphase);

for i = 1:bandnums
    [n{i},edges{i},bin{i}] = histcounts(bandphase{i},20);
end

bandcorr = cell(bandnums);

for j = 1:bandnums
    for k = 1:bandnums
        bandcorr{j,k} = zeros(20);
        for l = 1:length(bin{j})
        bandcorr{j,k}(bin{j}(l),bin{k}(l)) = bandcorr{j,k}(bin{j}(l),bin{k}(l)) + 1;
        end
    end
end

figure;
for j = 1:bandnums
    for k = 1:bandnums
        subplot(bandnums,bandnums,(j-1)*bandnums+k);
        imagesc(bandcorr{j,k});
    end
end
end