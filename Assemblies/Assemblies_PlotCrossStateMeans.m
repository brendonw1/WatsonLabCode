function Assemblies_PlotCrossStateMeans(secondsperbin)

[CrossStateActsPCA,CrossStateActsICA] = Assemblies_GatherCrossStateMeans(secondsperbin);
states = CrossStateActsPCA.states;

%% Start plotting
h = [];

%% Basic stats
texttext = {['N Rats = ' num2str(CrossStateActsPCA.NumRats)];...
    ['N Sesssions = ' num2str(length(CrossStateActsPCA.SessionNames))];...
    [' '];...
};
        
for b = 1:length(states)
    tst = states{b};
    eval(['tnum = (CrossStateActsPCA.num' tst 'Ass);'])
    texttext{end+1} = ['N ' tst '-BasedAssemblies = ' num2str(sum(tnum))]; 
end
h(end+1) = figure;    
% Create a uicontrol of type "text"
mTextBox = uicontrol('style','text');
set(mTextBox,'Units','Normalized','Position',[.1 .1 .8 .8])
set(mTextBox,'String',texttext)
set(h(end),'name','BasicCounts')


%% Plotting per-assembly projections
hpca = [];
hica = [];

for b = 1:length(states)

%% full pca figure
    ptst = states{b};
    hpca(end+1) = figure;
    eval(['pnass = size(CrossStateActsPCA.' ptst 'ActsOverRateNorm_PCA,1);'])
    subplot(1,3,1)
        eval(['plot(CrossStateActsPCA.' ptst 'ActsOverRateNorm_PCA'',''*'')'])
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:8],'XTickLabel',states)
    subplot(1,3,2)
        eval(['distributionPlot(CrossStateActsPCA.' ptst 'ActsOverRateNorm_PCA,''globalNorm'',0)'])
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:8],'XTickLabel',states)
    subplot(1,3,3)
        eval(['boxplot(CrossStateActsPCA.' ptst 'ActsOverRateNorm_PCA,''labels'',states);'])
        eval(['distributionPlot(CrossStateActsPCA.' ptst 'ActsOverRateNorm_PCA,''variableWidth'',0,''showMM'',0,''globalNorm'',0)'])
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:8],'XTickLabel',states)
    AboveTitle([num2str(secondsperbin) 'secPCA-NormTo' states{b} ' / SpikeRate'])
    set(hpca(end),'name',['PCA-NormTo' states{b} 'OverRate_AllStates'])
    
    eval(['v = CrossStateActsPCA.' ptst 'ActsOverRateNorm_PCA(:);'])
    ht = KruskalByLabel(v,repmat(pnass,length(states),1),states);
    close(ht(1),ht(2))
    hpca(end+1) = ht(3);
    ax = get(hpca(end),'Children');
    title(ax,['PCA-NormTo' states{b} 'OverRate_AllStates']);

% %% Only separate states PCA figure    
%     if strcmp(states{b},'MWakeE') | strcmp(states{b},'NMWakeE') | strcmp(states{b},'UPE') | strcmp(states{b},'SpindlesE') |strcmp(states{b},'REME')
%         ptst = states{b};
%         hpca(end+1) = figure;
%         eval(['pnass = size(CrossStateActsPCA.' ptst 'ActsOverRateNorm_PCA,1);'])
%         subplot(1,3,1)
%             eval(['plot(CrossStateActsPCA.' ptst 'ActsOverRateNorm_PCA'',''*'')'])
%             xlim([.5 length(states)+.5])
%             set(gca,'XTick',[1:8],'XTickLabel',states)
%         subplot(1,3,2)
%             eval(['distributionPlot(CrossStateActsPCA.' ptst 'ActsOverRateNorm_PCA)'])
%             xlim([.5 length(states)+.5])
%             set(gca,'XTick',[1:8],'XTickLabel',states)
%         subplot(1,3,3)
%             eval(['boxplot(CrossStateActsPCA.' ptst 'ActsOverRateNorm_PCA,''labels'',states);'])
%             eval(['distributionPlot(CrossStateActsPCA.' ptst 'ActsOverRateNorm_PCA,''variableWidth'',0,''showMM'',0)'])
%             xlim([.5 length(states)+.5])
%             set(gca,'XTick',[1:8],'XTickLabel',states)
% 
%         AboveTitle(['PCA-NormTo' states{b} ' / SpikeRate'])
%         set(hpca(end),'name',['PCA-NormTo' states{b} 'OverRate_SelectStates'])
%     end

%% full Ica figure
    itst = states{b};
    hica(end+1) = figure;
    eval(['inass = size(CrossStateActsICA.' itst 'ActsOverRateNorm_ICA,1);'])
    subplot(1,3,1)
        eval(['plot(CrossStateActsICA.' itst 'ActsOverRateNorm_ICA'',''*'')'])
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:8],'XTickLabel',states)
    subplot(1,3,2)
        eval(['distributionPlot(CrossStateActsICA.' itst 'ActsOverRateNorm_ICA,''globalNorm'',0)'])
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:8],'XTickLabel',states)
    subplot(1,3,3)
        eval(['boxplot(CrossStateActsICA.' itst 'ActsOverRateNorm_ICA,''labels'',states);'])
        eval(['distributionPlot(CrossStateActsICA.' itst 'ActsOverRateNorm_ICA,''variableWidth'',0,''showMM'',0,''globalNorm'',0)'])
        xlim([.5 length(states)+.5])
        set(gca,'XTick',[1:8],'XTickLabel',states)
    AboveTitle([num2str(secondsperbin) 'secICA-NormTo' states{b} ' / SpikeRate'])
    set(hica(end),'name',['ICA-NormTo' states{b} 'OverRate_AllStates'])

% %% Only separate states ICA figure    
%     if strcmp(states{b},'MWakeE') | strcmp(states{b},'NMWakeE') | strcmp(states{b},'UPE') | strcmp(states{b},'SpindlesE') |strcmp(states{b},'REME')
%         itst = states{b};
%         hica(end+1) = figure;
%         eval(['inass = size(CrossStateActsICA.' itst 'ActsOverRateNorm_ICA,1);'])
%         subplot(1,3,1)
%             eval(['plot(CrossStateActsICA.' itst 'ActsOverRateNorm_ICA'',''*'')'])
%             xlim([.5 length(states)+.5])
%             set(gca,'XTick',[1:8],'XTickLabel',states)
%         subplot(1,3,2)
%             eval(['distributionPlot(CrossStateActsICA.' itst 'ActsOverRateNorm_ICA)'])
%             xlim([.5 length(states)+.5])
%             set(gca,'XTick',[1:8],'XTickLabel',states)
%         subplot(1,3,3)
%             eval(['boxplot(CrossStateActsICA.' itst 'ActsOverRateNorm_ICA,''labels'',states);'])
%             eval(['distributionPlot(CrossStateActsICA.' itst 'ActsOverRateNorm_ICA,''variableWidth'',0,''showMM'',0)'])
%             xlim([.5 length(states)+.5])
%             set(gca,'XTick',[1:8],'XTickLabel',states)
% 
%         AboveTitle(['ICA-NormTo' states{b} ' / SpikeRate'])
%         set(hica(end),'name',['ICA-NormTo' states{b} 'OverRate_SelectStates'])
%     end


    eval(['v = CrossStateActsICA.' itst 'ActsOverRateNorm_ICA(:);'])
    ht = KruskalByLabel(v,repmat(inass,length(states),1),states);
    close(ht(1),ht(2))
    hica(end+1) = ht(3);
    ax = get(hica(end),'Children');
    title(ax,['ICA-NormTo' states{b} 'OverRate_AllStates']);
end

pfigdurname = ['/mnt/brendon4/Dropbox/BW OUTPUT/Assemblies/StateComparisons/FiguresPCAAllToAll_' num2str(secondsperbin) 'sec'];
savethesefigsas(hpca,'fig',pfigdurname)

ifigdurname = ['/mnt/brendon4/Dropbox/BW OUTPUT/Assemblies/StateComparisons/FiguresICAAllToAll_' num2str(secondsperbin) 'sec'];
savethesefigsas(hica,'fig',ifigdurname)
 
 