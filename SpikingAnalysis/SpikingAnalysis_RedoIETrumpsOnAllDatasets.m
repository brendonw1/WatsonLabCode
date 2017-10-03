function SpikingAnalysis_RedoIETrumpsOnAllDatasets
%% Get list of datasets
if exist('datasets','var')
    [names,dirs] = SleepDataset_GetDatasetsDirs(datasets);
else
    [names,dirs] = SleepDataset_GetDatasetsDirs_UI;
end
    
%% Cycle through datasets and grab any specified variables in each, to feed into the excute string
for a = 1:length(dirs);
    disp(['Starting ' names{a}])
    basename = names{a};
    basepath = dirs{a};
    
    %get data from mats and save 
    t = load(fullfile(basepath,[basename,'_CellClassificationOutput.mat']));
    CellClassOutput = t.CellClassificationOutput.CellClassOutput;
    PyrBoundary = t.CellClassificationOutput.PyrBoundary;
    
    t = load(fullfile(basepath,[basename,'_funcsynapses.mat']));
    funcsynapses = t.funcsynapses;

    % Fix this along the way
    if ~isfield(funcsynapses,'fullRawCCGMtx')
        t = load(fullfile(basepath,[basename,'_SStable.mat']));
        rawS = t.S;
        funcsynapses = FindSynapse_GetRawCCGMtx(funcsynapses,rawS);
        save(fullfile(basepath,[basename, '_funcsynapses.mat']),'funcsynapses')
    end
    
    %just cleaning up a prior error, while I'm here
    if exist([basename,'_Waveforms.mat'],'file')
        delete([basename,'_Waveforms.mat'])
    end
    
    %Find funcsynapases.ECells' that are part of CellClassOutput(:,4)== -1, set
    %back to ICells, remove from EDefinite, put in ILike and remove any Ecnxns
    %from funcsynapses... do this in BWCellClassification

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
        cd(basepath)
        
        close all
        [CellIDs,CellClassificationOutput,funcsynapses] = DealWithExcitatoryNarrowSpiker(excitnarrow,CellIDs,CellClassificationOutput,funcsynapses);
        str = input('Press any key to proceed','s');
        close all
%         
%         t = load(fullfile(basepath,[basename,'_SStable.mat']));
%         cellIx = t.cellIx;
%         shank = t.shank;
%         
%         [CellClassOutput, PyrBoundary,Waveforms] = BWCellClassification (basename, cellIx, shank, funcsynapses(1).ECells, funcsynapses(1).ICells);
%         ChgTrumpBool = 1;

        movefile(fullfile(basepath,[basename,'_CellClassificationOutput.mat']),fullfile(basepath,[basename,'_CellClassificationOutput_PreReTrump.mat']))
        movefile(fullfile(basepath,[basename,'_CellIDs.mat']),fullfile(basepath,[basename,'_CellIDs_PreReTrump.mat']))
        movefile(fullfile(basepath,[basename,'_funcsynapses.mat']),fullfile(basepath,[basename,'_funcsynapses_PreReTrump.mat']))

        save(fullfile(basepath,[basename,'_CellClassificationOutput.mat']),'CellClassificationOutput')
        save(fullfile(basepath,[basename, '_CellIDs.mat']),'CellIDs')
        save(fullfile(basepath,[basename, '_funcsynapses.mat']),'funcsynapses')

        if ~exist(fullfile(basepath,'CellClassificationFigs'),'dir')
            mkdir(fullfile(basepath,'CellClassificationFigs'))
        end
        cd(fullfile(basepath,'CellClassificationFigs'))
        saveallfigsas('fig')

        close gcf        
        
        t = load(fullfile(basepath,[basename,'_SStable.mat']));
        S = t.S;

        %% Dividing spikes by cell class (based on S variable above)
        Se = S(CellIDs.EAll);
        SeDef = S(CellIDs.EDefinite);
        SeLike = S(CellIDs.ELike);
        Si = S(CellIDs.IAll);
        SiDef = S(CellIDs.IDefinite);
        SiLike = S(CellIDs.ILike);
        SRates = Rate(S);
        SeRates = Rate(Se);
        SiRates = Rate(Si);

        movefile(fullfile(basepath,[basename '_SSubtypes.mat']),fullfile(basepath,[basename '_SSubtypes_PreReTrump.mat']))
        save(fullfile(basepath,[basename '_SSubtypes']),'Se','SeDef','SeLike','Si','SiDef','SiLike','SRates','SeRates','SiRates')
        % load([basename '_SSubtypes'])

        %% Getting binned spike times for all cells combined & for cell types... 10sec bins
        t = load(fullfile(basepath,[basename,'_Intervals.mat']));
        intervals = t.intervals;
        
        [binnedTrains,h] = SpikingAnalysis_PlotPopulationSpikeRates(basename,S,CellIDs,intervals);
        SpikingAnalysis_BinnedTrainsForStateEditor(binnedTrains,basename,basepath);

        movefile(fullfile(basepath,'RawSpikeRateFigs'),fullfile(basepath,'RawSpikeRateFigs_PreReTrump'))
        MakeDirSaveFigsThere(fullfile(basepath,'RawSpikeRateFigs'),h)
    end
    
    
end
