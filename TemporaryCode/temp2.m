function sortedUnitsByGroup = SortUnitsByDepthPerRegion(spikes,sessionInfo)

for a = 1:length(sessionInfo.spikeGroups.groups)%for each spike group
    tgroup = sessionInfo.spikeGroups.groups{a};
    OKUnits = ismember(spikes.maxWaveformCh,tgroup);%indices
    UnitsThisGroup = spikes.maxWaveformCh;
    UnitsThisGroup(~OKUnits) = nan;
    [sortedWaveforms,sortedUnits] =  sort(UnitsThisGroup);
    sortedUnits(isnan(sortedWaveforms)) = [];%remove units from other groups (that were denoted as NaN)
    
    sortedUnitsByGroup{a}  = sortedUnits;    
end



    