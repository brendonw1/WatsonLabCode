function SleepPETHs_PlotSummaryNormFigs_ONs

PF = '/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/';
h = [];

load(fullfile(PF,'UPs','ONIncidenceOverSleepInts.mat'))
load(fullfile(PF,'UPs','ONDursIntsOverSleepInts.mat'))
load(fullfile(PF,'UPs','ONRatesOverSleepInts.mat'))
load(fullfile(PF,'UPs','ONEICoVOverSleepInts.mat'))
statenames = ONIncidenceOverSleepInts.statenames;

%% Just packets first
for tstate = 1:length(statenames);
    h(end+1) = figure('name',['ONsIn' statenames{tstate}],'position',[2 2 900 600]);

    t = ONIncidenceOverSleepInts.AllEpAlignedI;
    subplot(3,3,1)
    PlotPETHNormAxesData(t{tstate});
    title ('ON state Incidence','fontweight','normal')

    t = ONDursIntsOverSleepInts.AllEpAlignedD;
    subplot(3,3,4)
    PlotPETHNormAxesData(t{tstate});
    title ('ON state Duration','fontweight','normal')

    t = ONDursIntsOverSleepInts.AllEpAlignedI;
    subplot(3,3,7)
    PlotPETHNormAxesData(t{tstate});
    title ('Inter-ON state Intervals','fontweight','normal')

    t = ONRatesOverSleepInts.AllEpAlignedE;
    subplot(3,3,2)
    PlotPETHNormAxesData(t{tstate});
    title ('E Cell Spike Rates in ONs','fontweight','normal')

    t = ONRatesOverSleepInts.AllEpAlignedI;
    subplot(3,3,5)
    PlotPETHNormAxesData(t{tstate});
    title ('I Cell Spike Rates in ONs','fontweight','normal')

    t = ONEICoVOverSleepInts.AllEpAlignedEIR;
    subplot(3,3,8)
    PlotPETHNormAxesData(t{tstate});
    title ('EIRatio in ONs','fontweight','normal')

    t = ONEICoVOverSleepInts.AllEpAlignedCoVE;
    subplot(3,3,3)
    PlotPETHNormAxesData(t{tstate});
    title ('Coeff of Var of E Rates in ONs','fontweight','normal')

    t = ONEICoVOverSleepInts.AllEpAlignedCoVI;
    subplot(3,3,6)
    PlotPETHNormAxesData(t{tstate});
    title ('Coeff of Var of I Rates in ONs','fontweight','normal')

    AboveTitle([statenames{tstate} ' Dynamics of ON states'])
end

MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Summaries/',h)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Summaries/',h,'png')
