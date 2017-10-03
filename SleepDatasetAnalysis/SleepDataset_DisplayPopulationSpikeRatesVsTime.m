function SleepDataset_DisplayPopulationSpikeRatesVsTime
% subplot with dimensions dim1,dim2

binningfactor = 100000;%10sec
numplots = 0;
[names,dirs] = SleepDataset_GetDatasetsDirs_WSWCellsSynapses;

for a = 1:length(dirs);
    t = load([fullfile(dirs{a},names{a}) '_WSWEpisodes.mat']);
    WSWEpisodes = t.WSWEpisodes;
    numplots = numplots+size(WSWEpisodes,2);
end

[vertplots,horizplots] = determinenumsubplots(length(dirs));
adim1 = min([vertplots horizplots]);
adim2 = max([vertplots horizplots]);

[vertplots,horizplots] = determinenumsubplots(numplots);
wdim1 = min([vertplots horizplots]);
wdim2 = max([vertplots horizplots]);
clear numplots vertplots horizplots

h1 = figure;
subplot(adim1,adim2,1);
h2 = figure;
subplot(wdim1,wdim2,1);
    
plotcounter = 1;
for a = 1:length(dirs);
    t = load([fullfile(dirs{a},names{a}) '_SStable.mat']);
    S = t.S;
    t = load([fullfile(dirs{a},names{a}) '_SSubtypes.mat']);
    Se = t.Se;
    Si = t.Si;
    t = load([fullfile(dirs{a},names{a}) '_CellIDs.mat']);
    CellIDs = t.CellIDs;
    t = load([fullfile(dirs{a},names{a}) '_Intervals.mat']);
    intervals = t.intervals;
    t = load([fullfile(dirs{a},names{a}) '_WSWEpisodes.mat']);
    WSWEpisodes = t.WSWEpisodes;
    t = load([fullfile(dirs{a},names{a}) '_Motion.mat']);
    motion = t.motiondata.motion;
    motionbinary = t.motiondata.thresholdedsecs;
    clear t
        
    [binnedTrains] = SleepAnalysis_GetPopulationSpikeRateData(S,Se,Si,CellIDs);
    bt{a} = binnedTrains;
    
%     m2 = zscore(motion);    
%     m2 = decimatebymaxmin(m2',10); 
    newlen = 10*ceil(size(motionbinary,1)/10);
    extrazeros = newlen-size(motionbinary,1);
    m2 = cat(1,motionbinary,zeros(extrazeros,1));
    m2 = reshape(m2,10,size(m2,1)/10);
    m2 = sum(m2,1);
    m2 = m2*500;
    
    figure(h1)
    subplot(adim1,adim2,a);
    title(names{a})
    hold on;
    plot(binnedTrains.All,'k')
    plot(binnedTrains.EAll,'g')
    if isfield(binnedTrains,'IAll')
        plot(binnedTrains.IAll,'r')
        end
    plotIntervalsStrip(gca,intervals,1/binningfactor)
    xlim([0 length(binnedTrains.All)])
    plot(m2/10,'color',[.5 .5 .5])
%     if totalpremvmt > 300;
%         plot(1,0.8*yl,'c*','MarkerSize',10);
%     end
    WSWPreWakeAbove200 = [];
    
    for b = 1:size(WSWEpisodes,2);
        int = mergeCloseIntervals(WSWEpisodes{b},10);

        thisprewake = subset(WSWEpisodes{b},1);
        thisspan = [Start(thisprewake) End(thisprewake)]/10000;
        totalpremvmt = sum(motionbinary(thisspan(1):thisspan(2)));
        
        figure(h2)
        subplot(wdim1,wdim2,plotcounter);
        title(names{a})
        hold on;
        plot(binnedTrains.All,'k')
        plot(binnedTrains.EAll,'g')
        if isfield(binnedTrains,'IAll')
            plot(binnedTrains.IAll,'r')
            end
        plotIntervalsStrip(gca,intervals,1/binningfactor)
        xlim([Start(int) End(int)]/100000)
        plot(m2/10,'color',[.5 .5 .5])
        yl = get(gca,'ylim');
        if totalpremvmt >= 200;
            disp(names{a})
            plot(mean(thisspan)/10,0.8*yl(2),'c*','MarkerSize',10);
            WSWPreWakeAbove200(b) = 1;
        else
            WSWPreWakeAbove200(b) = 0;
        end

        plotcounter = plotcounter+1;

    end
    save
%     t = load([fullfile(dirs{a},names{a}) '_WSWEpisodes.mat']);
%     v2struct(t);
%     save([fullfile(dirs{a},names{a}) '_WSWEpisodes2.mat'],...
%         'GoodSleepInterval','WSWEpisodes','WSWBestIdx','WSEpisodes','WSBestIdx',...
%         'SWBestIdx','SEpisodes','SBestIdx','WEpisodes','WBestIdx','WSWPreWakeAbove200');    
    
end

n = ['SleepPopulation_SpikeRateVsTime_On_' date];
set(h1,'name',n)

n = ['SleepPopulation_SpikeRateVsTimePerWSW_On_' date];
set(h2,'name',n)


CellStringToTextFile(names,[n,'.txt'])%save names of datasets used on this date
save(n,'binnedTrains')

saveas(h1,get(h1,'name'),'fig')
saveas(h2,get(h2,'name'),'fig')
% epswrite(h,get(h,'name'))