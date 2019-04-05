%% Reset
clear
% get basename and basepath from CD
[~,basename,~] = fileparts(cd);
basepath = cd;

t = load(fullfile(basepath,[basename '_BasicMetaData.mat']));

%% Basic motion scoring
% if ~exist([fullfile(basepath,[basename '_Motion.mat'])],'file')
%     t = load([fullfile(basepath,basename) '.eegstates.mat']);
%     motion = t.StateInfo.motion;
%     clear t
% 
%     [~,h] = FilterAndBinaryDetectMotion(motion,'clean',20,1);
%     title(basename)
% 
%     strs = {'Clean (Baseline fluct OK)';'High Freq Noise'};
%     [s,v] = listdlg('PromptString','Clean or noisy baseline?','SelectionMode','single','ListString',strs);
%     close(h)
% 
%     motiondata.motion = motion;
%     switch s
%         case 1
%             motiondata.filttype = 'clean';
%         case 2 
%             motiondata.filttype = 'noisybaseline';
%     end
% 
%     % Refilter using mode asked by user
%     movementsecs = FilterAndBinaryDetectMotion(motiondata.motion,motiondata.filttype,20,1);
%     title([basename,' ',motiondata.filttype,'.  Final Detection'])
% 
%     motiondata.thresholdedsecs = movementsecs;
% 
%     save([fullfile(basepath,basename) '_Motion.mat'],'motiondata')
%     %     motiondata.thresholdedsecs = movementsecs;
% end

%% Looking at spike rate changes over sleep intervals
% if ~exist(fullfile(basepath,[basename '_CellRateVariables.mat']),'file')
%     load(fullfile(basepath,[basename '_SSubtypes']))
%     load(fullfile(basepath,[basename '_Intervals']))
%     load(fullfile(basepath,[basename '_GoodSleepInterval']))
%     load(fullfile(basepath,[basename '_WSWEpisodes']))
%     CellRateVariables = SpikingAnalysis_IndividalCellRatesAnalysesWithSleep(basename,basepath,Se,Si,intervals,GoodSleepInterval,WSWEpisodes);
%     h = SpikingAnalysis_IndividalCellRatesAnalysesWithSleep_Plot(CellRateVariables);
%     MakeDirSaveFigsThere(fullfile(basepath,'CellRatesVsStates'),h)
%     close(h)
% end

% %% Assembly analysis (PCA training on entire data, 0.1sec bins)
% if ~exist(fullfile(basepath,[basename '_AssemblyBasicData.mat']),'file')
%     tSS = load(fullfile(basepath,[basename,'_SStable.mat']));
%     tCI = load(fullfile(basepath,[basename, '_CellIDs.mat']));
%     tI = load(fullfile(basepath,[basename '_Intervals']));
%     [AssemblyBasicData,h] = GetAndPlotAssemblies(tSS.S,tCI.CellIDs,tI.intervals,0.1);
%     save(fullfile(basepath,[basename '_AssemblyBasicData.mat']),'AssemblyBasicData')
%     MakeDirSaveFigsThere(fullfile(basepath,'AssemblyFigs'),h)
%     close(h)
% end