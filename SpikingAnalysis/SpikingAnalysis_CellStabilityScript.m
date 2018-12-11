function SpikingAnalysis_CellStabilityScript(basepath)
% Get rid of unstable cells - fit slope to energy for each spike over recording and if
% slope has absolute value greater than 0.3, call cell unstable and
% eliminate from analysis pool

if ~exist('basepath','var')
    basepath = cd;
end
basename = bz_BasenameFromBasepath(basepath);

%%
sessionInfo = bz_getSessionInfo(basepath);

%% Load spikes
load(fullfile(basepath,[basename, '_SAll.mat']));
<<<<<<< HEAD
if ~exist('manualbadscells','var')
    manualbadcells = [];
end
=======
>>>>>>> master

% [SpikeEnergiesCell,MahalDistancesCell] = AllCellsEnergyMahalPerSpike(S,shank,cellIx,basename);
[SpikeEnergiesCell,SelfMahalDistancesCell,LRatios,IsoDistances,ISIIndices] = ClusterQualityMetrics(basepath,S,shank,cellIx,basename,sessionInfo);

% MahalDistances = AllCellsMahalPerSpike(S,shank,cellIx,basename);
for a = 1:size(S,1);
    numspikes = length(S{a});

    SelfMahalDistances{a,1} = tsd(TimePoints(S{a}),SelfMahalDistancesCell{a});
    StartDistances(a) = mean(SelfMahalDistancesCell{a}(1:round(numspikes*.2)));
    EndDistances(a) = mean(SelfMahalDistancesCell{a}((round(numspikes*.8)+1):end));
    SelfMahalDistanceChanges(a) = (EndDistances(a)-StartDistances(a))/StartDistances(a);
    
    SpikeEnergies{a,1} = tsd(TimePoints(S{a}),SpikeEnergiesCell{a});
%     SmoothedSpikeEnergies{a} = smooth(SpikeEnergiesCell{a},500);
    StartEnergies(a) = mean(SpikeEnergiesCell{a}(1:round(numspikes*.2)));
    EndEnergies(a) = mean(SpikeEnergiesCell{a}((round(numspikes*.8)+1):end));
    SpikeEnergyChanges(a) = (EndEnergies(a)-StartEnergies(a))/StartEnergies(a);
end
SelfMahalDistances = tsdArray(SelfMahalDistances);%now have a TSD array of spike distances
SpikeEnergies = tsdArray(SpikeEnergies);

autobadcells = find(abs(SpikeEnergyChanges)>0.3 | abs(SelfMahalDistanceChanges)>0.3);
% bwbadcells = find(shank == 4 & [cellIx == 3 | cellIx == 8]);

%manualbadcells comes from BadCellsFromClusteringNotes, may be empty array
allbadcells = union(autobadcells,manualbadcells);

% SpikeEnergies = AllCellsEnergyPerSpike(S,shank,cellIx,basename);
% for a = 1:size(S,1);
%     SpikeEnergies{a,1} = tsd(TimePoints(S{a}),SpikeEnergiesCell{a});
% end

%store original datastructs for ?
UnselectedSpikeTsds = v2struct(S, cellIx, shank);

%keep only good cells in S, cellIx, shank
s2 = cellArray(S);
s2(allbadcells)=[];
S = tsdArray(s2);
cellIx(allbadcells) = [];
shank(allbadcells) = [];
numgoodcells = size(S,1);
badcells = v2struct(allbadcells,autobadcells,manualbadcells);

%plotting cluster/cell stability for visualization
evalstring = ['if ismember(a,varargin{2});set(lineh,''color'',''black'');end;'...
    '[xtrend,ytrend] = trend(x,y);hold on;plot(xtrend,ytrend,''r'');',...
    'text(max(x)/10,max(y),[num2str(a),'': '',num2str(varargin{1}(a))])'];
titlestring = 'Mahal Distances for each spike for each cell.  Eliminated cells in black';
fignamestring = 'MahalDist';
plot_multiperfigure(SelfMahalDistances,5,5,titlestring,fignamestring,evalstring,SelfMahalDistanceChanges,allbadcells)
% Par = LoadPar([basename '.xml']);
evalstring = ['if ismember(a,varargin{2});set(lineh,''color'',''black'');end;'...
    '[xtrend,ytrend] = trend(x,y);hold on;plot(xtrend,ytrend,''r'');',...
    'text(max(x)/10,max(y),[num2str(a),'': '',num2str(varargin{1}(a))])'];
titlestring = 'Spike Energies for each spike for each cell.  Eliminated cells in black';
fignamestring = 'SpikeEnergy';
plot_multiperfigure(SpikeEnergies,5,5,titlestring,fignamestring,evalstring,SpikeEnergyChanges,allbadcells)


titlestring = 'L Ratio for each cell.  First point for whole span, Next 4 points are for each quadrant.  Population mean in red.';
fignamestring = [basename 'LRatios'];
evalstring = ['m = mean(data(1,:));hold on; plot([1 5],[m m],''r'');text(1.25,min([m y(1)])+.5*(max([m y(1)])-min([m y(1)])),num2str(a))'];
plot_multiperfigure(LRatios',5,5,titlestring,fignamestring,evalstring);
% LRatio is the average chance per spike NOT in the cluster that it might
% be in the cluster... as measured by 1-distance from center the cluster (actually from of an
% approximation of the cluster).  <~0.75 is good
% N. SCHMITZER-TORBERT et al 2005

titlestring = 'Isolation Distance for each cell.  First point for whole span, Next 4 points are for each quadrant.  Population mean in red.';
fignamestring = [basename 'IsoDistances'];
evalstring = ['m = mean(data(1,:));hold on; plot([1 5],[m m],''r'');text(1.25,min([m y(1)])+.5*(max([m y(1)])-min([m y(1)])),num2str(a))'];
plot_multiperfigure(IsoDistances',5,5,titlestring,fignamestring,evalstring);
%"Isolation Distance is therefore the radius in Mahalanobis distance
%of the smallest ellipsoid from the cluster center containing a number of
%noise spikes equal to the number of cluster spikes.  ~10+ is good
% N. SCHMITZER-TORBERT et al 2005

titlestring = 'ISIIndex for each cell.  First point for whole span, Next 4 points are for each quadrant.  Population mean in red.';
fignamestring = [basename 'ISIIndices'];
evalstring = ['m = mean(data(1,:));hold on; plot([1 5],[m m],''r'');text(1.25,min([m y(1)])+.5*(max([m y(1)])-min([m y(1)])),num2str(a))'];
plot_multiperfigure(ISIIndices',5,5,titlestring,fignamestring,evalstring);
%ISIIndex measures "clean-ness" of the refractory period (2ms) by measuring spikes
%there over avg spikes overall (ie 0.1 means 90% spike reduction during
%refract period)
%Fee 1996

%save figs
if ~exist(fullfile(basepath,'CellQualityFigs'),'dir')
    mkdir(fullfile(basepath,'CellQualityFigs'))
end
cd(fullfile(basepath,'CellQualityFigs'))
saveallfigsas('fig')
cd(basepath)

%putting quality metrics away neatly
ClusterQualityMeasures = v2struct(SelfMahalDistances,SelfMahalDistancesCell,...
    SelfMahalDistanceChanges,StartDistances,EndDistances,...
    SpikeEnergies,SpikeEnergiesCell,SpikeEnergyChanges,StartEnergies,...
    EndEnergies,...
    LRatios,IsoDistances,ISIIndices,...%putting quality metrics away neatly
    manualbadcells,autobadcells,allbadcells);

%cleaning up
clear MahalDistances SelfDistancesCell MahalDistanceChanges StartDistances...
    EndDistances...
    SpikeEnergies SpikeEnergiesCell SpikeEnergyChanges StartEnergies...
    EndEnergies...
    LRatios IsoDistances ISIIndices...
    bwbadcells autobadcells allbadcells...
    a s2 numspikes titlestring evalstring

save([basename '_ClusterQualityMeasures'],'ClusterQualityMeasures')

close all

save([basename,'_SStable.mat'],'S','shank','cellIx','numgoodcells','badcells')

% load([basename '_ClusterQualityMeasures'])
% load([basename,'_SStable.mat'])
