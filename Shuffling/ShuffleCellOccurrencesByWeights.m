function surrbools = ShuffleCellOccurrencesByWeights(origbools,weights,nshuffs)
% Generates surrogate datasets for occurrence of cell PARTICIPATION in
% events based on a weighting vector giving at inputs (ie weights may be
% spike rates of cells, meaning the occurrence rates in the reshuffled
% dataset are proportional to the general spike rates).
% INPUTS
% origbools = boolean matrix of event (dim1) x cells (dim2) where a 0 at a
%                  coordinate means a cell did not participate in that event, a 1 means it
%                  did.  This algo will generate randomized versions of
%                  this bool
% weights = vector with one element for each cell giving relative
%                  likelihood of that cell being activated in a resampled 
%                  dataset
% nshuffs = number of randomized booleans to generate
%
% OUTPUTS
% surrbools = surrogate booleans, same dimensions as origbools, but with a
%             third dimesion, representing shuffles, added
%
%
% Brendon Watson 12/2014


% nshuffs = 100;
% R = Rate(S);
% weights = R/sum(R);
numints = size(origbools,1);
numcells =  size(origbools,2);
weights = weights(:);
weights = weights/sum(weights);
binids = cumsum(round(1000*weights));%for drawing randomly from cells to fill 
%      % a surrogate dataset with spike rates equivalent to the original dataset... 
%      % by making a distribution with a number of bins relating to (100*) the 
%      % spike rate of each cell... will use this below

cellsperevt = sum(origbools,2);
% cellsperevt = round(mean(cellsperevt))*ones(numints,1);

surrbools = zeros(size(origbools,1),size(origbools,2),nshuffs);
meansharedidxs_surr = zeros(nshuffs,1);
for a = 1:nshuffs%for each shuffle
    thissurrbools = zeros(size(origbools));
    for b = 1:numints%for each interval, make a new set
    %     theseids = find(origbools(a,:));
        nevtspks = cellsperevt(b);%num spikes in each event
        tb = zeros(1,numcells);

% % Matlab way to resample spikes based on rates - faster        
%         ts = datasample(1:numcells,nevtspks,'Replace',0,'Weights',weights);
%         tb(ts) = 1;
% BW way to resample spikes based on rates - I understand it
        while sum(tb)<nevtspks%generate spikes
            deficit = nevtspks-sum(tb);
            ts = randi(binids(end),deficit,1);%generate spikes at random points (bins)
            for c = 1:length(ts)%for each spike idx, number by cell id
                idx = find(binids>=ts(c),1,'first');
                tb(1,idx) = 1;        
            end
        end
% end

        thissurrbools(b,:) = tb;
        surrbools(b,:,a) = tb; 
    end
    if rem(a,10) == 0
        disp(['Shuffle ' num2str(a) ' out of ' num2str(nshuffs) ' done'])
    end
end
1;

