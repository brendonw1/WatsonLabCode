function Assemblies_CrossStateMeans(basepath,basename,secondsperbin)

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

%% Load pre-saved AllStateAssData structs
t = load(fullfile(basepath,'Assemblies','PCAAllToAll',[basename '_AllStateAssDataPCA_' num2str(secondsperbin) 'sec.mat']));
AllStateAssDataPCA = t.AllStateAssDataPCA;
t = load(fullfile(basepath,'Assemblies','ICAAllToAll',[basename '_AllStateAssDataICA_' num2str(secondsperbin) 'sec.mat']));
AllStateAssDataICA = t.AllStateAssDataICA;

%% Gather population rate matrices
secondsPerDetectionBin = secondsperbin;
secondsPerProjectionBin = secondsperbin;
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

nstates = length(states);
hpca = [];
hica = [];

for a = 1:length(states)
%     tpcaname = ['PCAAss' states{a} 'onto' states{a}];
%     ticaname = ['ICAAss' states{a} 'onto' states{a}];
%     
    eval([states{a} 'Acts_PCA = [];'])
    eval([states{a} 'ActsNorm_PCA = [];'])
    eval([states{a} 'ActsOverRate_PCA = [];'])
    eval([states{a} 'ActsOverRateNorm_PCA = [];'])

    eval([states{a} 'Acts_ICA = [];'])
    eval([states{a} 'ActsNorm_ICA = [];'])
    eval([states{a} 'ActsOverRate_ICA = [];'])
    eval([states{a} 'ActsOverRateNorm_ICA = [];'])
    
    eval(['tpnormassact = mean(AllStateAssDataPCA.PCAAss' states{a} 'onto' states{a} '.AssemblyActivities,2);'])
    eval(['tinormassact = mean(AllStateAssDataICA.ICAAss' states{a} 'onto' states{a} '.AssemblyActivities,2);'])

    for b = 1:length(states);
        tpcaname = ['PCAAss' states{a} 'onto' states{b}];
        ticaname = ['ICAAss' states{a} 'onto' states{b}];
    
        eval([tpcaname 'MeanAssActs = mean(AllStateAssDataPCA.' tpcaname '.AssemblyActivities,2);'])
        eval([ticaname 'MeanAssActs = mean(AllStateAssDataICA.' ticaname '.AssemblyActivities,2);'])

        eval([states{a} 'Acts_PCA = cat(2,' states{a} 'Acts_PCA,mean(AllStateAssDataPCA.' tpcaname '.AssemblyActivities,2));'])
        eval([states{a} 'ActsNorm_PCA = cat(2,' states{a} 'ActsNorm_PCA,' states{a} 'Acts_PCA(:,end)./tpnormassact);'])    
        eval([states{a} 'ActsOverRate_PCA = cat(2,' states{a} 'ActsOverRate_PCA,' states{a} 'Acts_PCA(:,end)./repmat(RatesMeans(b)'',size(' states{a} 'Acts_PCA,1),1));'])

        eval([states{a} 'Acts_ICA = cat(2,' states{a} 'Acts_ICA,mean(AllStateAssDataICA.' ticaname '.AssemblyActivities,2));'])
        eval([states{a} 'ActsNorm_ICA = cat(2,' states{a} 'ActsNorm_ICA,' states{a} 'Acts_ICA(:,end)./tinormassact);'])    
        eval([states{a} 'ActsOverRate_ICA = cat(2,' states{a} 'ActsOverRate_ICA,' states{a} 'Acts_ICA(:,end)./repmat(RatesMeans(b)'',size(' states{a} 'Acts_ICA,1),1));'])
    end
    
    eval(['tpnormoverrate = ' states{a} 'ActsOverRate_PCA(:,a);'])
    eval(['tinormoverrate = ' states{a} 'ActsOverRate_ICA(:,a);'])
    
    eval([states{a} 'ActsOverRateNorm_PCA = ' states{a} 'ActsOverRate_PCA./repmat(tpnormoverrate,1,nstates);'])
    eval([states{a} 'ActsOverRateNorm_ICA = ' states{a} 'ActsOverRate_ICA./repmat(tinormoverrate,1,nstates);'])

    eval(['nass_PCA = size(' states{a} 'Acts_PCA,1);'])
    eval(['nass_ICA = size(' states{a} 'Acts_ICA,1);'])
     
%% PCA PLOTTING
    hpca(end+1) = figure;
    subplot(4,2,1)%Raw vs shuffle raw plot
        eval(['plot(' states{a} 'Acts_PCA'',''-*'')'])
        plotlines = get(gca,'children');
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:length(states)],'XTickLabel',states)
        title('Real vs Shuffled Raw Proj')
        
    subplot(4,2,5) %after a blank, plot simple norm'd data
        eval(['plot(' states{a} 'ActsNorm_PCA'',''-*'')'])
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:length(states)],'XTickLabel',states)
        title(['Activities Norm to ' states{a}])
    if nass_PCA >= 2 %plot box version of same thing
        subplot(4,2,7)
            eval(['boxplot(' states{a} 'ActsNorm_PCA,''labels'',states);'])
            title(['Activities Norm To' states{a}])
    end
        
    subplot(4,2,2)% just rates
        plot(RatesMeans,'-*')
        xlim([.5 length(states)+.5])
        yl = ylim(gca);
        ylim([0 yl(2)])
        set(gca,'XTick',[1:length(states)],'XTickLabel',states)
        ylabel('Hz')
        title('Firing Rate Per State')
    subplot(4,2,4)
        eval(['plot(' states{a} 'ActsOverRate_PCA'',''-*'')'])
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:length(states)],'XTickLabel',states)
        title(['Activities / SpikeRate'])
    subplot(4,2,6)
        eval(['plot(' states{a} 'ActsOverRateNorm_PCA'',''-*'')'])
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:length(states)],'XTickLabel',states)
        title(['Acts/SpikeRate, NormTo' states{a} ])
    if nass_PCA >= 2 %plot box version of same thing
        subplot(4,2,8)
            eval(['boxplot(' states{a} 'ActsOverRateNorm_PCA,''labels'',states);'])
            title(['Acts/SpikeRate, NormTo' states{a} ])
    end
        
    AboveTitle([states{a} ' PCA'])
    set(hpca(end),'name',[states{a} 'OntoAllStatesPCA'])

%% ICA PLOTTING
    hica(end+1) = figure;
    subplot(4,2,1)%Raw vs shuffle raw plot
        eval(['plot(' states{a} 'Acts_ICA'',''-*'')'])
        plotlines = get(gca,'children');
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:length(states)],'XTickLabel',states)
        title('Real vs Shuffled Raw Proj')
        
    subplot(4,2,5) %after a blank, plot simple norm'd data
        eval(['plot(' states{a} 'ActsNorm_ICA'',''-*'')'])
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:length(states)],'XTickLabel',states)
        title(['Activities Norm to ' states{a}])
    if nass_ICA >= 2 %plot box version of same thing
        subplot(4,2,7)
            eval(['boxplot(' states{a} 'ActsNorm_ICA,''labels'',states);'])
            title(['Activities Norm To' states{a}])
    end
        
    subplot(4,2,2)% just rates
        plot(RatesMeans,'-*')
        xlim([.5 length(states)+.5])
        yl = ylim(gca);
        ylim([0 yl(2)])
        set(gca,'XTick',[1:length(states)],'XTickLabel',states)
        ylabel('Hz')
        title('Firing Rate Per State')
    subplot(4,2,4)
        eval(['plot(' states{a} 'ActsOverRate_ICA'',''-*'')'])
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:length(states)],'XTickLabel',states)
        title(['Activities / SpikeRate'])
    subplot(4,2,6)
        eval(['plot(' states{a} 'ActsOverRateNorm_ICA'',''-*'')'])
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:length(states)],'XTickLabel',states)
        title(['Acts/SpikeRate, NormTo' states{a} ])
    if nass_ICA >= 2 %plot box version of same thing
        subplot(4,2,8)
            eval(['boxplot(' states{a} 'ActsOverRateNorm_ICA,''labels'',states);'])
            title(['Acts/SpikeRate, NormTo' states{a} ])
    end
        
    AboveTitle([states{a} ' ICA'])
    set(hica(end),'name',[states{a} 'OntoAllStatesICA'])

end

savethesefigsas(hpca,'fig',fullfile(basepath,'Assemblies','PCAAllToAll'))
savethesefigsas(hica,'fig',fullfile(basepath,'Assemblies','ICAAllToAll'))

%% Put in structs for saving
CrossStateAssembliesPCA.states = states;
CrossStateAssembliesICA.states = states;
for a = 1:length(states)
    eval(['CrossStateAssembliesPCA.' states{a} 'Acts_PCA = ' states{a} 'Acts_PCA;'])
    eval(['CrossStateAssembliesPCA.' states{a} 'ActsNorm_PCA = ' states{a} 'ActsNorm_PCA;'])
    eval(['CrossStateAssembliesPCA.' states{a} 'ActsOverRate_PCA = ' states{a} 'ActsOverRate_PCA;'])
    eval(['CrossStateAssembliesPCA.' states{a} 'ActsOverRateNorm_PCA = ' states{a} 'ActsOverRateNorm_PCA;'])

    eval(['CrossStateAssembliesICA.' states{a} 'Acts_ICA = ' states{a} 'Acts_ICA;'])
    eval(['CrossStateAssembliesICA.' states{a} 'ActsNorm_ICA = ' states{a} 'ActsNorm_ICA;'])
    eval(['CrossStateAssembliesICA.' states{a} 'ActsOverRate_ICA = ' states{a} 'ActsOverRate_ICA;'])
    eval(['CrossStateAssembliesICA.' states{a} 'ActsOverRateNorm_ICA = ' states{a} 'ActsOverRateNorm_ICA;'])

    for b = 1:length(states);
        tpcaname = ['PCAAss' states{a} 'onto' states{b}];
        ticaname = ['ICAAss' states{a} 'onto' states{b}]; 
        
        eval(['CrossStateAssembliesPCA.' tpcaname 'MeanAssActs = ' tpcaname 'MeanAssActs;'])

        eval(['CrossStateAssembliesICA.' ticaname 'MeanAssActs = ' ticaname 'MeanAssActs;'])
    end
end

save(fullfile(basepath,'Assemblies','PCAAllToAll',[basename '_CrossStateAssembliesPCA_' num2str(secondsperbin) 'sec.mat']),'CrossStateAssembliesPCA')
save(fullfile(basepath,'Assemblies','ICAAllToAll',[basename '_CrossStateAssembliesICA_' num2str(secondsperbin) 'sec.mat']),'CrossStateAssembliesICA')

