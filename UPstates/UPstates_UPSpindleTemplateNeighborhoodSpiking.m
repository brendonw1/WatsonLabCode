function h = UPstates_UPSpindleTemplateNeighborhoodSpiking(basepath,basename)

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
% Puisse = SpikeStatsIntervalSubset(uisse,PartialSpindleUPs);
% Euisse = SpikeStatsIntervalSubset(uisse,EarlyStartUPs);
% Luisse = SpikeStatsIntervalSubset(uisse,LateStartUPs);

    
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

% %% Template to template comparisons
% [UPTvSpindleT_mpc_fit,UPTvSpindleT_mpc_R,UPTvSpindleT_mpc_P] =  RegressAndFindR(Templates.UPMeanVPeakCap,Templates.SpMeanVPeakCap);
% [UPTvSpindleT_rate_fit,UPTvSpindleT_rate_R,UPTvSpindleT_rate_P] =  RegressAndFindR(Templates.UPRate,Templates.SpRate);
% 
% if ~isempty(SpindleUPs)
%     [UPTvUPSpindleT_mpc_fit,UPTvUPSpindleT_mpc_R,UPTvUPSpindleT_mpc_P] =  RegressAndFindR(Templates.UPMeanVPeakCap,Templates.SpUPMeanVPeakCap);
%     [UPTvUPSpindleT_rate_fit,UPTvUPSpindleT_rate_R,UPTvUPSpindleT_rate_P] =  RegressAndFindR(Templates.UPRate,Templates.SpUPRate);
% 
%     
%     [SpindleTvUPSpindleT_mpc_fit,SpindleTvUPSpindleT_mpc_R,SpindleTvUPSpindleT_mpc_P] =  RegressAndFindR(Templates.SpMeanVPeakCap,Templates.SpUPMeanVPeakCap);
%     [SpindleTvUPSpindleT_rate_fit,SpindleTvUPSpindleT_rate_R,SpindleTvUPSpindleT_rate_P] =  RegressAndFindR(Templates.SpRate,Templates.SpRate);
% else
% %     UPTvUPSpindleTfit = [];
% %     UPTvUPSpindleTR = [];
% %     UPTvUPSpindleTP = [];
% %     SpindleTvUPSpindleTfit = [];
% %     SpindleTvUPSpindleTR = []; 
% %     SpindleTvUPSpindleTP = [];
%     UPTvUPSpindleT_mpc_fit = nan;
%     UPTvUPSpindleT_mpc_R = nan;
%     UPTvUPSpindleT_mpc_P = nan;
%     SpindleTvUPSpindleT_mpc_fit = nan;
%     SpindleTvUPSpindleT_mpc_R = nan; 
%     SpindleTvUPSpindleT_mpc_P = nan;
%     UPTvUPSpindleT_rate_fit = nan;
%     UPTvUPSpindleT_rate_R = nan;
%     UPTvUPSpindleT_rate_P = nan;
%     SpindleTvUPSpindleT_rate_fit = nan;
%     SpindleTvUPSpindleT_rate_R = nan; 
%     SpindleTvUPSpindleT_rate_P = nan;
% end

%% Calculate similarities of eachindividual type of event with each template
% Rates
% [rate_uVu_r,rate_uVu_p] = SequenceVsTemplateCorr(uisse.spkrates,Templates.UPRate);
[rate_nsuVu_r,rate_nsuVu_p] = SequenceVsTemplateCorr(Nuisse.spkrates,Templates.UPRate);
[rate_suVu_r,rate_suVu_p] = SequenceVsTemplateCorr(Suisse.spkrates,Templates.UPRate);
% [rate_psuVu_r,rate_psuVu_p] = SequenceVsTemplateCorr(Puisse.spkrates,Templates.UPRate);
% [rate_esuVu_r,rate_esuVu_p] = SequenceVsTemplateCorr(Euisse.spkrates,Templates.UPRate);
% [rate_lsuVu_r,rate_lsuVu_p] = SequenceVsTemplateCorr(Luisse.spkrates,Templates.UPRate);
% [rate_sVu_r,rate_sVu_p] = SequenceVsTemplateCorr(sisse.spkrates,Templates.UPRate);

% [rate_uVs_r,rate_uVs_p] = SequenceVsTemplateCorr(uisse.spkrates,Templates.SpRate);
[rate_nsuVs_r,rate_nsuVs_p] = SequenceVsTemplateCorr(Nuisse.spkrates,Templates.SpRate);
[rate_suVs_r,rate_suVs_p] = SequenceVsTemplateCorr(Suisse.spkrates,Templates.SpRate);
% [rate_psuVs_r,rate_psuVs_p] = SequenceVsTemplateCorr(Puisse.spkrates,Templates.SpRate);
% [rate_esuVs_r,rate_esuVs_p] = SequenceVsTemplateCorr(Euisse.spkrates,Templates.SpRate);
% [rate_lsuVs_r,rate_lsuVs_p] = SequenceVsTemplateCorr(Luisse.spkrates,Templates.SpRate);
% [rate_sVs_r,rate_sVs_p] = SequenceVsTemplateCorr(sisse.spkrates,Templates.SpRate);

% [rate_uVsu_r,rate_uVsu_p] = SequenceVsTemplateCorr(uisse.spkrates,Templates.SpUPRate);
[rate_nsuVsu_r,rate_nsuVsu_p] = SequenceVsTemplateCorr(Nuisse.spkrates,Templates.SpUPRate);
[rate_suVsu_r,rate_suVsu_p] = SequenceVsTemplateCorr(Suisse.spkrates,Templates.SpUPRate);
% [rate_psuVsu_r,rate_psuVsu_p] = SequenceVsTemplateCorr(Puisse.spkrates,Templates.SpUPRate);
% [rate_esuVsu_r,rate_esuVsu_p] = SequenceVsTemplateCorr(Euisse.spkrates,Templates.SpUPRate);
% [rate_lsuVsu_r,rate_lsuVsu_p] = SequenceVsTemplateCorr(Luisse.spkrates,Templates.SpUPRate);
% [rate_sVsu_r,rate_sVsu_p] = SequenceVsTemplateCorr(sisse.spkrates,Templates.SpUPRate);

% Mean vs Peak (capped)
% [mpc_uVu_r,mpc_uVu_p] = SequenceVsTemplateCorr(uisse.meanspktsfrompeak_capped,Templates.UPMeanVPeakCap);
[mpc_nsuVu_r,mpc_nsuVu_p] = SequenceVsTemplateCorr(Nuisse.meanspktsfrompeak_capped,Templates.UPMeanVPeakCap);
[mpc_suVu_r,mpc_suVu_p] = SequenceVsTemplateCorr(Suisse.meanspktsfrompeak_capped,Templates.UPMeanVPeakCap);
% [mpc_psuVu_r,mpc_psuVu_p] = SequenceVsTemplateCorr(Puisse.meanspktsfrompeak_capped,Templates.UPMeanVPeakCap);
% [mpc_esuVu_r,mpc_esuVu_p] = SequenceVsTemplateCorr(Euisse.meanspktsfrompeak_capped,Templates.UPMeanVPeakCap);
% [mpc_lsuVu_r,mpc_lsuVu_p] = SequenceVsTemplateCorr(Luisse.meanspktsfrompeak_capped,Templates.UPMeanVPeakCap);
% [mpc_sVu_r,mpc_sVu_p] = SequenceVsTemplateCorr(sisse.meanspktsfrompeak_capped,Templates.UPMeanVPeakCap);

% [mpc_uVs_r,mpc_uVs_p] = SequenceVsTemplateCorr(uisse.meanspktsfrompeak_capped,Templates.SpMeanVPeakCap);
[mpc_nsuVs_r,mpc_nsuVs_p] = SequenceVsTemplateCorr(Nuisse.meanspktsfrompeak_capped,Templates.SpMeanVPeakCap);
[mpc_suVs_r,mpc_suVs_p] = SequenceVsTemplateCorr(Suisse.meanspktsfrompeak_capped,Templates.SpMeanVPeakCap);
% [mpc_psuVs_r,mpc_psuVs_p] = SequenceVsTemplateCorr(Puisse.meanspktsfrompeak_capped,Templates.SpMeanVPeakCap);
% [mpc_esuVs_r,mpc_esuVs_p] = SequenceVsTemplateCorr(Euisse.meanspktsfrompeak_capped,Templates.SpMeanVPeakCap);
% [mpc_lsuVs_r,mpc_lsuVs_p] = SequenceVsTemplateCorr(Luisse.meanspktsfrompeak_capped,Templates.SpMeanVPeakCap);
% [mpc_sVs_r,mpc_sVs_p] = SequenceVsTemplateCorr(sisse.meanspktsfrompeak_capped,Templates.SpMeanVPeakCap);

% [mpc_uVsu_r,mpc_uVsu_p] = SequenceVsTemplateCorr(uisse.meanspktsfrompeak_capped,Templates.SpUPMeanVPeakCap);
[mpc_nsuVsu_r,mpc_nsuVsu_p] = SequenceVsTemplateCorr(Nuisse.meanspktsfrompeak_capped,Templates.SpUPMeanVPeakCap);
[mpc_suVsu_r,mpc_suVsu_p] = SequenceVsTemplateCorr(Suisse.meanspktsfrompeak_capped,Templates.SpUPMeanVPeakCap);
% [mpc_psuVsu_r,mpc_psuVsu_p] = SequenceVsTemplateCorr(Puisse.meanspktsfrompeak_capped,Templates.SpUPMeanVPeakCap);
% [mpc_esuVsu_r,mpc_esuVsu_p] = SequenceVsTemplateCorr(Euisse.meanspktsfrompeak_capped,Templates.SpUPMeanVPeakCap);
% [mpc_lsuVsu_r,mpc_lsuVsu_p] = SequenceVsTemplateCorr(Luisse.meanspktsfrompeak_capped,Templates.SpUPMeanVPeakCap);
% [mpc_sVsu_r,mpc_sVsu_p] = SequenceVsTemplateCorr(sisse.meanspktsfrompeak_capped,Templates.SpUPMeanVPeakCap);

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

% % gather and save rs and ps
% SpindleUPTemplateRsAndPs = v2struct(UPTvSpindleT_mpc_R,UPTvSpindleT_mpc_P,...
%     UPTvUPSpindleT_mpc_R,UPTvUPSpindleT_mpc_P, SpindleTvUPSpindleT_mpc_R,SpindleTvUPSpindleT_mpc_P,...
%     UPTvSpindleT_rate_R,UPTvSpindleT_rate_P,...
%     UPTvUPSpindleT_rate_R,UPTvUPSpindleT_rate_P, SpindleTvUPSpindleT_rate_R,SpindleTvUPSpindleT_rate_P,...
%     rate_uVu_r,rate_uVu_p,rate_nsuVu_r,rate_nsuVu_p,rate_suVu_r,rate_suVu_p,...
%     rate_psuVu_r,rate_psuVu_p,rate_esuVu_r,rate_esuVu_p,rate_lsuVu_r,rate_lsuVu_p,...
%     rate_sVu_r,rate_sVu_p,rate_uVs_r,rate_uVs_p,rate_nsuVs_r,rate_nsuVs_p,...
%     rate_suVs_r,rate_suVs_p,rate_psuVs_r,rate_psuVs_p,rate_esuVs_r,rate_esuVs_p,...
%     rate_lsuVs_r,rate_lsuVs_p,rate_sVs_r,rate_sVs_p,rate_uVsu_r,rate_uVsu_p,...
%     rate_nsuVsu_r,rate_nsuVsu_p,rate_suVsu_r,rate_suVsu_p,rate_psuVsu_r,rate_psuVsu_p,...
%     rate_esuVsu_r,rate_esuVsu_p,rate_lsuVsu_r,rate_lsuVsu_p,rate_sVsu_r,rate_sVsu_p,...
%     mpc_uVu_r,mpc_uVu_p,mpc_nsuVu_r,mpc_nsuVu_p,mpc_suVu_r,mpc_suVu_p,...
%     mpc_psuVu_r,mpc_psuVu_p,mpc_esuVu_r,mpc_esuVu_p,mpc_lsuVu_r,mpc_lsuVu_p,...
%     mpc_sVu_r,mpc_sVu_p,mpc_uVs_r,mpc_uVs_p,mpc_nsuVs_r,mpc_nsuVs_p,...
%     mpc_suVs_r,mpc_suVs_p,mpc_psuVs_r,mpc_psuVs_p,mpc_esuVs_r,mpc_esuVs_p,...
%     mpc_lsuVs_r,mpc_lsuVs_p,mpc_sVs_r,mpc_sVs_p,mpc_uVsu_r,mpc_uVsu_p,...
%     mpc_nsuVsu_r,mpc_nsuVsu_p,mpc_suVsu_r,mpc_suVsu_p,mpc_psuVsu_r,mpc_psuVsu_p,...
%     mpc_esuVsu_r,mpc_esuVsu_p,mpc_lsuVsu_r,mpc_lsuVsu_p,mpc_sVsu_r,mpc_sVsu_p);
SpindleUPTemplateRsAndPs = v2struct(rate_nsuVu_r,rate_nsuVu_p,rate_suVu_r,rate_suVu_p,...
    rate_nsuVs_r,rate_nsuVs_p,...
    rate_suVs_r,rate_suVs_p,...
    rate_nsuVsu_r,rate_nsuVsu_p,rate_suVsu_r,rate_suVsu_p,...
    mpc_nsuVu_r,mpc_nsuVu_p,mpc_suVu_r,mpc_suVu_p,...
    mpc_nsuVs_r,mpc_nsuVs_p,...
    mpc_suVs_r,mpc_suVs_p,...
    mpc_nsuVsu_r,mpc_nsuVsu_p,mpc_suVsu_r,mpc_suVsu_p);
% save(fullfile('UPstates',[basename 'SpindleUPTemplateRsAndPs.mat']),'SpindleUPTemplateRsAndPs')
% save(fullfile('UPstates',[basename 'SpindleUPMeanBasedTemplates.mat']),'Templates')


%% Find SpindleUPs, then neighboring ups
SupNeighRatio = nan(1,length(SpindleUPs));
for a = 1:length(SpindleUPs)
    tspupstart = Suisse.intstarts(a);
    preNups = find(Nuisse.intstarts<tspupstart,2,'last');
    postNups = find(Nuisse.intstarts>tspupstart,2,'first');
    
    SupCor = mpc_suVu_r(a);
    NupCor = mpc_nsuVu_r([preNups;postNups]);
   
    SupNeighRatio(a) = SupCor/mean(NupCor);
end

NupNeighRatio = nan(1,length(NoSpindleUPs));
for a = 1:length(NoSpindleUPs)
    tspupstart = Nuisse.intstarts(a);
    preNups = find(Nuisse.intstarts<tspupstart,2,'last');
    postNups = find(Nuisse.intstarts>tspupstart,2,'first');
    
    ThisNupCor = mpc_nsuVu_r(a);
    NupCor = mpc_nsuVu_r([preNups;postNups]);
   
    NupNeighRatio(a) = ThisNupCor/mean(NupCor);
end

NeighbRatios = v2struct(SupNeighRatio,NupNeighRatio);
save(fullfile('UPstates',[basename '_NeighborToTemplateAnalysis.mat']),'NeighbRatios')


%% initialize handles
h = [];

h(end+1) = figure;
hax = plot_nanmeanSD_bars(SupNeighRatio,NupNeighRatio);
set(hax,'Xtick',[1 2])
set(hax,'XtickLabel',{'SpUPvsLocalNUP';'NUPvsLocalNUP'})
ylabel(hax,'R Value (mean+-SD)')
title(hax,'Correlations of events to UP template / Mean Correlations of Local Non-Spindle UP Neighbors')
set(h(end),'name',[basename '_NeighborToTemplateAnalysis'])

%% save figs
cd(fullfile(basepath,'UPstates'))
if ~exist('SpindleUPTemplateFigs','dir')
    mkdir('SpindleUPTemplateFigs')
end
cd('SpindleUPTemplateFigs')
savefigsasname(h,'fig');
% close(h)
cd(basepath)


