function m = TimingVectorDots(times)
% assumes meantimes = events(dim1) x cells(dim2) matrix where each entry is a time relative to event
% time.  

[numevts,numcells] = size(times);

% all non-spikes set to 0 (and all 0 times set to 1/10000)
% this works for dot product since 0 has no effect on product
times(times==0) = 1/10000;
times(isnan(times)) = 0;

% %normalize
% n = 1./sqrt(sum(rates.^2,2));%calc norms
% nr = rates.*repmat(n,[1 size(rates,2)]);%multiply

%prep 2 matrices to dot each vector against every other
mt2 = reshape(times,[numevts 1 numcells]);%flip so cells is in 3rd dimension
mt2 = repmat(mt2,[1 numevts 1]);%replicate over intervals
mt3 = permute(mt2,[2 1 3]);%make a copy that is flipped so the spindles will cross index

%calculate
m = dot(mt2,mt3,3);
