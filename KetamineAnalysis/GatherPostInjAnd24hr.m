function CompareMatrix = GatherPostInjAnd24hr(CompareMatrix)

warning off

[names,dirs]=GetKetamineDataset;
if ~exist('CompareMatrix','var')
    CompareMatrix  = [];
    CompareMatrixNames = {};
end

rec_counter = 0;
for a = 1:length(names)
    basename = names{a};
    basepath = dirs{a};

    %% do not execute if data unavailable
    a_path = fullfile(basepath,[basename '_KetaminePostInjectionWake.mat']);
    b_path = fullfile(basepath,[basename '_KetamineBinnedDataByIntervalState.mat']);
    if ~exist(a_path,'file') || ~exist(b_path,'file')
%         disp(['Files for binned data comparisons do not exist for ' basename])
        continue
%     else
%         disp(['Files for binned data comparisons DO exist for ' basename])
    end

    %% open data
    load(fullfile(basepath,[basename '_KetaminePostInjectionWake.mat']),'KetaminePostInjectionWakeData')
    load(fullfile(basepath,[basename '_KetamineBinnedDataByIntervalState.mat']),'KetamineBinnedDataByIntervalState')

    m_counter = 0;
    rec_counter = rec_counter+1;
    
    %% collect into bins from post-inj wake
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.Duration;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIWakeDur';
    m_counter = m_counter + 1;
    
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.ERateStats.InjNoninjMeanRatio;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PISeMeanPrePostRatio';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.ERateStats.InjNoninjMedianRatio;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PISeMedianPPRatio';
    m_counter = m_counter + 1;
    
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.MotionStats.TotalInj;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIMvmtTotal';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.MotionStats.MeanInj;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIMvmtMean';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.MotionStats.MedianInj;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIMvmtMedian';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.MotionStats.InjNoninjMeanRatio;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIMvmtMeanPPRatio';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.MotionStats.InjNoninjMedianRatio;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIMvmtMedianPPRatio';
    m_counter = m_counter + 1;
    
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.BandsData.lowgamma(1).ChannelStats.MeanInj;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PILoGammaMean';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.BandsData.lowgamma(1).ChannelStats.MedianInj;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PILoGammaMedian';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.BandsData.lowgamma(1).ChannelStats.InjNoninjMeanRatio;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PILoGammaMeanPPRatio';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.BandsData.lowgamma(1).ChannelStats.InjNoninjMedianRatio;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PILoGammaMedianPPRatio';
    m_counter = m_counter + 1;

    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.BandsData.midgamma(1).ChannelStats.MeanInj;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIMidGammaMean';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.BandsData.midgamma(1).ChannelStats.MedianInj;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIMidGammaMedian';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.BandsData.midgamma(1).ChannelStats.InjNoninjMeanRatio;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIMidGammaMeanPPRatio';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.BandsData.midgamma(1).ChannelStats.InjNoninjMedianRatio;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIMidGammaMedianPPRatio';
    m_counter = m_counter + 1;

    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.BandsData.highgamma(1).ChannelStats.MeanInj;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIHighGammaMean';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.BandsData.highgamma(1).ChannelStats.MedianInj;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIHighGammaMedian';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.BandsData.highgamma(1).ChannelStats.InjNoninjMeanRatio;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIHighGammaMeanPPRatio';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.BandsData.highgamma(1).ChannelStats.InjNoninjMedianRatio;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIHighGammaMedianPPRatio';
    m_counter = m_counter + 1;

    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.BandsData.ripple(1).ChannelStats.MeanInj;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIRippleMean';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.BandsData.ripple(1).ChannelStats.MedianInj;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIRippleMedian';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.BandsData.ripple(1).ChannelStats.InjNoninjMeanRatio;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIRippleMeanPPRatio';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.BandsData.ripple(1).ChannelStats.InjNoninjMedianRatio;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIRippleMedianPPRatio';
    m_counter = m_counter + 1;

    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.HRLRRStats.MeanInj;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIHRLRMean';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.HRLRRStats.MedianInj;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIHRLRMedian';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.HRLRRStats.InjNoninjMeanRatio;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIHRLRMeanPPRatio';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.HRLRRStats.InjNoninjMedianRatio;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIHRLRMedianPPRatio';
    m_counter = m_counter + 1;

    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.HRRStats.MeanInj;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIHRMean';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.HRRStats.MedianInj;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIHRMedian';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.HRRStats.InjNoninjMeanRatio;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIHRMeanPPRatio';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.HRRStats.InjNoninjMedianRatio;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIHRMedianPPRatio';
    m_counter = m_counter + 1;

    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.LRRStats.MeanInj;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PILRMean';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.LRRStats.MedianInj;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PILRMedian';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.LRRStats.InjNoninjMeanRatio;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PILRMeanPPRatio';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.LRRStats.InjNoninjMedianRatio;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PILRMedianPPRatio';
    m_counter = m_counter + 1;

    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.ECoVStats.MeanInj;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PICoVMean';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.ECoVStats.MedianInj;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PICoVMedian';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.ECoVStats.InjNoninjMeanRatio;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PICoVMeanPPRatio';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.ECoVStats.InjNoninjMedianRatio;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PICoVMedianPPRatio';
    m_counter = m_counter + 1;

    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.EIRatioStats.MeanInj;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIEIRMean';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.EIRatioStats.MedianInj;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIEIRMedian';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.EIRatioStats.InjNoninjMeanRatio;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIEIRMeanPPRatio';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.EIRatioStats.InjNoninjMedianRatio;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIEIRMedianPPRatio';
    m_counter = m_counter + 1;

    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.EBurstStats.MeanInj;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIBurstMean';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.EBurstStats.MedianInj;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIBurstMedian';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.EBurstStats.InjNoninjMeanRatio;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIBurstMeanPPRatio';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = KetaminePostInjectionWakeData.EBurstStats.InjNoninjMedianRatio;
    CompareMatrixNames{m_counter+1,rec_counter} = 'PIBurstMedianPPRatio';
    m_counter = m_counter + 1;
    
    %% collect into bins from 24hr wake
    CompareMatrix(m_counter+1,rec_counter) = median(KetamineBinnedDataByIntervalState.hrlrBaseline24Data.int2WAKEvals);
    CompareMatrixNames{m_counter+1,rec_counter} = 'Hr24HRLRRMedian';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = CompareMatrix(m_counter,rec_counter)./median(KetamineBinnedDataByIntervalState.hrlrBaselineData.int1WAKEvals);
    CompareMatrixNames{m_counter+1,rec_counter} = 'Hr24HRLRR24VBaseRatio';
    m_counter = m_counter + 1;

    CompareMatrix(m_counter+1,rec_counter) = median(KetamineBinnedDataByIntervalState.hrBaseline24Data.int2WAKEvals);
    CompareMatrixNames{m_counter+1,rec_counter} = 'Hr24HRMedian';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = CompareMatrix(m_counter,rec_counter)./median(KetamineBinnedDataByIntervalState.hrBaselineData.int1WAKEvals);
    CompareMatrixNames{m_counter+1,rec_counter} = 'Hr24HR24VBaseRatio';
    m_counter = m_counter + 1;
    
    CompareMatrix(m_counter+1,rec_counter) = median(KetamineBinnedDataByIntervalState.lrBaseline24Data.int2WAKEvals);
    CompareMatrixNames{m_counter+1,rec_counter} = 'Hr24LRMedian';
    m_counter = m_counter + 1;
    CompareMatrix(m_counter+1,rec_counter) = CompareMatrix(m_counter,rec_counter)./median(KetamineBinnedDataByIntervalState.lrBaselineData.int1WAKEvals);
    CompareMatrixNames{m_counter+1,rec_counter} = 'Hr24LR24VBaseRatio';
    m_counter = m_counter + 1;
    
    
%     fnpi = fieldnames(KetaminePostInjectionWakeData);
%     fn24 = fieldnames(KetamineBinnedDataByIntervalState);
%     counter = 1;
%     for b = 1:length(fnpi)
%        t = getfield(KetaminePostInjectionWakeData,fnpi{b});
%        if isnumeric(t)
%            CompareMatrix(a,counter) = t;
%            CompareMatrixNames{counter} = fnpi{b};
%            counter = counter+1;
%        end
%     end
%     for b = 1:length(fn24)
%        t = getfield(KetamineBinnedDataByIntervalState,fn24{b});
%        if isnumeric(t)
%            CompareMatrix(a,counter) = t;
%            CompareMatrixNames{counter} = fn24{b};
%            counter = counter+1;
%        end
%     end

    1;
    
end

1;


