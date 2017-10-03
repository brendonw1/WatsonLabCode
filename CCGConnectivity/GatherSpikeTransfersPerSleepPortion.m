function ST = GatherSpikeTransfersPerSleepPortion

[names,dirs] = GetDefaultDataset;

ST.RatioChangeNormSlopeE = [];
ST.RatioChangeNormSlopeI = [];
ST.RatioChangeNormSlopeEE = [];
ST.RatioChangeNormSlopeEI = [];
ST.RatioChangeNormSlopeIE = [];
ST.RatioChangeNormSlopeII = [];
ST.RatioChangeNormPerPortionMedianE = [];
ST.RatioChangeNormPerPortionMedianI = [];
ST.RatioChangeNormPerPortionMedianEE = [];
ST.RatioChangeNormPerPortionMedianEI = [];
ST.RatioChangeNormPerPortionMedianIE = [];
ST.RatioChangeNormPerPortionMedianII = [];
ST.RateDiffChangeNormPerPortionMedianE = [];
ST.RateDiffChangeNormPerPortionMedianI = [];
ST.RateDiffChangeNormPerPortionMedianEE = [];
ST.RateDiffChangeNormPerPortionMedianEI = [];
ST.RateDiffChangeNormPerPortionMedianIE = [];
ST.RateDiffChangeNormPerPortionMedianII = [];
for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};

    t = load(fullfile(basepath,[basename '_SpikeTransferPerSleepPortion.mat']));
    ST.RatioChangeNormSlopeE = cat(1,ST.RatioChangeNormSlopeE,t.SpikeTransferPerSleepPortion.MedianRatioSlopesAbsE);
    ST.RatioChangeNormSlopeI = cat(1,ST.RatioChangeNormSlopeI,t.SpikeTransferPerSleepPortion.MedianRatioSlopesAbsI);
%     ST.RatioChangeNormSlopeEE = cat(1,ST.RatioChangeNormSlopeEE,t.SpikeTransferPerSleepPortion.MedianRatioSlopesAbsEE);
%     ST.RatioChangeNormSlopeEE = cat(1,ST.RatioChangeNormSlopeEI,t.SpikeTransferPerSleepPortion.MedianRatioSlopesAbsEI);
%     ST.RatioChangeNormSlopeIE = cat(1,ST.RatioChangeNormSlopeIE,t.SpikeTransferPerSleepPortion.MedianRatioSlopesAbsIE);
%     ST.RatioChangeNormSlopeII = cat(1,ST.RatioChangeNormSlopeII,t.SpikeTransferPerSleepPortion.MedianRatioSlopesAbsII);

    ST.RatioChangeNormPerPortionMedianE = cat(2,ST.RatioChangeNormPerPortionMedianE,t.SpikeTransferPerSleepPortion.strengthbyratiosWSMedianE);
    ST.RatioChangeNormPerPortionMedianI = cat(2,ST.RatioChangeNormPerPortionMedianI,t.SpikeTransferPerSleepPortion.strengthbyratiosWSMedianI);
    ST.RatioChangeNormPerPortionMedianEE = cat(2,ST.RatioChangeNormPerPortionMedianEE,t.SpikeTransferPerSleepPortion.strengthbyratiosWSMedianEE);
    ST.RatioChangeNormPerPortionMedianEI = cat(2,ST.RatioChangeNormPerPortionMedianEI,t.SpikeTransferPerSleepPortion.strengthbyratiosWSMedianEI);
    ST.RatioChangeNormPerPortionMedianIE = cat(2,ST.RatioChangeNormPerPortionMedianIE,t.SpikeTransferPerSleepPortion.strengthbyratiosWSMedianIE);
    ST.RatioChangeNormPerPortionMedianII = cat(2,ST.RatioChangeNormPerPortionMedianII,t.SpikeTransferPerSleepPortion.strengthbyratiosWSMedianII);
    
    ST.RateDiffChangeNormPerPortionMedianE = cat(2,ST.RateDiffChangeNormPerPortionMedianE,t.SpikeTransferPerSleepPortion.strengthbyratediffsWSMedianE);
    ST.RateDiffChangeNormPerPortionMedianI = cat(2,ST.RateDiffChangeNormPerPortionMedianI,t.SpikeTransferPerSleepPortion.strengthbyratediffsWSMedianI);
    ST.RateDiffChangeNormPerPortionMedianEE = cat(2,ST.RateDiffChangeNormPerPortionMedianEE,t.SpikeTransferPerSleepPortion.strengthbyratediffsWSMedianEE);
    ST.RateDiffChangeNormPerPortionMedianEI = cat(2,ST.RateDiffChangeNormPerPortionMedianEI,t.SpikeTransferPerSleepPortion.strengthbyratediffsWSMedianEI);
    ST.RateDiffChangeNormPerPortionMedianIE = cat(2,ST.RateDiffChangeNormPerPortionMedianIE,t.SpikeTransferPerSleepPortion.strengthbyratediffsWSMedianIE);
    ST.RateDiffChangeNormPerPortionMedianII = cat(2,ST.RateDiffChangeNormPerPortionMedianII,t.SpikeTransferPerSleepPortion.strengthbyratediffsWSMedianII);
end