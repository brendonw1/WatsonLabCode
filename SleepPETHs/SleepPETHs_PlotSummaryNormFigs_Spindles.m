function SleepPETHs_PlotSummaryNormFigs_Ripples
PF = '/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/';
h = [];

load(fullfile(PF,'Spindles','SpindleIncidenceOverSleepInts.mat'))
load(fullfile(PF,'Spindles','SpindleDursIntsOverSleepInts.mat'))
load(fullfile(PF,'Spindles','SpindleAmpFreqOverSleepInts.mat'))
load(fullfile(PF,'Spindles','SpindleRatesOverSleepInts.mat'))
statenames = SpindleIncidenceOverSleepInts.statenames;

for tstate = 1:length(statenames);
    h(end+1) = figure('name',['SpindlesIn' statenames{tstate}],'position',[2 2 900 600]);

    t = SpindleIncidenceOverSleepInts.AllEpAlignedI;
    subplot(3,3,1)
    PlotPETHNormAxesData(t{tstate});
    title ('Spindle Incidence','fontweight','normal')

    t = SpindleDursIntsOverSleepInts.AllEpAlignedD;
    subplot(3,3,4)
    PlotPETHNormAxesData(t{tstate});
    title ('Spindle Duration','fontweight','normal')

    t = SpindleDursIntsOverSleepInts.AllEpAlignedI;
    subplot(3,3,7)
    PlotPETHNormAxesData(t{tstate});
    title ('Inter-Spindle Intervals','fontweight','normal')

    t = SpindleAmpFreqOverSleepInts.AllEpAlignedA;
    subplot(3,3,2)
    PlotPETHNormAxesData(t{tstate});
    title ('Spindle Amplitude','fontweight','normal')

    t = SpindleAmpFreqOverSleepInts.AllEpAlignedF;
    subplot(3,3,5)
    PlotPETHNormAxesData(t{tstate});
    title ('Spindle Frequency','fontweight','normal')

    t = SpindleRatesOverSleepInts.AllEpAlignedE;
    subplot(3,3,3)
    PlotPETHNormAxesData(t{tstate});
    title ('Spindle E Cell Rates','fontweight','normal')

    t = SpindleRatesOverSleepInts.AllEpAlignedI;
    subplot(3,3,6)
    PlotPETHNormAxesData(t{tstate});
    title ('Spindle I Cell Rates','fontweight','normal')

    AboveTitle([statenames{tstate} ' Dynamics of Spindles'])
end

MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Summaries/',h)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Summaries/',h,'png')
