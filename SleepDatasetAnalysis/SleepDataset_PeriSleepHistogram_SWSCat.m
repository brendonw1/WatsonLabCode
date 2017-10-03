function SleepDataset_PeriSleepHistogram_SWSCat(SType,plotting)

if ~exist('SType','var')
    SType = 'Se';
end
if ~exist('plotting','var')
    plotting = 1;%boolean for PETH command
end

[names,dirs] = SleepDataset_GetDatasetsDirs_WSWCellsSynapses;
n = ['PeriSleepSpiking_On_' date];

tssampfreq = 10000;%timebase of the tstoolbox objects used here
binsize = 2;%seconds
beforesample = 100;%seconds
aftersample = 300;%seconds
eventtime = beforesample/binsize;
pethNumBeforeBins = beforesample/binsize;
pethNumAfterBins = aftersample/binsize;

AvailCells = [];
rawcounts = [];
normcounts = [];
norminterpolatedcounts = [];

for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};
    
    switch (SType)
       case 'S'
            t = load([fullfile(dirs{a},names{a}) '_SStable.mat']);
            S = t.S;
       case 'Se'
            t = load([fullfile(dirs{a},names{a}) '_SSubtypes.mat']);
            S = t.Se;
       case 'Si'
            t = load([fullfile(dirs{a},names{a}) '_SSubtypes.mat']);
            S = t.Si;
    end
    t = load([fullfile(dirs{a},names{a}) '_Intervals.mat']);
    intervals = t.intervals;
%     t = load([fullfile(dirs{a},names{a}) '_GoodSleepInterval.mat']);
%     GoodSleepInterval = t.GoodSleepInterval;
    t = load([fullfile(dirs{a},names{a}) '_WSWEpisodes.mat']);
    WSWEpisodes = t.WSWEpisodes;

    for b = 1:size(WSWEpisodes,2)
        %% prep for plotting
        postInterval = subset(WSWEpisodes{b},2);
        preInterval = subset(WSWEpisodes{b},1);
        IncludeIntervals = intervals{3};
        [tstarts,tAvailCells,trawcounts,tnormcounts,tnorminterpolatedcounts] = TriggeredIntervalTransitionSpikingHistogram...
            (postInterval,preInterval,beforesample,aftersample,S,IncludeIntervals,tssampfreq,binsize,plotting);
        if strcmp('IntervalTriggeredSpiking',get(gcf,'name'))
            title(basename);
            set(gcf,'name',[basename, '-SleepOnsetTriggeredSpiking'])
    %         xl = xlim(gca);
            plotIntervalsStrip(gca,intervals,1/10000)
    %         xlim(xl);
            xlim([min(tstarts) max(tstarts)]);
        end
        %stack across recordings
        AvailCells = cat(1,AvailCells,tAvailCells);
        rawcounts = cat(1,rawcounts,trawcounts);
        normcounts = cat(1,normcounts,tnormcounts);
        norminterpolatedcounts = cat(1,norminterpolatedcounts,tnorminterpolatedcounts);
    end
end

%% account for cases where there are fewer than the full number of cells in each bin
counts = AccumulateStateTriggeredSpikesOverSessions(AvailCells,rawcounts,normcounts,norminterpolatedcounts,beforesample,aftersample,binsize);
% below is subsituted by function above
% AvailCellsPerBin = sum(AvailCells,1);
% gidx = find(AvailCellsPerBin);
% gcounts = norminterpolatedcounts(:,gidx);
% 
% % meancellrate = median(counts(:,beforesample/binsize-5:beforesample/binsize+5),2);
% % gcounts = gcounts./repmat(meancellrate,[1,size(gcounts,2)]);
% gAvail = AvailCellsPerBin(gidx);
% gcounts=gcounts./repmat(gAvail,[size(norminterpolatedcounts,1),1]);
% 
% if ~ismember(1,gidx) %if empties at the begninning, pad the beginning with zeros
%     lastempty = find(norminterpolatedcounts(1:pethNumBeforeBins)==0,1,'last');
%     gcounts = cat(2,zeros(1,lastempty),gcounts);
% end
% if ~ismember(length(norminterpolatedcounts),gidx) %if empties at the begninning, pad the beginning with zeros
%     firstempty = find(norminterpolatedcounts(end-pethNumAfterBins)==0,1,'first');
%     gcounts = cat(2,gcounts,zeros(1,firstempty));
% end
% 
% counts = gcounts;


%% Figure
h = figure;
subplot(2,1,1);
imagesc(counts)
subplot(2,1,2);
plot(sum(counts,1));
%     xlim([tstarts(1),tstops(end)])
hold on;
yl = ylim(gca);
plot([eventtime eventtime],yl,'c')

%% Output

% CellStringToTextFile(names,[n,'.txt'])%save names of datasets used on this date
% save(n,'CellTransferVariables')
% 
% 
% 
% savethesefigsas(h,'fig')
% savethesefigsas(h,'eps')
% 
% varstograb = {'WSEpisodes','S'};

% SleepDataset_ExecuteOnDatasets(executestring,varstograb)