PF = '/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/PETHS/';
h = [];

load(fullfile(PF,'UPs','UPIncidenceOverSleepInts.mat'))
load(fullfile(PF,'UPs','UPDursIntsOverSleepInts.mat'))
load(fullfile(PF,'UPs','UPRatesOverSleepInts.mat'))
load(fullfile(PF,'UPs','UPEICoVOverSleepInts.mat'))

%% Just packets first
for tstate = 1:7;
    h(end+1) = figure;

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
    title ('Intra-UP state Interval Lengths','fontweight','normal')

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

    AboveTitle([UPIncidenceOverSleepInts.statenames{tstate} ' Dynamics of UP states'])
end

%put EIR as 6

% Put COv as 3, 6

% put relative rates as 9

%% Sleep next


%% REM?