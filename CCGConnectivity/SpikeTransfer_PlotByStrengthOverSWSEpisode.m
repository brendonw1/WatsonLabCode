function SpikeTransfer_PlotByStrengthOverSWSEpisode

nstrengthdivisions = 6;
fchunk = 1;
lchunk = 10;

ST = GatherSpikeTransfersPerSWSEpisodePortion;
DecilePerCnxnRatioE = ST.RatioChangeNormPerPortionMedianE;
DecilePerCnxnRatioI = ST.RatioChangeNormPerPortionMedianI;
DecilePerCnxnRateChgE = ST.RateChgChangeNormPerPortionMedianE;
DecilePerCnxnRateChgI = ST.RateChgChangeNormPerPortionMedianI;

SynapseByStateAll = SpikeTransfer_GatherAllSpikeTransferByState;
ERatioWakeB = SynapseByStateAll.ERatios(:,ismember(SynapseByStateAll.StateNames,'WSWake'));

h = [];
h(end+1) = PlotEachDistro(DecilePerCnxnRatioE,ERatioWakeB,fchunk,lchunk,nstrengthdivisions);
    AboveTitle('SpikeTransmissionRatio Over Sleep Tenths: ECnxns')
    set(gcf,'name','STRatio_OverSleepTenthsByECnxnHexile')
h(end+1) = PlotEachDistro(DecilePerCnxnRatioI,ERatioWakeB,fchunk,lchunk,nstrengthdivisions);
    AboveTitle('SpikeTransmissionRatio Over Sleep Tenths: ICnxns')
    set(gcf,'name','STRatio_OverSleepTenthsByICnxnHexile')
h(end+1) = PlotEachDistro(DecilePerCnxnRateChgE,ERatioWakeB,fchunk,lchunk,nstrengthdivisions);
    AboveTitle('SpikeTransmissionRatio Over Sleep Tenths: ECnxns')
    set(gcf,'name','STRateChg_OverSleepTenthsByECnxnHexile')
h(end+1) = PlotEachDistro(DecilePerCnxnRateChgI,ERatioWakeB,fchunk,lchunk,nstrengthdivisions);
    AboveTitle('SpikeTransmissionRatio Over Sleep Tenths: ICnxns')
    set(gcf,'name','STRateChg_OverSleepTenthsByICnxnHexile')

MakeDirSaveFigsThere('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/SpikeTransfer/OverSWSEpisodePortions',h)
1;





function h = PlotEachDistro(Data,RankingParam,fchunk,lchunk,nstrengthdivisions)
d = Data(:);
Data(d == Inf) = max(d(d<Inf));
Data(d <= 0) = min(d(d>0));
FData = FillInMissingStartEnds(Data,fchunk,lchunk);

StrengthGroups = GetQuartilesByRank(RankingParam,nstrengthdivisions);%ie quartiles or hexiles

for a = 1:nstrengthdivisions
    RatioStrengthsByGroupE(:,a) = nanmean(Data(:,StrengthGroups==a),2);
    FRatioStrengthsByGroupE(:,a) = nanmean(FData(:,StrengthGroups==a),2);
end

cols = RainbowColors(nstrengthdivisions);

Data = log10(Data);
FData = log10(FData);

h = figure('position',[2 2 1000 700]);
subplot(2,2,1)
    plot(Data);
    hold on
    errorbar([0.5 size(Data,1)+.5],[nanmean(Data(fchunk,:)) nanmean(Data(lchunk,:))],[nanstd(Data(fchunk,:)) nanstd(Data(lchunk,:))],'k.')
    axis tight
    xlim([0 size(Data,1)+1])
    variancep = vartestn(Data([fchunk lchunk],:)','testtype','brownforsythe','display','off');
    title(['Variance Diff: p = ' num2str(variancep)],'fontweight','normal');
subplot(2,2,2)
    plot(FData);
    hold on
    errorbar([0.5 size(FData,fchunk)+.5],[nanmean(FData(fchunk,:)) nanmean(FData(lchunk,:))],[nanstd(FData(fchunk,:)) nanstd(FData(lchunk,:))],'k.')
    axis tight
    xlim([0 size(FData,1)+1])
    variancep = vartestn(FData([fchunk lchunk],:)','testtype','brownforsythe','display','off');
    title(['Variance Diff: p = ' num2str(variancep)],'fontweight','normal');
subplot(2,2,3) 
    set(gca,'color',[.9 .9 .9])
    for a = 1:nstrengthdivisions
        semilogy(RatioStrengthsByGroupE(:,a),'color',cols(a,:),'LineWidth',2);
        hold on;
    end
subplot(2,2,4)    
    set(gca,'color',[.9 .9 .9])
    for a = 1:nstrengthdivisions
        semilogy(FRatioStrengthsByGroupE(:,a),'color',cols(a,:),'LineWidth',2);
        hold on;
    end

