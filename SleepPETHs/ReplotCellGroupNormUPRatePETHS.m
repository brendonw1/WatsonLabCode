function ReplotCellGroupNormUPRatePETHS

load('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/UPs/UPStateRateParticipationPerCellRankGroup.mat')
% Will have UPStateRateParticipationPerCellRankGroup

sn = UPStateRateParticipationPerCellRankGroup.statenames;

%plot ER over Sleep, SWSSEpisodes, SWSPackets
col = OrangeColorsConfined(6);
h = [];

%% Rates
h(end+1) = figure('position',[2 2 750 650],'name','UPRateGroupRates');
subplot(2,3,1)
    for a = 1:6
        PlotPETHNormAxesData(UPStateRateParticipationPerCellRankGroup.AllEpAlignedER{3,a},gca,col(a,:));
    end
    set(gca,'YScale','log')
    title('E UP Rates over Sleep','fontweight','normal')
subplot(2,3,2)
    for a = 1:6
        PlotPETHNormAxesData(UPStateRateParticipationPerCellRankGroup.AllEpAlignedER{2,a},gca,col(a,:));
    end
    set(gca,'YScale','log')
    title('E UP Rates SWSEpisodes','fontweight','normal')
subplot(2,3,3)
    for a = 1:6
        PlotPETHNormAxesData(UPStateRateParticipationPerCellRankGroup.AllEpAlignedER{1,a},gca,col(a,:));
    end
    set(gca,'YScale','log')
    title('E UP Rates SWSPackets','fontweight','normal')
subplot(2,3,4)
    for a = 1:6
        PlotPETHNormAxesData(UPStateRateParticipationPerCellRankGroup.AllEpAlignedIR{3,a},gca,col(a,:));
    end
    set(gca,'YScale','log')
    title('I UP Rates over Sleep','fontweight','normal')
subplot(2,3,5)
    for a = 1:6
        PlotPETHNormAxesData(UPStateRateParticipationPerCellRankGroup.AllEpAlignedIR{2,a},gca,col(a,:));
    end
    set(gca,'YScale','log')
    title('I UP Rates SWSEpisodes','fontweight','normal')
subplot(2,3,6)
    for a = 1:6
        PlotPETHNormAxesData(UPStateRateParticipationPerCellRankGroup.AllEpAlignedIR{1,a},gca,col(a,:));
    end
    set(gca,'YScale','log')
    title('I UP Rates SWSPackets','fontweight','normal')
AboveTitle('UP state Firing rates by Rate Group')

%% Participation
h(end+1)  = figure('position',[2 2 750 650],'name','UPRateGroupPartic');
subplot(2,3,1)
    for a = 1:6
        PlotPETHNormAxesData(UPStateRateParticipationPerCellRankGroup.AllEpAlignedEP{3,a},gca,col(a,:));
    end
    set(gca,'YScale','log')
    title('E UP Partic over Sleep','fontweight','normal')
subplot(2,3,2)
    for a = 1:6
        PlotPETHNormAxesData(UPStateRateParticipationPerCellRankGroup.AllEpAlignedEP{2,a},gca,col(a,:));
    end
    set(gca,'YScale','log')
    title('E UP Partic SWSEpisodes','fontweight','normal')
subplot(2,3,3)
    for a = 1:6
        PlotPETHNormAxesData(UPStateRateParticipationPerCellRankGroup.AllEpAlignedEP{1,a},gca,col(a,:));
    end
    set(gca,'YScale','log')
    title('E UP Partic SWSPackets','fontweight','normal')
subplot(2,3,4)
    for a = 1:6
        PlotPETHNormAxesData(UPStateRateParticipationPerCellRankGroup.AllEpAlignedIP{3,a},gca,col(a,:));
    end
    set(gca,'YScale','log')
    title('I UP Partic over Sleep','fontweight','normal')
subplot(2,3,5)
    for a = 1:6
        PlotPETHNormAxesData(UPStateRateParticipationPerCellRankGroup.AllEpAlignedIP{2,a},gca,col(a,:));
    end
    set(gca,'YScale','log')
    title('I UP Partic SWSEpisodes','fontweight','normal')
subplot(2,3,6)
    for a = 1:6
        PlotPETHNormAxesData(UPStateRateParticipationPerCellRankGroup.AllEpAlignedIP{1,a},gca,col(a,:));
    end
    set(gca,'YScale','log')
    title('I UP Partic SWSPackets','fontweight','normal')
AboveTitle('UP state participation by Rate Group')
    
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Summaries/',h)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Summaries/',h,'png')
