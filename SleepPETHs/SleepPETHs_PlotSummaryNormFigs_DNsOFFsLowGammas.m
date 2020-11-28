function SleepPETHs_PlotSummaryNormFigs_DNsOFFsLowGammas

PF = '/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/';
h = [];

load(fullfile(PF,'UPs','DNIncidenceOverSleepInts.mat'))
load(fullfile(PF,'UPs','DNDursIntsOverSleepInts.mat'))
load(fullfile(PF,'UPs','OFFIncidenceOverSleepInts.mat'))
load(fullfile(PF,'UPs','OFFDursIntsOverSleepInts.mat'))
load(fullfile(PF,'UPs','LowGammaIncidenceOverSleepInts.mat'))
load(fullfile(PF,'UPs','LowGammaDursIntsOverSleepInts.mat'))
statenames = DNIncidenceOverSleepInts.statenames;

%% Just packets first
for tstate = 1:length(statenames);
    h(end+1) = figure('name',['DNsOFFsLowGammasIn' statenames{tstate}],'position',[2 2 900 600]);

    t = DNIncidenceOverSleepInts.AllEpAlignedI;
    subplot(3,3,1)
    PlotPETHNormAxesData(t{tstate});
    title ('DN state Incidence','fontweight','normal')

    t = DNDursIntsOverSleepInts.AllEpAlignedD;
    subplot(3,3,4)
    PlotPETHNormAxesData(t{tstate});
    title ('DN state Duration','fontweight','normal')

    t = DNDursIntsOverSleepInts.AllEpAlignedI;
    subplot(3,3,7)
    PlotPETHNormAxesData(t{tstate});
    title ('Inter-DN state Intervals','fontweight','normal')
%% OFFs
    t = OFFIncidenceOverSleepInts.AllEpAlignedI;
    subplot(3,3,2)
    PlotPETHNormAxesData(t{tstate});
    title ('OFF state Incidence','fontweight','normal')

    t = OFFDursIntsOverSleepInts.AllEpAlignedD;
    subplot(3,3,5)
    PlotPETHNormAxesData(t{tstate});
    title ('OFF state Duration','fontweight','normal')

    t = OFFDursIntsOverSleepInts.AllEpAlignedI;
    subplot(3,3,8)
    PlotPETHNormAxesData(t{tstate});
    title ('Inter-OFF state Intervals','fontweight','normal')
%% Low Gammas
    t = LowGammaIncidenceOverSleepInts.AllEpAlignedI;
    subplot(3,3,3)
    PlotPETHNormAxesData(t{tstate});
    title ('LowGamma state Incidence','fontweight','normal')

    t = LowGammaDursIntsOverSleepInts.AllEpAlignedD;
    subplot(3,3,6)
    PlotPETHNormAxesData(t{tstate});
    title ('LowGamma state Duration','fontweight','normal')

    t = LowGammaDursIntsOverSleepInts.AllEpAlignedI;
    subplot(3,3,9)
    PlotPETHNormAxesData(t{tstate});
    title ('InterLowGamma state Intervals','fontweight','normal')    
    
    AboveTitle([statenames{tstate} ' Dynamics of DOWN, OFF, LowGammas'])
end

MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Summaries/',h)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Summaries/',h,'png')
