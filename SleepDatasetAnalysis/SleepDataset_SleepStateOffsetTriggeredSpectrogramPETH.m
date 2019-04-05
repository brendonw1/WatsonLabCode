function SleepDataset_SleepStateOffsetTriggeredSpectrogramPETH(statenumber,beforesample,aftersample,STypes,intervalsToTransitionToNumber,plotting)

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
if ~exist('intervalsToTransitionToNumber')
    intervalsToTransitionToNumber = 3;%SWS
end
if ~exist('plotting','var')
    plotting = 0;%boolean for PETH command
end

tssampfreq = 10000;%timebase of the tstoolbox objects used here
binsize = 1;%seconds
eventtime = beforesample/binsize;
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

pethNumBeforeBins = beforesample/binsize;
pethNumAfterBins = aftersample/binsize;
totalNumBins = pethNumBeforeBins+pethNumAfterBins;
beforebins = 1:pethNumBeforeBins;
afterbins = totalNumBins-(pethNumAfterBins-1):totalNumBins;

%% Grab info on all datasets available
[names,dirs] = SleepDataset_GetDatasetsDirs_WSW;
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
EBeforeSumTrains = [];
EAfterSumTrains = [];
IBeforeSumTrains = [];
IAfterSumTrains = [];
figs = [];

for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};
    
%% load variables
    warning off
    t = load([fullfile(dirs{a},names{a}) '_Intervals.mat']);
    intervals = t.intervals;
    t = load([fullfile(dirs{a},names{a}) '_GoodSleepInterval.mat']);
    GoodSleepInterval = t.GoodSleepInterval;
    t = load([fullfile(dirs{a},names{a}) '_BasicMetaData.mat']);
    goodshanks = t.goodshanks;
%     t = load([fullfile(dirs{a},names{a}) '_WSWEpisodes.mat']);
%     WSEpisodes = t.WSEpisodes;
%     WSBestIdx = t.WSBestIdx;
    spikegroupanatomy = read_mixed_csv([fullfile(dirs{a},names{a}) '_SpikeGroupAnatomy.csv'],',');
    spikegroupanatomy = spikegroupanatomy(2:end,:);
    channelanatomy = read_mixed_csv([fullfile(dirs{a},names{a}) '_ChannelAnatomy.csv'],',');
    
    if Sbool%if want to look at all cells
        t = load([fullfile(dirs{a},names{a}) '_SStable.mat']);
        S = t.S;
    end
    if Sebool%if want to look at E/RS cells
        t = load([fullfile(dirs{a},names{a}) '_SSubtypes.mat']);
        Se = t.Se;
    end
    if Sibool%if want to look at I/FS cells
        t = load([fullfile(dirs{a},names{a}) '_SSubtypes.mat']);
        Si = t.Si;
    end
    
%             S = t.S;
%     switch (SType)
%        case 'S'
%             t = load([fullfile(dirs{a},names{a}) '_SStable.mat']);
%             S = t.S;
%        case 'Se'
%             t = load([fullfile(dirs{a},names{a}) '_SSubtypes.mat']);
%             S = t.Se;
%        case 'Si'
%             t = load([fullfile(dirs{a},names{a}) '_SSubtypes.mat']);
%             S = t.Si;
%     end
    % read spectrum from .eegstates.mat file
    t = load([fullfile(basepath,basename) '.eegstates.mat']);
    chans = t.StateInfo.Chs;

    warning on
    tcell = {};
    for b = 1:size(spikegroupanatomy,1)
       if ismember(b,goodshanks)
           tcell{end+1} = spikegroupanatomy{b,2};
       end
    end
    t = unique(tcell);
    for b = 1:length(t);
        if b == 1;
            SpikesAnatomy = [t{b}];
        else
            SpikesAnatomy = [SpikesAnatomy,'&',t{b}];
        end
    end
%% for each channel in the state editor, plot graphs
    for b = 1:length(chans)
        channum = chans(b);
        intervalsToTransitionTo = intervals{intervalsToTransitionToNumber};%restrict to REMs terminating with SWS
        intervalsToTransitionTo = dropShortIntervals(intervalsToTransitionTo,aftersample*tssampfreq);%... of proper length
        meanthischanspectra = StateStopTriggeredSpectrogram...
            (statenumber,beforesample,aftersample,channum,intervals,GoodSleepInterval,tssampfreq,basepath,basename,intervalsToTransitionTo);
        figs(end+1) = gcf;
        thischannelanat = channelanatomy{channum,2};
        
        %% gather spiking data from same time
        if Sbool
            AvailCells = [];
            rawcounts = [];
            normcounts = [];
            norminterpolatedcounts = [];
            meanBeforenormcounts = [];
            meanAfternormcounts = [];
        end
        if Sebool
            EAvailCells = [];
            Erawcounts = [];
            Enormcounts = [];
            Enorminterpolatedcounts = [];
            EmeanBeforenormcounts = [];
            EmeanAfternormcounts = [];
        end
        if Sibool
            IAvailCells = [];
            Irawcounts = [];
            Inormcounts = [];
            Inorminterpolatedcounts = [];
            ImeanBeforenormcounts = [];
            ImeanAfternormcounts = [];        
        end
        
        intervalstouse = intervals{statenumber};%use the same intervals as above, next line
        % get their bounds
        [prestops,poststops,intervalidxs] = getIntervalStopsWithinBounds(intervalstouse,beforesample,aftersample,GoodSleepInterval,tssampfreq,intervalsToTransitionTo);
        for c = 1:length(intervalidxs);        %go through each interval
            tidx = intervalidxs(c);%gather info
            preInterval = subset(intervalstouse,tidx);
            postInterval = intervalSet(End(preInterval),End(preInterval)+tssampfreq*aftersample+1);
            IncludeIntervals = [];
            %execute for each interval
            if Sbool %all cells
                [tstarts,tAvailCells,trawcounts,tnormcounts,tnorminterpolatedcounts] = TriggeredIntervalTransitionSpikingHistogram...
                    (postInterval,preInterval,beforesample,aftersample,S,IncludeIntervals,tssampfreq,binsize,plotting);
                AvailCells = cat(1,AvailCells,tAvailCells);
                rawcounts = cat(1,rawcounts,trawcounts);%2d array of all rates for all cells in all episodes, raw
                normcounts = cat(1,normcounts,tnormcounts);%each cell rate normalized to own mean in that episode
                norminterpolatedcounts = cat(1,norminterpolatedcounts,tnorminterpolatedco/mnt/packmouse/userdirs/brendonunts);%not different here from normcounts
                meanBeforenormcounts(:,end+1) = mean(mean(tnormcounts(:,1:pethNumBeforeBins),2),1);%mean rate over all cells and time points of each episode in pre period
                meanAfternormcounts(:,end+1) = mean(mean(tnormcounts(:,end-pethNumAfterBins+1:end),2),1);%... double mean as above for post period            end
            end
            if Sebool % E cells
                [tEstarts,tEAvailCells,tErawcounts,tEnormcounts,tEnorminterpolatedcounts] = TriggeredIntervalTransitionSpikingHistogram...
                    (postInterval,preInterval,beforesample,aftersample,Se,IncludeIntervals,tssampfreq,binsize,plotting);
                EAvailCells = cat(1,EAvailCells,tEAvailCells);
                Erawcounts = cat(1,Erawcounts,tErawcounts);
                Enormcounts = cat(1,Enormcounts,tEnormcounts);
                Enorminterpolatedcounts = cat(1,Enorminterpolatedcounts,tEnorminterpolatedcounts);
                EmeanBeforenormcounts(:,end+1) = mean(mean(tEnormcounts(:,1:pethNumBeforeBins),2),1);
                EmeanAfternormcounts(:,end+1) = mean(mean(tEnormcounts(:,end-pethNumAfterBins+1:end),2),1);
            end
            if Sibool % I cells
                [tIstarts,tIAvailCells,tIrawcounts,tInormcounts,tInorminterpolatedcounts] = TriggeredIntervalTransitionSpikingHistogram...
                    (postInterval,preInterval,beforesample,aftersample,Si,IncludeIntervals,tssampfreq,binsize,plotting);
                IAvailCells = cat(1,IAvailCells,tIAvailCells);
                Irawcounts = cat(1,Irawcounts,tIrawcounts);
                Inormcounts = cat(1,Inormcounts,tInormcounts);
                Inorminterpolatedcounts = cat(1,Inorminterpolatedcounts,tInorminterpolatedcounts);
                ImeanBeforenormcounts(:,end+1) = mean(mean(tInormcounts(:,1:pethNumBeforeBins),2),1);
                ImeanAfternormcounts(:,end+1) = mean(mean(tInormcounts(:,end-pethNumAfterBins+1:end),2),1);
            end
        end
        %accumulate spike counts, based on how many cells spiked in each bin
        %... function below uses norminterpolatedcounts, as of how this fcn
        %is currently written norminterpolated exactly equals normcounts
        %because include intervals is empty.
        if b == 1;%only do this once per spike train
            if Sbool
                %not
                counts = AccumulateStateTriggeredSpikesOverSessions(AvailCells,rawcounts,normcounts,norminterpolatedcounts,beforesample,aftersample,binsize);
                SumCounts = sum(counts,1);
                BeforeSumTrains(end+1,:) = SumCounts(beforebins);
                AfterSumTrains(end+1,:) = SumCounts(afterbins);

                %for normalizing for display purposes
                normtotalcounts = bwnormalize(SumCounts);
                aftersd = std(normtotalcounts(afterbins));
                aftermean = mean(normtotalcounts(afterbins));
                normtotalcounts = (normtotalcounts-aftermean)/aftersd;
                
                %for final summation bar graph
%                 [different,p] = ttest2(meanBeforenormcounts,meanAfternormcounts);
%                 allbefaftmeans{end+1} = meanBeforenormcounts;
%                 allbefaftmeans{end+1} = meanAfternormcounts;
                [different,p] = ttest2(BeforeSumTrains(end,:),AfterSumTrains(end,:));
                allbefaftvals{end+1} = BeforeSumTrains(end,:);
                allbefaftvals{end+1} = AfterSumTrains(end,:);
                allbefaftvals{end+1} = 0;
                alldiffsPs(end+1,:) = [different,p];
                allSpikesAnatomies{end+1} = SpikesAnatomy;
            end
            if Sebool
                Ecounts = AccumulateStateTriggeredSpikesOverSessions(EAvailCells,Erawcounts,Enormcounts,Enorminterpolatedcounts,beforesample,aftersample,binsize);
                ESumCounts = sum(Ecounts,1);
                EBeforeSumTrains(end+1,:) = ESumCounts(beforebins);
                EAfterSumTrains(end+1,:) = ESumCounts(afterbins);

                Enormtotalcounts = bwnormalize(ESumCounts);
                aftersd = std(Enormtotalcounts(afterbins));
                aftermean = mean(Enormtotalcounts(afterbins));
                Enormtotalcounts = (Enormtotalcounts-aftermean)/aftersd;
                
%                 [different,p] = ttest2(EmeanBeforenormcounts,EmeanAfternormcounts);
%                 Eallbefaftmeans{end+1} = EmeanBeforenormcounts;
%                 Eallbefaftmeans{end+1} = EmeanAfternormcounts;                
                [different,p] = ttest2(EBeforeSumTrains(end,:),EAfterSumTrains(end,:));
                Eallbefaftvals{end+1} = EBeforeSumTrains(end,:);
                Eallbefaftvals{end+1} = EAfterSumTrains(end,:);                
                Eallbefaftvals{end+1} = 0;
                EalldiffsPs(end+1,:) = [different,p];
                EallSpikesAnatomies{end+1} = SpikesAnatomy;
            end
            if Sibool
                Icounts = AccumulateStateTriggeredSpikesOverSessions(IAvailCells,Irawcounts,Inormcounts,Inorminterpolatedcounts,beforesample,aftersample,binsize);
                ISumCounts = sum(Icounts,1);
                IBeforeSumTrains(end+1,:) = ISumCounts(beforebins);
                IAfterSumTrains(end+1,:) = ISumCounts(afterbins);

                Inormtotalcounts = bwnormalize(ISumCounts);
                aftersd = std(Inormtotalcounts(afterbins));
                aftermean = mean(Inormtotalcounts(afterbins));
                Inormtotalcounts = (Inormtotalcounts-aftermean)/aftersd;
                
%                 [different,p] = ttest2(ImeanBeforenormcounts,ImeanAfternormcounts);
%                 Iallbefaftmeans{end+1} = ImeanBeforenormcounts;
%                 Iallbefaftmeans{end+1} = ImeanAfternormcounts;
                [different,p] = ttest2(IBeforeSumTrains(end,:),IAfterSumTrains(end,:));
                Iallbefaftvals{end+1} = IBeforeSumTrains(end,:);
                Iallbefaftvals{end+1} = IAfterSumTrains(end,:);
                Iallbefaftvals{end+1} = 0;
                IalldiffsPs(end+1,:) = [different,p];
                IallSpikesAnatomies{end+1} = SpikesAnatomy;
            end
        end
        
        %plot spiking lines onto figure initated by StateTriggeredSpectrogram
        hold on
        ttext = get(get(gca,'Title'),'String');
        ttext = {['Spectrogram from ',ttext];...
            ['Spikes From: ',SpikesAnatomy,'.  n = ',num2str(length(intervalidxs)),' episodes']};
        title(ttext)
        if Sbool
            plot(normtotalcounts*10+40,'Color','w','LineWidth',2.5)
        end
        if Sebool
            plot(Enormtotalcounts*10+40,'Color',[.2 .2 .2],'LineWidth',3)%background line for visibility
            plot(Enormtotalcounts*10+40,'Color',[.1 .7 .1],'LineWidth',1)
        end
        if Sibool
            plot(Inormtotalcounts*10+40,'Color',[.2 .2 .2],'LineWidth',3)
            plot(Inormtotalcounts*10+40,'Color',[1 .3 .3],'LineWidth',1)
        end
        set(figs(end),'name',['SpectrogramPETHfor' statestring 'Stop|' ...
            num2str(beforesample) 'sPre' num2str(aftersample) 'sPost|'...
            basename 'Ch' num2str(channum)...
            '|' SpikesAnatomy 'Spiking'])
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
    set(figs(end),'name',['Bars&TTestfor' statestring 'Stop|AllCellsPETH|'...
        num2str(beforesample) 'sPre' num2str(aftersample) 'sPost'])
end
if Sebool
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
    set(figs(end),'name',['Bars&TTestfor' statestring 'Stop|ECellsPETH|'...
        num2str(beforesample) 'sPre' num2str(aftersample) 'sPost'])
end
if Sibool
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
    set(figs(end),'name',['Bars&TTestfor' statestring 'Stop|ICellsPETH|'...
        num2str(beforesample) 'sPre' num2str(aftersample) 'sPost'])
end


% save important data into a struct
TriggeredPETHData = v2struct(statenumber,beforesample,aftersample,STypes,...
    pethNumBeforeBins,pethNumAfterBins,...
    allbefaftvals,alldiffsPs,allSpikesAnatomies,...
    Eallbefaftvals,EalldiffsPs,allSpikesAnatomies,...
    Iallbefaftvals,IalldiffsPs,IallSpikesAnatomies);

%% Output
n = ['SpectrogramPETHfor' statestring 'Stop|' ...
            num2str(beforesample) 'sPre' num2str(aftersample) 'sPost|'...
            'On_' date];

CellStringToTextFile(names,[n,'.txt'])%save names of datasets used on this date
save(n,'TriggeredPETHData')

savethesefigsas(figs,'fig')
savethesefigsas(figs,'eps')
