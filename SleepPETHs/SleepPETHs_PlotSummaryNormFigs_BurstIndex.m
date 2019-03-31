function SleepPETHs_PlotSummaryNormFigs_BurstIndex
PF = '/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/';
h = [];

load(fullfile(PF,'BurstIndex','MeanBurstIndexOverSleepInts.mat'))
statenames = MeanBurstIndexOverSleepInts.statenames;

%% for tstate = 1:length(statenames);
h(end+1) = figure('name','BurstIdxEOverStates','position',[2 2 400 800]);
for a = 1:length(statenames);
    ax = subplot(3,2,a);
    t = MeanBurstIndexOverSleepInts.AllEpAlignedE;
    PlotPETHNormAxesData(t{a},ax);
    title ([statenames{a}],'fontweight','normal')
    ylabel('% of initial value')
end

h(end+1) = figure('name','BurstIdxIOverStates','position',[2 2 400 800]);
for a = 1:length(statenames);
    ax = subplot(3,2,a);
    t = MeanBurstIndexOverSleepInts.AllEpAlignedI;
    PlotPETHNormAxesData(t{a},ax);
    title ([statenames{a}],'fontweight','normal')
    ylabel('% of initial value')
end



MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Summaries/',h)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Summaries/',h,'png')
