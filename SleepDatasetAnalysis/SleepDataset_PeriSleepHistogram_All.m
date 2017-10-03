function SleepDataset_PeriSleepHistogram_All(SType)

if ~exist('Stype','var')
    Stype = 'all'
end
[names,dirs] = SleepDataset_GetDatasetsDirs_WSWandSynapses;
n = ['PeriSleepSpiking_On_' date];

tssampfreq = 10000;%timebase of the tstoolbox objects used here
binsize = 10;%seconds
beforesample = 1000;%seconds
aftersample = 3000;%seconds
plotting = 0;%boolean for PETH command
eventtime = beforesample/binsize;

pethNumBeforeBins = beforesample/binsize;
pethNumAfterBins = aftersample/binsize;

AvailCells = [];
rawcounts = [];
normcounts = [];

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
    WSEpisodes = t.WSEpisodes;
    WSBestIdx = t.WSBestIdx;
    
    
    
%% Record how many bins are fillable with each dataset in the loop based on how long the durations of the wake and sleep are
    BeforeDur = End(subset(WSEpisodes{WSBestIdx},1))-Start(subset(WSEpisodes{WSBestIdx},1));
    BeforeDur = floor(BeforeDur/tssampfreq/binsize);%#of bins long there is sleep data for
    AvailCellsBefore = [zeros(1,pethNumBeforeBins-BeforeDur) size(S,1)*ones(1,BeforeDur)];
    AvailCellsBefore = AvailCellsBefore(end-pethNumBeforeBins+1:end);
    
    AfterDur = End(subset(WSEpisodes{WSBestIdx},2))-Start(subset(WSEpisodes{WSBestIdx},2));
    AfterDur = floor(AfterDur/tssampfreq/binsize);%#of bins long there is sleep data for
    AvailCellsAfter = [size(S,1)*ones(1,AfterDur) zeros(1,pethNumAfterBins-AfterDur)];
    AvailCellsAfter = AvailCellsAfter(1:pethNumAfterBins);
    
    AvailCells = cat(1,AvailCells,[AvailCellsBefore,AvailCellsAfter]);
    
%% Get spike counts per cels
    wakestart = Start(subset(WSEpisodes{WSBestIdx},1))/tssampfreq;
    sleepstart = Start(subset(WSEpisodes{WSBestIdx},2))/tssampfreq;%in seconds
    sleepstop = End(subset(WSEpisodes{WSBestIdx},2))/tssampfreq;
    [tstarts, tcounts] = PETH (S, sleepstart , beforesample, aftersample, binsize, 0);
    
    SWSInts = intersect(subset(WSEpisodes{WSBestIdx},2),intervals{3});
    
    
    % clear places late in these plots where sleep was no longer ongoing 
%     tcounts(:,AvailCellsBefore == 0) = 0;
%     tcounts(:,pethNumBeforeBins+find(AvailCellsAfter) == 0) = 0;

    tcounts(:,tstarts<wakestart | tstarts>sleepstop) = 0;

    figure;plot(tstarts,sum(tcounts,1));hold on;plot([sleepstart sleepstart],ylim(gca),'m')
    
    ncounts = bsxfun(@rdivide,tcounts,Rate(S));%normalize bins for each cell by global rate of that cell

    rawcounts = cat(1,rawcounts,tcounts);
    normcounts = cat(1,normcounts,ncounts);
end

%% account for cases where there are fewer than the full number of cells in each bin
AvailCellsPerBin = sum(AvailCells,1);
gidx = find(AvailCellsPerBin);
gcounts = normcounts(:,gidx);

% meancellrate = median(counts(:,beforesample/binsize-5:beforesample/binsize+5),2);
% gcounts = gcounts./repmat(meancellrate,[1,size(gcounts,2)]);
gAvail = AvailCellsPerBin(gidx);
gcounts=gcounts./repmat(gAvail,[size(normcounts,1),1]);

if ~ismember(1,gidx) %if empties at the begninning, pad the beginning with zeros
    lastempty = find(normcounts(1:pethNumBeforeBins)==0,1,'last');
    gcounts = cat(2,zeros(1,lastempty),gcounts);
end
if ~ismember(length(normcounts),gidx) %if empties at the begninning, pad the beginning with zeros
    firstempty = find(counts(end-pethNumAfterBins)==0,1,'first');
    gcounts = cat(2,gcounts,zeros(1,lastempty));
end

% counts = gcounts;

%% Figure
h = figure;
subplot(2,1,1);
imagesc(gcounts)
subplot(2,1,2);
plot(sum(gcounts,1));
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

SleepDataset_ExecuteOnDatasets(executestring,varstograb)