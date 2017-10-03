% Assemblies_BigScript

clear

[~,basename,~] = fileparts(cd);
basepath = cd;

t = load(fullfile(basepath,[basename '_BasicMetaData.mat']));

if ~exist(fullfile(basepath,'Assemblies'),'dir')
    mkdir(fullfile(basepath,'Assemblies'),'dir')
end

tSS = load(fullfile(basepath,[basename,'_SSubtypes.mat']));
tCI = load(fullfile(basepath,[basename, '_CellIDs.mat']));
tI = load(fullfile(basepath,[basename '_Intervals']));


%% Assembly analysis (PCA training on entire data, 0.1sec bins)
% if ~exist(fullfile(basepath,[basename '_AssemblyBasicData.mat']),'file')
    [AssemblyBasicData,h] = GetAndPlotAssemblies(tSS.Se,tCI.CellIDs,tI.intervals,0.1);
    MakeDirSaveThere(fullfile(basepath,'Assemblies','WholeBasedPCA',[basename '_AssemblyBasicData.mat']),'AssemblyBasicData',AssemblyBasicData)
    MakeDirSaveFigsThereAs(fullfile(basepath,'Assemblies','WholeBasedPCA'),h,'fig')
    MakeDirSaveFigsThereAs(fullfile(basepath,'Assemblies','WholeBasedPCA'),h,'png')
    close(h)
% end

%% Assembly analysis (ICA training on Wake, 0.1sec bins)
    [AssemblyBasicDataWakeDetect,h] = GetAndPlotIntervalRestrictedAssemblies(tSS.Se,tCI.CellIDs,tI.intervals{1},0.1,tI.intervals);
    MakeDirSaveThere(fullfile(basepath,'Assemblies','WakeBasedPCA',[basename '_AssemblyBasicDataWakeDetect.mat']),'AssemblyBasicDataWakeDetect',AssemblyBasicDataWakeDetect)
    MakeDirSaveFigsThereAs(fullfile(basepath,'Assemblies','WakeBasedPCA'),h,'fig')
    MakeDirSaveFigsThereAs(fullfile(basepath,'Assemblies','WakeBasedPCA'),h,'png')
    close(h)

%% Assembly analysis (ICA training on SWS, 0.1sec bins)
    [AssemblyBasicDataSWSDetect,h] = GetAndPlotIntervalRestrictedAssemblies(tSS.Se,tCI.CellIDs,tI.intervals{3},0.1,tI.intervals);
    MakeDirSaveThere(fullfile(basepath,'Assemblies','SWSBasedPCA',[basename '_AssemblyBasicDataSWSDetect.mat']),'AssemblyBasicDataSWSDetect',AssemblyBasicDataSWSDetect)
    MakeDirSaveFigsThereAs(fullfile(basepath,'Assemblies','SWSBasedPCA'),h,'fig')
    MakeDirSaveFigsThereAs(fullfile(basepath,'Assemblies','SWSBasedPCA'),h,'png')
    close(h)

%% Assembly analysis (ICA training on REM, 0.1sec bins)
    [AssemblyBasicDataREMDetect,h] = GetAndPlotIntervalRestrictedAssemblies(tSS.Se,tCI.CellIDs,tI.intervals{5},0.1,tI.intervals);
    MakeDirSaveThere(fullfile(basepath,'Assemblies','REMBasedPCA',[basename '_AssemblyBasicDataREMDetect.mat']),'AssemblyBasicDataREMDetect',AssemblyBasicDataREMDetect)
    MakeDirSaveFigsThereAs(fullfile(basepath,'Assemblies','REMBasedPCA'),h,'fig')
    MakeDirSaveFigsThereAs(fullfile(basepath,'Assemblies','REMBasedPCA'),h,'png')
    close(h)

    
%% Wake PCA Assemblies vs UP, Spindle, REM Rate Vectors
secondsPerDetectionBin = 1;
secondsPerProjectionBin = 1;

% pointsPerDetectionBin = secondsPerDetectionBin * 10000;
pointsPerProjectionBin = secondsPerProjectionBin * 10000;

labelsarray = {'Wake','MovWk','NMovWk','UPs','SUPs','Spindles','NDSpindles','REM'};
t = load(fullfile(basepath,[basename,'_SSubtypes.mat']));
Se = t.Se;

% Spindles
t = load(fullfile('Spindles',[basename '_SpindleSpikeStats.mat']));%load spindles with no DOWN states
sisse = t.isse;
RateMatrixSpindlesE = sisse.spkrates;
% NoDOWNSpindles
t = load(fullfile('Spindles',[basename '_SpindleNoDOWNSpikeStats.mat']));%load spindles with no DOWN states
ndsisse = t.isse;
RateMatrixNDSpindlesE = ndsisse.spkrates;
% UPstates
t = load(fullfile('UPstates',[basename '_UPSpikeStatsE.mat']));
uisse = t.isse;
RateMatrixUPstatesE = uisse.spkrates;
% SpindleUPstates
t = load(fullfile('UPstates',[basename '_SpindleUPEvents.mat']));
RateMatrixSUPstatesE = RateMatrixUPstatesE(t.SpindleUPEvents.SpindleUPs,:);
% % AllBins
% SeBinned = MakeQfromS(Se,pointsPerProjectionBin);%bin every 1000pts, which is 100msec (10000 pts per sec)
% RateMatrixAllE = Data(SeBinned);
% Wake
t = load(fullfile(basepath,[basename '_Intervals']));
wakesecs = [Start(t.intervals{1},'s') End(t.intervals{1},'s')];%for motion later
wakebins = NonClippedBinsFromIntervals(t.intervals{1},secondsPerProjectionBin);
wakebins = intervalSet(wakebins(:,1)*10000,wakebins(:,2)*10000);
WakeSeBinned = MakeQfromS(Se,wakebins);%bin every 1000pts, which is 100msec (10000 pts per sec)
RateMatrixWakeE = Data(WakeSeBinned);
% REM
REMbins = NonClippedBinsFromIntervals(t.intervals{5},secondsPerProjectionBin);
REMbins = intervalSet(REMbins(:,1)*10000,REMbins(:,2)*10000);
REMSeBinned = MakeQfromS(Se,REMbins);%bin every 1000pts, which is 100msec (10000 pts per sec)
RateMatrixREME = Data(REMSeBinned);
% Moving Wake
t = load([basename '_Motion.mat']);
wakesecs = inttobool(wakesecs,length(t.motiondata.thresholdedsecs));
movewake = wakesecs.*t.motiondata.thresholdedsecs';
movewake2 = booltoint(movewake);
mwbins = NonClippedBinsFromIntervals(movewake2,secondsPerProjectionBin);
mwbins = intervalSet(mwbins(:,1)*10000,mwbins(:,2)*10000);
MWSeBinned = MakeQfromS(Se,mwbins);%bin every 1000pts, which is 100msec (10000 pts per sec)
RateMatrixMWE = Data(MWSeBinned);
% Non-moving Wake
nonmovewake = ~movewake;
nonmovewake = nonmovewake .* wakesecs;%Have to take times that are both (notmoving) and (yeswake)
nonmovewake2 = booltoint(nonmovewake);
nmwbins = NonClippedBinsFromIntervals(nonmovewake2,secondsPerProjectionBin);
nmwbins = intervalSet(nmwbins(:,1)*10000,nmwbins(:,2)*10000);
NMWSeBinned = MakeQfromS(Se,nmwbins);%bin every 1000pts, which is 100msec (10000 pts per sec)
RateMatrixNMWE = Data(NMWSeBinned);


[AssemblyPatterns,h] = GetAndPlotIntervalRestrictedAssembliesNoProj(Se,tI.intervals{1},secondsPerDetectionBin);
% [AssemblyBasicData_AllEBins,h] = ProjectAssembliesOntoBinnedMatrix_NoPlot(AssemblyPatterns,AllERateMatrix,h);
[AssemblyBasicData_WakeEBins,h] = ProjectAssembliesOntoBinnedMatrix_NoPlot(AssemblyPatterns,RateMatrixWakeE);
[AssemblyBasicData_MWEBins,h] = ProjectAssembliesOntoBinnedMatrix_NoPlot(AssemblyPatterns,RateMatrixMWE);
[AssemblyBasicData_NMWEBins,h] = ProjectAssembliesOntoBinnedMatrix_NoPlot(AssemblyPatterns,RateMatrixNMWE);
[AssemblyBasicData_UPstates,h] = ProjectAssembliesOntoBinnedMatrix_NoPlot(AssemblyPatterns,RateMatrixUPstatesE);
[AssemblyBasicData_SUPstates,h] = ProjectAssembliesOntoBinnedMatrix_NoPlot(AssemblyPatterns,RateMatrixSUPstatesE);
[AssemblyBasicData_Spindles,h] = ProjectAssembliesOntoBinnedMatrix_NoPlot(AssemblyPatterns,RateMatrixSpindlesE);
[AssemblyBasicData_NDSpindles,h] = ProjectAssembliesOntoBinnedMatrix_NoPlot(AssemblyPatterns,RateMatrixNDSpindlesE);
[AssemblyBasicData_REMEBins,h] = ProjectAssembliesOntoBinnedMatrix_NoPlot(AssemblyPatterns,RateMatrixREME);

% AllAssActs = mean(AssemblyBasicData_AllEBins.AssemblyActivities,2);
WakeAssActs = mean(AssemblyBasicData_WakeEBins.AssemblyActivities,2);
MWAssActs = mean(AssemblyBasicData_MWEBins.AssemblyActivities,2);
NMWAssActs = mean(AssemblyBasicData_NMWEBins.AssemblyActivities,2);
UPAssActs = mean(AssemblyBasicData_UPstates.AssemblyActivities,2);
SUPAssActs = mean(AssemblyBasicData_SUPstates.AssemblyActivities,2);
SpindleAssActs = mean(AssemblyBasicData_Spindles.AssemblyActivities,2);
NDSpindleAssActs = mean(AssemblyBasicData_NDSpindles.AssemblyActivities,2);
REMAssActs = mean(AssemblyBasicData_REMEBins.AssemblyActivities,2);

% % Stuff for non-corrected means of projections at various states
% uprates = mean(mean(uisse.spkrates)');
% % suprates = mean(mean(Suisse.spkrates)');
% sprates = mean(mean(sisse.spkrates)');
% ndsprates = mean(mean(ndsisse.spkrates)');
% allrates = mean(Rate(Se));
% wakerates = mean(Rate(WakeSe));
% REMrates = mean(Rate(REMSe));

nsurrogates = 100;
AssZWake = ZScoreAssemblyActivityVsShuffled(AssemblyPatterns,RateMatrixWakeE,WakeAssActs,nsurrogates);
disp('AssZWake Done')
AssZMW = ZScoreAssemblyActivityVsShuffled(AssemblyPatterns,RateMatrixMWE,MWAssActs,nsurrogates);
disp('AssZMW Done')
AssZNMW = ZScoreAssemblyActivityVsShuffled(AssemblyPatterns,RateMatrixNMWE,NMWAssActs,nsurrogates);
disp('AssZNMW Done')
AssZUP = ZScoreAssemblyActivityVsShuffled(AssemblyPatterns,RateMatrixUPstatesE,UPAssActs,nsurrogates);
disp('AssZUP Done')
AssZSUP = ZScoreAssemblyActivityVsShuffled(AssemblyPatterns,RateMatrixSUPstatesE,SUPAssActs,nsurrogates);
disp('AssZSUP Done')
AssZSpindle = ZScoreAssemblyActivityVsShuffled(AssemblyPatterns,RateMatrixSpindlesE,SpindleAssActs,nsurrogates);
disp('AssZSpindle Done')
AssZNDSpindle = ZScoreAssemblyActivityVsShuffled(AssemblyPatterns,RateMatrixNDSpindlesE,NDSpindleAssActs,nsurrogates);
disp('AssZNDSpindle Done')
AssZREM = ZScoreAssemblyActivityVsShuffled(AssemblyPatterns,RateMatrixREME,REMAssActs,nsurrogates);
disp('AssZREM Done')


AssZWakeNorm = AssZWake./AssZWake;
AssZMWNorm = AssZMW./AssZWake;
AssZNMWNorm = AssZNMW./AssZWake;
AssZUPNorm = AssZUP./AssZWake;
AssZSUPNorm = AssZSUP./AssZWake;
AssZSpindleNorm = AssZSpindle./AssZWake;
AssZNDSpindleNorm = AssZNDSpindle./AssZWake;
AssZREMNorm = AssZREM./AssZWake;

AssZTogether = [AssZWake;AssZMW;AssZNMW;AssZUP;AssZSUP;AssZSpindle;AssZNDSpindle;AssZREM];
AssZTogetherNorm = [AssZWakeNorm;AssZMWNorm;AssZNMWNorm;AssZUPNorm;AssZSUPNorm;AssZSpindleNorm;AssZNDSpindleNorm;AssZREMNorm];

% Showing whole population trends across states at once... lower one
figure;
boxplot(AssZTogetherNorm','labels',labelsarray)
ylabel('ZScore relative to ZScore of Wake')

% Tracing individual assemblies over states, bottom focuses on UP vs REM
% only
figure;
subplot(2,1,1)
plot(AssZTogetherNorm(:,1:end),'-*')
xlim([.5 8.5])
set(gca,'XTick',[1:8],'XTickLabel',labelsarray)
subplot(2,1,2)
plot(AssZTogetherNorm([4 8],:),'-*')
xlim([.5 2.5])
set(gca,'XTick',[1,2],'XTickLabel',{'UPs','REM'})

% Histogram of UPstate to REM ratio... looking for bimodality
figure;hist(log10(AssZUPNorm./AssZREMNorm))
xlabel('Log10 of UP/REM ratio')
ylabel('AssemblyCounts')

% Histogram of Movement to NonMovWake ratio... looking for bimodality
figure;hist(log10(AssZMWNorm./AssZNMWNorm))
xlabel('Log10 of MovWk/NMovWk ratio')
ylabel('AssemblyCounts')


% % Relative activities... not taking spike rate/Z score into account
% figure;plot(WakeAssActs,AllAssActs,'.')
%     hold on;plot([0 2],[0 2])
%     xlabel('wake');ylabel('all')
% figure;plot(WakeAssActs,UPAssActs,'.')
%     hold on;plot([0 2],[0 2])
%     xlabel('wake');ylabel('UPs')
% figure;plot(WakeAssActs,SpindleAssActs,'.')
%     hold on;plot([0 2],[0 2])
%     xlabel('wake');ylabel('Spindles')
% figure;plot(WakeAssActs,NDSpindleAssActs,'.')
%     hold on;plot([0 2],[0 2])
%     xlabel('wake');ylabel('NoDOWNSpindles')
% figure;plot(WakeAssActs,REMAssActs,'.')
%     hold on;plot([0 2],[0 2])
%     xlabel('wake');ylabel('REM')
% 
% figure;
% subplot(1,2,1)
% hax = plot_meanSD_bars(AllAssActs,WakeAssActs,UPAssActs,SpindleAssActs,REMAssActs);
% set(hax,'XTick',[1,2,3,4,5])
% set(hax,'XTickLabel',{'a';'w';'u';'s';'r'})
% subplot(1,2,2)
% hax = plot_meanSD_bars(allrates,wakerates,uprates,sprates,REMrates);
% set(hax,'XTick',[1,2,3,4,5])
% set(hax,'XTickLabel',{'a';'w';'u';'s';'r'})


% Plot for each assembly a full picture of 1. cells, 2. projected activity
% over time colorized by SWS, REM, Wake, MovingWake, 3. Movement trace, 
% 4. projected activity over UPs, SpindleUPs and Spindles, 5. it's
% state-wise modulation plotted, 6. it's movement-wise modulation plotted


