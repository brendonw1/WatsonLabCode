function [counts,bincenters,binstarts,binstops] = CrossCorrelateByMesh(times1,times2,binwidth,mintime,maxtime)
% Generates corellogram between two timeseries (times1 and times1) given as
% vectors.  times2 serves as the reference vector (0 timestamp), outputs
% are counts of times1 events relative to times2 (within the window
% specified via mintime to maxtime).  Uses diff of a meshgrid... advantage
% is it's faster than loop-based methods, problem is it's quite memory
% intensive.
% 
% INPUTS
% times1 & times2: vectors of timeseries, in units of seconds
% binwidth: width of output bins (in seconds)
% mintime: start of window, relative to reference, to output counts for
% maxtime: end of window, relative to reference, to output counts for
%
% OUTPUTS
% counts: histogram counts in specified bins
% bincenters: center times of bins
% binstarts: start times of bins
% binstops: stop times of bins
%
% Brendon Watson 2015


%% Prepare
times1 = times1(:);
times2 = times2(:);

%% Meshgrid and subtract spindles-ups
[mesh1,mesh2] = meshgrid(times1,times2);
diffs = mesh1-mesh2;
diffs = diffs(:);

%% histc
binstarts = [mintime:binwidth:maxtime-binwidth];
binstops = [mintime+binwidth:binwidth:maxtime];
bincenters = [mintime+binwidth/2:binwidth:maxtime-binwidth/2];

counts = histc(diffs,binstarts);