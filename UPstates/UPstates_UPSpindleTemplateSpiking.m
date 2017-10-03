function h = UPstates_UPSpindleTemplateSpiking(basepath,basename)

if ~exist('basepath','var')
    [basepath,basename,~] = fileparts(cd);
    basepath = fullfile(basepath,basename);
end
cd(basepath)

%% Load ups, get starts, stops
t = load([basename, '_UPDOWNIntervals']);
UPints = t.UPInts;
UPstarts = Start(UPints)/10000;
UPstops = End(UPints)/10000;

%% Load Spindles, get starts, stops
load(fullfile(basepath,'Spindles','SpindleData.mat'),'SpindleData')
normspindles = SpindleData.normspindles;
sp_starts = normspindles(:,1);
sp_stops = normspindles(:,3);

%% Load SpikeStats
t = load(fullfile('Spindles',[basename '_SpindleSpikeStats.mat']));
sisse = t.isse;

t = load(fullfile('UPstates',[basename '_UPSpikeStatsE.mat']));
uisse = t.isse;

SpindleUPEvents = FindUPsWithSpindles(basepath,basename);
v2struct(SpindleUPEvents); %extracts [SpindleUPs,NoSpindleUPs,PartialSpindleUPs,EarlyStartUPs,LateStartUPs,UpPercents,UpSpindleMsCounts] 
Suisse = SpikeStatsIntervalSubset(uisse,SpindleUPs);
Nuisse = SpikeStatsIntervalSubset(uisse,NoSpindleUPs);
Puisse = SpikeStatsIntervalSubset(uisse,PartialSpindleUPs);
Euisse = SpikeStatsIntervalSubset(uisse,EarlyStartUPs);
Luisse = SpikeStatsIntervalSubset(uisse,LateStartUPs);

    
%% Get templates from average
%UP state mean rate-based template
Templates.UPRate = nanmean(uisse.spkrates,1);
%Spindle mean timing-based template
Templates.SpRate= nanmean(sisse.spkrates,1);
%Spindle-UP state mean timing-based template
Templates.SpUPRate = nanmean(Suisse.spkrates,1);

%UP state mean timing-based template
Templates.UPMeanVPeakCap = nanmean(uisse.meanspktsfrompeak_capped,1);
Templates.UPMeanVStartCap = nanmean(uisse.meanspktsfromstart_capped,1);
Templates.UPMeanVPeak = nanmean(uisse.meanspktsfrompeak,1);
Templates.UPMeanVStart = nanmean(uisse.meanspktsfromstart,1);
Templates.UPFirstVPeak = nanmean(uisse.firstspktsfrompeak,1);
Templates.UPFirstVStart = nanmean(uisse.firstspktsfromstart,1);
%Spindle mean timing-based template
Templates.SpMeanVPeakCap= nanmean(sisse.meanspktsfrompeak_capped,1);
Templates.SpMeanVStartCap = nanmean(sisse.meanspktsfromstart_capped,1);
Templates.SpMeanVPeak = nanmean(sisse.meanspktsfrompeak,1);
Templates.SpMeanVStart = nanmean(sisse.meanspktsfromstart,1);
Templates.SpFirstVPeak = nanmean(sisse.firstspktsfrompeak,1);
Templates.SpFirstVStart = nanmean(sisse.firstspktsfromstart,1);
%Spindle-UP state mean timing-based template
Templates.SpUPMeanVPeakCap = nanmean(Suisse.meanspktsfrompeak_capped,1);
Templates.SpUPMeanVStartCap = nanmean(Suisse.meanspktsfromstart_capped,1);
Templates.SpUPMeanVPeak = nanmean(Suisse.meanspktsfrompeak,1);
Templates.SpUPMeanVStart = nanmean(Suisse.meanspktsfromstart,1);
Templates.SpUPFirstVPeak = nanmean(Suisse.firstspktsfrompeak,1);
Templates.SpUPFirstVStart = nanmean(Suisse.firstspktsfromstart,1);

%% Template to template comparisons
[UPTvSpindleT_mpc_fit,UPTvSpindleT_mpc_R,UPTvSpindleT_mpc_P] =  RegressAndFindR(Templates.UPMeanVPeakCap,Templates.SpMeanVPeakCap);
[UPTvSpindleT_rate_fit,UPTvSpindleT_rate_R,UPTvSpindleT_rate_P] =  RegressAndFindR(Templates.UPRate,Templates.SpRate);

if ~isempty(SpindleUPs)
    [UPTvUPSpindleT_mpc_fit,UPTvUPSpindleT_mpc_R,UPTvUPSpindleT_mpc_P] =  RegressAndFindR(Templates.UPMeanVPeakCap,Templates.SpUPMeanVPeakCap);
    [UPTvUPSpindleT_rate_fit,UPTvUPSpindleT_rate_R,UPTvUPSpindleT_rate_P] =  RegressAndFindR(Templates.UPRate,Templates.SpUPRate);

    
    [SpindleTvUPSpindleT_mpc_fit,SpindleTvUPSpindleT_mpc_R,SpindleTvUPSpindleT_mpc_P] =  RegressAndFindR(Templates.SpMeanVPeakCap,Templates.SpUPMeanVPeakCap);
    [SpindleTvUPSpindleT_rate_fit,SpindleTvUPSpindleT_rate_R,SpindleTvUPSpindleT_rate_P] =  RegressAndFindR(Templates.SpRate,Templates.SpRate);
else
%     UPTvUPSpindleTfit = [];
%     UPTvUPSpindleTR = [];
%     UPTvUPSpindleTP = [];
%     SpindleTvUPSpindleTfit = [];
%     SpindleTvUPSpindleTR = []; 
%     SpindleTvUPSpindleTP = [];
    UPTvUPSpindleT_mpc_fit = nan;
    UPTvUPSpindleT_mpc_R = nan;
    UPTvUPSpindleT_mpc_P = nan;
    SpindleTvUPSpindleT_mpc_fit = nan;
    SpindleTvUPSpindleT_mpc_R = nan; 
    SpindleTvUPSpindleT_mpc_P = nan;
    UPTvUPSpindleT_rate_fit = nan;
    UPTvUPSpindleT_rate_R = nan;
    UPTvUPSpindleT_rate_P = nan;
    SpindleTvUPSpindleT_rate_fit = nan;
    SpindleTvUPSpindleT_rate_R = nan; 
    SpindleTvUPSpindleT_rate_P = nan;
end

%% Calculate similarities of eachindividual type of event with each template
% Rates
[rate_uVu_r,rate_uVu_p] = SequenceVsTemplateCorr(uisse.spkrates,Templates.UPRate);
[rate_nsuVu_r,rate_nsuVu_p] = SequenceVsTemplateCorr(Nuisse.spkrates,Templates.UPRate);
[rate_suVu_r,rate_suVu_p] = SequenceVsTemplateCorr(Suisse.spkrates,Templates.UPRate);
[rate_psuVu_r,rate_psuVu_p] = SequenceVsTemplateCorr(Puisse.spkrates,Templates.UPRate);
[rate_esuVu_r,rate_esuVu_p] = SequenceVsTemplateCorr(Euisse.spkrates,Templates.UPRate);
[rate_lsuVu_r,rate_lsuVu_p] = SequenceVsTemplateCorr(Luisse.spkrates,Templates.UPRate);
[rate_sVu_r,rate_sVu_p] = SequenceVsTemplateCorr(sisse.spkrates,Templates.UPRate);

[rate_uVs_r,rate_uVs_p] = SequenceVsTemplateCorr(uisse.spkrates,Templates.SpRate);
[rate_nsuVs_r,rate_nsuVs_p] = SequenceVsTemplateCorr(Nuisse.spkrates,Templates.SpRate);
[rate_suVs_r,rate_suVs_p] = SequenceVsTemplateCorr(Suisse.spkrates,Templates.SpRate);
[rate_psuVs_r,rate_psuVs_p] = SequenceVsTemplateCorr(Puisse.spkrates,Templates.SpRate);
[rate_esuVs_r,rate_esuVs_p] = SequenceVsTemplateCorr(Euisse.spkrates,Templates.SpRate);
[rate_lsuVs_r,rate_lsuVs_p] = SequenceVsTemplateCorr(Luisse.spkrates,Templates.SpRate);
[rate_sVs_r,rate_sVs_p] = SequenceVsTemplateCorr(sisse.spkrates,Templates.SpRate);

[rate_uVsu_r,rate_uVsu_p] = SequenceVsTemplateCorr(uisse.spkrates,Templates.SpUPRate);
[rate_nsuVsu_r,rate_nsuVsu_p] = SequenceVsTemplateCorr(Nuisse.spkrates,Templates.SpUPRate);
[rate_suVsu_r,rate_suVsu_p] = SequenceVsTemplateCorr(Suisse.spkrates,Templates.SpUPRate);
[rate_psuVsu_r,rate_psuVsu_p] = SequenceVsTemplateCorr(Puisse.spkrates,Templates.SpUPRate);
[rate_esuVsu_r,rate_esuVsu_p] = SequenceVsTemplateCorr(Euisse.spkrates,Templates.SpUPRate);
[rate_lsuVsu_r,rate_lsuVsu_p] = SequenceVsTemplateCorr(Luisse.spkrates,Templates.SpUPRate);
[rate_sVsu_r,rate_sVsu_p] = SequenceVsTemplateCorr(sisse.spkrates,Templates.SpUPRate);

% Mean vs Peak (capped)
[mpc_uVu_r,mpc_uVu_p] = SequenceVsTemplateCorr(uisse.meanspktsfrompeak_capped,Templates.UPMeanVPeakCap);
[mpc_nsuVu_r,mpc_nsuVu_p] = SequenceVsTemplateCorr(Nuisse.meanspktsfrompeak_capped,Templates.UPMeanVPeakCap);
[mpc_suVu_r,mpc_suVu_p] = SequenceVsTemplateCorr(Suisse.meanspktsfrompeak_capped,Templates.UPMeanVPeakCap);
[mpc_psuVu_r,mpc_psuVu_p] = SequenceVsTemplateCorr(Puisse.meanspktsfrompeak_capped,Templates.UPMeanVPeakCap);
[mpc_esuVu_r,mpc_esuVu_p] = SequenceVsTemplateCorr(Euisse.meanspktsfrompeak_capped,Templates.UPMeanVPeakCap);
[mpc_lsuVu_r,mpc_lsuVu_p] = SequenceVsTemplateCorr(Luisse.meanspktsfrompeak_capped,Templates.UPMeanVPeakCap);
[mpc_sVu_r,mpc_sVu_p] = SequenceVsTemplateCorr(sisse.meanspktsfrompeak_capped,Templates.UPMeanVPeakCap);

[mpc_uVs_r,mpc_uVs_p] = SequenceVsTemplateCorr(uisse.meanspktsfrompeak_capped,Templates.SpMeanVPeakCap);
[mpc_nsuVs_r,mpc_nsuVs_p] = SequenceVsTemplateCorr(Nuisse.meanspktsfrompeak_capped,Templates.SpMeanVPeakCap);
[mpc_suVs_r,mpc_suVs_p] = SequenceVsTemplateCorr(Suisse.meanspktsfrompeak_capped,Templates.SpMeanVPeakCap);
[mpc_psuVs_r,mpc_psuVs_p] = SequenceVsTemplateCorr(Puisse.meanspktsfrompeak_capped,Templates.SpMeanVPeakCap);
[mpc_esuVs_r,mpc_esuVs_p] = SequenceVsTemplateCorr(Euisse.meanspktsfrompeak_capped,Templates.SpMeanVPeakCap);
[mpc_lsuVs_r,mpc_lsuVs_p] = SequenceVsTemplateCorr(Luisse.meanspktsfrompeak_capped,Templates.SpMeanVPeakCap);
[mpc_sVs_r,mpc_sVs_p] = SequenceVsTemplateCorr(sisse.meanspktsfrompeak_capped,Templates.SpMeanVPeakCap);

[mpc_uVsu_r,mpc_uVsu_p] = SequenceVsTemplateCorr(uisse.meanspktsfrompeak_capped,Templates.SpUPMeanVPeakCap);
[mpc_nsuVsu_r,mpc_nsuVsu_p] = SequenceVsTemplateCorr(Nuisse.meanspktsfrompeak_capped,Templates.SpUPMeanVPeakCap);
[mpc_suVsu_r,mpc_suVsu_p] = SequenceVsTemplateCorr(Suisse.meanspktsfrompeak_capped,Templates.SpUPMeanVPeakCap);
[mpc_psuVsu_r,mpc_psuVsu_p] = SequenceVsTemplateCorr(Puisse.meanspktsfrompeak_capped,Templates.SpUPMeanVPeakCap);
[mpc_esuVsu_r,mpc_esuVsu_p] = SequenceVsTemplateCorr(Euisse.meanspktsfrompeak_capped,Templates.SpUPMeanVPeakCap);
[mpc_lsuVsu_r,mpc_lsuVsu_p] = SequenceVsTemplateCorr(Luisse.meanspktsfrompeak_capped,Templates.SpUPMeanVPeakCap);
[mpc_sVsu_r,mpc_sVsu_p] = SequenceVsTemplateCorr(sisse.meanspktsfrompeak_capped,Templates.SpUPMeanVPeakCap);

% %First vs Peak
% [fp_uVu_r,fp_uVu_p] = SequenceVsTemplateCorr(uisse.firstspktsfrompeak,Templates.UPFirstVPeak);
% [fp_nsuVu_r,fp_nsuVu_p] = SequenceVsTemplateCorr(Nuisse.firstspktsfrompeak,Templates.UPFirstVPeak);
% [fp_suVu_r,fp_suVu_p] = SequenceVsTemplateCorr(Suisse.firstspktsfrompeak,Templates.UPFirstVPeak);
% [fp_psuVu_r,fp_psuVu_p] = SequenceVsTemplateCorr(Puisse.firstspktsfrompeak,Templates.UPFirstVPeak);
% [fp_esuVu_r,fp_esuVu_p] = SequenceVsTemplateCorr(Euisse.firstspktsfrompeak,Templates.UPFirstVPeak);
% [fp_lsuVu_r,fp_lsuVu_p] = SequenceVsTemplateCorr(Luisse.firstspktsfrompeak,Templates.UPFirstVPeak);
% [fp_sVu_r,fp_sVu_p] = SequenceVsTemplateCorr(sisse.firstspktsfrompeak,Templates.UPFirstVPeak);
% 
% [fp_uVs_r,fp_uVs_p] = SequenceVsTemplateCorr(uisse.firstspktsfrompeak,Templates.SpFirstVPeak);
% [fp_nsuVs_r,fp_nsuVs_p] = SequenceVsTemplateCorr(Nuisse.firstspktsfrompeak,Templates.SpFirstVPeak);
% [fp_suVs_r,fp_suVs_p] = SequenceVsTemplateCorr(Suisse.firstspktsfrompeak,Templates.SpFirstVPeak);
% [fp_psuVs_r,fp_psuVs_p] = SequenceVsTemplateCorr(Puisse.firstspktsfrompeak,Templates.SpFirstVPeak);
% [fp_esuVs_r,fp_esuVs_p] = SequenceVsTemplateCorr(Euisse.firstspktsfrompeak,Templates.SpFirstVPeak);
% [fp_lsuVs_r,fp_lsuVs_p] = SequenceVsTemplateCorr(Luisse.firstspktsfrompeak,Templates.SpFirstVPeak);
% [fp_sVs_r,fp_sVs_p] = SequenceVsTemplateCorr(sisse.firstspktsfrompeak,Templates.SpFirstVPeak);
% 
% [fp_uVsu_r,fp_uVsu_p] = SequenceVsTemplateCorr(uisse.firstspktsfrompeak,Templates.SpUPFirstVPeak);
% [fp_nsuVsu_r,fp_nsuVsu_p] = SequenceVsTemplateCorr(Nuisse.firstspktsfrompeak,Templates.SpUPFirstVPeak);
% [fp_suVsu_r,fp_suVsu_p] = SequenceVsTemplateCorr(Suisse.firstspktsfrompeak,Templates.SpUPFirstVPeak);
% [fp_psuVsu_r,fp_psuVsu_p] = SequenceVsTemplateCorr(Puisse.firstspktsfrompeak,Templates.SpUPFirstVPeak);
% [fp_esuVsu_r,fp_esuVsu_p] = SequenceVsTemplateCorr(Euisse.firstspktsfrompeak,Templates.SpUPFirstVPeak);
% [fp_lsuVsu_r,fp_lsuVsu_p] = SequenceVsTemplateCorr(Luisse.firstspktsfrompeak,Templates.SpUPFirstVPeak);
% [fp_sVsu_r,fp_sVsu_p] = SequenceVsTemplateCorr(sisse.firstspktsfrompeak,Templates.SpUPFirstVPeak);

% gather and save rs and ps
SpindleUPTemplateRsAndPs = v2struct(UPTvSpindleT_mpc_R,UPTvSpindleT_mpc_P,...
    UPTvUPSpindleT_mpc_R,UPTvUPSpindleT_mpc_P, SpindleTvUPSpindleT_mpc_R,SpindleTvUPSpindleT_mpc_P,...
    UPTvSpindleT_rate_R,UPTvSpindleT_rate_P,...
    UPTvUPSpindleT_rate_R,UPTvUPSpindleT_rate_P, SpindleTvUPSpindleT_rate_R,SpindleTvUPSpindleT_rate_P,...
    rate_uVu_r,rate_uVu_p,rate_nsuVu_r,rate_nsuVu_p,rate_suVu_r,rate_suVu_p,...
    rate_psuVu_r,rate_psuVu_p,rate_esuVu_r,rate_esuVu_p,rate_lsuVu_r,rate_lsuVu_p,...
    rate_sVu_r,rate_sVu_p,rate_uVs_r,rate_uVs_p,rate_nsuVs_r,rate_nsuVs_p,...
    rate_suVs_r,rate_suVs_p,rate_psuVs_r,rate_psuVs_p,rate_esuVs_r,rate_esuVs_p,...
    rate_lsuVs_r,rate_lsuVs_p,rate_sVs_r,rate_sVs_p,rate_uVsu_r,rate_uVsu_p,...
    rate_nsuVsu_r,rate_nsuVsu_p,rate_suVsu_r,rate_suVsu_p,rate_psuVsu_r,rate_psuVsu_p,...
    rate_esuVsu_r,rate_esuVsu_p,rate_lsuVsu_r,rate_lsuVsu_p,rate_sVsu_r,rate_sVsu_p,...
    mpc_uVu_r,mpc_uVu_p,mpc_nsuVu_r,mpc_nsuVu_p,mpc_suVu_r,mpc_suVu_p,...
    mpc_psuVu_r,mpc_psuVu_p,mpc_esuVu_r,mpc_esuVu_p,mpc_lsuVu_r,mpc_lsuVu_p,...
    mpc_sVu_r,mpc_sVu_p,mpc_uVs_r,mpc_uVs_p,mpc_nsuVs_r,mpc_nsuVs_p,...
    mpc_suVs_r,mpc_suVs_p,mpc_psuVs_r,mpc_psuVs_p,mpc_esuVs_r,mpc_esuVs_p,...
    mpc_lsuVs_r,mpc_lsuVs_p,mpc_sVs_r,mpc_sVs_p,mpc_uVsu_r,mpc_uVsu_p,...
    mpc_nsuVsu_r,mpc_nsuVsu_p,mpc_suVsu_r,mpc_suVsu_p,mpc_psuVsu_r,mpc_psuVsu_p,...
    mpc_esuVsu_r,mpc_esuVsu_p,mpc_lsuVsu_r,mpc_lsuVsu_p,mpc_sVsu_r,mpc_sVsu_p);
save(fullfile('UPstates',[basename 'SpindleUPTemplateRsAndPs.mat']),'SpindleUPTemplateRsAndPs')
save(fullfile('UPstates',[basename 'SpindleUPMeanBasedTemplates.mat']),'Templates')

%% initialize handles
h = [];

%% Plot rate templates against each other
h(end+1) = figure;
subplot(2,2,1);
plot(Templates.UPRate,Templates.SpRate,'.k');
hold on;
plot(Templates.UPRate,UPTvSpindleT_rate_fit,'r')
xl = get(gca,'xlim');
yl = get(gca,'ylim');
text(xl(1),0.9*(yl(2)-yl(1))+yl(1),['r=' num2str(UPTvSpindleT_rate_R) '.p=' num2str(UPTvSpindleT_rate_P)])
title('Spindle Templ v UP Templ');
xlabel('UP Template Rates')
ylabel('Spindle Template Rates')
subplot(2,2,2);
if isempty(SpindleUPs)
    text(.25,.5,'No Spindle UPs')
else
    plot(Templates.UPRate,Templates.SpUPRate,'.k');
    hold on;
    plot(Templates.UPRate,UPTvUPSpindleT_rate_fit,'r')
    xl = get(gca,'xlim');
    yl = get(gca,'ylim');
    text(xl(1),0.9*(yl(2)-yl(1))+yl(1),['r=' num2str(UPTvUPSpindleT_rate_R) '.p=' num2str(UPTvUPSpindleT_rate_P)])
    title('Spindle-UP Templ v UP Templ');
    xlabel('UP Template Rates')
    ylabel('Spindle-UP Template Rates')
    subplot(2,2,3);
    plot(Templates.SpRate,Templates.SpUPRate,'.k');
    hold on;
    plot(Templates.SpRate,SpindleTvUPSpindleT_rate_fit,'r')
    xl = get(gca,'xlim');
    yl = get(gca,'ylim');
    text(xl(1),0.9*(yl(2)-yl(1))+yl(1),['r=' num2str(SpindleTvUPSpindleT_rate_R) '.p=' num2str(SpindleTvUPSpindleT_rate_P)])
    title('Spindle-UP Templ vs Spindle Templ');
    xlabel('Spindle Template Rates')
    ylabel('Spindle-UP Template Rates')
    AboveTitle('Rate Templates')
    set(h(end),'name','TemplateComparisons_MeanVPeak')
end

%% Plot timing templates against each other
h(end+1) = figure;
subplot(2,2,1);
plot(Templates.UPMeanVPeakCap,Templates.SpMeanVPeakCap,'.k');
hold on;
plot(Templates.UPMeanVPeakCap,UPTvSpindleT_mpc_fit,'r')
xl = get(gca,'xlim');
yl = get(gca,'ylim');
text(xl(1),0.9*(yl(2)-yl(1))+yl(1),['r=' num2str(UPTvSpindleT_mpc_R) '.p=' num2str(UPTvSpindleT_mpc_P)])
title('Spindle Templ v UP Templ');
xlabel('UP Template Timing')
ylabel('Spindle Template Timing')
subplot(2,2,2);
if isempty(SpindleUPs)
    text(.25,.5,'No Spindle UPs')
else
    plot(Templates.UPMeanVPeakCap,Templates.SpUPMeanVPeakCap,'.k');
    hold on;
    plot(Templates.UPMeanVPeakCap,UPTvUPSpindleT_mpc_fit,'r')
    xl = get(gca,'xlim');
    yl = get(gca,'ylim');
    text(xl(1),0.9*(yl(2)-yl(1))+yl(1),['r=' num2str(UPTvUPSpindleT_mpc_R) '.p=' num2str(UPTvUPSpindleT_mpc_P)])
    title('Spindle-UP Templ v UP Templ');
    xlabel('UP Template Timing')
    ylabel('Spindle-UP Template Timing')
    subplot(2,2,3);
    plot(Templates.SpMeanVPeakCap,Templates.SpUPMeanVPeakCap,'.k');
    hold on;
    plot(Templates.SpMeanVPeakCap,SpindleTvUPSpindleT_mpc_fit,'r')
    xl = get(gca,'xlim');
    yl = get(gca,'ylim');
    text(xl(1),0.9*(yl(2)-yl(1))+yl(1),['r=' num2str(SpindleTvUPSpindleT_mpc_R) '.p=' num2str(SpindleTvUPSpindleT_mpc_P)])
    title('Spindle-UP Templ vs Spindle Templ');
    xlabel('Spindle Template Timing')
    ylabel('Spindle-UP Template Timing')
    AboveTitle('Mean vs Peak Templates')
    set(h(end),'name','TemplateComparisons_MeanVPeak')
end

%% Plot mean sd correlations of each type vs each for rate 
h(end+1) = figure;
subplot(2,2,1);
hax = plot_nanmeanSD_bars(rate_uVu_r,rate_nsuVu_r,rate_suVu_r,rate_psuVu_r,rate_esuVu_r,rate_lsuVu_r,rate_sVu_r);
title(hax,'Event v UP Temp (R)')
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{['AllUPs n=' num2str(length(length(UPints)))];...
    ['Non-SU n=' num2str(length(NoSpindleUPs))];...
    ['SpindU n=' num2str(length(SpindleUPs))];...
    ['Part-SU n=' num2str(length(PartialSpindleUPs))];...
    ['EarlySU n=' num2str(length(EarlyStartUPs))];...
    ['LateSU n=' num2str(length(LateStartUPs))];...
    ['Spinds n=' num2str(length(sp_starts))]})
subplot(2,2,2);
hax = plot_nanmeanSD_bars(rate_uVs_r,rate_nsuVs_r,rate_suVs_r,rate_psuVs_r,rate_esuVs_r,rate_lsuVs_r,rate_sVs_r);
title(hax,'Event v Spindle Temp (R)')
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{['AllUPs n=' num2str(length(length(UPints)))];...
    ['Non-SU n=' num2str(length(NoSpindleUPs))];...
    ['SpindU n=' num2str(length(SpindleUPs))];...
    ['Part-SU n=' num2str(length(PartialSpindleUPs))];...
    ['EarlySU n=' num2str(length(EarlyStartUPs))];...
    ['LateSU n=' num2str(length(LateStartUPs))];...
    ['Spinds n=' num2str(length(sp_starts))]})
subplot(2,2,3);
hax = plot_nanmeanSD_bars(rate_uVsu_r,rate_nsuVsu_r,rate_suVsu_r,rate_psuVsu_r,rate_esuVsu_r,rate_lsuVsu_r,rate_sVsu_r);
title(hax,'Event v SpindleUP Temp (R)')
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{['AllUPs n=' num2str(length(length(UPints)))];...
    ['Non-SU n=' num2str(length(NoSpindleUPs))];...
    ['SpindU n=' num2str(length(SpindleUPs))];...
    ['Part-SU n=' num2str(length(PartialSpindleUPs))];...
    ['EarlySU n=' num2str(length(EarlyStartUPs))];...
    ['LateSU n=' num2str(length(LateStartUPs))];...
    ['Spinds n=' num2str(length(sp_starts))]})
AboveTitle('Rate Events vs Template Rs')
set(h(end),'name','RsOfEvtTypesVsTemplateTypes_MeanVPeakCap')

%% Plot mean sd correlations of each type vs each for mean vs peak cap timing
h(end+1) = figure;
subplot(2,2,1);
hax = plot_nanmeanSD_bars(mpc_uVu_r,mpc_nsuVu_r,mpc_suVu_r,mpc_psuVu_r,mpc_esuVu_r,mpc_lsuVu_r,mpc_sVu_r);
title(hax,'Event v UP Temp (R)')
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{['AllUPs n=' num2str(length(length(UPints)))];...
    ['Non-SU n=' num2str(length(NoSpindleUPs))];...
    ['SpindU n=' num2str(length(SpindleUPs))];...
    ['Part-SU n=' num2str(length(PartialSpindleUPs))];...
    ['EarlySU n=' num2str(length(EarlyStartUPs))];...
    ['LateSU n=' num2str(length(LateStartUPs))];...
    ['Spinds n=' num2str(length(sp_starts))]})
subplot(2,2,2);
hax = plot_nanmeanSD_bars(mpc_uVs_r,mpc_nsuVs_r,mpc_suVs_r,mpc_psuVs_r,mpc_esuVs_r,mpc_lsuVs_r,mpc_sVs_r);
title(hax,'Event v Spindle Temp (R)')
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{['AllUPs n=' num2str(length(length(UPints)))];...
    ['Non-SU n=' num2str(length(NoSpindleUPs))];...
    ['SpindU n=' num2str(length(SpindleUPs))];...
    ['Part-SU n=' num2str(length(PartialSpindleUPs))];...
    ['EarlySU n=' num2str(length(EarlyStartUPs))];...
    ['LateSU n=' num2str(length(LateStartUPs))];...
    ['Spinds n=' num2str(length(sp_starts))]})
subplot(2,2,3);
hax = plot_nanmeanSD_bars(mpc_uVsu_r,mpc_nsuVsu_r,mpc_suVsu_r,mpc_psuVsu_r,mpc_esuVsu_r,mpc_lsuVsu_r,mpc_sVsu_r);
title(hax,'Event v SpindleUP Temp (R)')
set(hax,'XTick',[1:7])
set(hax,'XTickLabel',{['AllUPs n=' num2str(length(length(UPints)))];...
    ['Non-SU n=' num2str(length(NoSpindleUPs))];...
    ['SpindU n=' num2str(length(SpindleUPs))];...
    ['Part-SU n=' num2str(length(PartialSpindleUPs))];...
    ['EarlySU n=' num2str(length(EarlyStartUPs))];...
    ['LateSU n=' num2str(length(LateStartUPs))];...
    ['Spinds n=' num2str(length(sp_starts))]})
AboveTitle('FirstVPeak Events vs Template Rs')
set(h(end),'name','RsOfEvtTypesVsTemplateTypes_Rate')

%% Plot correlation r's over time
% 3 figures
h(end+1) = figure;
subplot(2,2,1)
plot(UPstarts,mpc_uVu_r,'b.')
hold on;
plot(UPstarts,mpc_uVs_r,'g.')
plot(UPstarts,mpc_uVsu_r,'r.')
plot(UPstarts,smooth(mpc_uVu_r,500),'color','b','linewidth',10)
plot(UPstarts,smooth(mpc_uVs_r,500),'color','g','linewidth',10)
plot(UPstarts,smooth(mpc_uVsu_r,500),'color','r','linewidth',10)
title('UP states vs UP(b), Spindle(g), SpindleUP(r)')
set(h(end),'name','UPsVTemplatesRsOverTime')

subplot(2,2,2)
plot(Suisse.intstarts,mpc_suVu_r,'b.')
hold on;
plot(Suisse.intstarts,mpc_suVs_r,'g.')
plot(Suisse.intstarts,mpc_suVsu_r,'r.')
plot(Suisse.intstarts,smooth(mpc_suVu_r,500),'color','b','linewidth',10)
plot(Suisse.intstarts,smooth(mpc_suVs_r,500),'color','g','linewidth',10)
plot(Suisse.intstarts,smooth(mpc_suVsu_r,500),'color','r','linewidth',10)
title('SpindleUPs vs UP(b), Spindle(g), SpindleUP(r)')
set(h(end),'name','SpUPsVTemplatesRsOverTime')

subplot(2,2,3)
plot(sisse.intstarts,mpc_sVu_r,'b.')
hold on;
plot(sisse.intstarts,mpc_sVs_r,'g.')
plot(sisse.intstarts,mpc_sVsu_r,'r.')
plot(sisse.intstarts,smooth(mpc_sVu_r,500),'color','b','linewidth',10)
plot(sisse.intstarts,smooth(mpc_sVs_r,500),'color','g','linewidth',10)
plot(sisse.intstarts,smooth(mpc_sVsu_r,500),'color','r','linewidth',10)
title('Spindles vs UP(b), Spindle(g), SpindleUP(r)')
set(h(end),'name','SpindlesVTemplatesRsOverTime_MeanVPeakCap')

%% Correlate up-wise up correlation vs all kinds of stuff
UPTimeStamp = uisse.intstarts;

h(end+1) = figure;
mcorr_bw(mpc_uVu_r,UPTimeStamp,UPPercents)
AboveTitle('UPvUP vs Time vs Percent')
set(h(end),'name','UPvUPvsTime&SpPct_MeanVPeakCap')

h(end+1) = figure;
mcorr_bw(mpc_uVs_r,UPTimeStamp,UPPercents)
AboveTitle('UPvSpindle vs Time vs Percent')
set(h(end),'name','UPvSpindlevsTime&SpPct_MeanVPeakCap')

h(end+1) = figure;
mcorr_bw(mpc_uVsu_r,UPTimeStamp,UPPercents)
AboveTitle('UPvSpindleUP vs Time vs Percent')
set(h(end),'name','UPvSpUPvsTime&SpPct_MeanVPeakCap')

if ~isempty(SpindleUPs);
    SpUPTimeStamp = Suisse.intstarts;
    SpUPPercents = UPPercents(SpindleUPs);
    h(end+1) = figure;
    mcorr_bw(mpc_suVu_r,SpUPTimeStamp,SpUPPercents)
    AboveTitle('SpindleUPvUP vs Other')
    set(h(end),'name','SpUPvUPvOtherFactors_MeanVPeakCap')

    h(end+1) = figure;
    mcorr_bw(mpc_suVs_r,SpUPTimeStamp,SpUPPercents)
    AboveTitle('SpindleUPvSpindle vs Other')
    set(h(end),'name','SpUPvSpindlevOtherFactors_MeanVPeakCap')

    h(end+1) = figure;
    mcorr_bw(mpc_suVsu_r,SpUPTimeStamp,SpUPPercents)
    AboveTitle('SpindleUPvSpindleUP vs Other')
    set(h(end),'name','SpUPvSpUPvOtherFactors_MeanVPeakCap')
end

%%
UPNearestEvents = FindNearestToUps(basepath,basename);
v2struct(UPNearestEvents); 
% extracts UPTimeSinceLastSleepStart,UPTimeSinceLastSWSStart,...
%         UPTimeSinceLastREMEnd, UPTimeSinceLastSpindle,...
%         UPTimeToNextSleepEnd, UPTimeToNextSWSEnd, UPTimeToNextREMStart,... 
%         UPTimeToNextSpindle, UPTimeToClosestSpindle
SpindleNearestEvents = FindNearestToSpindles(basepath,basename);
v2struct(SpindleNearestEvents);
% extracts SpindleTimeSinceLastSleepStart,...
%         SpindleTimeSinceLastSWSStart,SpindleTimeSinceLastREMEnd,...
%         SpindleTimeToNextSleepEnd, SpindleTimeToNextSWSEnd, SpindleTimeToNextREMStart);


%% Correlate up-wise up correlation vs all kinds of stuff
UPTimeStamp = uisse.intstarts;
h(end+1) = figure;
mcorr_bw(mpc_uVu_r,UPTimeStamp,UPPercents,UPTimeSinceLastSleepStart,UPTimeSinceLastSWSStart,...
        UPTimeSinceLastREMEnd, UPTimeSinceLastSpindle,...
        UPTimeToNextSleepEnd, UPTimeToNextSWSEnd, UPTimeToNextREMStart,... 
        UPTimeToNextSpindle, UPTimeToClosestSpindle)
AboveTitle('UPvUP vs Other')
set(h(end),'name','UPvUPvOtherFactors_MeanVPeakCap')

h(end+1) = figure;
mcorr_bw(mpc_uVs_r,UPTimeStamp,UPPercents,UPTimeSinceLastSleepStart,UPTimeSinceLastSWSStart,...
        UPTimeSinceLastREMEnd, UPTimeSinceLastSpindle,...
        UPTimeToNextSleepEnd, UPTimeToNextSWSEnd, UPTimeToNextREMStart,... 
        UPTimeToNextSpindle, UPTimeToClosestSpindle)
AboveTitle('UPvSpindle vs Other')
set(h(end),'name','UPvSpindlevOtherFactors_MeanVPeakCap')

h(end+1) = figure;
mcorr_bw(mpc_uVsu_r,UPTimeStamp,UPPercents,UPTimeSinceLastSleepStart,UPTimeSinceLastSWSStart,...
        UPTimeSinceLastREMEnd, UPTimeSinceLastSpindle,...
        UPTimeToNextSleepEnd, UPTimeToNextSWSEnd, UPTimeToNextREMStart,... 
        UPTimeToNextSpindle, UPTimeToClosestSpindle)
AboveTitle('UPvSpindleUP vs Other')
set(h(end),'name','UPvSpUPvOtherFactors_MeanVPeakCap')


SpindleTimeStamp = sisse.intstarts;
h(end+1) = figure;
mcorr_bw(mpc_sVu_r,SpindleTimeStamp,SpindleTimeSinceLastSleepStart,...
        SpindleTimeSinceLastSWSStart,SpindleTimeSinceLastREMEnd,...
        SpindleTimeToNextSleepEnd, SpindleTimeToNextSWSEnd, SpindleTimeToNextREMStart);
AboveTitle('SpindlevUP vs Other')
set(h(end),'name','SpindlevUPvOtherFactors_MeanVPeakCap')

h(end+1) = figure;
mcorr_bw(mpc_sVs_r,SpindleTimeStamp,SpindleTimeSinceLastSleepStart,...
        SpindleTimeSinceLastSWSStart,SpindleTimeSinceLastREMEnd,...
        SpindleTimeToNextSleepEnd, SpindleTimeToNextSWSEnd, SpindleTimeToNextREMStart);
AboveTitle('SpindlevSpindle vs Other')
set(h(end),'name','SpindlevSpindlevOtherFactors_MeanVPeakCap')

h(end+1) = figure;
mcorr_bw(mpc_sVsu_r,SpindleTimeStamp,SpindleTimeSinceLastSleepStart,...
        SpindleTimeSinceLastSWSStart,SpindleTimeSinceLastREMEnd,...
        SpindleTimeToNextSleepEnd, SpindleTimeToNextSWSEnd, SpindleTimeToNextREMStart);
AboveTitle('SpindlevSpindleUP vs Other')
set(h(end),'name','SpindlevSpUPvOtherFactors_MeanVPeakCap')




%% save figs
cd(fullfile(basepath,'UPstates'))
if ~exist('SpindleUPTemplateFigs','dir')
    mkdir('SpindleUPTemplateFigs')
end
cd('SpindleUPTemplateFigs')
savefigsasname(h,'fig');
% close(h)
cd(basepath)





% - UPspindle percentage
% - UP vs spindle start time (nan if none)
% - UP vs spindle end time (nan if none)
% - Time to nearest spindle (if non-spindle only)
% - time since sleep start
% - time to sleep end
% - time til next rem
% - time since last rem

% Separate vectors/figure for spindles
% - ?UPspindle percentage
% - ?UP vs spindle start time (nan if none)
% - ?UP vs spindle end time (nan if none)
% - time since sleep start
% - time to sleep end
% - time til next rem
% - time since last rem

%% Repeat for spindle-template correlation

%% Repeat for up-wise correlation

