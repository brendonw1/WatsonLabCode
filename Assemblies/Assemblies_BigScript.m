function Assemblies_BigScript(basepath,basename)


% Assemblies_BigScript
if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

savepath = fullfile(basepath,'Assemblies');

SecondsPerBin = 0.1;
load(fullfile(basepath,[basename,'_SStable.mat']),'S');
load(fullfile(basepath,[basename,'_SSubtypes.mat']),'Se');
load(fullfile(basepath,[basename '_CellIDs.mat']),'CellIDs');
load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']),'WakeInts');
load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']),'SleepInts');
load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']),'WakeSleep');
load(fullfile(basepath,[basename '_StateIDA.mat']),'stateintervals');
switch class(stateintervals{1})
    case 'double'
        allwakesints = intervalSet(stateintervals{1}(:,1)*10000,stateintervals{1}(:,2)*10000);
    case 'intervalSet'
        allwakesints = stateintervals{1};
end

%% Assembly analysis (ICA training on Wake, 0.1sec bins) 
h = [];

for a = 1:length(length(WakeInts))
    WakeIntervalsInWake = intersect(allwakesints,subset(WakeInts,a));
    WSInts = timeSpan(WakeSleep{a});

    % StateRateBins = GatherStateRateBinMatrices(basepath,basename,secondsPerDetectionBin,secondsPerProjectionBin,gsi);
    % v2struct(StateRateBins);%unpacks RateMtxSpindlesE,RateMtxNDSpindlesE,RateMtxUPE,RateMtxSUPE,
    WakeBins = NonClippedBinsFromIntervals(WakeIntervalsInWake,SecondsPerBin);
    WakeBinStarts{a} = WakeBins(:,1);
    WakeBinEnds{a} = WakeBins(:,2);
    WakeBins = intervalSet(WakeBins(:,1)*10000,WakeBins(:,2)*10000);
    WSBins = NonClippedBinsFromIntervals(WSInts,SecondsPerBin);
    WSBinStarts{a} = WSBins(:,1);
    WSBinEnds{a} = WSBins(:,2);
    WSBins = intervalSet(WSBins(:,1)*10000,WSBins(:,2)*10000);

% All Cells
    WakeBinned = MakeQfromS(S,WakeBins);%bin every 1000pts, which is 100msec (10000 pts per sec)
    RateMtxWakeAll{a} = Data(WakeBinned);
    WSBinned = MakeQfromS(S,WSBins);%bin every 1000pts, which is 100msec (10000 pts per sec)
    RateMtxWSAll{a} = Data(WSBinned);
    [ICAAssTemplatesWakeAll{a},th] = GetICAAssembliesPrebinnedNoProj(RateMtxWakeAll{a},SecondsPerBin,CellIDs);
    if ~isempty(th);h(end+1) = th;end
    WakeICAProjOnWSAll{a} = ProjectAssembliesOntoBinnedMatrix_NoPlot(ICAAssTemplatesWakeAll{a},RateMtxWSAll{a});
    set(gcf,'position',[2 2 800 800],'name','WakeICAToWSAllCells')
    AboveTitle('ICA from Wake - All Cells')
    %     WakeICAOntoSWS_NS = ProjectNonSigAssembliesOntoBinnedMatrix_NoPlot(ICAAssDataWakeA,RateMtxSWSA);
      % non-signif doesn't work with ICA... I think

    WakeBinned = MakeQfromS(Se,WakeBins);%bin every 1000pts, which is 100msec (10000 pts per sec)
    RateMtxWakeE{a} = Data(WakeBinned);
    WSBinned = MakeQfromS(Se,WSBins);%bin every 1000pts, which is 100msec (10000 pts per sec)
    RateMtxWSE{a} = Data(WSBinned);
    [ICAAssTemplatesWakeE{a},th] = GetICAAssembliesPrebinnedNoProj(RateMtxWakeE{a},SecondsPerBin);
    if ~isempty(th);h(end+1) = th;end
    WakeICAProjOnWSE{a} = ProjectAssembliesOntoBinnedMatrix_NoPlot(ICAAssTemplatesWakeE{a},RateMtxWSE{a});
    set(gcf,'position',[2 2 800 800],'name','WakeICAToWSECells')
    AboveTitle('ICA from Wake - E Cells')
end
    
WakeICAAssOnWS = v2struct(SecondsPerBin,...
    WakeBinStarts, WakeBinEnds,WSBinStarts,WSBinEnds,...
    RateMtxWakeAll,RateMtxWSAll,...
    RateMtxWakeE,RateMtxWSE,...
    ICAAssTemplatesWakeAll,WakeICAProjOnWSAll,...
    ICAAssTemplatesWakeE,WakeICAProjOnWSE);
MakeDirSaveVarThere(savepath,WakeICAAssOnWS);
MakeDirSaveFigsThere(savepath,h);


% E Cells

% % All Cells
% if ~exist(fullfile(basepath,'Assemblies','WakeBasedICA'),'dir')
%     [AssemblyBasicDataWakeDetect,h] = GetAndPlotIntervalRestrictedAssembliesICAEOnly(S,WakeIntervalsInWake,0.1,tWSRI.intervals);
%     MakeDirSaveVarThere(fullfile(basepath,'Assemblies','WakeBasedICAonEI'),AssemblyBasicDataWakeDetect)
%     MakeDirSaveFigsThereAs(fullfile(basepath,'Assemblies','WakeBasedICAonEI'),h,'fig')
%     MakeDirSaveFigsThereAs(fullfile(basepath,'Assemblies','WakeBasedICAonEI'),h,'png')
%     close(h)
% end
% 
% % E Cells
% if ~exist(fullfile(basepath,'Assemblies','WakeBasedICA'),'dir')
%     [AssemblyBasicDataWakeDetect,h] = GetAndPlotIntervalRestrictedAssembliesICAEOnly(Se,WakeIntervalsInWake,0.1,tWSRI.intervals);
%     MakeDirSaveVarThere(fullfile(basepath,'Assemblies','WakeBasedICAonE'),AssemblyBasicDataWakeDetect)
%     MakeDirSaveFigsThereAs(fullfile(basepath,'Assemblies','WakeBasedICAonE'),h,'fig')
%     MakeDirSaveFigsThereAs(fullfile(basepath,'Assemblies','WakeBasedICAonE'),h,'png')
%     close(h)
% end


%% PCA Assemblies, E Only
% % Assembly analysis (PCA training on entire data, 0.1sec bins)
% if ~exist(fullfile(basepath,[basename '_AssemblyBasicData.mat']),'file')
%     [AssemblyBasicData,h] = GetAndPlotIntervalRestrictedAssembliesPCAEOnly(Se,[],0.1,tI.intervals);
%     MakeDirSaveThere(fullfile(basepath,'Assemblies','WholeBasedPCA'),'AssemblyBasicData',AssemblyBasicData)
%     MakeDirSaveFigsThereAs(fullfile(basepath,'Assemblies','WholeBasedPCA'),h,'fig')
%     MakeDirSaveFigsThereAs(fullfile(basepath,'Assemblies','WholeBasedPCA'),h,'png')
%     close(h)
% end
% % Assembly analysis (PCA training on Wake, 0.1sec bins)
% if ~exist(fullfile(basepath,'Assemblies','WakeBasedPCA'),'dir')
%     [AssemblyBasicDataWakeDetect,h] = GetAndPlotIntervalRestrictedAssembliesPCAEOnly(Se,tI.intervals{1},0.1,tI.intervals);
%     MakeDirSaveThere(fullfile(basepath,'Assemblies','WakeBasedPCA'),'AssemblyBasicDataWakeDetect',AssemblyBasicDataWakeDetect)
%     MakeDirSaveFigsThereAs(fullfile(basepath,'Assemblies','WakeBasedPCA'),h,'fig')
%     MakeDirSaveFigsThereAs(fullfile(basepath,'Assemblies','WakeBasedPCA'),h,'png')
%     close(h)
% end
% % Assembly analysis (PCA training on SWS, 0.1sec bins)
% if ~exist(fullfile(basepath,'Assemblies','SWSBasedPCA'),'dir')
%     [AssemblyBasicDataSWSDetect,h] = GetAndPlotIntervalRestrictedAssembliesPCAEOnly(Se,tI.intervals{3},0.1,tI.intervals);
%     MakeDirSaveThere(fullfile(basepath,'Assemblies','SWSBasedPCA'),'AssemblyBasicDataSWSDetect',AssemblyBasicDataSWSDetect)
%     MakeDirSaveFigsThereAs(fullfile(basepath,'Assemblies','SWSBasedPCA'),h,'fig')
%     MakeDirSaveFigsThereAs(fullfile(basepath,'Assemblies','SWSBasedPCA'),h,'png')
%     close(h)
% end
% % Assembly analysis (PCA training on REM, 0.1sec bins)
% if ~exist(fullfile(basepath,'Assemblies','REMBasedPCA'),'dir')
%     [AssemblyBasicDataREMDetect,h] = GetAndPlotIntervalRestrictedAssembliesPCAEOnly(Se,tI.intervals{5},0.1,tI.intervals);
%     MakeDirSaveThere(fullfile(basepath,'Assemblies','REMBasedPCA'),'AssemblyBasicDataREMDetect',AssemblyBasicDataREMDetect)
%     MakeDirSaveFigsThereAs(fullfile(basepath,'Assemblies','REMBasedPCA'),h,'fig')
%     MakeDirSaveFigsThereAs(fullfile(basepath,'Assemblies','REMBasedPCA'),h,'png')
%     close(h)
% end


    
%% Wake PCA Assemblies vs UP, Spindle, REM Rate Vectors

% AssembliesByState(basepath,basename)