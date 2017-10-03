function SleepPETHs_PlotSummaryNormFigs_UPs

PF = '/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/';
h = [];

load(fullfile(PF,'UPs','UPIncidenceOverSleepInts.mat'))
load(fullfile(PF,'UPs','UPDursIntsOverSleepInts.mat'))
load(fullfile(PF,'UPs','UPRatesOverSleepInts.mat'))
load(fullfile(PF,'UPs','UPEICoVOverSleepInts.mat'))
statenames = {'SWSPackets','SWSEpisodes','Sleep'};

%% Just packets first
for tstate = 1:length(statenames);
    h(end+1) = figure('name',['UPsIn' statenames{tstate}],'position',[2 2 900 600]);

    t = UPIncidenceOverSleepInts.AllEpAlignedI;
    subplot(3,3,1)
    PlotPETHNormAxesData(t{tstate});
    title ('UP state Incidence','fontweight','normal')

    t = UPDursIntsOverSleepInts.AllEpAlignedD;
    subplot(3,3,4)
    PlotPETHNormAxesData(t{tstate});
    title ('UP state Duration','fontweight','normal')

    t = UPDursIntsOverSleepInts.AllEpAlignedI;
    subplot(3,3,7)
    PlotPETHNormAxesData(t{tstate});
    title ('Inter-UP state Intervals','fontweight','normal')

    t = UPRatesOverSleepInts.AllEpAlignedE;
    subplot(3,3,2)
    PlotPETHNormAxesData(t{tstate});
    title ('E Cell Spike Rates in UPs','fontweight','normal')

    t = UPRatesOverSleepInts.AllEpAlignedI;
    subplot(3,3,5)
    PlotPETHNormAxesData(t{tstate});
    title ('I Cell Spike Rates in UPs','fontweight','normal')

    t = UPEICoVOverSleepInts.AllEpAlignedEIR;
    subplot(3,3,8)
    PlotPETHNormAxesData(t{tstate});
    title ('EIRatio in UPs','fontweight','normal')

    t = UPEICoVOverSleepInts.AllEpAlignedCoVE;
    subplot(3,3,3)
    PlotPETHNormAxesData(t{tstate});
    title ('Coeff of Var of E Rates in UPs','fontweight','normal')

    t = UPEICoVOverSleepInts.AllEpAlignedCoVI;
    subplot(3,3,6)
    PlotPETHNormAxesData(t{tstate});
    title ('Coeff of Var of I Rates in UPs','fontweight','normal')

%     t = UPEICoVOverSleepInts.AllEpAlignedCoVI;
%     subplot(3,3,6)
%     PlotPETHNormAxesData(t{tstate});
%     title ('BurstIdx of I Rates in UPs','fontweight','normal')
    
    AboveTitle([statenames{tstate} ' Dynamics of UP states'])
end

MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Summaries/',h)
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/Summaries/',h,'png')
