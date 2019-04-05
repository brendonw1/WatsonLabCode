function [surrcounts,surrbools] = ShuffleTotalEventSpikesByWeights(origcounts,weights,nshuffs)
% Generates surrogate datasets for occurrence of cell by cell spiking in
% events based on a weighting vector giving at inputs (ie weights may be
% spike rates of cells, meaning the spike rates in the reshuffled
% dataset are proportional to the general spike rates).
% INPUTS
% origcounts = matrix of event (dim1) x cells (dim2) where a each
%                  coordinate gives the number of spikes by that cell in 
%                  that event  This algo will generate randomized versions of
%                  this bool
% weights = vector with one element for each cell giving relative
%                  likelihood of that cell being activated in a resampled 
%                  dataset
% nshuffs = number of randomized matrices to generate
%
% OUTPUTS
% surrcounts = surrogate counts, same dimensions as origcounts, but with a
%             third dimesion, representing shuffles
% surrbools = surrogate booleans, same as counts, but 0 spikes = 0 and any
%             spikes per event = 1;
%
%
% Brendon Watson 12/2014


% nshuffs = 100;
% R = Rate(S);
% weights = R/sum(R);
numints = size(origcounts,1);
numcells =  size(origcounts,2);
weights = weights(:);
weights = weights/sum(weights);
% binids = cumsum(round(1000*weights));%for drawing randomly from cells to fill 
% %      % a surrogate dataset with spike rates equivalent to the original dataset... 
% %      % by making a distribution with a number of bins relating to (100*) the 
% %      % spike rate of each cell... will use this below

spikesperevt = sum(origcounts,2);
% cellsperevt = round(mean(cellsperevt))*ones(numints,1);

surrbools = zeros(size(origcounts,1),size(origcounts,2),nshuffs);
surrcounts = zeros(size(origcounts,1),size(origcounts,2),nshuffs);
meansharedidxs_surr = zeros(nshuffs,1);
for a = 1:nshuffs%for each shuffle
    thissurrbools = zeros(size(origcounts));
    thissurrcounts = zeros(size(origcounts));
    for b = 1:numints%for each interval, make a new set
    %     theseids = find(origcounts(a,:));
        nevtspks = spikesperevt(b);%num spikes in each event
        tc = zeros(1,numcells);
        tb = zeros(1,numcells);

% Matlab way to resample spikes based on rates - faster        
        t = datasample(1:numcells,nevtspks,'Replace',1,'Weights',weights);
        u = unique(t);
        for c = 1:length(u)
            tc(u(c)) = sum(t==u(c));
        end
%         tb(t) = 1;

%         thissurrbools(b,:) = tb;
%         surrbools(b,:,a) = tb; 
        thissurrcounts(b,:) = tc;
        surrcounts(b,:,a) = tc; 
    end
    if rem(a,10) == 0
        disp(['Shuffle ' num2str(a) ' out of ' num2str(nshuffs) ' done'])
    end
end

surrbools = logical(surrcounts);

1;

