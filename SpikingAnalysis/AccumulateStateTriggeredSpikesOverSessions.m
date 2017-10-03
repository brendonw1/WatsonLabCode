function counts = AccumulateStateTriggeredSpikesOverSessions(AvailCells,rawcounts,normcounts,norminterpolatedcounts,beforesample,aftersample,binsize)
% Accumulates total spiking across multiple recordings and normalizes each
% bin by the number of cells available in that bin.  Uses, as of now the 
% normalized interpolated counts output from TriggeredIntervalTransitionSpikingHistogram.m.  
% Brendon Watson 2014


pethNumBeforeBins = beforesample/binsize;%get number of bins before
pethNumAfterBins = aftersample/binsize;%get number of bins after

AvailCellsPerBin = sum(AvailCells,1);%will be a denominator
gidx = find(AvailCellsPerBin);%find bins where there were cells spiking (most bins)
counts = norminterpolatedcounts(:,gidx);%get counts from bins where there were spikes

% meancellrate = median(counts(:,beforesample/binsize-5:beforesample/binsize+5),2);
% gcounts = gcounts./repmat(meancellrate,[1,size(gcounts,2)]);
gAvail = AvailCellsPerBin(gidx);

%% Action step
counts=counts./repmat(gAvail,[size(norminterpolatedcounts,1),1]);%divide spike count by number of cells per bin

if ~ismember(1,gidx) %if empties at the begninning, pad the beginning with zeros
    lastempty = find(norminterpolatedcounts(1:pethNumBeforeBins)==0,1,'last');
    counts = cat(2,zeros(1,lastempty),counts);
end
if ~ismember(size(norminterpolatedcounts,2),gidx) %if empties at the end, pad the beginning with zeros
    firstempty = find(norminterpolatedcounts(end-pethNumAfterBins)==0,1,'first');
    counts = cat(2,counts,zeros(1,firstempty));
end