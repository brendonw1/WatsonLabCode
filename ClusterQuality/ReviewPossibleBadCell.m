function ReviewPossibleBadCell(basepath,basename,cellnum,ei)

load(fullfile(basepath,[basename '-states.mat']))
load([basename '_ClusterQualityMeasures.mat'])
load([basename '_SSubtypes.mat'])
if strcmp(lower(ei),'e')
    badOrigIdxs = OriginalIndicesOfBadECells(cellnum,basename);
elseif strcmp(lower(ei),'i')
    badOrigIdxs = OriginalIndicesOfBadICells(cellnum,basename);
end
    
%% Spike Rates
eval(['tb = MakeQfromS(S' lower(ei) ',10000);'])
tb = Data(tb);
bins = tb(:,cellnum);
CellSpikes = resample(bins,size(states,2),size(bins,1))';
% CellSpikes = bins(1:end-1)';

%% Cell Energies
CellEnergySums = MakeSummedValQfromS(ClusterQualityMeasures.SpikeEnergies,10000);
CellEnergySums = Data(CellEnergySums);
CellEnergySums = CellEnergySums(:,badOrigIdxs);

CellEnergyNums = MakeQfromS(ClusterQualityMeasures.SpikeEnergies,10000);
CellEnergyNums = Data(CellEnergyNums);
CellEnergyNums = CellEnergyNums(:,badOrigIdxs);

CellEnergy = CellEnergySums./CellEnergyNums;
CellEnergy(isnan(CellEnergy)) = 0;
CellEnergy = resample(CellEnergy,size(states,2),size(CellEnergy,1))';
% CellEnergy = CellEnergy(1:end-1)';

%% Cell Mahal distances
CellMahalSums = MakeSummedValQfromS(ClusterQualityMeasures.SelfMahalDistances,10000);
CellMahalSums = Data(CellMahalSums);
CellMahalSums = CellMahalSums(:,badOrigIdxs);

CellMahalNums = MakeQfromS(ClusterQualityMeasures.SelfMahalDistances,10000);
CellMahalNums = Data(CellMahalNums);
CellMahalNums = CellMahalNums(:,badOrigIdxs);

CellMahal = CellMahalSums./CellMahalNums;
CellMahal(isnan(CellMahal)) = 0;
CellMahal = resample(CellMahal,size(states,2),size(CellMahal,1))';
% CellMahal = CellMahal(1:end-1)';

%%
out = cat(1,CellSpikes,CellEnergy,CellMahal);
save(fullfile(basepath,[basename '_StateEditorOverlay_' upper(ei) 'Cell' num2str(cellnum) '_RateEnergyMahal.mat']),'out')
