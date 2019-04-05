function Assemblies_PlotCrossStateZScoreMeans(secondsperbin)

[CrossStateZActsPCA,CrossStateZActsICA] = Assemblies_GatherCrossStateZScoreMeans(secondsperbin);

hpca = [];
hica = [];

states = CrossStateZActsPCA.states;

for b = 1:length(states)

%% full pca figure
    ptst = states{b};
    hpca(end+1) = figure;
    eval(['pnass = size(CrossStateZActsPCA.' ptst 'AbsoluteActsNormOverRate_PCA,1);'])
    subplot(1,3,1)
        eval(['plot(CrossStateZActsPCA.' ptst 'AbsoluteActsNormOverRate_PCA'',''*'')'])
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:8],'XTickLabel',states)
    subplot(1,3,2)
        eval(['distributionPlot(CrossStateZActsPCA.' ptst 'AbsoluteActsNormOverRate_PCA)'])
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:8],'XTickLabel',states)
    subplot(1,3,3)
        eval(['boxplot(CrossStateZActsPCA.' ptst 'AbsoluteActsNormOverRate_PCA,''labels'',states);'])
        eval(['distributionPlot(CrossStateZActsPCA.' ptst 'AbsoluteActsNormOverRate_PCA,''variableWidth'',0,''showMM'',0)'])
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:8],'XTickLabel',states)
    AboveTitle(['PCA-NormTo' states{b} ' / SpikeRate'])
    set(hpca(end),'name',['PCA-NormTo' states{b} 'OverRate_AllStates'])

% %% Only separate states PCA figure    
%     if strcmp(states{b},'MWakeE') | strcmp(states{b},'NMWakeE') | strcmp(states{b},'UPE') | strcmp(states{b},'SpindlesE') |strcmp(states{b},'REME')
%         ptst = states{b};
%         hpca(end+1) = figure;
%         eval(['pnass = size(CrossStateZActsPCA.' ptst 'AbsoluteActsNormOverRate_PCA,1);'])
%         subplot(1,3,1)
%             eval(['plot(CrossStateZActsPCA.' ptst 'AbsoluteActsNormOverRate_PCA'',''*'')'])
%             xlim([.5 length(states)+.5])
%             set(gca,'XTick',[1:8],'XTickLabel',states)
%         subplot(1,3,2)
%             eval(['distributionPlot(CrossStateZActsPCA.' ptst 'AbsoluteActsNormOverRate_PCA)'])
%             xlim([.5 length(states)+.5])
%             set(gca,'XTick',[1:8],'XTickLabel',states)
%         subplot(1,3,3)
%             eval(['boxplot(CrossStateZActsPCA.' ptst 'AbsoluteActsNormOverRate_PCA,''labels'',states);'])
%             eval(['distributionPlot(CrossStateZActsPCA.' ptst 'AbsoluteActsNormOverRate_PCA,''variableWidth'',0,''showMM'',0)'])
%             xlim([.5 length(states)+.5])
%             set(gca,'XTick',[1:8],'XTickLabel',states)
% 
%         AboveTitle(['PCA-NormTo' states{b} ' / SpikeRate'])
%         set(hpca(end),'name',['PCA-NormTo' states{b} 'OverRate_SelectStates'])
%     end

%% full Ica figure
    itst = states{b};
    hica(end+1) = figure;
    eval(['inass = size(CrossStateZActsICA.' itst 'AbsoluteActsNormOverRate_ICA,1);'])
    subplot(1,3,1)
        eval(['plot(CrossStateZActsICA.' itst 'AbsoluteActsNormOverRate_ICA'',''*'')'])
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:8],'XTickLabel',states)
    subplot(1,3,2)
        eval(['distributionPlot(CrossStateZActsICA.' itst 'AbsoluteActsNormOverRate_ICA)'])
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:8],'XTickLabel',states)
    subplot(1,3,3)
        eval(['boxplot(CrossStateZActsICA.' itst 'AbsoluteActsNormOverRate_ICA,''labels'',states);'])
        eval(['distributionPlot(CrossStateZActsICA.' itst 'AbsoluteActsNormOverRate_ICA,''variableWidth'',0,''showMM'',0)'])
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:8],'XTickLabel',states)
    AboveTitle(['ICA-NormTo' states{b} ' / SpikeRate'])
    set(hica(end),'name',['ICA-NormTo' states{b} 'OverRate_AllStates'])

% %% Only separate states ICA figure    
%     if strcmp(states{b},'MWakeE') | strcmp(states{b},'NMWakeE') | strcmp(states{b},'UPE') | strcmp(states{b},'SpindlesE') |strcmp(states{b},'REME')
%         itst = states{b};
%         hica(end+1) = figure;
%         eval(['inass = size(CrossStateZActsICA.' itst 'AbsoluteActsNormOverRate_ICA,1);'])
%         subplot(1,3,1)
%             eval(['plot(CrossStateZActsICA.' itst 'AbsoluteActsNormOverRate_ICA'',''*'')'])
%             xlim([.5 length(states)+.5])
%             set(gca,'XTick',[1:8],'XTickLabel',states)
%         subplot(1,3,2)
%             eval(['distributionPlot(CrossStateZActsICA.' itst 'AbsoluteActsNormOverRate_ICA)'])
%             xlim([.5 length(states)+.5])
%             set(gca,'XTick',[1:8],'XTickLabel',states)
%         subplot(1,3,3)
%             eval(['boxplot(CrossStateZActsICA.' itst 'AbsoluteActsNormOverRate_ICA,''labels'',states);'])
%             eval(['distributionPlot(CrossStateZActsICA.' itst 'AbsoluteActsNormOverRate_ICA,''variableWidth'',0,''showMM'',0)'])
%             xlim([.5 length(states)+.5])
%             set(gca,'XTick',[1:8],'XTickLabel',states)
% 
%         AboveTitle(['ICA-NormTo' states{b} ' / SpikeRate'])
%         set(hica(end),'name',['ICA-NormTo' states{b} 'OverRate_SelectStates'])
%     end

    
    eval(['v = CrossStateZActsPCA.' ptst 'AbsoluteActsNormOverRate_PCA(:);'])
    h = KruskalByLabel(v,repmat(pnass,length(states),1),states);
    close(h(1),h(2))
    hpca(end+1) = h(3);

    eval(['v = CrossStateZActsICA.' itst 'AbsoluteActsNormOverRate_ICA(:);'])
    h = KruskalByLabel(v,repmat(inass,length(states),1),states);
    close(h(1),h(2))
    hica(end+1) = h(3);
end