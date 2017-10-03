function SleepPETHs_PlotSummaryNormFigs_Ripples
PF = '/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/';
h = [];

load(fullfile(PF,'Ripples','RippleIncidenceOverSleepInts.mat'))
load(fullfile(PF,'Ripples','RippleDursIntsOverSleepInts.mat'))
load(fullfile(PF,'Ripples','RippleAmpFreqOverSleepInts.mat'))
load(fullfile(PF,'Ripples','RippleRatesOverSleepInts.mat'))
statenames = RippleIncidenceOverSleepInts.statenames;

for tstate = 1:length(statenames);
    h(end+1) = figure('name',['RipplesIn' statenames{tstate}],'position',[2 2 900 600]);

    t = RippleIncidenceOverSleepInts.AllEpAlignedI;
    subplot(3,3,1)
    PlotPETHNormAxesData(t{tstate});
    title ('Ripple Incidence','fontweight','normal')

    t = RippleDursIntsOverSleepInts.AllEpAlignedD;
    subplot(3,3,4)
    PlotPETHNormAxesData(t{tstate});
    title ('Ripple Duration','fontweight','normal')

    t = RippleDursIntsOverSleepInts.AllEpAlignedI;
    subplot(3,3,7)
    PlotPETHNormAxesData(t{tstate});
    title ('Inter-Ripple Intervals','fontweight','normal')

    t = RippleAmpFreqOverSleepInts.AllEpAlignedA;
    subplot(3,3,2)
    PlotPETHNormAxesData(t{tstate});
    title ('Ripple Amplitude','fontweight','normal')

    t = RippleAmpFreqOverSleepInts.AllEpAlignedF;
    subplot(3,3,5)
    PlotPETHNormAxesData(t{tstate});
    title ('Ripple Frequency','fontweight','normal')

    t = RippleRatesOverSleepInts.AllEpAlignedE;
    subplot(3,3,3)
    PlotPETHNormAxesData(t{tstate});
    title ('Ripple E Cell Rates','fontweight','normal')

    t = RippleRatesOverSleepInts.AllEpAlignedI;
    subplot(3,3,6)
    PlotPETHNormAxesData(t{tstate});
    title ('Ripple I Cell Rates','fontweight','normal')

    AboveTitle([statenames{tstate} ' Dynamics of Ripples'])
end

MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Summaries/',h)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Summaries/',h,'png')
