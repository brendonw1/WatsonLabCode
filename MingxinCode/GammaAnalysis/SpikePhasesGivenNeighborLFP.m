function [spkphases,spkPowerState,spkLFPPower,spkState] = SpikePhasesGivenNeighborLFP(spikes,neighborPhases,...
    cellneighborIdx,PowerStateIdx,PowerIdx,StateIdx,freqlist,savefile)

basepath = cd;
[~,basename] = fileparts(cd);
load(fullfile(basepath,[basename '_GoodSleepInterval.mat']),'GoodSleepInterval');

samplingRate = 1250;
spkphases = cell(length(spikes),length(freqlist));
spkPowerState = cell(length(spikes),length(freqlist));
spkLFPPower = cell(length(spikes),length(freqlist));
spkState = cell(length(spikes),length(freqlist));

for i = 1:length(spikes)
    spikes{i} = spikes{i}(logical(belong(GoodSleepInterval.intervalSetFormat,spikes{i})));
    spikes{i} = spikes{i}(round(spikes{i}*samplingRate)>0);
    for j = 1:length(freqlist)
        spkphases{i,j} = neighborPhases{cellneighborIdx(i)}(round(spikes{i}*samplingRate),j);
        spkPowerState{i,j} = PowerStateIdx{cellneighborIdx(i)}(round(spikes{i}*samplingRate),j);
        spkLFPPower{i,j} = PowerIdx{cellneighborIdx(i)}(round(spikes{i}*samplingRate),j);
        spkState{i,j} = StateIdx(round(spikes{i}*samplingRate));
        %     spkLFPPowerIdx
        %     spkphases{i,j} = spkphases{i,j}(~isnan(spkphases{i,j}));
    end
end

if savefile
    save(fullfile(basepath,[basename '_SpikePhasesAndPowerStateIdx.mat']),'spkphases','spkPowerState','spkLFPPower','spkState');
end

end