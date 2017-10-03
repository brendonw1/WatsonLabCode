function AllCellSpikeHistoForStateEditor
% Assuming you are in directory with data from recording of interest, will
% import spike data, make a 1sec

basename = 'BWRat17_121912';
binwidth = 100;%ms
binpersec = 1000/binwidth;
samplerate = 20000;
durationinsec = 13758;


[spiket, spikeind, numclus, iEleClu, spikeph] = ReadEl4CCG2(basename);
[numspikes,bincenters]=hist(spiket,durationinsec*binpersec);
bincenters = bincenters/samplerate*binpersec;
figure;bar(bincenters,numspikes);
maxspikes = max(numspikes);

load ([basename,'-states.mat']);
freezing=find(states==2);
tempvar = diff(freezing);
startinds = find(tempvar>1);
freezingstarts = freezing(startinds+1);
freezingstarts = cat(2,freezing(1),freezingstarts);

hold on
for a = 1:length(freezingstarts)
	plot([freezingstarts(a)*binpersec, freezingstarts(a)*binpersec],[0, maxspikes],'r:')
end

ns = reshape(numspikes,[binpersec,durationinsec]);
ns = sum(ns,1);
save ([basename,'_SpikesPerSec.mat'],'ns')
