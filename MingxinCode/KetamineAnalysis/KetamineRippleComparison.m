function KetamineRippleComparison(basepath,basename)

if ~exist('basepath','var')
    basepath = cd;
    [~,basename,~] = fileparts(cd);
end

% load(fullfile(basepath,[basename '_PostInjectionWakeInterval.mat']),'postinjwake','noninjwake');
% load(fullfile(basepath,[basename '_Ripples.mat']),'RippleData');
load(fullfile(basepath,[basename '_Ripples_Ch79.mat']),'RippleData');
load(fullfile(basepath,[basename '_BasicMetaData.mat']),'InjectionType');
load(fullfile(basepath,[basename '_KetamineIntervalState.mat']),'KetamineIntervalState');
load(fullfile(basepath,[basename '-states.mat']),'states');

RippleIntervals = intervalSet(RippleData.ripples(:,1),RippleData.ripples(:,3));

%% Compare among single periods of wake state right before, right after, and 24hr after injection.
% PreInjWakeIdx = [];
% PostInj24WakeIdx = [];
% PreInjWakeIdx = find(noninjwake.noninjwake_se(:,1)<postinjwake.postinjwake_se(1),1,'last');
% PreInjWakeInterval = intervalSet(noninjwake.noninjwake_se(PreInjWakeIdx,1),noninjwake.noninjwake_se(PreInjWakeIdx,2));
% PostInj24WakeIdx = find(noninjwake.noninjwake_se(:,1)>postinjwake.postinjwake_se(1)+24*60*60,1);
% if isempty(PostInj24WakeIdx)
%     PostInj24WakeIdx = find(noninjwake.noninjwake_se(:,1)<postinjwake.postinjwake_se(1)+24*60*60,1,'last');
% end
% PostInj24WakeInterval = intervalSet(noninjwake.noninjwake_se(PostInj24WakeIdx,1),noninjwake.noninjwake_se(PostInj24WakeIdx,2));
% 
% RipplePostInjWake = intersect(postinjwake.postinjwake_IS,RippleIntervals);
% RippleNonInjWake  = intersect(noninjwake.noninjwake_IS,RippleIntervals);
% RipplePreInjWake  = intersect(PreInjWakeInterval,RippleIntervals);
% RipplePostInj24Wake  = intersect(PostInj24WakeInterval,RippleIntervals);
% 
% FreRipplePostInjWake = length(array(RipplePostInjWake))/(postinjwake.postinjwake_se(2)-postinjwake.postinjwake_se(1));
% FreRipplePreInjWake = length(array(RipplePreInjWake))/tot_length(PreInjWakeInterval);
% FreRipplePostInj24Wake = length(array(RipplePostInj24Wake))/tot_length(PostInj24WakeInterval);
% 
% PlotRipplesInOneWakeSession = figure;
% bar([FreRipplePreInjWake,FreRipplePostInjWake,FreRipplePostInj24Wake]);
% set(gca,'xtick',[1:3],'XTickLabel',{'Pre Inj','Post Inj','Inj+24hr'})
% ylabel('RippleFrequency')
% title('Ripples in one session of WAKE');
% 
figpath = fullfile(basepath,[basename '_KetamineRippleFig']);
if ~exist(figpath, 'dir')
    mkdir([basename '_KetamineRippleFig']);
end
% 
% savefig(PlotRipplesInOneWakeSession, fullfile(figpath,[basename '_RipplesInOneWakeSession.fig']));
% print(PlotRipplesInOneWakeSession,fullfile(figpath,[basename '_RipplesInOneWakeSession']),'-dpng','-r0');
%% Compare wake state in a certain length of time (as in KetamineBinnedDataByIntervalState).
baselineWakeIntervals = KetamineIntervalState.baselineStateIntervals.int1WAKE;
baseline24WakeIntervals = KetamineIntervalState.baseline24StateIntervals.int2WAKE;
InjM1WakeIntervals = KetamineIntervalState.InjM1StateIntervals.int1WAKE;
InjP1WakeIntervals = KetamineIntervalState.InjP1StateIntervals.int2WAKE;
InjP2WakeIntervals = KetamineIntervalState.InjP2StateIntervals.int2WAKE;

RippleBaselineWake = intersect(baselineWakeIntervals,RippleIntervals);
RippleBaseline24Wake = intersect(baseline24WakeIntervals,RippleIntervals);
RippleInjM1Wake = intersect(InjM1WakeIntervals,RippleIntervals);
RippleInjP1Wake = intersect(InjP1WakeIntervals,RippleIntervals);
RippleInjP2Wake = intersect(InjP2WakeIntervals,RippleIntervals);

FreRippleBaselineWake = length(array(RippleBaselineWake))/tot_length(baselineWakeIntervals);
FreRippleBaseline24Wake = length(array(RippleBaseline24Wake))/tot_length(baseline24WakeIntervals);
FreRippleInjM1Wake = length(array(RippleInjM1Wake))/tot_length(InjM1WakeIntervals);
FreRippleInjP1Wake = length(array(RippleInjP1Wake))/tot_length(InjP1WakeIntervals);
FreRippleInjP2Wake = length(array(RippleInjP2Wake))/tot_length(InjP2WakeIntervals);

PlotRipplesInWakeHours = figure;
bar([FreRippleBaselineWake,FreRippleBaseline24Wake;FreRippleBaselineWake,FreRippleInjP2Wake;...
    FreRippleInjM1Wake,FreRippleInjP1Wake]);
set(gca,'xtick',[1:3],'XTickLabel',{'baseline baseline+24hr','baseline Inj+2hr','Inj-1hr Inj+1hr'})
ylabel('Ripple Occurrance')
title('Ripples in WAKE during Several Hours')

savefig(PlotRipplesInWakeHours, fullfile(figpath,[basename '_RipplesInWake(Hours).fig']));
print(PlotRipplesInWakeHours,fullfile(figpath,[basename '_RipplesInWake(Hours)']),'-dpng','-r0');
%% plot ripple occurrence across time
states_orig = states;
states = IDXtoINT(states);

WAKEInts = intervalSet(states{1}(:,1), states{1}(:,2));
MAInts = intervalSet(states{2}(:,1), states{2}(:,2));
NREMInts = intervalSet(states{3}(:,1), states{3}(:,2));
REMInts = intervalSet(states{5}(:,1), states{5}(:,2));

WAKERipplesIdx = find(belong(WAKEInts,round(RippleData.ripples(:,1))));
MARipplesIdx = find(belong(MAInts,round(RippleData.ripples(:,1))));
NREMRipplesIdx = find(belong(NREMInts,round(RippleData.ripples(:,1))));
REMRipplesIdx = find(belong(REMInts,round(RippleData.ripples(:,1))));

WAKERipples = RippleData.ripples(WAKERipplesIdx,[1,3]);
MARipples = RippleData.ripples(MARipplesIdx,[1,3]);
NREMRipples = RippleData.ripples(NREMRipplesIdx,[1,3]);
REMRipples = RippleData.ripples(REMRipplesIdx,[1,3]);

% figure;
% plot(WAKERipples(:,1),WAKERipplesIdx,'r',MARipples(:,1),MARipplesIdx,'y',NREMRipples(:,1),NREMRipplesIdx,'k',REMRipples(:,1),REMRipplesIdx,'b');
% or scatter()

fre = Frequency(RippleData.ripples(:,1),'binSize',50,'limits',[0 length(states_orig)]);
PlotRippleStates = figure;PlotXY(fre);
hold on
plot([postinjwake.postinjwake_se(1) postinjwake.postinjwake_se(1)],[0,1.5]);
plotIntervalsStrip(gca,states);
title('Ripples and States')

savefig(PlotRippleStates, fullfile(figpath,[basename '_RipplesAndStates.fig']));
print(PlotRippleStates,fullfile(figpath,[basename '_RipplesAndStates']),'-dpng','-r0');
%% Compare NREM sleep ripple rate

baselineNREMIntervals = KetamineIntervalState.baselineStateIntervals.int1NREM;
baseline24NREMIntervals = KetamineIntervalState.baseline24StateIntervals.int2NREM;
InjM1NREMIntervals = KetamineIntervalState.InjM1StateIntervals.int1NREM;
InjP1NREMIntervals = KetamineIntervalState.InjP1StateIntervals.int2NREM;
InjP2NREMIntervals = KetamineIntervalState.InjP2StateIntervals.int2NREM;

RippleBaselineNREM = intersect(baselineNREMIntervals,RippleIntervals);
RippleBaseline24NREM = intersect(baseline24NREMIntervals,RippleIntervals);
RippleInjM1NREM = intersect(InjM1NREMIntervals,RippleIntervals);
RippleInjP1NREM = intersect(InjP1NREMIntervals,RippleIntervals);
RippleInjP2NREM = intersect(InjP2NREMIntervals,RippleIntervals);

FreRippleBaselineNREM = length(array(RippleBaselineNREM))/tot_length(baselineNREMIntervals);
FreRippleBaseline24NREM = length(array(RippleBaseline24NREM))/tot_length(baseline24NREMIntervals);
FreRippleInjM1NREM = length(array(RippleInjM1NREM))/tot_length(InjM1NREMIntervals);
FreRippleInjP1NREM = length(array(RippleInjP1NREM))/tot_length(InjP1NREMIntervals);
FreRippleInjP2NREM = length(array(RippleInjP2NREM))/tot_length(InjP2NREMIntervals);

PlotRipplesInNREMHours = figure;
bar([FreRippleBaselineNREM,FreRippleBaseline24NREM;FreRippleBaselineNREM,FreRippleInjP2NREM;...
    FreRippleInjM1NREM,FreRippleInjP1NREM]);
set(gca,'xtick',[1:3],'XTickLabel',{'baseline baseline+24hr','baseline Inj+2hr','Inj-1hr Inj+1hr'})
ylabel('Ripple Occurrance')
title('Ripples in NREM during Several Hours')

savefig(PlotRipplesInNREMHours, fullfile(figpath,[basename '_RipplesInNREM(Hours).fig']));
print(PlotRipplesInNREMHours,fullfile(figpath,[basename '_RipplesInNREM(Hours)']),'-dpng','-r0');


%% put Wake and NREM together

figure;
bar([FreRippleBaselineWake,FreRippleInjM1Wake,FreRippleInjP1Wake,FreRippleInjP2Wake,FreRippleBaseline24Wake;...
    FreRippleBaselineNREM,FreRippleInjM1NREM,FreRippleInjP1NREM,FreRippleInjP2NREM,FreRippleBaseline24NREM],'b');
set(gca,'xtick',[1:5],'XTickLabel',{'baseline','Inj-1hr','Inj+1hr','Inj+2hr','baseline+24'})
ylabel('Ripple Occurrance')
end


