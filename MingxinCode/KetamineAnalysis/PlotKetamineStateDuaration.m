function PlotKetamineStateDuaration(basepath, basename)

if ~exist('basepath','var')
    [~,basename] = fileparts(cd);
    basepath = cd;
end

load(fullfile(basepath,[basename '_BasicMetaData.mat']),'InjectionType')
% load(fullfile(basepath,[basename '_BasicMetaData.mat']),'BadIntervali')
% load(fullfile(basepath,[basename '_InjectionComparisionIntervals.mat']))
% load(fullfile(basepath,[basename '-states.mat']),'states')
% 
% basestart = InjectionComparisionIntervals.BaselineStartRecordingSeconds;
% baseend = InjectionComparisionIntervals.BaselineEndRecordingSeconds;
% base24end = InjectionComparisionIntervals.BaselineP24EndRecordingSeconds;
% base24start = InjectionComparisionIntervals.BaselineP24StartRecordingSeconds;
% 
% injm1start = InjectionComparisionIntervals.InjMinusHourStartRecordingSeconds;
% injm1end = InjectionComparisionIntervals.InjMinusHourEndRecordingSeconds;
% injp1start = InjectionComparisionIntervals.InjPlusHourStartRecordingSeconds;
% injp1end = InjectionComparisionIntervals.InjPlusHourEndRecordingSeconds;
% 
% injp2start = InjectionComparisionIntervals.InjPlus2HourStartRecordingSeconds;
% injp2end = InjectionComparisionIntervals.InjPlus2HourEndRecordingSeconds;
% 
% baseint = intervalSet(basestart,baseend);
% base24int = intervalSet(base24start,base24end);
% injm1int = intervalSet(injm1start,injm1end);
% injp1int = intervalSet(injp1start,injp1end);
% injp2int = intervalSet(injp2start,injp2end);
% 
% % exclude bad intervals
% if ~isempty(BadIntervali)
%    baseint = minus(baseint,BadIntervali);
%    base24int = minus(base24int,BadIntervali);
%    injm1int = minus(injm1int,BadIntervali);
%    injp1int = minus(injp1int,BadIntervali);
%    injp2int = minus(injp2int,BadIntervali);
% end
% 
% states = IDXtoINT(states);
% 
% WAKEInts = intervalSet(states{1}(:,1), states{1}(:,2));
% MAInts = intervalSet(states{2}(:,1), states{2}(:,2));
% NREMInts = intervalSet(states{3}(:,1), states{3}(:,2));
% REMInts = intervalSet(states{5}(:,1), states{5}(:,2));
% 
% for i = 1:3
%     
% baseWAKE = intersect(int1,WAKEInts);
% base24WAKE = intersect(int2,WAKEInts);
% baseMA = intersect(int1,MAInts);
% base24MA = intersect(int2,MAInts);
% int1NREM = intersect(int1,NREMInts);
% int2NREM = intersect(int2,NREMInts);
% int1REM = intersect(int1,REMInts);
% int2REM = intersect(int2,REMInts);
% 
% int1states = v2struct(int1WAKE,int1MA,int1NREM,int1REM);
% int2states = v2struct(int2WAKE,base24MA,int2NREM,int2REM);

load(fullfile(basepath,[basename '_KetamineIntervalState.mat'])); %,'baselineStateIntervals',...
%     'baseline24StateIntervals','InjM1StateIntervals','InjP1StateIntervals','InjP2Stateintervals',...
%     'baseint','base24int','injm1int','injp1int','injp2int');
baselineWAKELength = tot_length(KetamineIntervalState.baselineStateIntervals.int1WAKE);
baselineREMLength = tot_length(KetamineIntervalState.baselineStateIntervals.int1REM);
baselineNREMLength = tot_length(KetamineIntervalState.baselineStateIntervals.int1NREM);
baselineMALength = tot_length(KetamineIntervalState.baselineStateIntervals.int1MA);
baselineLength = tot_length(KetamineIntervalState.baseint);
baselineWAKEProp = baselineWAKELength/baselineLength;
baselineREMProp = baselineREMLength/baselineLength;
baselineNREMProp = baselineNREMLength/baselineLength;
baselineMAProp = baselineMALength/baselineLength;
baseline = v2struct(baselineWAKELength,baselineREMLength,baselineNREMLength,baselineMALength,...
    baselineWAKEProp,baselineREMProp,baselineNREMProp,baselineMAProp,baselineLength);

baseline24WAKELength = tot_length(KetamineIntervalState.baseline24StateIntervals.int2WAKE);
baseline24REMLength = tot_length(KetamineIntervalState.baseline24StateIntervals.int2REM);
baseline24NREMLength = tot_length(KetamineIntervalState.baseline24StateIntervals.int2NREM);
baseline24MALength = tot_length(KetamineIntervalState.baseline24StateIntervals.int2MA);
baseline24Length = tot_length(KetamineIntervalState.base24int);
baseline24WAKEProp = baseline24WAKELength/baseline24Length;
baseline24REMProp = baseline24REMLength/baseline24Length;
baseline24NREMProp = baseline24NREMLength/baseline24Length;
baseline24MAProp = baseline24MALength/baseline24Length;
baseline24 = v2struct(baseline24WAKELength,baseline24REMLength,baseline24NREMLength,baseline24MALength,...
    baseline24WAKEProp,baseline24REMProp,baseline24NREMProp,baseline24MAProp,baseline24Length);

InjM1WAKELength = tot_length(KetamineIntervalState.InjM1StateIntervals.int1WAKE);
InjM1REMLength = tot_length(KetamineIntervalState.InjM1StateIntervals.int1REM);
InjM1NREMLength = tot_length(KetamineIntervalState.InjM1StateIntervals.int1NREM);
InjM1MALength = tot_length(KetamineIntervalState.InjM1StateIntervals.int1MA);
InjM1Length = tot_length(KetamineIntervalState.injm1int);
InjM1WAKEProp = InjM1WAKELength/InjM1Length;
InjM1REMProp = InjM1REMLength/InjM1Length;
InjM1NREMProp = InjM1NREMLength/InjM1Length;
InjM1MAProp = InjM1MALength/InjM1Length;
InjM1 = v2struct(InjM1WAKELength,InjM1REMLength,InjM1NREMLength,InjM1MALength,...
    InjM1WAKEProp,InjM1REMProp,InjM1NREMProp,InjM1MAProp,InjM1Length);

InjP1WAKELength = tot_length(KetamineIntervalState.InjP1StateIntervals.int2WAKE);
InjP1REMLength = tot_length(KetamineIntervalState.InjP1StateIntervals.int2REM);
InjP1NREMLength = tot_length(KetamineIntervalState.InjP1StateIntervals.int2NREM);
InjP1MALength = tot_length(KetamineIntervalState.InjP1StateIntervals.int2MA);
InjP1Length = tot_length(KetamineIntervalState.injp1int);
InjP1WAKEProp = InjP1WAKELength/InjP1Length;
InjP1REMProp = InjP1REMLength/InjP1Length;
InjP1NREMProp = InjP1NREMLength/InjP1Length;
InjP1MAProp = InjP1MALength/InjP1Length;
InjP1 = v2struct(InjP1WAKELength,InjP1REMLength,InjP1NREMLength,InjP1MALength,...
    InjP1WAKEProp,InjP1REMProp,InjP1NREMProp,InjP1MAProp,InjP1Length);

InjP2WAKELength = tot_length(KetamineIntervalState.InjP2StateIntervals.int2WAKE);
InjP2REMLength = tot_length(KetamineIntervalState.InjP2StateIntervals.int2REM);
InjP2NREMLength = tot_length(KetamineIntervalState.InjP2StateIntervals.int2NREM);
InjP2MALength = tot_length(KetamineIntervalState.InjP2StateIntervals.int2MA);
InjP2Length = tot_length(KetamineIntervalState.injp2int);
InjP2WAKEProp = InjP2WAKELength/InjP2Length;
InjP2REMProp = InjP2REMLength/InjP2Length;
InjP2NREMProp = InjP2NREMLength/InjP2Length;
InjP2MAProp = InjP2MALength/InjP2Length;
InjP2 = v2struct(InjP2WAKELength,InjP2REMLength,InjP2NREMLength,InjP2MALength,...
    InjP2WAKEProp,InjP2REMProp,InjP2NREMProp,InjP2MAProp,InjP2Length);

KetamineStateDuration = v2struct(baseline,baseline24,InjM1,InjP1,InjP2);
save(fullfile(basepath,[basename '_KetamineStateDuration.mat']),'KetamineStateDuration');

plotBaselinev24 = figure;
bar([baselineWAKEProp,baseline24WAKEProp; baselineREMProp,baseline24REMProp; baselineNREMProp,baseline24NREMProp; baselineMAProp,baseline24MAProp]);
set(gca,'xtick',[1:4],'XTickLabel',{'WAKE','REM','NREM','MA'})
ylabel('Percentage')
legend('Baseline','Baseline+24hr')

plotInjM1vP1 = figure;
bar([InjM1WAKEProp,InjP1WAKEProp; InjM1REMProp,InjP1REMProp; InjM1NREMProp,InjP1NREMProp; InjM1MAProp,InjP1MAProp]);
set(gca,'xtick',[1:4],'XTickLabel',{'WAKE','REM','NREM','MA'})
ylabel('Percentage')
legend('Inj-1hr','Inj+1hr')

plotBaselinevP2 = figure;
bar([baselineWAKEProp,InjP2WAKEProp; baselineREMProp,InjP2REMProp; baselineNREMProp,InjP2NREMProp; baselineMAProp,InjP2MAProp]);
set(gca,'xtick',[1:4],'XTickLabel',{'WAKE','REM','NREM','MA'})
ylabel('Percentage')
legend('Baseline','Inj+2hr')

figpath = fullfile(basepath,[basename '_KetamineStateDurationFig']);
if ~exist(figpath, 'dir')
    mkdir([basename '_KetamineStateDurationFig']);
end

savefig(plotBaselinev24, fullfile(figpath,[basename '_BaselineVsBaseline+24hr.fig']));
print(plotBaselinev24,fullfile(figpath,[basename '_BaselineVsBaseline+24hr']),'-dpng','-r0');

savefig(plotInjM1vP1, fullfile(figpath,[basename '_Inj-1hrVsInj+1hr.fig']));
print(plotInjM1vP1,fullfile(figpath,[basename '_Inj-1hrVsInj+1hr']),'-dpng','-r0');

savefig(plotBaselinevP2, fullfile(figpath,[basename '_BaselineVsInj+2hr.fig']));
print(plotBaselinevP2,fullfile(figpath,[basename '_BaselineVsInj+2hr']),'-dpng','-r0');
end
