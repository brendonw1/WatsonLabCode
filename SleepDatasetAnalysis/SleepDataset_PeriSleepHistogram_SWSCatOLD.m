function SleepDataset_PeriSleepHistogram_SWSCat(SType,plotting)

if ~exist('Stype','var')
    Stype = 'all'
end
if ~exist('plotting','var')
    plotting = 1;%boolean for PETH command
end

[names,dirs] = SleepDataset_GetDatasetsDirs_WSWandSynapses;
n = ['PeriSleepSpiking_On_' date];

tssampfreq = 10000;%timebase of the tstoolbox objects used here
binsize = 10;%seconds
beforesample = 1000;%seconds
aftersample = 3000;%seconds
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
    WSEpisodes = t.WSEpisodes;
    WSBestIdx = t.WSBestIdx;
    
%     postInterval = subset(WSEpisodes{WSBestIdx},2);
%     preInterval = subset(WSEpisodes{WSBestIdx},1);
%     [AvailCells,rawcounts,normcounts,norminterpolatedcounts] = TriggeredIntervalTransitionSpikingHistogram...
%         (postInterval,preInterval,beforesample,aftersample,S,intervals,tssampfreq,binsize,plotting);
%     if strcmp('IntervalTriggeredSpiking',get(gcf,'name'))
%         title(basename);
%         set(gcf,'name',[basename, '-SleepOnsetTriggeredSpiking'])
% %         xl = xlim(gca);
%         plotIntervalsStrip(gca,intervals,1/10000)
% %         xlim(xl);
%         tstarts = get(gcf,'UserData')
%         xlim([min(tstarts) max(tstarts)]);
%     end
%     %stack across recordings
%     AvailCells = cat(1,AvailCells,AvailCells);
%     rawcounts = cat(1,rawcounts,rawcounts);
%     normcounts = cat(1,normcounts,normcounts);
%     norminterpolatedcounts = cat(1,norminterpolatedcounts,norminterpcounts);
%     
%     
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
    
%% Get spike counts per cell
    wakestart = Start(subset(WSEpisodes{WSBestIdx},1))/tssampfreq;
    sleepstart = Start(subset(WSEpisodes{WSBestIdx},2))/tssampfreq;%in seconds
    sleepstop = End(subset(WSEpisodes{WSBestIdx},2))/tssampfreq;
    [tstarts, ttcounts] = PETH (S, sleepstart , beforesample, aftersample, binsize, 0);
    
    ttcounts(:,tstarts<wakestart | tstarts>sleepstop) = 0;
    
%% accumulate SWS chunks by NaN'ing anything in between    
    [st, et] = intervalSetToVectors(intersect(subset(WSEpisodes{WSBestIdx},2),intervals{3}));
    if st(1) ~= Start(subset(WSEpisodes{WSBestIdx},2))
        et = [Start(subset(WSEpisodes{WSBestIdx},2));et];
        ststart = 1;
    else
        ststart = 2;
    end
    if st(end) ~= End(subset(WSEpisodes{WSBestIdx},2))
        st = [st;End(subset(WSEpisodes{WSBestIdx},2))];
        eend = length(et);
    else
        eend = length(et)-1;
    end
    s = et(1:eend);%finding intervals between SWSs
    e = st(ststart:end);
    s = s/tssampfreq;
    e = e/tssampfreq;
    tcounts = ttcounts;
    interpcounts = ttcounts;
    for b = 1:length(s)
        g = tstarts>=s(b) & tstarts<=e(b);
        fg = find(g);
        tcounts(:,g) = NaN;
        if ~isempty(fg)
            for c = 1:size(tcounts,1);
                try
                    interpcounts(c,fg) = linspace(tcounts(c,fg(1)-1),tcounts(c,fg(end)+1),length(fg));
                catch
                    interpcounts(c,fg) = tcounts(c,fg(1)-1)*ones(1,length(fg));
                end
            end
        end
    end
    
%% alternate: Cat together SWS chunks     
%     [s, e] = intervalSetToVectors(intersect(subset(WSEpisodes{WSBestIdx},2),intervals{3}));
%     s = s/tssampfreq;
%     e = e/tssampfreq;
%     tcounts = ttcounts(:,tstarts<sleepstart);%grab part before sleep start
%     tstarts = ttstarts(:,tstarts<sleepstart);
%     for b = 1:length(s);
%         g = ttstarts>=s(b) & ttstarts<=e(b);
%         tcounts = cat(2,tcounts,ttcounts(:,g));
%     %        numpointscut = e(b)-s(b)-1;
%         tstarts = cat(2,tstarts,ttstarts(g));
%     end
    
    
    % clear places late in these plots where sleep was no longer ongoing 
%     tcounts(:,AvailCellsBefore == 0) = 0;
%     tcounts(:,pethNumBeforeBins+find(AvailCellsAfter) == 0) = 0;

    
    ncounts = bsxfun(@rdivide,tcounts,Rate(S));%normalize bins for each cell by global rate of that cell
    ninterpcounts = bsxfun(@rdivide,interpcounts,Rate(S));
    
    if plotting
        figure;
            plot(tstarts,sum(ninterpcounts,1),'m');%interpolated sections magenta
            hold on;
            plot(tstarts,sum(ncounts,1),'b');%rest is blue
            plot([sleepstart sleepstart],ylim(gca),'m')
        title(basename);
        set(gcf,'name',basename)
        plotIntervalsStrip(gca,intervals,1/10000)
        xlim([min(tstarts) max(tstarts)]);
    end
    
    rawcounts = cat(1,rawcounts,tcounts);
    normcounts = cat(1,normcounts,ncounts);
    norminterpolatedcounts = cat(1,norminterpolatedcounts,ninterpcounts);

end

%% account for cases where there are fewer than the full number of cells in each bin
AvailCellsPerBin = sum(AvailCells,1);
gidx = find(AvailCellsPerBin);
gcounts = norminterpolatedcounts(:,gidx);

% meancellrate = median(counts(:,beforesample/binsize-5:beforesample/binsize+5),2);
% gcounts = gcounts./repmat(meancellrate,[1,size(gcounts,2)]);
gAvail = AvailCellsPerBin(gidx);
gcounts=gcounts./repmat(gAvail,[size(norminterpolatedcounts,1),1]);

if ~ismember(1,gidx) %if empties at the begninning, pad the beginning with zeros
    lastempty = find(norminterpolatedcounts(1:pethNumBeforeBins)==0,1,'last');
    gcounts = cat(2,zeros(1,lastempty),gcounts);
end
if ~ismember(length(norminterpolatedcounts),gidx) %if empties at the begninning, pad the beginning with zeros
    firstempty = find(norminterpolatedcounts(end-pethNumAfterBins)==0,1,'first');
    gcounts = cat(2,gcounts,zeros(1,firstempty));
end

counts = gcounts;


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

% SleepDataset_ExecuteOnDatasets(executestring,varstograb)