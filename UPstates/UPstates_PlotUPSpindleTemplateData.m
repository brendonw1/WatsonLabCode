function UPstates_PlotUPSpindleTemplateData(UPSpindleTemplateData)

if ~exist('UPSpindleTemplateData','var')
    UPSpindleTemplateData = UPstates_GatherUPSpindleTemplateData;
end
v2struct(UPSpindleTemplateData)%extracts field names as variables (necessary for labeling in fcns below)

%% Start plotting
h = [];

%% Basic stats
texttext = {['N Rats = ' num2str(NumRats)];...
    ['N Sesssions = ' num2str(NumSessions)];...
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
set(h(end),'name','BasicCounts')

%% Fig comparing CORRELATION of events to templates, averaged per session. 
% h(end+1) = figure;
% subplot(2,2,1)
% hax = plot_nanmeanSD_bars(mpc_uVu_r,mpc_nsuVu_r,mpc_suVu_r,mpc_psuVu_r,mpc_esuVu_r,mpc_lsuVu_r,mpc_sVu_r);
% title(hax,'UP Template (Mean +- SD)')
% set(hax,'XTick',[1:7])
% set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'EarlySU';'LateSU';'Spinds'})
% subplot(2,2,2)
% hax = plot_nanmeanSD_bars(mpc_uVs_r,mpc_nsuVs_r,mpc_suVs_r,mpc_psuVs_r,mpc_esuVs_r,mpc_lsuVs_r,mpc_sVs_r);
% title(hax,'Spindle Template (Mean +- SD)')
% set(hax,'XTick',[1:7])
% set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'EarlyPSU';'LatePSU';'Spinds'})
% subplot(2,2,3)
% hax = plot_nanmeanSD_bars(mpc_uVsu_r,mpc_nsuVsu_r,mpc_suVsu_r,mpc_psuVsu_r,mpc_esuVsu_r,mpc_lsuVsu_r,mpc_sVsu_r);
% title(hax,'UP Spindle Template (Mean +- SD)')
% set(hax,'XTick',[1:7])
% set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'EarlySU';'LateSU';'Spinds'})
% 
% set(h(end),'name','EventVsTemplateBars')

%% Fig comparing CORRELATION of events to templates, averaged per session. 
h(end+1) = figure;
subplot(2,2,1)
hax = plot_nanmeanSD_bars(mpc_uVu_r,mpc_nsuVu_r,mpc_suVu_r,mpc_psuVu_r,mpc_sVu_r);
title(hax,'UP MPC Timing Template (Mean +- SD)')
set(hax,'XTick',[1:5])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'Spinds'})
subplot(2,2,2)
hax = plot_nanmeanSD_bars(mpc_uVs_r,mpc_nsuVs_r,mpc_suVs_r,mpc_psuVs_r,mpc_sVs_r);
title(hax,'Spindle MPC Timing Template (Mean +- SD)')
set(hax,'XTick',[1:5])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'Spinds'})
subplot(2,2,3)
hax = plot_nanmeanSD_bars(mpc_uVsu_r,mpc_nsuVsu_r,mpc_suVsu_r,mpc_psuVsu_r,mpc_sVsu_r);
title(hax,'UP Spindle MPC Timing Template (Mean +- SD)')
set(hax,'XTick',[1:5])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'Spinds'})

set(h(end),'name','MPCEventVsTemplateBars5')

%% Fig comparing CORRELATION of events to templates, averaged per session. 
h(end+1) = figure;
subplot(2,2,1)
hax = plot_nanmeanSD_bars(mpc_uVu_r./mpc_uVu_r,mpc_nsuVu_r./mpc_uVu_r,mpc_suVu_r./mpc_uVu_r,mpc_psuVu_r./mpc_uVu_r,mpc_sVu_r./mpc_uVu_r);
title(hax,'UP MPC Timing Template (Mean +- SD)')
set(hax,'XTick',[1:5])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'Spinds'})
subplot(2,2,2)
hax = plot_nanmeanSD_bars(mpc_uVs_r./mpc_sVs_r,mpc_nsuVs_r./mpc_sVs_r,mpc_suVs_r./mpc_sVs_r,mpc_psuVs_r./mpc_sVs_r,mpc_sVs_r./mpc_sVs_r);
title(hax,'Spindle MPC Timing Template (Mean +- SD)')
set(hax,'XTick',[1:5])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'Spinds'})
subplot(2,2,3)
hax = plot_nanmeanSD_bars(mpc_uVsu_r./mpc_suVsu_r,mpc_nsuVsu_r./mpc_suVsu_r,mpc_suVsu_r./mpc_suVsu_r,mpc_psuVsu_r./mpc_suVsu_r,mpc_sVsu_r./mpc_suVsu_r);
title(hax,'UP Spindle MPC Timing Template (Mean +- SD)')
set(hax,'XTick',[1:5])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'Spinds'})
AboveTitle('Normalized to coherence of event type creating template')
set(h(end),'name','MPCNormdEventVsTemplateBars5')

%% Fig comparing CORRELATION of events to templates, averaged per session. 
h(end+1) = figure;
subplot(2,2,1)
hax = plot_nanmeanSD_bars(mpc_uVu_r,mpc_suVu_r,mpc_sVu_r);
title(hax,'UP MPC Timing Template (Mean +- SD)')
set(hax,'XTick',[1:3])
set(hax,'XTickLabel',{'AllUPs';'SpindU';'Spinds'})
subplot(2,2,2)
hax = plot_nanmeanSD_bars(mpc_uVs_r,mpc_suVs_r,mpc_sVs_r);
title(hax,'Spindle MPC Timing Template (Mean +- SD)')
set(hax,'XTick',[1:3])
set(hax,'XTickLabel',{'AllUPs';'SpindU';'Spinds'})
subplot(2,2,3)
hax = plot_nanmeanSD_bars(mpc_uVsu_r,mpc_suVsu_r,mpc_sVsu_r);
title(hax,'UP Spindle MPC Timing Template (Mean +- SD)')
set(hax,'XTick',[1:3])
set(hax,'XTickLabel',{'AllUPs';'SpindU';'Spinds'})

set(h(end),'name','MPCEventVsTemplateBars3')

%% Fig comparing CORRELATION of events to templates, averaged per session. 
h(end+1) = figure;
subplot(2,2,1)
hax = plot_nanmeanSD_bars(mpc_uVu_r./mpc_uVu_r,mpc_suVu_r./mpc_uVu_r,mpc_sVu_r./mpc_uVu_r);
title(hax,'UP MPC Timing Template (Mean +- SD)')
set(hax,'XTick',[1:3])
set(hax,'XTickLabel',{'AllUPs';'SpindU';'Spinds'})
subplot(2,2,2)
hax = plot_nanmeanSD_bars(mpc_uVs_r./mpc_sVs_r,mpc_suVs_r./mpc_sVs_r,mpc_sVs_r./mpc_sVs_r);
title(hax,'Spindle MPC Timing Template (Mean +- SD)')
set(hax,'XTick',[1:3])
set(hax,'XTickLabel',{'AllUPs';'SpindU';'Spinds'})
subplot(2,2,3)
hax = plot_nanmeanSD_bars(mpc_uVsu_r./mpc_suVsu_r,mpc_suVsu_r./mpc_suVsu_r,mpc_sVsu_r./mpc_suVsu_r);
title(hax,'UP Spindle MPC Timing Template (Mean +- SD)')
set(hax,'XTick',[1:3])
set(hax,'XTickLabel',{'AllUPs';'SpindU';'Spinds'})
AboveTitle('Normalized to coherence of event type creating template')

set(h(end),'name','MPCNormdEventVsTemplateBars3')

%% Fig comparing correlation of TIMING templates to templates, averaged per session. 

h(end+1) = figure;
hax = plot_nanmeanSD_bars(UPTvSpindleT_mpc_R,UPTvUPSpindleT_mpc_R,SpindleTvUPSpindleT_mpc_R);
title(hax,'Mean Timing Template V Template Comparison (Mean +- SD)')
set(hax,'XTick',[1:3])
set(hax,'XTickLabel',{'UPvSpindle';'UPvUPspindle';'SpindlevUPspindle'})

set(h(end),'name','TimingTemplateVsTemplateBars')


%% Fig comparing correlation of RATES of events to templates, averaged per session. 
h(end+1) = figure;
subplot(2,2,1)
hax = plot_nanmeanSD_bars(rate_uVu_r,rate_nsuVu_r,rate_suVu_r,rate_psuVu_r,rate_sVu_r);
title(hax,'UP Rate Template (Mean +- SD)')
set(hax,'XTick',[1:5])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'Spinds'})
subplot(2,2,2)
hax = plot_nanmeanSD_bars(rate_uVs_r,rate_nsuVs_r,rate_suVs_r,rate_psuVs_r,rate_sVs_r);
title(hax,'Spindle Rate Template (Mean +- SD)')
set(hax,'XTick',[1:5])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'Spinds'})
subplot(2,2,3)
hax = plot_nanmeanSD_bars(rate_uVsu_r,rate_nsuVsu_r,rate_suVsu_r,rate_psuVsu_r,rate_sVsu_r);
title(hax,'UP Spindle Rate Template (Mean +- SD)')
set(hax,'XTick',[1:5])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'Spinds'})

set(h(end),'name','RateEventVsTemplateBars5')

%% Fig comparing correlation of RATES OF of events to templates, averaged per session. 
h(end+1) = figure;
subplot(2,2,1)
hax = plot_nanmeanSD_bars(rate_uVu_r./rate_uVu_r,rate_nsuVu_r./rate_uVu_r,rate_suVu_r./rate_uVu_r,rate_psuVu_r./rate_uVu_r,rate_sVu_r./rate_uVu_r);
title(hax,'UP Template (Mean +- SD)')
set(hax,'XTick',[1:5])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'Spinds'})
subplot(2,2,2)
hax = plot_nanmeanSD_bars(rate_uVs_r./rate_sVs_r,rate_nsuVs_r./rate_sVs_r,rate_suVs_r./rate_sVs_r,rate_psuVs_r./rate_sVs_r,rate_sVs_r./rate_sVs_r);
title(hax,'Spindle Template (Mean +- SD)')
set(hax,'XTick',[1:5])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'Spinds'})
subplot(2,2,3)
hax = plot_nanmeanSD_bars(rate_uVsu_r./rate_suVsu_r,rate_nsuVsu_r./rate_suVsu_r,rate_suVsu_r./rate_suVsu_r,rate_psuVsu_r./rate_suVsu_r,rate_sVsu_r./rate_suVsu_r);
title(hax,'UP Spindle Template (Mean +- SD)')
set(hax,'XTick',[1:5])
set(hax,'XTickLabel',{'AllUPs';'Non-SU';'SpindU';'Part-SU';'Spinds'})
AboveTitle('Normalized to coherence of event type creating template')
set(h(end),'name','RateEventVsTemplateBars5')

%% Fig comparing correlation of RATE templates to templates, averaged per session. 

h(end+1) = figure;
hax = plot_nanmeanSD_bars(UPTvSpindleT_rate_R,UPTvUPSpindleT_rate_R,SpindleTvUPSpindleT_rate_R);
title(hax,'Mean Rate Template V Template Comparison (Mean +- SD)')
set(hax,'XTick',[1:3])
set(hax,'XTickLabel',{'UPvSpindle';'UPvUPspindle';'SpindlevUPspindle'})

set(h(end),'name','RateTemplateVsTemplateBars')

%% save figures
od = cd;
savestr = ['SpindleModulationData_',date];

if ~exist('/mnt/brendon4/Dropbox/Data/SpindleModulationData','dir')
    mkdir('/mnt/brendon4/Dropbox/Data/SpindleModulationData')
end
cd(fullfile('/mnt/brendon4/Dropbox/Data/SpindleModulationData', savestr),'SpindleModulationData')
savefigsasname(h,'fig');
cd(od)

