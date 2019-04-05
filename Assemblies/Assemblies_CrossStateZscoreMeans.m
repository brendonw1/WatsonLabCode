function Assemblies_CrossStateZscoreMeans(basepath,basename,secondsperbin)

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

%% Load pre-saved AllStateAssData structs
t = load(fullfile(basepath,'Assemblies','PCAAllToAll',[basename '_AllStateAssDataPCA_' num2str(secondsperbin) 'sec']))
AllStateAssDataPCA = t.AllStateAssDataPCA;
t = load(fullfile(basepath,'Assemblies','ICAAllToAll',[basename '_AllStateAssDataICA_' num2str(secondsperbin) 'sec']))
AllStateAssDataICA = t.AllStateAssDataICA;

%% Gather population rate matrices
secondsPerDetectionBin = 1;
secondsPerProjectionBin = 1;
gsi = load(fullfile(basepath,[basename '_GoodSleepInterval.mat']));
gsi = gsi.GoodSleepInterval;

StateRateBins = GatherStateRateBinMatrices(basepath,basename,secondsPerDetectionBin,secondsPerProjectionBin,gsi);
v2struct(StateRateBins);%unpacks RateMtxSpindlesE,RateMtxNDSpindlesE,RateMtxUPE,RateMtxSUPE,
                        %RateMtxWakeE,RateMtxREME,RateMtxMWakeE,RateMtxNMWakeE
RatesMeans = [mean(mean(RateMtxWakeE));mean(mean(RateMtxMWakeE));...
mean(mean(RateMtxNMWakeE));mean(mean(RateMtxUPE));mean(mean(RateMtxSUPE));mean(mean(RateMtxNSUPE));...
mean(mean(RateMtxSpindlesE));mean(mean(RateMtxNDSpindlesE));mean(mean(RateMtxREME))];
                        
                        
%% Set up for looping through each comparison for Z scoring the real Assemblies vs Within-Cell-Bin-Shuffled Assemblies
% states = {'WakeE','MWakeE','NMWakeE','UPE','SUPE','NSUPE','SpindlesE','NDSpindlesE','REME'};
states = AllStateAssDataPCA.states;

nsurrogates = 100;
hpca = [];
hica = [];

for a = 1:length(states)
    tpcaname = ['PCAAss' states{a} 'onto' states{a}];
    ticaname = ['ICAAss' states{a} 'onto' states{a}];
    
    eval([tpcaname 'MeanAssActs = mean(AllStateAssDataPCA.' tpcaname '.AssemblyActivities,2);'])
    eval([ticaname 'MeanAssActs = mean(AllStateAssDataICA.' ticaname '.AssemblyActivities,2);'])

    eval(['[ ' tpcaname 'AssZ, ' tpcaname 'MeanSurrAssActs] = ZScoreAssemblyActivityVsShuffled(AllStateAssDataPCA.' tpcaname ',' ...
        'RateMtx' states{a} ',' tpcaname 'MeanAssActs,nsurrogates);'])
    eval(['[ ' ticaname 'AssZ, ' ticaname 'MeanSurrAssActs] = ZScoreAssemblyActivityVsShuffled(AllStateAssDataICA.' ticaname ',' ...
        'RateMtx' states{a} ',' ticaname 'MeanAssActs,nsurrogates);'])

%     eval(['AssZTogether_' states{a} '_PCA = ' tpcaname 'AssZ;'])
%     eval(['AssZTogetherNorm_' states{a} '_PCA = ones(size(' tpcaname 'AssZ));'])
%     eval([states{a} 'surrMeans = mean(' tpcaname 'MeanSurrAssActs,2);'])
%     eval([states{a} 'surrSDs = std(' tpcaname 'MeanSurrAssActs,[],2);'])
%     eval([states{a} 'AbsoluteActs = mean(AllStateAssDataPCA.' tpcaname '.AssemblyActivities,2);'])
    eval(['AssZTogether_' states{a} '_PCA = [];'])
    eval(['AssZTogetherNorm_' states{a} '_PCA = [];'])
    eval(['AssZTogether_' states{a} '_ICA = [];'])
    eval(['AssZTogetherNorm_' states{a} '_ICA = [];'])
%     eval(['AssZTogetherNormOverRate_' states{a} '_PCA = [];'])
    eval([states{a} 'surrMeans_PCA = [];'])
    eval([states{a} 'surrSDs_PCA = [];'])
    eval([states{a} 'AbsoluteActs_PCA = [];'])
    eval([states{a} 'AbsoluteActsNorm_PCA = [];'])
    eval([states{a} 'AbsoluteActsNormOverRate_PCA = [];'])
    eval([states{a} 'surrMeans_ICA = [];'])
    eval([states{a} 'surrSDs_ICA = [];'])
    eval([states{a} 'AbsoluteActs_ICA = [];'])
    eval([states{a} 'AbsoluteActsNorm_ICA = [];'])
    eval([states{a} 'AbsoluteActsNormOverRate_ICA = [];'])

    eval(['tpnormassact = mean(AllStateAssDataPCA.PCAAss' states{a} 'onto' states{a} '.AssemblyActivities,2);'])
    eval(['tinormassact = mean(AllStateAssDataICA.ICAAss' states{a} 'onto' states{a} '.AssemblyActivities,2);'])

    for b = 1:length(states);
        tpcaname = ['PCAAss' states{a} 'onto' states{b}];
        ticaname = ['ICAAss' states{a} 'onto' states{b}];
        if a ~= b %a==b already taken care of above
            eval([tpcaname 'MeanAssActs = mean(AllStateAssDataPCA.' tpcaname '.AssemblyActivities,2);'])
            eval([ticaname 'MeanAssActs = mean(AllStateAssDataICA.' ticaname '.AssemblyActivities,2);'])
            eval(['[' tpcaname 'AssZ, ' tpcaname 'MeanSurrAssActs] = ZScoreAssemblyActivityVsShuffled(AllStateAssDataPCA.' tpcaname ',' ...
                'RateMtx' states{b} ',' tpcaname 'MeanAssActs,nsurrogates);'])
            eval(['[' ticaname 'AssZ, ' ticaname 'MeanSurrAssActs] = ZScoreAssemblyActivityVsShuffled(AllStateAssDataICA.' ticaname ',' ...
                'RateMtx' states{b} ',' ticaname 'MeanAssActs,nsurrogates);'])
        end
        
        eval([tpcaname 'AssZNorm = ' tpcaname 'AssZ./PCAAss' states{a} 'onto' states{a} 'AssZ;'])
        eval([ticaname 'AssZNorm = ' ticaname 'AssZ./ICAAss' states{a} 'onto' states{a} 'AssZ;'])

        eval(['AssZTogether_' states{a} '_PCA = cat(1,AssZTogether_' states{a} '_PCA, ' tpcaname 'AssZ);'])
        eval(['AssZTogetherNorm_' states{a} '_PCA = cat(1,AssZTogetherNorm_' states{a} '_PCA, ' tpcaname 'AssZNorm);'])
        eval([states{a} 'surrMeans_PCA = cat(2,' states{a} 'surrMeans_PCA,mean(' tpcaname 'MeanSurrAssActs,2));'])
        eval([states{a} 'surrSDs_PCA = cat(2,' states{a} 'surrSDs_PCA,std(' tpcaname 'MeanSurrAssActs,[],2));'])
        eval([states{a} 'AbsoluteActs_PCA = cat(2,' states{a} 'AbsoluteActs_PCA,mean(AllStateAssDataPCA.' tpcaname '.AssemblyActivities,2));'])
        eval([states{a} 'AbsoluteActsNorm_PCA = cat(2,' states{a} 'AbsoluteActsNorm_PCA,mean(AllStateAssDataPCA.' tpcaname '.AssemblyActivities,2)./tpnormassact);'])

        eval(['AssZTogether_' states{a} '_ICA = cat(1,AssZTogether_' states{a} '_ICA, ' ticaname 'AssZ);'])
        eval(['AssZTogetherNorm_' states{a} '_ICA = cat(1,AssZTogetherNorm_' states{a} '_ICA, ' ticaname 'AssZNorm);'])
        eval([states{a} 'surrMeans_ICA = cat(2,' states{a} 'surrMeans_ICA,mean(' ticaname 'MeanSurrAssActs,2));'])
        eval([states{a} 'surrSDs_ICA = cat(2,' states{a} 'surrSDs_ICA,std(' ticaname 'MeanSurrAssActs,[],2));'])
        eval([states{a} 'AbsoluteActs_ICA = cat(2,' states{a} 'AbsoluteActs_ICA,mean(AllStateAssDataICA.' ticaname '.AssemblyActivities,2));'])
        eval([states{a} 'AbsoluteActsNorm_ICA = cat(2,' states{a} 'AbsoluteActsNorm_ICA,mean(AllStateAssDataICA.' ticaname '.AssemblyActivities,2)./tinormassact);'])    
    end

    eval([states{a} 'AbsoluteActsNormOverRate_PCA = ' states{a} 'AbsoluteActsNorm_PCA./repmat(RatesMeans'',size(' states{a} 'AbsoluteActsNorm_PCA,1),1);'])
    eval([states{a} 'AbsoluteActsNormOverRate_ICA = ' states{a} 'AbsoluteActsNorm_ICA./repmat(RatesMeans'',size(' states{a} 'AbsoluteActsNorm_ICA,1),1);'])
    eval(['nass_PCA = size(' states{a} 'surrSDs_PCA,1);'])
    eval(['nass_ICA = size(' states{a} 'surrSDs_ICA,1);'])
     
%% PCA PLOTTING
    hpca(end+1) = figure;
    subplot(4,2,1)%Raw vs shuffle raw plot
        eval(['plot(' states{a} 'AbsoluteActs_PCA'',''-*'')'])
        plotlines = get(gca,'children');
        hold on
        for b = 1:nass_PCA
            eval(['errorbar(' states{a} 'surrMeans_PCA(b,:),' states{a} 'surrSDs_PCA(b,:),''color'',get(plotlines(b),''color''),''LineStyle'','':'')'])
        end
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:length(states)],'XTickLabel',states)
        title('Real vs Shuffled Raw Proj')
    subplot(4,2,3)
        eval(['plot(' states{a} 'AbsoluteActsNorm_PCA'',''-*'')'])
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:length(states)],'XTickLabel',states)
        title(['Absolute Activities Norm to ' states{a}])
    subplot(4,2,5)
        eval(['plot(' states{a} 'AbsoluteActsNormOverRate_PCA'',''-*'')'])
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:length(states)],'XTickLabel',states)
        title(['AbsNormTo' states{a} ' / SpikeRate'])
    if nass_PCA >= 2
    subplot(4,2,7)
            eval(['boxplot(' states{a} 'AbsoluteActsNormOverRate_PCA,''labels'',states);'])
            title(['AbsNormTo' states{a} ' / SpikeRate'])
    end
        
    subplot(4,2,2)%Z normalized vs 
        eval(['plot(AssZTogether_' states{a} '_PCA,''-*'')'])
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:length(states)],'XTickLabel',states)
        title('Proj Z vs Shuffled')
    subplot(4,2,4)
        eval(['plot(AssZTogetherNorm_' states{a} '_PCA,''-*'')'])
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:length(states)],'XTickLabel',states)
        title(['ZProj vs ' states{a}])
    if nass_PCA >= 2
    subplot(4,2,6)
        eval(['boxplot(AssZTogetherNorm_' states{a} '_PCA'',''labels'',states);'])
        title('Box:ZProj vs Native')
    end
    subplot(4,2,8)
        plot(RatesMeans,'-*')
        xlim([.5 length(states)+.5])
        yl = ylim(gca);
        ylim([0 yl(2)])
        set(gca,'XTick',[1:length(states)],'XTickLabel',states)
        ylabel('Hz')
        title('Firing Rate Per State')
    AboveTitle([states{a} ' PCA'])
    set(hpca(end),'name',[states{a} 'OntoAllStatesPCA'])

%% ICA PLOTTING
    hica(end+1) = figure;
    subplot(4,2,1)%Raw vs shuffle raw plot
        eval(['plot(' states{a} 'AbsoluteActs_ICA'',''-*'')'])
        plotlines = get(gca,'children');
        hold on
        for b = 1:nass_ICA
            eval(['errorbar(' states{a} 'surrMeans_ICA(b,:),' states{a} 'surrSDs_ICA(b,:),''color'',get(plotlines(b),''color''),''LineStyle'','':'')'])
        end
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:length(states)],'XTickLabel',states)
        title('Real vs Shuffled Raw Proj')
    subplot(4,2,3)
        eval(['plot(' states{a} 'AbsoluteActsNorm_ICA'',''-*'')'])
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:length(states)],'XTickLabel',states)
        title(['Absolute Activities Norm to ' states{a}])
    subplot(4,2,5)
        eval(['plot(' states{a} 'AbsoluteActsNormOverRate_ICA'',''-*'')'])
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:length(states)],'XTickLabel',states)
        title(['AbsNormTo' states{a} ' / SpikeRate'])
    if nass_ICA >= 2
    subplot(4,2,7)
            eval(['boxplot(' states{a} 'AbsoluteActsNormOverRate_ICA,''labels'',states);'])
            title(['AbsNormTo' states{a} ' / SpikeRate'])
    end
        
    subplot(4,2,2)%Z normalized vs 
        eval(['plot(AssZTogether_' states{a} '_ICA,''-*'')'])
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:length(states)],'XTickLabel',states)
        title('Proj Z vs Shuffled')
    subplot(4,2,4)
        eval(['plot(AssZTogetherNorm_' states{a} '_ICA,''-*'')'])
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:length(states)],'XTickLabel',states)
        title(['ZProj vs ' states{a}])
    if nass_ICA >= 2
    subplot(4,2,6)
        eval(['boxplot(AssZTogetherNorm_' states{a} '_ICA'',''labels'',states);'])
        title('Box:ZProj vs Native')
    end
    subplot(4,2,8)
        plot(RatesMeans,'-*')
        xlim([.5 length(states)+.5])
        yl = ylim(gca);
        ylim([0 yl(2)])
        set(gca,'XTick',[1:length(states)],'XTickLabel',states)
        ylabel('(Hz)')
        title('Firing Rate Per State')
    AboveTitle([states{a} ' ICA'])
    set(hica(end),'name',[states{a} 'OntoAllStatesICA'])

end

savethesefigsas(hpca,'fig',fullfile(basepath,'Assemblies','PCAAllToAll'))
savethesefigsas(hica,'fig',fullfile(basepath,'Assemblies','ICAAllToAll'))

%% Put in structs for saving
CrossStateAssembliesZScorePCA.states = states;
CrossStateAssembliesZScoreICA.states = states;
for a = 1:length(states)
    eval(['CrossStateAssembliesZScorePCA.AssZTogether_' states{a} '_PCA = AssZTogether_' states{a} '_PCA;'])
    eval(['CrossStateAssembliesZScorePCA.AssZTogetherNorm_' states{a} '_PCA = AssZTogetherNorm_' states{a} '_PCA;'])
    eval(['CrossStateAssembliesZScorePCA.' states{a} 'surrMeans_PCA = ' states{a} 'surrMeans_PCA;'])
    eval(['CrossStateAssembliesZScorePCA.' states{a} 'surrSDs_PCA = ' states{a} 'surrSDs_PCA;'])
    eval(['CrossStateAssembliesZScorePCA.' states{a} 'AbsoluteActs_PCA = ' states{a} 'AbsoluteActs_PCA;'])
    eval(['CrossStateAssembliesZScorePCA.' states{a} 'AbsoluteActsNorm_PCA = ' states{a} 'AbsoluteActsNorm_PCA;'])
    eval(['CrossStateAssembliesZScorePCA.' states{a} 'AbsoluteActsNormOverRate_PCA = ' states{a} 'AbsoluteActsNormOverRate_PCA;'])

    eval(['CrossStateAssembliesZScoreICA.AssZTogether_' states{a} '_ICA = AssZTogether_' states{a} '_ICA;'])
    eval(['CrossStateAssembliesZScoreICA.AssZTogetherNorm_' states{a} '_ICA = AssZTogetherNorm_' states{a} '_ICA;'])
    eval(['CrossStateAssembliesZScoreICA.' states{a} 'surrMeans_ICA = ' states{a} 'surrMeans_ICA;'])
    eval(['CrossStateAssembliesZScoreICA.' states{a} 'surrSDs_ICA = ' states{a} 'surrSDs_ICA;'])
    eval(['CrossStateAssembliesZScoreICA.' states{a} 'AbsoluteActs_ICA = ' states{a} 'AbsoluteActs_ICA;'])
    eval(['CrossStateAssembliesZScoreICA.' states{a} 'AbsoluteActsNorm_ICA = ' states{a} 'AbsoluteActsNorm_ICA;'])
    eval(['CrossStateAssembliesZScoreICA.' states{a} 'AbsoluteActsNormOverRate_ICA = ' states{a} 'AbsoluteActsNormOverRate_ICA;'])

    for b = 1:length(states);
        tpcaname = ['PCAAss' states{a} 'onto' states{b}];
        ticaname = ['ICAAss' states{a} 'onto' states{b}]; 
        
        eval(['CrossStateAssembliesZScorePCA.' tpcaname 'MeanAssActs = ' tpcaname 'MeanAssActs;'])
        eval(['CrossStateAssembliesZScorePCA.' tpcaname 'AssZ = ' tpcaname 'AssZ;'])

        eval(['CrossStateAssembliesZScoreICA.' ticaname 'MeanAssActs = ' ticaname 'MeanAssActs;'])
        eval(['CrossStateAssembliesZScoreICA.' ticaname 'AssZ = ' ticaname 'AssZ;'])        
    end
end

save(fullfile(basepath,'Assemblies','PCAAllToAll',[basename '_CrossStateAssembliesZScorePCA_' num2str(secondsperbin) 'sec']),'CrossStateAssembliesZScorePCA')
save(fullfile(basepath,'Assemblies','ICAAllToAll',[basename '_CrossStateAssembliesZScoreICA_' num2str(secondsperbin) 'sec']),'CrossStateAssembliesZScoreICA')


% 
% 
% % AllAssActs = mean(AssemblyBasicData_AllEBins.AssemblyActivities,2);
% WakeAssActs = mean(AssemblyBasicData_WakeEBins.AssemblyActivities,2);
% MWAssActs = mean(AssemblyBasicData_MWEBins.AssemblyActivities,2);
% NMWAssActs = mean(AssemblyBasicData_NMWEBins.AssemblyActivities,2);
% UPAssActs = mean(AssemblyBasicData_UPstates.AssemblyActivities,2);
% SUPAssActs = mean(AssemblyBasicData_SUPstates.AssemblyActivities,2);
% SpindleAssActs = mean(AssemblyBasicData_Spindles.AssemblyActivities,2);
% NDSpindleAssActs = mean(AssemblyBasicData_NDSpindles.AssemblyActivities,2);
% REMAssActs = mean(AssemblyBasicData_REMEBins.AssemblyActivities,2);
% 
% AssZWake = ZScoreAssemblyActivityVsShuffled(AssPatts,RateMtxWakeE,WakeAssActs,nsurrogates);
% AssZMW = ZScoreAssemblyActivityVsShuffled(AssPatts,RateMtxMWE,MWAssActs,nsurrogates);
% AssZNMW = ZScoreAssemblyActivityVsShuffled(AssPatts,RateMtxNMWE,NMWAssActs,nsurrogates);
% AssZUP = ZScoreAssemblyActivityVsShuffled(AssPatts,RateMtxUPE,UPAssActs,nsurrogates);
% AssZSUP = ZScoreAssemblyActivityVsShuffled(AssPatts,RateMtxSUPE,SUPAssActs,nsurrogates);
% AssZSpindle = ZScoreAssemblyActivityVsShuffled(AssPatts,RateMtxSpindleE,SpindleAssActs,nsurrogates);
% AssZNDSpindle = ZScoreAssemblyActivityVsShuffled(AssPatts,RateMtxNDSpindleE,NDSpindleAssActs,nsurrogates);
% AssZREM = ZScoreAssemblyActivityVsShuffled(AssPatts,RateMtxREME,REMAssActs,nsurrogates);
% 
% AssZWakeNorm = AssZWake./AssZWake;
% AssZMWNorm = AssZMW./AssZWake;
% AssZNMWNorm = AssZNMW./AssZWake;
% AssZUPNorm = AssZUP./AssZWake;
% AssZSUPNorm = AssZSUP./AssZWake;
% AssZSpindleNorm = AssZSpindle./AssZWake;
% AssZNDSpindleNorm = AssZNDSpindle./AssZWake;
% AssZREMNorm = AssZREM./AssZWake;
% 
% AssZTogether = [AssZWake;AssZMW;AssZNMW;AssZUP;AssZSUP;AssZSpindle;AssZNDSpindle;AssZREM];
% AssZTogetherNorm = [AssZWakeNorm;AssZMWNorm;AssZNMWNorm;AssZUPNorm;AssZSUPNorm;AssZSpindleNorm;AssZNDSpindleNorm;AssZREMNorm];

% % Showing whole population trends across states at once... lower one
% figure;
% boxplot(AssZTogetherNorm','labels',names)
% ylabel('ZScore relative to ZScore of Wake')
% 
% % Tracing individual assemblies over states, bottom focuses on UP vs REM
% % only
% figure;
% subplot(2,1,1)
% plot(AssZTogetherNorm(:,2:end),'-*')
% xlim([.5 8.5])
% set(gca,'XTick',[1:8],'XTickLabel',labelsarray)
% subplot(2,1,2)
% plot(AssZTogetherNorm([4 8],:),'-*')
% xlim([.5 2.5])
% set(gca,'XTick',[1,2],'XTickLabel',{'UPs','REM'})
% 
% % Histogram of UPstate to REM ratio... looking for bimodality
% figure;hist(log10(AssZUPNorm./AssZREMNorm))
% xlabel('Log10 of UP/REM ratio')
% ylabel('AssemblyCounts')
% 
% % Histogram of Movement to NonMovWake ratio... looking for bimodality
% figure;hist(log10(AssZMWNorm./AssZNMWNorm))
% xlabel('Log10 of MovWk/NMovWk ratio')
% ylabel('AssemblyCounts')

% save stuff

% Plot for each assembly a full picture of 1. cells, 2. projected activity
% over time colorized by SWS, REM, Wake, MovingWake, 3. Movement trace, 
% 4. projected activity over UPs, SpindleUPs and Spindles, 5. it's
% state-wise modulation plotted, 6. it's movement-wise modulation plotted

