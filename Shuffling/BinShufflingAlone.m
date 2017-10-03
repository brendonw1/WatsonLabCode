function SurrogateBins = BinShufflingAlone(SpikeCount,number_of_surrogates)
% Takes a matrix of bins x cells, for each cell, randomizes which bin is
% where.  Repeats this process [number_of_surrogates] times and stores in
% SurrogateBins.

SurrogateBins = zeros(size(SpikeCount,1),size(SpikeCount,2),number_of_surrogates);
for surr_idx = 1:number_of_surrogates
    for neuron_idx = 1:size(SpikeCount,1)
        SurrogateBins(neuron_idx,:,surr_idx) = SpikeCount(neuron_idx,randperm(size(SpikeCount,2)));
    end
end