function ST = GatherSpikeTransfersPerREMPortion

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
ST.GoodSessions = ones(length(dirs),1);

for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};

    t = load(fullfile(basepath,[basename '_SpikeTransferPerREMPortion.mat']));
    if isempty(t.SpikeTransferPerREMPortion)
        ST.GoodSessions(a) = 0;
    else
        ST.RatioChangeNormSlopeE = cat(1,ST.RatioChangeNormSlopeE,t.SpikeTransferPerREMPortion.MedianRatioSlopesAbsE);
        ST.RatioChangeNormSlopeI = cat(1,ST.RatioChangeNormSlopeI,t.SpikeTransferPerREMPortion.MedianRatioSlopesAbsI);
    %     ST.RatioChangeNormSlopeEE = cat(1,ST.RatioChangeNormSlopeEE,t.SpikeTransferPerREMPortion.MedianRatioSlopesAbsEE);
    %     ST.RatioChangeNormSlopeEE = cat(1,ST.RatioChangeNormSlopeEI,t.SpikeTransferPerREMPortion.MedianRatioSlopesAbsEI);
    %     ST.RatioChangeNormSlopeIE = cat(1,ST.RatioChangeNormSlopeIE,t.SpikeTransferPerREMPortion.MedianRatioSlopesAbsIE);
    %     ST.RatioChangeNormSlopeII = cat(1,ST.RatioChangeNormSlopeII,t.SpikeTransferPerREMPortion.MedianRatioSlopesAbsII);

        ST.RatioChangeNormPerPortionMedianE = cat(2,ST.RatioChangeNormPerPortionMedianE,t.SpikeTransferPerREMPortion.strengthbyratiosWSMedianE);
        ST.RatioChangeNormPerPortionMedianI = cat(2,ST.RatioChangeNormPerPortionMedianI,t.SpikeTransferPerREMPortion.strengthbyratiosWSMedianI);
        ST.RatioChangeNormPerPortionMedianEE = cat(2,ST.RatioChangeNormPerPortionMedianEE,t.SpikeTransferPerREMPortion.strengthbyratiosWSMedianEE);
        ST.RatioChangeNormPerPortionMedianEI = cat(2,ST.RatioChangeNormPerPortionMedianEI,t.SpikeTransferPerREMPortion.strengthbyratiosWSMedianEI);
        ST.RatioChangeNormPerPortionMedianIE = cat(2,ST.RatioChangeNormPerPortionMedianIE,t.SpikeTransferPerREMPortion.strengthbyratiosWSMedianIE);
        ST.RatioChangeNormPerPortionMedianII = cat(2,ST.RatioChangeNormPerPortionMedianII,t.SpikeTransferPerREMPortion.strengthbyratiosWSMedianII);

        ST.RateDiffChangeNormPerPortionMedianE = cat(2,ST.RateDiffChangeNormPerPortionMedianE,t.SpikeTransferPerREMPortion.strengthbyratediffsWSMedianE);
        ST.RateDiffChangeNormPerPortionMedianI = cat(2,ST.RateDiffChangeNormPerPortionMedianI,t.SpikeTransferPerREMPortion.strengthbyratediffsWSMedianI);
        ST.RateDiffChangeNormPerPortionMedianEE = cat(2,ST.RateDiffChangeNormPerPortionMedianEE,t.SpikeTransferPerREMPortion.strengthbyratediffsWSMedianEE);
        ST.RateDiffChangeNormPerPortionMedianEI = cat(2,ST.RateDiffChangeNormPerPortionMedianEI,t.SpikeTransferPerREMPortion.strengthbyratediffsWSMedianEI);
        ST.RateDiffChangeNormPerPortionMedianIE = cat(2,ST.RateDiffChangeNormPerPortionMedianIE,t.SpikeTransferPerREMPortion.strengthbyratediffsWSMedianIE);
        ST.RateDiffChangeNormPerPortionMedianII = cat(2,ST.RateDiffChangeNormPerPortionMedianII,t.SpikeTransferPerREMPortion.strengthbyratediffsWSMedianII);
    end
end