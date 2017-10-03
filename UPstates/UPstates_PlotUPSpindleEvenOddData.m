function UPstates_PlotUPSpindleEvenOddData(UPSpindleEvenOddData)

if ~exist('UPSpindleEvenOddData','var')
    UPSpindleEvenOddData = UPstates_GatherUPSpindleEvenOddData;
end
v2struct(UPSpindleEvenOddData)%extracts field names as variables (necessary for labeling in fcns below)

%% Start plotting
h = [];

%% Basic stats
texttext = {['N Rats = ' num2str(NumRats)];...
    ['N Sesssions = ' num2str(NumSessions)];...
    ['N Sleeps = ' num2str(sum(NumSleeps))];...
    ['N UPs = ' num2str(sum(NumUPs))];...
    ['N Spindles = ' num2str(sum(NumSpindles))];...
    ['N Non-SpindleUPs = ' num2str(sum(NumNonSpindleUPs))];...
    ['N SpindleUPs = ' num2str(sum(NumSpindleUPs))];...
    ['N Partial-SpindleUPs = ' num2str(sum(NumPartSpindleUPs))];...
    ['N Early-SpindleUPs = ' num2str(sum(NumEarlySpindleUPs))];...
    ['N Late-SpindleUPs = ' num2str(sum(NumLateSpindleUPs))];...
};
h(end+1) = figure;    
% Create a uicontrol of type "text"
mTextBox = uicontrol('style','text');
set(mTextBox,'Units','Normalized','Position',[.1 .1 .8 .8])
set(mTextBox,'String',texttext)


%% Fig comparing CORRELATION COEFFS OF POP RATE VECTORS from different classes of events 
h(end+1) = figure;
subplot(2,1,1)
hax = plot_nanmeanSEM_bars(r_ue_rate,r_nue_rate,r_sue_rate,r_pue_rate,r_eue_rate,r_lue_rate,r_se_rate);
title(hax,'Raw')
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'EarlySU';'LateSU';'Spinds'})
subplot(2,1,2)
hax = plot_nanmeanSEM_bars(r_ue_rate./r_ue_rate,r_nue_rate./r_ue_rate,...
    r_sue_rate./r_ue_rate,r_pue_rate./r_ue_rate,r_eue_rate./r_ue_rate,...
    r_lue_rate./r_ue_rate,r_se_rate./r_ue_rate);
title(hax,'Relative to AllUPs within session')
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'EarlySU';'LateSU';'Spinds'})
AboveTitle('Mean+SEMs of Session-wise R values of Rate Vectors')
set(h(end),'name','DatasetUPSpindRateRs')


%% Fig comparing RAW CORRELATION COEFFS OF SEQUENCE TIMING VECTORS from different classes of events 
% % Raw only
h(end+1) = figure;
subplot(2,2,1)
hax = plot_nanmeanSEM_bars(r_ue_seq_firstvstart,r_nue_seq_firstvstart,r_sue_seq_firstvstart,...
    r_pue_seq_firstvstart,r_eue_seq_firstvstart,r_lue_seq_firstvstart,r_se_seq_firstvstart);
title (hax,'CellFirstVEventStart Seqs')
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'EarlySU';'LateSU';'Spinds'})
subplot(2,2,2)
hax = plot_nanmeanSEM_bars(r_ue_seq_firstvpeak,r_nue_seq_firstvpeak,r_sue_seq_firstvpeak,...
    r_pue_seq_firstvpeak,r_eue_seq_firstvpeak,r_lue_seq_firstvpeak,r_se_seq_firstvpeak);
title (hax,'CellFirstVEventPeak Seqs')
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'EarlySU';'LateSU';'Spinds'})

subplot(2,2,3)
hax = plot_nanmeanSEM_bars(r_ue_seq_meanvstart,r_nue_seq_meanvstart,r_sue_seq_meanvstart,...
    r_pue_seq_meanvstart,r_eue_seq_meanvstart,r_lue_seq_meanvstart,r_se_seq_meanvstart);
title (hax,'CellMeanVEventStart Seqs')
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'EarlySU';'LateSU';'Spinds'})

subplot(2,2,4)
hax = plot_nanmeanSEM_bars(r_ue_seq_meanvpeak,r_nue_seq_meanvpeak,r_sue_seq_meanvpeak,...
    r_pue_seq_meanvpeak,r_eue_seq_meanvpeak,r_lue_seq_meanvpeak,r_se_seq_meanvpeak);
title (hax,'CellMeanVEventPeak Seqs')
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'EarlySU';'LateSU';'Spinds'})

AboveTitle('Mean+SEMs of Session-wise sequence Rs - Raw')
set(h(end),'name','DatasetUPSpindSeqRsRaw')

%% Fig comparing CORRELATION COEFFS OF SEQUENCE TIMING VECTORS from different classes of events 
% % Within-session relative to ALLUPS baseline
h(end+1) = figure;
subplot(2,2,1)
hax = plot_nanmeanSEM_bars(r_ue_seq_firstvstart./r_ue_seq_firstvstart,...
    r_nue_seq_firstvstart./r_ue_seq_firstvstart,r_sue_seq_firstvstart./r_ue_seq_firstvstart,...
    r_pue_seq_firstvstart./r_ue_seq_firstvstart,r_eue_seq_firstvstart./r_ue_seq_firstvstart,...
    r_lue_seq_firstvstart./r_ue_seq_firstvstart,r_se_seq_firstvstart./r_ue_seq_firstvstart);
title(hax,'CellFirstVEventStart Seqs')
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'EarlySU';'LateSU';'Spinds'})

subplot(2,2,2)
hax = plot_nanmeanSEM_bars(r_ue_seq_firstvpeak./r_ue_seq_firstvpeak,...
    r_nue_seq_firstvpeak./r_ue_seq_firstvpeak,r_sue_seq_firstvpeak./r_ue_seq_firstvpeak,...
    r_pue_seq_firstvpeak./r_ue_seq_firstvpeak,r_eue_seq_firstvpeak./r_ue_seq_firstvpeak,...
    r_lue_seq_firstvpeak./r_ue_seq_firstvpeak,r_se_seq_firstvpeak./r_ue_seq_firstvpeak);
title (hax,'CellFirstVEventPeak Seqs')
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'EarlySU';'LateSU';'Spinds'})

subplot(2,2,3)
hax = plot_nanmeanSEM_bars(r_ue_seq_meanvstart./r_ue_seq_meanvstart,...
    r_nue_seq_meanvstart./r_ue_seq_meanvstart,r_sue_seq_meanvstart./r_ue_seq_meanvstart,...
    r_pue_seq_meanvstart./r_ue_seq_meanvstart,r_eue_seq_meanvstart./r_ue_seq_meanvstart,...
    r_lue_seq_meanvstart./r_ue_seq_meanvstart,r_se_seq_meanvstart./r_ue_seq_meanvstart);
title(hax,'CellMeanVEventStart Seqs')
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'EarlySU';'LateSU';'Spinds'})

subplot(2,2,4)
hax = plot_nanmeanSEM_bars(r_ue_seq_meanvpeak./r_ue_seq_meanvpeak,...
    r_nue_seq_meanvpeak./r_ue_seq_meanvpeak,r_sue_seq_meanvpeak./r_ue_seq_meanvpeak,...
    r_pue_seq_meanvpeak./r_ue_seq_meanvpeak,r_eue_seq_meanvpeak./r_ue_seq_meanvpeak,...
    r_lue_seq_meanvpeak./r_ue_seq_meanvpeak,r_se_seq_meanvpeak./r_ue_seq_meanvpeak);
title(hax,'CellMeanVEventPeak Seqs')
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'EarlySU';'LateSU';'Spinds'})

AboveTitle('Mean+SEMs of Session-wise sequence Rs - % of AllUP R per sleep sess')
set(h(end),'name','DatasetUPSpindSeqRsRel')


%% Fig comparing DURATIONS of different classes of events 
h(end+1) = figure;
subplot(2,1,1)
hax = plot_nanmeanSEM_bars(AllUPMeanDur,NonSpindleUPMeanDur,SpindleUPMeanDur,PartSpindleUPMeanDur,...
    EarlySpindleUPMeanDur,LateSpindleUPMeanDur,SpindleMeanDur);
title(hax,'Raw')
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'EarlySU';'LateSU';'Spinds'})
subplot(2,1,2)
hax = plot_nanmeanSEM_bars(AllUPMeanDur./AllUPMeanDur,NonSpindleUPMeanDur./AllUPMeanDur,...
    SpindleUPMeanDur./AllUPMeanDur,PartSpindleUPMeanDur./AllUPMeanDur,...
    EarlySpindleUPMeanDur./AllUPMeanDur,LateSpindleUPMeanDur./AllUPMeanDur,...
    SpindleMeanDur./AllUPMeanDur);
title(hax,'Relative to AllUPs within session')
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'EarlySU';'LateSU';'Spinds'})
AboveTitle('Mean+SEMs of Session-wise Event Duration Means')
set(h(end),'name','DatasetUPSpindDurs')

%% Fig comparing RAW#PARTICIPANTS of different classes of events 
h(end+1) = figure;
subplot(2,1,1)
hax = plot_nanmeanSEM_bars(AllUPMeanCellCt,NonSpindleUPMeanCellCt,SpindleUPMeanCellCt,PartSpindleUPMeanCellCt,...
    EarlySpindleUPMeanCellCt,LateSpindleUPMeanCellCt,SpindleMeanCellCt);
title(hax,'Raw')
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'EarlySU';'LateSU';'Spinds'})
subplot(2,1,2)
hax = plot_nanmeanSEM_bars(AllUPMeanCellCt./AllUPMeanCellCt,NonSpindleUPMeanCellCt./AllUPMeanCellCt,...
    SpindleUPMeanCellCt./AllUPMeanCellCt,PartSpindleUPMeanCellCt./AllUPMeanCellCt,...
    EarlySpindleUPMeanCellCt./AllUPMeanCellCt,LateSpindleUPMeanCellCt./AllUPMeanCellCt,...
    SpindleMeanCellCt./AllUPMeanCellCt);
title(hax,'Relative to AllUPs within session')
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'EarlySU';'LateSU';'Spinds'})
AboveTitle('Mean+SEMs of Session-wise Event #Particip Means')
set(h(end),'name','DatasetUPSpindParticips')

%% Fig comparing MEAN RATES of different classes of events 
h(end+1) = figure;
subplot(2,1,1)
hax = plot_nanmeanSEM_bars(AllUPMeanRate,NonSpindleUPMeanRate,SpindleUPMeanRate,PartSpindleUPMeanRate,...
    EarlySpindleUPMeanRate,LateSpindleUPMeanRate,SpindleMeanRate);
title(hax,'Raw')
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'EarlySU';'LateSU';'Spinds'})
subplot(2,1,2)
hax = plot_nanmeanSEM_bars(AllUPMeanRate./AllUPMeanRate,NonSpindleUPMeanRate./AllUPMeanRate,...
    SpindleUPMeanRate./AllUPMeanRate,PartSpindleUPMeanRate./AllUPMeanRate,...
    EarlySpindleUPMeanRate./AllUPMeanRate,LateSpindleUPMeanRate./AllUPMeanRate,...
    SpindleMeanRate./AllUPMeanRate);
title(hax,'Relative to AllUPs within session')
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'EarlySU';'LateSU';'Spinds'})
AboveTitle('Mean+SEMs of Session-wise Event Rate Means')
set(h(end),'name','DatasetUPSpindRates')

%% Save figs 
od = cd;
savedir = '/mnt/brendon4/Dropbox/Data/SpindleUPDatasetData/EvenOdd';
if ~exist(savedir,'dir')
    mkdir(savedir)
end
cd(savedir)
savefigsasname(h,'fig');
% close(h)
cd(od)

