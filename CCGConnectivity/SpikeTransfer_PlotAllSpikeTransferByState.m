function SpikeTransfer_PlotAllSpikeTransferByState

SynapseByStateAll = SpikeTransfer_GatherAllSpikeTransferByState;
v2struct(SynapseByStateAll);%unpacks StateNames, ERatios, IRatios, EDiffs, IDiffs


goodstates = 1:9;% as of 9/30/15 this is     'WakeSleepCycles','WSWake','WSSleep','SWS','REM','FSWS','LSWS','Spindles','UPstates'
labels = StateNames(goodstates);

% Plot ratiometric spike transfer
h = figure('position',[2 2 900 800],'name','SpikeTranferRatioByState');
subplot(2,1,1)
[hax,~,~,siax] = plot_stats_bars(log10(ERatios(:,goodstates)),'central','median','variance','sem');
axes(hax)
set(hax,'XTickLabels',labels)
xticklabel_rotate([],60)
title('ESynapses')
for a = 1:2
    axes(siax(a))
end

subplot(2,1,2)
[hax,~,~,siax] = plot_stats_bars(log10(IRatios(:,goodstates)),'central','median','variance','sem');
axes(hax)
set(hax,'XTickLabels',labels)
xticklabel_rotate([],60)
title('ISynapses')
for a = 1:2
    axes(siax(a))
end
AboveTitle('Ratio-based Spike Transfer')

% Plot difference-based spike transfer
h(end+1) = figure('position',[2 2 900 800],'name','SpikeTranferRatioByState');
subplot(2,1,1)
[hax,~,~,siax] = plot_stats_bars(EDiffs(:,goodstates),'central','median','variance','sem');
axes(hax)
set(hax,'XTickLabels',labels)
xticklabel_rotate([],60)
title('ESynapses')
for a = 1:2
    axes(siax(a))
end
AboveTitle('Difference-based Spike Transfer')

subplot(2,1,2)
[hax,~,~,siax] = plot_stats_bars(IDiffs(:,goodstates),'central','median','variance','sem');
axes(hax)
set(hax,'XTickLabels',labels)
xticklabel_rotate([],60)
title('ISynapses')
for a = 1:2
    axes(siax(a))
end

%% save
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/SpikeTransfer/ByState',h)

