function ST = GatherSpikeTransfersPerPacketPortion

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

    t = load(fullfile(basepath,[basename '_SpikeTransferPerPacketPortion.mat']));
    ST.RatioChangeNormSlopeE = cat(1,ST.RatioChangeNormSlopeE,t.SpikeTransferPerPacketPortion.MedianRatioSlopesAbsE);
    ST.RatioChangeNormSlopeI = cat(1,ST.RatioChangeNormSlopeI,t.SpikeTransferPerPacketPortion.MedianRatioSlopesAbsI);
%     ST.RatioChangeNormSlopeEE = cat(1,ST.RatioChangeNormSlopeEE,t.SpikeTransferPerPacketPortion.MedianRatioSlopesAbsEE);
%     ST.RatioChangeNormSlopeEE = cat(1,ST.RatioChangeNormSlopeEI,t.SpikeTransferPerPacketPortion.MedianRatioSlopesAbsEI);
%     ST.RatioChangeNormSlopeIE = cat(1,ST.RatioChangeNormSlopeIE,t.SpikeTransferPerPacketPortion.MedianRatioSlopesAbsIE);
%     ST.RatioChangeNormSlopeII = cat(1,ST.RatioChangeNormSlopeII,t.SpikeTransferPerPacketPortion.MedianRatioSlopesAbsII);

    ST.RatioChangeNormPerPortionMedianE = cat(2,ST.RatioChangeNormPerPortionMedianE,t.SpikeTransferPerPacketPortion.strengthbyratiosWSMedianE);
    ST.RatioChangeNormPerPortionMedianI = cat(2,ST.RatioChangeNormPerPortionMedianI,t.SpikeTransferPerPacketPortion.strengthbyratiosWSMedianI);
    ST.RatioChangeNormPerPortionMedianEE = cat(2,ST.RatioChangeNormPerPortionMedianEE,t.SpikeTransferPerPacketPortion.strengthbyratiosWSMedianEE);
    ST.RatioChangeNormPerPortionMedianEI = cat(2,ST.RatioChangeNormPerPortionMedianEI,t.SpikeTransferPerPacketPortion.strengthbyratiosWSMedianEI);
    ST.RatioChangeNormPerPortionMedianIE = cat(2,ST.RatioChangeNormPerPortionMedianIE,t.SpikeTransferPerPacketPortion.strengthbyratiosWSMedianIE);
    ST.RatioChangeNormPerPortionMedianII = cat(2,ST.RatioChangeNormPerPortionMedianII,t.SpikeTransferPerPacketPortion.strengthbyratiosWSMedianII);
    
    ST.RateDiffChangeNormPerPortionMedianE = cat(2,ST.RateDiffChangeNormPerPortionMedianE,t.SpikeTransferPerPacketPortion.strengthbyratediffsWSMedianE);
    ST.RateDiffChangeNormPerPortionMedianI = cat(2,ST.RateDiffChangeNormPerPortionMedianI,t.SpikeTransferPerPacketPortion.strengthbyratediffsWSMedianI);
    ST.RateDiffChangeNormPerPortionMedianEE = cat(2,ST.RateDiffChangeNormPerPortionMedianEE,t.SpikeTransferPerPacketPortion.strengthbyratediffsWSMedianEE);
    ST.RateDiffChangeNormPerPortionMedianEI = cat(2,ST.RateDiffChangeNormPerPortionMedianEI,t.SpikeTransferPerPacketPortion.strengthbyratediffsWSMedianEI);
    ST.RateDiffChangeNormPerPortionMedianIE = cat(2,ST.RateDiffChangeNormPerPortionMedianIE,t.SpikeTransferPerPacketPortion.strengthbyratediffsWSMedianIE);
    ST.RateDiffChangeNormPerPortionMedianII = cat(2,ST.RateDiffChangeNormPerPortionMedianII,t.SpikeTransferPerPacketPortion.strengthbyratediffsWSMedianII);
end