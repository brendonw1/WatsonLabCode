function S = burstfilter(S,msburst)
% function Sbf = burstfilter(S,msburst)
% Remove any incidences of consecutive spikes in a single spike train that
% are spaced less than or equal to msburst milliseconds apart.  Typical
% might be 4ms.  

for a = 1:size(S,1)
    spks = TimePoints(S{a});
    burstspikes = find(diff(spks)/10<=msburst)+1;
    spks(burstspikes) = [];
    S{a} = tsd(spks,spks);
end