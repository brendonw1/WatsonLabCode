function ST = GatherSpikeTransfersPerWakePortion

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

    t = load(fullfile(basepath,[basename '_SpikeTransferPerWakePortion.mat']));
    ST.RatioChangeNormSlopeE = cat(1,ST.RatioChangeNormSlopeE,t.SpikeTransferPerWakePortion.MedianRatioSlopesAbsE);
    ST.RatioChangeNormSlopeI = cat(1,ST.RatioChangeNormSlopeI,t.SpikeTransferPerWakePortion.MedianRatioSlopesAbsI);
%     ST.RatioChangeNormSlopeEE = cat(1,ST.RatioChangeNormSlopeEE,t.SpikeTransferPerWakePortion.MedianRatioSlopesAbsEE);
%     ST.RatioChangeNormSlopeEE = cat(1,ST.RatioChangeNormSlopeEI,t.SpikeTransferPerWakePortion.MedianRatioSlopesAbsEI);
%     ST.RatioChangeNormSlopeIE = cat(1,ST.RatioChangeNormSlopeIE,t.SpikeTransferPerWakePortion.MedianRatioSlopesAbsIE);
%     ST.RatioChangeNormSlopeII = cat(1,ST.RatioChangeNormSlopeII,t.SpikeTransferPerWakePortion.MedianRatioSlopesAbsII);

    ST.RatioChangeNormPerPortionMedianE = cat(2,ST.RatioChangeNormPerPortionMedianE,t.SpikeTransferPerWakePortion.strengthbyratiosWSMedianE);
    ST.RatioChangeNormPerPortionMedianI = cat(2,ST.RatioChangeNormPerPortionMedianI,t.SpikeTransferPerWakePortion.strengthbyratiosWSMedianI);
    ST.RatioChangeNormPerPortionMedianEE = cat(2,ST.RatioChangeNormPerPortionMedianEE,t.SpikeTransferPerWakePortion.strengthbyratiosWSMedianEE);
    ST.RatioChangeNormPerPortionMedianEI = cat(2,ST.RatioChangeNormPerPortionMedianEI,t.SpikeTransferPerWakePortion.strengthbyratiosWSMedianEI);
    ST.RatioChangeNormPerPortionMedianIE = cat(2,ST.RatioChangeNormPerPortionMedianIE,t.SpikeTransferPerWakePortion.strengthbyratiosWSMedianIE);
    ST.RatioChangeNormPerPortionMedianII = cat(2,ST.RatioChangeNormPerPortionMedianII,t.SpikeTransferPerWakePortion.strengthbyratiosWSMedianII);
    
    ST.RateDiffChangeNormPerPortionMedianE = cat(2,ST.RateDiffChangeNormPerPortionMedianE,t.SpikeTransferPerWakePortion.strengthbyratediffsWSMedianE);
    ST.RateDiffChangeNormPerPortionMedianI = cat(2,ST.RateDiffChangeNormPerPortionMedianI,t.SpikeTransferPerWakePortion.strengthbyratediffsWSMedianI);
    ST.RateDiffChangeNormPerPortionMedianEE = cat(2,ST.RateDiffChangeNormPerPortionMedianEE,t.SpikeTransferPerWakePortion.strengthbyratediffsWSMedianEE);
    ST.RateDiffChangeNormPerPortionMedianEI = cat(2,ST.RateDiffChangeNormPerPortionMedianEI,t.SpikeTransferPerWakePortion.strengthbyratediffsWSMedianEI);
    ST.RateDiffChangeNormPerPortionMedianIE = cat(2,ST.RateDiffChangeNormPerPortionMedianIE,t.SpikeTransferPerWakePortion.strengthbyratediffsWSMedianIE);
    ST.RateDiffChangeNormPerPortionMedianII = cat(2,ST.RateDiffChangeNormPerPortionMedianII,t.SpikeTransferPerWakePortion.strengthbyratediffsWSMedianII);
end