function niss = SpikeStatsIntervalSubset(iss,subset)
% takes a spike stats file (ie from SpikeStatsInIntervals) and extracts
% only information correspoinding to the subset specified in the vector
% subset.  Subset is a list of indices to keep.

niss = 1;

niss = iss;
missing = setdiff(1:length(iss.intstarts),subset);

niss.intstarts(missing) = [];
niss.intends(missing) = [];
% niss.s(missing) = [];
niss.intcellcounts(missing) = [];
niss.intspkcounts(missing) = [];
niss.spkts(missing,:) = [];
niss.spkbools(missing,:) = [];
niss.spkcounts(missing,:) = [];
niss.spkrates(missing,:) = [];
niss.spkrelativerates(missing,:) = [];
niss.meanspktsfromstart(missing,:) = [];
niss.firstspktsfromstart(missing,:) = [];
niss.meanspktsfrompeak(missing,:) = [];
niss.firstspktsfrompeak(missing,:) = [];
niss.meanspktsfromstart_capped(missing,:) = [];
niss.meanspktsfrompeak_capped(missing,:) = [];
niss.intervalsubset = subset;