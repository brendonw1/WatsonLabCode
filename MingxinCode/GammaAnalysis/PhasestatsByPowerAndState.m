function [SpkphasesPowerState,PhasestatsPowerState] =PhasestatsByPowerAndState...
    (spikes,neighborPhases,cellneighborIdx,PowerStateIdx,PowerIdx,StateIdx,states,freqlist,UsingFreqIdx,GoodSleepInterval)

samplingRate = 1250;
spkphases = cell(length(spikes),length(UsingFreqIdx));
spkPowerState = cell(length(spikes),length(UsingFreqIdx));
spkLFPPower = cell(length(spikes),length(UsingFreqIdx));
spkState = cell(length(spikes),length(UsingFreqIdx));

for i = 1:length(spikes)
    spikes{i} = spikes{i}(logical(belong(GoodSleepInterval.intervalSetFormat,spikes{i})));
    spikes{i} = spikes{i}(logical(logical(round(spikes{i}*samplingRate)>0).*logical(round(spikes{i}*samplingRate)<=size(neighborPhases{1},1))));
    for j = 1:length(UsingFreqIdx)
        spkphases{i,j} = neighborPhases{cellneighborIdx(i)}(round(spikes{i}*samplingRate),UsingFreqIdx(j));
        spkPowerState{i,j} = PowerStateIdx{cellneighborIdx(i)}(round(spikes{i}*samplingRate),UsingFreqIdx(j));
        spkLFPPower{i,j} = PowerIdx{cellneighborIdx(i)}(round(spikes{i}*samplingRate),UsingFreqIdx(j));
        spkState{i,j} = StateIdx(round(spikes{i}*samplingRate));
    end
end

spk = cell(size(spkphases));
spkH = cell(size(spkphases));
spkL = cell(size(spkphases));
WAKEspk = cell(size(spkphases));
WAKEspkH = cell(size(spkphases));
WAKEspkL = cell(size(spkphases));

MAspk = cell(size(spkphases));
MAspkH = cell(size(spkphases));
MAspkL = cell(size(spkphases));

NREMspk = cell(size(spkphases));
NREMspkH = cell(size(spkphases));
NREMspkL = cell(size(spkphases));

REMspk = cell(size(spkphases));
REMspkH = cell(size(spkphases));
REMspkL = cell(size(spkphases));


for ii = 1:size(spkphases,1)
    for jj = 1:size(spkphases,2)
        spk{ii,jj} = spkphases{ii,jj};
        spkH{ii,jj} = spkphases{ii,jj}(spkLFPPower{ii,jj}==1);
        spkL{ii,jj} = spkphases{ii,jj}(spkLFPPower{ii,jj}==-1);
        
        WAKEspk{ii,jj} = spkphases{ii,jj}(spkState{ii,jj}==1);
        WAKEspkH{ii,jj} = spkphases{ii,jj}(spkPowerState{ii,jj}==1);
        WAKEspkL{ii,jj} = spkphases{ii,jj}(spkPowerState{ii,jj}==-1);
        
        if ~isempty(states{2})
            MAspk{ii,jj} = spkphases{ii,jj}(spkState{ii,jj}==2);
            MAspkH{ii,jj} = spkphases{ii,jj}(spkPowerState{ii,jj}==2);
            MAspkL{ii,jj} = spkphases{ii,jj}(spkPowerState{ii,jj}==-2);
        end
        
        NREMspk{ii,jj} = spkphases{ii,jj}(spkState{ii,jj}==3);
        NREMspkH{ii,jj} = spkphases{ii,jj}(spkPowerState{ii,jj}==3);
        NREMspkL{ii,jj} = spkphases{ii,jj}(spkPowerState{ii,jj}==-3);
        
        if length(states)==5
            REMspk{ii,jj} = spkphases{ii,jj}(spkState{ii,jj}==5);
            REMspkH{ii,jj} = spkphases{ii,jj}(spkPowerState{ii,jj}==5);
            REMspkL{ii,jj} = spkphases{ii,jj}(spkPowerState{ii,jj}==-5);
        end
    end
end
SpkphasesPowerState = v2struct(spk,spkH,spkL,WAKEspk,WAKEspkH,WAKEspkL,MAspk,MAspkH,MAspkL,...
    NREMspk,NREMspkH,NREMspkL,REMspk,REMspkH,REMspkL);

phst = PhasestatsEachCellEachFreq(spk);
phstH = PhasestatsEachCellEachFreq(spkH);
phstL = PhasestatsEachCellEachFreq(spkL);
WAKEphst = PhasestatsEachCellEachFreq(WAKEspk);
WAKEphstH = PhasestatsEachCellEachFreq(WAKEspkH);
WAKEphstL = PhasestatsEachCellEachFreq(WAKEspkL);

MAphst = PhasestatsEachCellEachFreq(MAspk);
MAphstH = PhasestatsEachCellEachFreq(MAspkH);
MAphstL = PhasestatsEachCellEachFreq(MAspkL);

NREMphst = PhasestatsEachCellEachFreq(NREMspk);
NREMphstH = PhasestatsEachCellEachFreq(NREMspkH);
NREMphstL = PhasestatsEachCellEachFreq(NREMspkL);

REMphst = PhasestatsEachCellEachFreq(REMspk);
REMphstH = PhasestatsEachCellEachFreq(REMspkH);
REMphstL = PhasestatsEachCellEachFreq(REMspkL);


PhasestatsPowerState = v2struct(phst,phstH,phstL,WAKEphst,WAKEphstH,WAKEphstL,...
    MAphst,MAphstH,MAphstL,NREMphst,NREMphstH,NREMphstL,REMphst,REMphstH,REMphstL);

end