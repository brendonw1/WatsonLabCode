function ReclassifyCellsAfterRedoFuncSynapses(basepath,basename)

%% Get loaded up
if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

c = load(fullfile(basepath,[basename '_CellIDs.mat']));
OldCellIDs = c.CellIDs;

load(fullfile(basepath,[basename '_funcsynapsesMoreStringent.mat']));

%% Re-do basic cell labeling based on waveform shape and prior boundary by user
[CellClassOutput, PyrBoundary] = RedoCellClass(funcsynapses(1).ECells, funcsynapses(1).ICells,basepath,basename);
CellClassificationOutput = v2struct(CellClassOutput,PyrBoundary);

%% Re-create CellIDs
CellIDs.EDefinite = funcsynapses(1).ECells';%First approximation... will handle special case later
CellIDs.IDefinite = funcsynapses(1).ICells';%inhibitory interactions 
CellIDs.ELike = find((CellClassOutput(:,4)==1) & (CellClassOutput(:,5)==0));
CellIDs.ILike = find((CellClassOutput(:,4)==-1) & (CellClassOutput(:,5)==0));
CellIDs.EAll = union(CellIDs.EDefinite,CellIDs.ELike);
CellIDs.IAll = union(CellIDs.IDefinite,CellIDs.ILike);
CellClassificationOutput = v2struct(CellClassOutput,PyrBoundary);


% test for ERROR of narrowspiking cell that was called excitatory 
excitnarrow = intersect(funcsynapses(1).ECells,find(CellClassificationOutput.CellClassOutput(:,4)==-1))';
if ~isempty(excitnarrow)
    close all
    [CellIDs,CellClassificationOutput,funcsynapses] = DealWithExcitatoryNarrowSpiker(excitnarrow,CellIDs,CellClassificationOutput,funcsynapses);
    str = input('Press any key to proceed','s');
    close all
%     [CellClassOutput, PyrBoundary, Waveforms] = BWCellClassification (basename, cellIx, shank, funcsynapses(1).ECells, funcsynapses(1).ICells);
    [CellClassOutput, PyrBoundary] = RedoCellClass(funcsynapses(1).ECells, funcsynapses(1).ICells,basepath,basename);
end

save(fullfile(basepath,[basename, '_CellIDs.mat']),'CellIDs')
save(fullfile(basepath,[basename,'_CellClassificationOutput.mat']),'CellClassificationOutput')

%% Dividing spikes by cell class (based on S variable above)
[Se,SeDef,SeLike,Si,SiDef,SiLike,SRates,SeRates,SiRates] = MakeSSubtypes(basepath,basename);


%% Compare Old and new CellIDs
ed = setdiff(CellIDs.EAll,OldCellIDs.EAll);
id = setdiff(CellIDs.IAll,OldCellIDs.IAll);

if numel(ed)>0 || numel(id)>0
    disp(['Difference in ALLs in ' basename ''])
end


