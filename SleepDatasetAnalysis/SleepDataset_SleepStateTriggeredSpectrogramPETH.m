function SleepDataset_SleepStateTriggeredSpectrogramPETH(statenumber,beforesample,aftersample,binsize,STypes,plotting)

%% Setup/input interpretation/basic calculations
if ~exist('statenumber','var')
    statenumber = 5;%default is REM
end
if ~exist('beforesample','var')
    beforesample = 100;%seconds
end
if ~exist('aftersample','var')
    aftersample = 30;%seconds
end
if ~exist('binsize','var')
    binsize = 1;%seconds
end
if exist('STypes','var')
    Ss = strfind(STypes,'S');
    try
        es = strfind(STypes(Ss+1),'e');
    catch
        es = [];
    end
    try
        is = strfind(STypes(Ss+1),'i');
    catch
        is = [];
    end
    Ss([es is]) = [];
    Sbool = ~isempty(Ss);
    Sebool = ~isempty(strfind(STypes,'Se'));
    Sibool = ~isempty(strfind(STypes,'Si'));
else
    STypes = 'S';
    Sbool = 1;
    Sebool = 0;
    Sibool = 0;
end
if ~exist('plotting','var')
    plotting = 0;%boolean for PETH command
end

% tssampfreq = 10000;%timebase of the tstoolbox objects used here
% binsize = 1;%seconds
% eventtsime = beforesample/binsize;
switch(statenumber)
    case 1 
        statestring = 'Waking'
    case 2 
        statestring = 'Drowsy';
    case 3 
        statestring = 'SWS';
    case 4 
        statestring = 'Intermed';
    case 5 
        statestring = 'REM';
end

% pethNumBeforeBins = beforesample/binsize;
% pethNumAfterBins = aftersample/binsize;
% totalNumBins = pethNumBeforeBins+pethNumAfterBins;
% beforebins = 1:pethNumBeforeBins;
% afterbins = totalNumBins-(pethNumAfterBins-1):totalNumBins;

%% Grab info on all datasets available
[names,paths] = SleepDataset_GetDatasetsDirs_UI;
n = ['PeriSleepSpiking_On_' date];


% AvailCells = [];
% rawcounts = [];
% normcounts = [];
% norminterpolatedcounts = [];
% meanperchannel = [];
allbefaftvals = {};
alldiffsPs = [];
allSpikesAnatomies = {};
Eallbefaftvals = {};
EalldiffsPs = [];
EallSpikesAnatomies = {};
Iallbefaftvals = {};
IalldiffsPs = [];
IallSpikesAnatomies = {};
BeforeSumTrains = [];
AfterSumTrains = [];
EIRatiobefaftvals = {};
EIRatiodiffsPs = [];
EIRatioSpikesAnatomies = {};
% EBeforeSumTrains = [];
% EAfterSumTrains = [];
% IBeforeSumTrains = [];
% IAfterSumTrains = [];
figs = [];

for a = 1:length(paths);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = paths{a};
    
    [TriggeredPETHSpectrumData,figs(end+1)] = SingleRecording_SleepStateTriggeredSpectrogramPETH(basepath,basename,statenumber,beforesample,aftersample,binsize,STypes);

    if Sbool
        allbefaftvals{end+1} = TriggeredPETHSpectrumData.befaftvals{1};
        allbefaftvals{end+1} = TriggeredPETHSpectrumData.befaftvals{2};
        allbefaftvals{end+1} = 0;
        alldiffsPs(end+1,:) = TriggeredPETHSpectrumData.diffsPs;
        allSpikesAnatomies{end+1} = TriggeredPETHSpectrumData.SpikesAnatomies;
    end
    if Sebool
        if sum(sum(TriggeredPETHSpectrumData.EAvailCells))
            Eallbefaftvals{end+1} = TriggeredPETHSpectrumData.Ebefaftvals{1};
            Eallbefaftvals{end+1} = TriggeredPETHSpectrumData.Ebefaftvals{2};
            Eallbefaftvals{end+1} = 0;
            EalldiffsPs(end+1,:) = TriggeredPETHSpectrumData.EdiffsPs;
            EallSpikesAnatomies{end+1} = TriggeredPETHSpectrumData.ESpikesAnatomies;
        end
    end
    if Sibool
        if sum(sum(TriggeredPETHSpectrumData.IAvailCells))
            Iallbefaftvals{end+1} = TriggeredPETHSpectrumData.Ibefaftvals{1};
            Iallbefaftvals{end+1} = TriggeredPETHSpectrumData.Ibefaftvals{2};
            Iallbefaftvals{end+1} = 0;
            IalldiffsPs(end+1,:) = TriggeredPETHSpectrumData.IdiffsPs;
            IallSpikesAnatomies{end+1} = TriggeredPETHSpectrumData.ISpikesAnatomies;
        end
    end
    if Sebool && Sibool
        if sum(sum(TriggeredPETHSpectrumData.IAvailCells)) && sum(sum(TriggeredPETHSpectrumData.EAvailCells))
            EIRatiobefaftvals{end+1} = TriggeredPETHSpectrumData.EIRatiobefaftVals{1};
            EIRatiobefaftvals{end+1} = TriggeredPETHSpectrumData.EIRatiobefaftVals{2};
            EIRatiobefaftvals{end+1} = 0;
            EIRatiodiffsPs(end+1,:) = TriggeredPETHSpectrumData.EIRatiodiffsPs;
            EIRatioSpikesAnatomies{end+1} = TriggeredPETHSpectrumData.EIRatioSpikesAnatomies;
        end
    end
end
   


% Now for a summation bar graph with display of anatomical location and
% signif
if Sbool
    figs(end+1) = figure;
    plot_meanSD_bars(allbefaftvals);
    hold on
    yl = ylim;
    ylim([yl(1) yl(2)*1.1])
    for a = 1:size(alldiffsPs,1)
        if alldiffsPs(a,1)
            plot(a*3-1.5,yl(2)*.95,'k*')
        end
        text(a*3-3,yl(2),allSpikesAnatomies{a},'FontSize',7)
    end
    title('All cell rates comparisons')
    set(figs(end),'name',['Bars&TTestfor' statestring 'Start|AllCellsPETH|'...
        num2str(beforesample) 'sPre' num2str(aftersample) 'sPost'])
end
if Sebool
    if sum(sum(TriggeredPETHSpectrumData.EAvailCells))
        figs(end+1) = figure;
        plot_meanSD_bars(Eallbefaftvals);
        hold on
        yl = ylim;
        ylim([yl(1) yl(2)*1.1])
        for a = 1:size(EalldiffsPs,1)
            if EalldiffsPs(a,1)
                plot(a*3-1.5,yl(2)*.95,'k*')
            end
            text(a*3-3,yl(2),EallSpikesAnatomies{a},'FontSize',7)
        end
        title('E Rates comparisons')
        set(figs(end),'name',['Bars&TTestfor' statestring 'Start|ECellsPETH|'...
            num2str(beforesample) 'sPre' num2str(aftersample) 'sPost'])
    end
end
if Sibool
    if sum(sum(TriggeredPETHSpectrumData.IAvailCells))
        figs(end+1) = figure;
        plot_meanSD_bars(Iallbefaftvals);
        hold on
        yl = ylim;
        ylim([yl(1) yl(2)*1.1])
        for a = 1:size(IalldiffsPs,1)
            if IalldiffsPs(a,1)
                plot(a*3-1.5,yl(2)*.95,'k*')
            end
            text(a*3-3,yl(2),IallSpikesAnatomies{a},'FontSize',7)
        end
        title('I Rates comparisons')
        set(figs(end),'name',['Bars&TTestfor' statestring 'Start|ICellsPETH|'...
            num2str(beforesample) 'sPre' num2str(aftersample) 'sPost'])
    end
end
if Sebool & Sibool
    if sum(sum(TriggeredPETHSpectrumData.IAvailCells)) & sum(sum(TriggeredPETHSpectrumData.EAvailCells))
        figs(end+1) = figure;
        plot_meanSD_bars(EIRatiobefaftvals);
        hold on
        yl = ylim;
        ylim([yl(1) yl(2)*1.1])
        for a = 1:size(EIRatiodiffsPs,1)
            if EIRatiodiffsPs(a,1)
                plot(a*3-1.5,yl(2)*.95,'k*')
            end
            text(a*3-3,yl(2),EIRatioSpikesAnatomies{a},'FontSize',7)
        end
        title('E:I Ratios')
        set(figs(end),'name',['Bars&TTestfor' statestring 'Start|EIRatioFromPETH|'...
            num2str(beforesample) 'sPre' num2str(aftersample) 'sPost'])
    end
end


% save important data into a struct
TriggeredSpectrogramPETHData = v2struct(statenumber,beforesample,aftersample,binsize,STypes,...
    allbefaftvals,alldiffsPs,allSpikesAnatomies,...
    Eallbefaftvals,EalldiffsPs,allSpikesAnatomies,...
    Iallbefaftvals,IalldiffsPs,IallSpikesAnatomies,...
    EIRatiobefaftvals,EIRatiodiffsPs,EIRatioSpikesAnatomies);

%% Output
savepath = uigetdir(cd,'Choose Where To Save Output');

n = ['SpectrogramPETHfor' statestring 'Start|' ...
            num2str(beforesample) 'sPre' num2str(aftersample) 'sPost|'...
            'On_' date];

CellStringToTextFile(names,fullfile(savepath,[n,'.txt']))%save names of datasets used on this date
save(fullfile(savepath,n),'TriggeredSpectrogramPETHData')


savethesefigsas(figs,'fig',savepath)
savethesefigsas(figs,'eps',savepath)
