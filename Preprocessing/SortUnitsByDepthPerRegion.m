function sortedUnitsByGroup = SortUnitsByDepthPerRegion(spikes,sessionInfo)

for a = 1:length(sessionInfo.spikeGroups.groups)%for each spike group
    tgroupchannelseq = sessionInfo.spikeGroups.groups{a};
    
%     OKUnits = ismember(spikes.maxWaveformCh,tgroup);%indices
%     UnitsThisGroup = spikes.maxWaveformCh;
%     UnitsThisGroup(~OKUnits) = nan;
    
    sortedUnits = [];
    % for each channel, find waveforms with that channel as max
    for b = 1:length(tgroupchannelseq)%go in order that's in xml/sessioninfo - presumed anatomical order
        tchannel = tgroupchannelseq(b);
        tunits = find(spikes.maxWaveformCh==tchannel);
        sortedUnits = cat(2,sortedUnits,tunits);
    end
    
    
%     %NO sort by when the channel occurs, not channel number!
%     [UnitsByShank,UnitsByShankIdxs] = sort(UnitsThisGroup);
%     
%     [sortedWaveforms,sortedUnitsByWaveChanNum] =  sort(UnitsThisGroup);
% 
%     sortedUnits(isnan(sortedWaveforms)) = [];%remove units from other groups (that were denoted as NaN)
    
    sortedUnitsByGroup{a}  = sortedUnits;    
end
1;


    