function SleepPETHs_PlotSummaryNormFigs_UPEICoV
PF = '/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/';
h = [];

load(fullfile(PF,'UPs','UPEICoVOverSleepInts.mat'))
statenames = UPEICoVOverSleepInts.statenames;

%% for tstate = 1:length(statenames);
h(end+1) = figure('name','UPEIOverStates','position',[2 2 400 800]);
for a = 1:length(statenames);
    ax = subplot(3,2,a);
    t = UPEICoVOverSleepInts.AllEpAlignedEIR;
    PlotPETHNormAxesData(t{a},ax);
    title ([statenames{a}],'fontweight','normal')
end

h(end+1) = figure('name','UPCoVEOverStates','position',[2 2 400 800]);
for a = 1:length(statenames);
    ax = subplot(3,2,a);
    t = UPEICoVOverSleepInts.AllEpAlignedCoVE;
    PlotPETHNormAxesData(t{a},ax);
    title ([statenames{a}],'fontweight','normal')
end

h(end+1) = figure('name','UPCoVIOverStates','position',[2 2 400 800]);
for a = 1:length(statenames);
    ax = subplot(3,2,a);
    t = UPEICoVOverSleepInts.AllEpAlignedCoVI;
    PlotPETHNormAxesData(t{a},ax);
    title ([statenames{a}],'fontweight','normal')
end


MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Summaries/',h)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Summaries/',h,'png')
