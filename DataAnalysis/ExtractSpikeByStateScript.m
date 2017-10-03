sleepInSamples = sleep*20000;
sleepSpikes(1).allspiket = [];
sleepSpikes(1).allspikeind = [];
wakeInSamples = wake*20000;
wakeSpikes(1).allspiket = [];
wakeSpikes(1).allspikeind = [];

for a = 1:size(sleep,1);
    inds=find(spiket>sleepInSamples(a,1) & spiket<sleepInSamples(a,2));
    sleepSpikes(a).spiket = spiket(inds);
    sleepSpikes(a).spikeind = spikeind(inds);
    sleepSpikes(1).allspiket = [sleepSpikes(1).allspiket spiket(inds)'];
    sleepSpikes(1).allspikeind = [sleepSpikes(1).allspikeind spikeind(inds)'];
end
for a = 1:size(wake,1);
    inds=find(spiket>wakeInSamples(a,1) & spiket<wakeInSamples(a,2));
    wakeSpikes(a).spiket = spiket(inds);
    wakeSpikes(a).spikeind = spikeind(inds);
    wakeSpikes(1).allspiket = [wakeSpikes(1).allspiket spiket(inds)'];
    wakeSpikes(1).allspikeind = [wakeSpikes(1).allspikeind spikeind(inds)'];
end
if exist('freezing')==1;
    freezingInSamples = freezing*20000;
    freezingSpikes(1).allspiket = [];
    freezingSpikes(1).allspikeind = [];
    for a = 1:size(freezing,1);
        inds=find(spiket>freezingInSamples(a,1) & spiket<freezingInSamples(a,2));
        freezingSpikes(a).spiket = spiket(inds);
        freezingSpikes(a).spikeind = spikeind(inds);
        freezingSpikes(1).allspiket = [freezingSpikes(1).allspiket spiket(inds)'];
        freezingSpikes(1).allspikeind = [freezingSpikes(1).allspikeind spikeind(inds)'];
    end
end


