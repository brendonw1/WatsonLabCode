function SleepDataset_IntervalSetTriggeredSpectrogramPETH(basenames,basepaths,intervalset,beforesample,aftersample,STypes,plotting)

%% Setup/input interpretation/basic calculations

if ~exist('beforesample','var')
    beforesample = 100;%seconds
end
if ~exist('aftersample','var')
    aftersample = 30;%seconds
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

% pethNumBeforeBins = beforesample/binsize;
% pethNumAfterBins = aftersample/binsize;
% totalNumBins = pethNumBeforeBins+pethNumAfterBins;
% beforebins = 1:pethNumBeforeBins;
% afterbins = totalNumBins-(pethNumAfterBins-1):totalNumBins;

%% Grab info on all datasets available
% [names,paths] = SleepDataset_GetDatasetsDirs_WSW;
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
% EBeforeSumTrains = [];
% EAfterSumTrains = [];
% IBeforeSumTrains = [];
% IAfterSumTrains = [];
figs = [];

for a = 1:length(basepaths);
    disp(['Starting ' basenames{a}])
    basename = basenames{a};
    basepath = basepaths{a};
    
    [TriggeredPETHSpectrumData,figs(end+1)] = SingleRecording_IntervalSetTriggeredSpectrogramPETH(basepath,basename,intervalset,beforesample,aftersample,STypes);

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
            IalldiffsPs(end+1,:) = TriggeredPETHSpectrumData.IdiffsPs;
            IallSpikesAnatomies{end+1} = TriggeredPETHSpectrumData.ISpikesAnatomies;
        end
    end
end
   
%managing a little input/display figure for the name of the interval
itb = findobj('Tag','IntervalTypeBox');
close(ith);

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


% save important data into a struct
TriggeredPETHData = v2struct(statenumber,beforesample,aftersample,STypes,...
    pethNumBeforeBins,pethNumAfterBins,...
    allbefaftvals,alldiffsPs,allSpikesAnatomies,...
    Eallbefaftvals,EalldiffsPs,allSpikesAnatomies,...
    Iallbefaftvals,IalldiffsPs,IallSpikesAnatomies);

%% Output
n = ['SpectrogramPETHfor' statestring 'Start|' ...
            num2str(beforesample) 'sPre' num2str(aftersample) 'sPost|'...
            'On_' date];

CellStringToTextFile(basenames,[n,'.txt'])%save names of datasets used on this date
save(n,'TriggeredPETHData')

savethesefigsas(figs,'fig')
savethesefigsas(figs,'eps')
