function ST = GatherSpikeTransfersPerSWSEpisodePortion

[names,dirs] = GetDefaultDataset;

ST.RatioChangeNormSlopeE = [];
ST.RatioChangeNormSlopeI = [];
ST.RatioChangeNormPerPortionMedianE = [];
ST.RatioChangeNormPerPortionMedianI = [];
ST.RateDiffChangeNormPerPortionMedianE = [];
ST.RateDiffChangeNormPerPortionMedianI = [];
for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};

    t = load(fullfile(basepath,[basename '_SpikeTransferPerSWSEpisodePortion.mat']));
    ST.RatioChangeNormSlopeE = cat(1,ST.RatioChangeNormSlopeE,t.SpikeTransferPerSWSEpisodePortion.MedianRatioSlopesAbsE);
    ST.RatioChangeNormSlopeI = cat(1,ST.RatioChangeNormSlopeI,t.SpikeTransferPerSWSEpisodePortion.MedianRatioSlopesAbsI);

    ST.RatioChangeNormPerPortionMedianE = cat(2,ST.RatioChangeNormPerPortionMedianE,t.SpikeTransferPerSWSEpisodePortion.strengthbyratiosWSMedianE);
    ST.RatioChangeNormPerPortionMedianI = cat(2,ST.RatioChangeNormPerPortionMedianI,t.SpikeTransferPerSWSEpisodePortion.strengthbyratiosWSMedianI);
    ST.RateDiffChangeNormPerPortionMedianE = cat(2,ST.RateDiffChangeNormPerPortionMedianE,t.SpikeTransferPerSWSEpisodePortion.strengthbyratechgsWSMedianE);
    ST.RateDiffChangeNormPerPortionMedianI = cat(2,ST.RateDiffChangeNormPerPortionMedianI,t.SpikeTransferPerSWSEpisodePortion.strengthbyratechgsWSMedianI);
end