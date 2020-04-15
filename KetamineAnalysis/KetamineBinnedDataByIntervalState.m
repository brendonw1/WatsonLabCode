function KetamineBinnedDataByIntervalState(basepath,basename)
% Loads data from various binned metrics (Firing rates, EIRatio etc), then
% grabs values of each variable in a number of specified time chunks (such 
% as pre-injection baseline, baseline+24hrs see subsection below, not given
% as an input at this point) and in each time chunk subdivides values by
% brain states, plots and saves.
% Also, NB, KetamineDatasetWideBinnedComparisons can grab these values
% across the full dataset
% Brendon Watson 2016

if ~exist('basepath','var')
    [~,basename] = fileparts(cd);
    basepath = cd;
end
if ~exist(basepath,'dir')
    basepath = fullfile(getdropbox,'Data','KetamineDataset',basename);
end

%% do not execute if data unavailable
hrlrpath = fullfile(basepath,[basename '_HighLowFRRatio.mat']);
icipath = fullfile(basepath,[basename '_InjectionComparisionIntervals.mat']);
if ~exist(hrlrpath,'file') && exist(icipath,'file')
    disp(['Files for binned data comparisons do not exist for ' basename])
    return
end

%% load data
% load(fullfile(basepath,[basename '_BasicMetaData.mat']),'InjectionTimestamp')
load(fullfile(basepath,[basename '_BasicMetaData.mat']),'InjectionType')
load(fullfile(basepath,[basename '_BasicMetaData.mat']),'BadIntervali')
load(fullfile(basepath,[basename '_SSubtypes.mat']),'Se')
load(fullfile(basepath,[basename '_SSubtypes.mat']),'Si')
load(fullfile(basepath,[basename '_HighLowFRRatio.mat']))
load(fullfile(basepath,[basename '.EMGFromLFP.LFP.mat']))
load(fullfile(basepath,[basename '_EIRatio.mat']))
load(fullfile(basepath,[basename '_BurstPerBinData.mat']))
load(fullfile(basepath,[basename '_SpikingCoeffVaration.mat']))
load(fullfile(basepath,[basename '_InjectionComparisionIntervals.mat']))
load(fullfile(basepath,[basename '-states.mat']),'states')

%% Prep E and I rates data real quick, to make them average-able
EPopRate_tsd = MakeQfromTsd(oneSeries(Se),1);
tt = Range(EPopRate_tsd);
td = Data(EPopRate_tsd)/length(Se);
EPopRate_tsd = tsd(tt,td);

IPopRate_tsd = MakeQfromTsd(oneSeries(Si),1);
tt = Range(IPopRate_tsd);
td = Data(IPopRate_tsd)/length(Si);
IPopRate_tsd = tsd(tt,td);

%% Make a time-matched plot of all variables for each recording
injt = InjectionComparisionIntervals.InjPlusHourStartRecordingSeconds;% Get Injection time for plotting

h = figure('position',[200 10 800 900]);
subplot(7,1,1);
    plot(EMGFromLFP.timestamps,smooth(EMGFromLFP.data,100))
    axis tight
    hold on;plot([injt injt],get(gca,'ylim'),'k')
    legend('EMG Based on Correlation')
subplot(7,1,2);
    hold on
    plot(Range(EPopRate_tsd),smooth(Data(EPopRate_tsd),30),'g')
    plot(Range(IPopRate_tsd),smooth(Data(IPopRate_tsd),30),'r')
    axis tight
    plot([injt injt],get(gca,'ylim'),'k')
    legend('EPopRate','IPopRate','Location','NorthWest');
subplot(7,1,3);
    plot(EIRatioData.bincentertimes,EIRatioData.EI)
    axis tight
    hold on;plot([injt injt],get(gca,'ylim'),'k')
    legend('EIRatio')
subplot(7,1,4);
    plot(BurstPerBinData.bincentertimes,BurstPerBinData.MBIE)
    axis tight
    hold on;plot([injt injt],get(gca,'ylim'),'k')
    legend('E Cell Burst Index')
subplot(7,1,5);
    plot(HighLowFRRatioData.bincentertimes,smooth(HighLowFRRatioData.hr,100))
    hold on;plot(HighLowFRRatioData.bincentertimes,smooth(HighLowFRRatioData.lr,100),'r')
    set(gca,'yscale','log')
    legend('High FR group','Low FR group','Location','SouthEast')
    axis tight
    hold on;plot([injt injt],get(gca,'ylim'),'k')
subplot(7,1,6)
    plot(HighLowFRRatioData.bincentertimes,smooth(HighLowFRRatioData.hrlr,100))
    axis tight
    hold on;plot([injt injt],get(gca,'ylim'),'k')
    legend('HR:LR Ratio')
subplot(7,1,7)
    plot(SpikingCoeffVarationData.bincentertimes,SpikingCoeffVarationData.CoVE)
    axis tight
    hold on;plot([injt injt],get(gca,'ylim'),'k')
    legend('CoV of E Cells')

AboveTitle([basename ': ' InjectionType])    
    
%% grab interval starts and ends
% intervals used could be expanded later, for now it's 
% - inj+1hour, inj-1hour, baseline, baseline+24
basestart = InjectionComparisionIntervals.BaselineStartRecordingSeconds;
baseend = InjectionComparisionIntervals.BaselineEndRecordingSeconds;
base24end = InjectionComparisionIntervals.BaselineP24EndRecordingSeconds;
base24start = InjectionComparisionIntervals.BaselineP24StartRecordingSeconds;

injm1start = InjectionComparisionIntervals.InjMinusHourStartRecordingSeconds;
injm1end = InjectionComparisionIntervals.InjMinusHourEndRecordingSeconds;
injp1start = InjectionComparisionIntervals.InjPlusHourStartRecordingSeconds;
injp1end = InjectionComparisionIntervals.InjPlusHourEndRecordingSeconds;

injp2start = InjectionComparisionIntervals.InjPlus2HourStartRecordingSeconds;
injp2end = InjectionComparisionIntervals.InjPlus2HourEndRecordingSeconds;

baseint = intervalSet(basestart,baseend);
base24int = intervalSet(max(HighLowFRRatioData.bincentertimes)-3600*5,max(HighLowFRRatioData.bincentertimes));
injm1int = intervalSet(injm1start,injm1end);
injp1int = intervalSet(injp1start,injp1end);
injp2int = intervalSet(injp2start,injp2end);

% exclude bad intervals
if ~isempty(BadIntervali)
   baseint = minus(baseint,BadIntervali);
   base24int = minus(base24int,BadIntervali);
   injm1int = minus(injm1int,BadIntervali);
   injp1int = minus(injp1int,BadIntervali);
   injp2int = minus(injp2int,BadIntervali);
end

%% tsds of data
hrlr_tsd = tsd(HighLowFRRatioData.bincentertimes,HighLowFRRatioData.hrlr);
hr_tsd = tsd(HighLowFRRatioData.bincentertimes,HighLowFRRatioData.hr);
lr_tsd = tsd(HighLowFRRatioData.bincentertimes,HighLowFRRatioData.lr);
CoV_tsd = tsd(SpikingCoeffVarationData.bincentertimes,SpikingCoeffVarationData.CoVE);
EIR_tsd = tsd(EIRatioData.bincentertimes,EIRatioData.EI);
BurstE_tsd = tsd(BurstPerBinData.bincentertimes,BurstPerBinData.MBIE);
EPopRate_tsd = EPopRate_tsd;
IPopRate_tsd = IPopRate_tsd;

%% ploting by interval and state
% hour before vs hour after injection 
% ...(but not much wake before and not much sleep after)
h1 = [];
[h1(end+1),ERateInjm1Data,ERateInjp1Data,InjM1StateIntervals,InjP1StateIntervals] =...
    VariablesByIntervalAndState(EPopRate_tsd,injm1int,injp1int,states);
AboveTitle([basename '- ' InjectionType '- Inj-1hrVInj+1hr - ECell Pop Rate']);
[h1(end+1),IRateInjm1Data,IRateInjp1Data] = VariablesByIntervalAndState(IPopRate_tsd,injm1int,injp1int,states);
AboveTitle([basename '- ' InjectionType '- Inj-1hrVInj+1hr - ICell Pop Rate']);
[h1(end+1),hrlrInjm1Data,hrlrInjp1Data] = VariablesByIntervalAndState(hrlr_tsd,injm1int,injp1int,states);
AboveTitle([basename '- ' InjectionType '- Inj-1hrVInj+1hr - HR/LR Rate Ratio']);
[h1(end+1),hrInjm1Data,hrInjp1Data] = VariablesByIntervalAndState(hr_tsd,injm1int,injp1int,states);
AboveTitle([basename '- ' InjectionType '- Inj-1hrVInj+1hr - High FR Cell Rate']);
[h1(end+1),lrInjm1Data,lrInjp1Data] = VariablesByIntervalAndState(lr_tsd,injm1int,injp1int,states);
AboveTitle([basename '- ' InjectionType '- Inj-1hrVInj+1hr - Low FR Cell Rate']);
[h1(end+1),CoVInjm1Data,CoVInjp1Data] = VariablesByIntervalAndState(CoV_tsd,injm1int,injp1int,states);
AboveTitle([basename '- ' InjectionType '- Inj-1hrVInj+1hr - Population FR CoV']);
[h1(end+1),EIRInjm1Data,EIRInjp1Data] = VariablesByIntervalAndState(EIR_tsd,injm1int,injp1int,states);
AboveTitle([basename '- ' InjectionType '- Inj-1hrVInj+1hr - E:I Ratio']);
[h1(end+1),BurstEInjm1Data,BurstEInjp1Data] = VariablesByIntervalAndState(BurstE_tsd,injm1int,injp1int,states);
AboveTitle([basename '- ' InjectionType '- Inj-1hrVInj+1hr - E Cell Burst Ratio']);

% baseline ~6hr vs 2hr after inj
h2 = [];
[h1(end+1),ERateBaselineData,ERateInjp2Data,baselineStateIntervals,InjP2StateIntervals] =...
    VariablesByIntervalAndState(EPopRate_tsd,baseint,injp2int,states);
AboveTitle([basename '- ' InjectionType '- BaselineVInj+2hr - ECell Pop Rate']);
[h1(end+1),IRateBaselineData,IRateInjp2Data] = VariablesByIntervalAndState(IPopRate_tsd,baseint,injp2int,states);
AboveTitle([basename '- ' InjectionType '- BaselineVInj+2hr - ICell Pop Rate']);
[h2(end+1),hrlrBaselineData,hrlrInjp2Data] = VariablesByIntervalAndState(hrlr_tsd,baseint,injp2int,states);
AboveTitle([basename '- ' InjectionType '- BaselineVInj+2hr - HR/LR Rate Ratio']);
[h2(end+1),hrBaselineData,hrInjp2Data] = VariablesByIntervalAndState(hr_tsd,baseint,injp2int,states);
AboveTitle([basename '- ' InjectionType '- BaselineVInj+2hr - High FR Cell Rate']);
[h2(end+1),lrBaselineData,lrInjp2Data] = VariablesByIntervalAndState(lr_tsd,baseint,injp2int,states);
AboveTitle([basename '- ' InjectionType '- BaselineVInj+2hr - Low FR Cell Rate']);
[h2(end+1),CoVBaselineData,CoVInjp2Data] = VariablesByIntervalAndState(CoV_tsd,baseint,injp2int,states);
AboveTitle([basename '- ' InjectionType '- BaselineVInj+2hr - Population FR CoV']);
[h2(end+1),EIRBaselineData,EIRInjp2Data] = VariablesByIntervalAndState(EIR_tsd,baseint,injp2int,states);
AboveTitle([basename '- ' InjectionType '- BaselineVInj+2hr - E:I Ratio']);
[h2(end+1),BurstEBaselineData,BurstEInjp2Data] = VariablesByIntervalAndState(BurstE_tsd,baseint,injp2int,states);
AboveTitle([basename '- ' InjectionType '- BaselineVInj+2hr - E Cell Burst Ratio']);


% baseline ~6hr before inj vs 24hours later
h3 = [];
[h1(end+1),ERateBaselineData,ERateBaseline24Data,baselineStateIntervals,baseline24StateIntervals] =...
    VariablesByIntervalAndState(EPopRate_tsd,baseint,base24int,states);
AboveTitle([basename '- ' InjectionType '- BaselineVBaseline+24 - ECell Pop Rate']);
[h1(end+1),IRateBaselineData,IRateBaseline24Data] = VariablesByIntervalAndState(IPopRate_tsd,baseint,base24int,states);
AboveTitle([basename '- ' InjectionType '- BaselineVBaseline+24 - ICell Pop Rate']);
[h3(end+1),hrlrBaselineData,hrlrBaseline24Data] = VariablesByIntervalAndState(hrlr_tsd,baseint,base24int,states);
AboveTitle([basename '- ' InjectionType '- BaselineVBaseline+24 - HR/LR Rate Ratio']);
[h3(end+1),hrBaselineData,hrBaseline24Data] = VariablesByIntervalAndState(hr_tsd,baseint,base24int,states);
AboveTitle([basename '- ' InjectionType '- BaselineVBaseline+24 - High FR Cell Rate']);
[h3(end+1),lrBaselineData,lrBaseline24Data] = VariablesByIntervalAndState(lr_tsd,baseint,base24int,states);
AboveTitle([basename '- ' InjectionType '- BaselineVBaseline+24 - Low FR Cell Rate']);
[h3(end+1),CoVBaselineData,CoVBaseline24Data] = VariablesByIntervalAndState(CoV_tsd,baseint,base24int,states);
AboveTitle([basename '- ' InjectionType '- BaselineVBaseline+24 - Population FR CoV']);
[h3(end+1),EIRBaselineData,EIRBaseline24Data] = VariablesByIntervalAndState(EIR_tsd,baseint,base24int,states);
AboveTitle([basename '- ' InjectionType '- BaselineVBaseline+24 - E:I Ratio']);
[h3(end+1),BurstEBaselineData,BurstEBaseline24Data] = VariablesByIntervalAndState(BurstE_tsd,baseint,base24int,states);
AboveTitle([basename '- ' InjectionType '- BaselineVBaseline+24 - E Cell Burst Ratio']);

KetamineBinnedDataByIntervalState = v2struct(...
    ERateInjm1Data,ERateInjp1Data,...
    IRateInjm1Data,IRateInjp1Data,...
    hrlrInjm1Data,hrlrInjp1Data,...
    hrInjm1Data,hrInjp1Data,...
    lrInjm1Data,lrInjp1Data,...
    CoVInjm1Data,CoVInjp1Data,...
    EIRInjm1Data,EIRInjp1Data,...
    BurstEInjm1Data,BurstEInjp1Data,...
    ERateInjp2Data,IRateInjp2Data,hrlrInjp2Data,hrInjp2Data,...
    lrInjp2Data,CoVInjp2Data,EIRInjp2Data,BurstEInjp2Data,...
    ERateBaselineData,ERateBaseline24Data,...
    IRateBaselineData,IRateBaseline24Data,...
    hrlrBaselineData,hrlrBaseline24Data,...
    hrBaselineData,hrBaseline24Data,...
    lrBaselineData,lrBaseline24Data,...
    CoVBaselineData,CoVBaseline24Data,...
    EIRBaselineData,EIRBaseline24Data,...
    BurstEBaselineData,BurstEBaseline24Data,...
    baselineStateIntervals,baseline24StateIntervals,...
    InjM1StateIntervals,InjP1StateIntervals,...
    InjP2StateIntervals,...
    baseint,base24int,injm1int,injp1int,injp2int);

save(fullfile(basepath,[basename '_KetamineBinnedDataByIntervalState.mat']),'KetamineBinnedDataByIntervalState')

savefigsasindir(fullfile(basepath,[basename '_BinnedSpikeStatsFig']),h,'fig')
savefigsasindir(fullfile(basepath,'BinnedDataInjectionPreHourVPostHour'),h1,'fig')
savefigsasindir(fullfile(basepath,'BinnedDataBaselineVPost2Hour'),h1,'fig')
savefigsasindir(fullfile(basepath,'BinnedDataBaselineVBaselinePlus24'),h3,'fig')

function [h,int1datavals,int2datavals,int1states,int2states] = VariablesByIntervalAndState(datatsd,int1,int2,states)

states = IDXtoINT(states);

WAKEInts = intervalSet(states{1}(:,1), states{1}(:,2));
MAInts = intervalSet(states{2}(:,1), states{2}(:,2));
NREMInts = intervalSet(states{3}(:,1), states{3}(:,2));
REMInts = intervalSet(states{5}(:,1), states{5}(:,2));

int1WAKE = intersect(int1,WAKEInts);
int2WAKE = intersect(int2,WAKEInts);
int1MA = intersect(int1,MAInts);
int2MA = intersect(int2,MAInts);
int1NREM = intersect(int1,NREMInts);
int2NREM = intersect(int2,NREMInts);
int1REM = intersect(int1,REMInts);
int2REM = intersect(int2,REMInts);

int1states = v2struct(int1WAKE,int1MA,int1NREM,int1REM);
int2states = v2struct(int2WAKE,int2MA,int2NREM,int2REM);

%do restrict stuff below
int1vals = Data(Restrict(datatsd,int1));
int2vals = Data(Restrict(datatsd,int2));
int1WAKEvals = Data(Restrict(datatsd,int1WAKE));
int2WAKEvals = Data(Restrict(datatsd,int2WAKE));
int1MAvals = Data(Restrict(datatsd,int1MA));
int2MAvals = Data(Restrict(datatsd,int2MA));
int1NREMvals = Data(Restrict(datatsd,int1NREM));
int2NREMvals = Data(Restrict(datatsd,int2NREM));
int1REMvals = Data(Restrict(datatsd,int1REM));
int2REMvals = Data(Restrict(datatsd,int2REM));

int1datavals = v2struct(int1vals,int1WAKEvals,int1MAvals,int1NREMvals,int1REMvals);
int2datavals = v2struct(int2vals,int2WAKEvals,int2MAvals,int2NREMvals,int2REMvals);

h = figure;
subplot(1,6,1);
distributionPlot({int1vals,int2vals},'color',{'k','b'},'xNames',{'Baseline','Baseline+24hr'})
set(gca,'yscale','log')
set(gca,'xtick',[1 2],'XTickLabel',{'Baseline','Baseline+24hr'})
xticklabel_rotate

subplot(1,6,3:6);
distributionPlot({int1WAKEvals,int2WAKEvals,nan,int1MAvals,int2MAvals,nan,int1NREMvals,int2NREMvals,nan,int1REMvals,int2REMvals},...
    'color',{'k','b','k','k','b','k','k','b','k','k','b','k'})
set(gca,'yscale','log')
set(gca,'xtick',[1:11],'XTickLabel',{'BaseWAKE','Base+24hrWAKE','',...
    'BaseMA','Base+24hrMA','',...
    'BaseNREM','Base+24hrNREM','',...
    'BaseREM','Base+24hrREM'})
xticklabel_rotate


% load('Splinter_021215_SleepScore_FromStateEditor.mat')
% 
% %change time span???
% first5hrInt = intervalSet(0,3600*5);
% last5hrInt = intervalSet(max(HighLowFRRatioData.bincentertimes)-3600*5,max(HighLowFRRatioData.bincentertimes));
% 
% NREMInts = StateIntervals.NREMpacket;
% REMInts = StateIntervals.REMepisode;
% WAKEInts = StateIntervals.WAKEeposode;
% MAInts = StateIntervals.MAstate;
% 
% earlyNREMints = intersect(first5hrInt,intervalSet(NREMInts(:,1),NREMInts(:,2)));
% lateNREMints = intersect(last5hrInt,intervalSet(NREMInts(:,1),NREMInts(:,2)));
% earlyREMints = intersect(first5hrInt,intervalSet(REMInts(:,1),REMInts(:,2)));
% lateREMints = intersect(last5hrInt,intervalSet(REMInts(:,1),REMInts(:,2)));
% earlyWAKEints = intersect(first5hrInt,intervalSet(WAKEInts(:,1),WAKEInts(:,2)));
% lateWakeints = intersect(last5hrInt,intervalSet(WAKEInts(:,1),WAKEInts(:,2)));
% earlyMAints = intersect(first5hrInt,intervalSet(MAInts(:,1),MAInts(:,2)));
% lateMAints = intersect(last5hrInt,intervalSet(MAInts(:,1),MAInts(:,2)));
% 
% %do restrict stuff below
% 
% earlyHrRates = HighLowFRRatioData.hr(1:4000);
% lateHrRates = HighLowFRRatioData.hr(end-3999:end);
% 
% earlyLrRates = HighLowFRRatioData.lr(1:4000);
% lateLrRates = HighLowFRRatioData.lr(end-3999:end);

