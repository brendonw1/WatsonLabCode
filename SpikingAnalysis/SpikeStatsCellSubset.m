function niss = SpikeStatsCellSubset(iss,subset)
% takes a spike stats file (ie from SpikeStatsInIntervals) and extracts
% only information correspoinding to the subset OF CELLS specified in the 
% vector "subset".  "Subset" is a list of indices to keep.

niss = iss;
missing = setdiff(1:size(iss.S,1),subset);

%% No need to change
% niss.intstarts(missing) = [];
% niss.intends(missing) = [];

%% No longer in matrices, too big
% % niss.s(missing) = [];

%% Straight matrix deletion works
niss.S = iss.S(subset);
niss.spkts(:,missing) = [];
niss.spkbools(:,missing) = [];
niss.spkcounts(:,missing) = [];
niss.spkrates(:,missing) = [];
niss.spkrelativerates(:,missing) = [];
niss.meanspktsfromstart(:,missing) = [];
niss.firstspktsfromstart(:,missing) = [];
niss.meanspktsfrompeak(:,missing) = [];
niss.firstspktsfrompeak(:,missing) = [];
niss.meanspktsfromstart_capped(:,missing) = [];
niss.meanspktsfrompeak_capped(:,missing) = [];

%% Needs actual re-calculations
niss.intcellcounts = sum(niss.spkbools,2);
niss.intspkcounts = sum(niss.spkcounts,2);

