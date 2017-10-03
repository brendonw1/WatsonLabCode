function [times2timestamps,mindiffs,idxs] = FindLastTimeBefore(times1,times2)
% Finds last time a times2 happened before each times1 entry.  Outputs are
% same lengths as and aligned to times1 entries).
% times1 - list of times (vector)
% times2 - list of times (vector)
% 
% Brendon Watson 2015


times1 = times1(:);
times2 = times2(:);

[m1,m2] = meshgrid(times1,times2);
d = m1-m2;
d(d<0) = NaN; %elim negative
[mindiffs,idxs] = min(d,[],1);%find nearest times1 starting on or equal each times1
times2timestamps = times2(idxs);
times2timestamps(isnan(mindiffs)) = NaN;%get rid of idxs where the difference was NaN... ie if no times2 prior to a given times1 value
idxs(isnan(mindiffs)) = NaN;