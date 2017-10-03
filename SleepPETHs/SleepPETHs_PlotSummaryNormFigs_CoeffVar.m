function SleepPETHs_PlotSummaryNormFigs_CoeffVar

PF = '/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/';
h = [];

load(fullfile(PF,'CoeffVar','CoeffVarOverSleepInts.mat'))
statenames = CoeffVarOverSleepInts.statenames;

%% for tstate = 1:length(statenames);
h(end+1) = figure('name','CoeffVarEOverStates','position',[2 2 400 800]);
for a = 1:length(statenames);
    ax = subplot(3,2,a);
    t = CoeffVarOverSleepInts.AllEpAlignedE;
    PlotPETHNormAxesData(t{a},ax);
    title ([statenames{a}],'fontweight','normal')
    ylabel('% of initial value')
end

h(end+1) = figure('name','CoeffVarIOverStates','position',[2 2 400 800]);
for a = 1:length(statenames);
    ax = subplot(3,2,a);
    t = CoeffVarOverSleepInts.AllEpAlignedI;
    PlotPETHNormAxesData(t{a},ax);
    title ([statenames{a}],'fontweight','normal')
    ylabel('% of initial value')
end



MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Summaries/',h)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Summaries/',h,'png')
