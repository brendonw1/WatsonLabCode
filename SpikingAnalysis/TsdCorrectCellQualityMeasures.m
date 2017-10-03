for a = 1:length(ClusterQualityMeasures.SpikeEnergies);
    x = cellArray(ClusterQualityMeasures.SpikeEnergies);
    t = 10000*Range(x{a});
    d = ClusterQualityMeasures.SpikeEnergiesCell{a};
    y{a} =tsd(t,d);
end
ClusterQualityMeasures.SpikeEnergies = tsdArray(y);

for a = 1:length(ClusterQualityMeasures.SelfMahalDistances);
    x = cellArray(ClusterQualityMeasures.SelfMahalDistances);
    t = 10000*Range(x{a});
    d = ClusterQualityMeasures.SelfMahalDistancesCell{a};
    y{a} =tsd(t,d);
end
ClusterQualityMeasures.SelfMahalDistances = tsdArray(y);

save([basename '_ClusterQualityMeasures'],'ClusterQualityMeasures')