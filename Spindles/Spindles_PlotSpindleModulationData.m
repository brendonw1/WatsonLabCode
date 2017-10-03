function h = Spindles_PlotSpindleModulationData(SpindleModulationData)

if ~exist('SpindleModulationData','var')
    SpindleModulationData = Spindles_GatherSpindlePhaseModulationData;;
end
v2struct(SpindleModulationData)%extracts field names as variables (necessary for labeling in fcns below)

%% Start plotting
h = [];

%% Basic stats
texttext = {['N Rats = ' num2str(NumRats)];...
    ['N Sesssions = ' num2str(NumSessions)];...
    ['N Spindles = ' num2str(sum(NumSpindles))];...
    [''];...
    ['N Cells = ' num2str(sum(NumCells))];...
    ['Total significant (Rayleigh p<0.05) = ' num2str(sum(modsignif>0.05)) ' (' num2str(100*sum(modsignif>0.05)/length(modsignif)) '%)'];...
    ['All-Cells Mean Phase Mean = ' num2str(nanmean(meanphase))];...
    [''];...
    ['N E Cells = ' num2str(sum(NumECells))];...
    ['E Cells significant (Rayleigh p<0.05) = ' num2str(sum(Emodsignif>0.05)) ' (' num2str(100*sum(Emodsignif>0.05)/length(Emodsignif)) '%)'];...
    ['E Cells Mean Phase Mean = ' num2str(nanmean(Emeanphase))];...
    [''];...
    ['N I Cells = ' num2str(sum(NumICells))];...
    ['I Cells significant (Rayleigh p<0.05) = ' num2str(sum(Imodsignif>0.05)) ' (' num2str(100*sum(Imodsignif>0.05)/length(Imodsignif)) '%)'];...
    ['I Cells Mean Phase Mean = ' num2str(nanmean(Imeanphase))];...
};
h(end+1) = figure;    
% Create a uicontrol of type "text"
mTextBox = uicontrol('style','text');
set(mTextBox,'Units','Normalized','Position',[.1 .1 .8 .8])
set(mTextBox,'String',texttext)
set(h(end),'name','BasicModulationStats')

% ps, means

%% Big correlation Figures

h(end+1) = figure;
mcorr_bw(Emodsignif,Emeanphase,ERates,Epeaktroughtimes,Espikewidthtimes)
set(h(end),'name','ECellCorrelationsVsCellFeatures')

h(end+1) = figure;
mcorr_bw(Imodsignif,Imeanphase,IRates,Ipeaktroughtimes,Ispikewidthtimes)
set(h(end),'name','ICellCorrelationsVsCellFeatures')

%% E vs I cell mean phases
h(end+1) = figure;
hax = subplot(1,2,1);
hist(Emeanphase,20)
yl = ylim(gca);
axis tight
hold on
xlim([0 2*pi])
[counts,bins] = hist(Imeanphase,20);
plot(bins,counts,'m');
legend('E','I')    
plot([0:0.05:2*pi],cos([0:0.05:2*pi])*0.05*max(yl)+0.9*max(yl),'color',[.7 .7 .7])
xlabel('Mean spindle phase per cell')
ylabel('# Cells')

hax = subplot(1,2,2)
t = plot_nanmeanSD_bars(Emeanphase,Imeanphase);
set(hax,'XTick',[1 2])
set(hax,'XTickLabel',{'E';'I'})
ylabel(hax,'Mean spindle phase per cell')
title(hax,'Histogram of per-cell mean phases')

set(h(end),'name','PerCellMeanPhases')


%% Plot total E cell spikes Vs total I cell spikes
h(end+1) = figure;
subplot(1,2,1)
bar(phasebins,sum(Ephasedistros_rawpersec'));
hold on
plot(phasebins,sum(Iphasedistros_rawpersec'),'m');
legend('E','I')
xlim([0 2*pi])
yl = ylim(gca);
plot([0:0.05:2*pi],cos([0:0.05:2*pi])*0.05*max(yl)+0.9*max(yl),'color',[.7 .7 .7])
xlabel('Phase')
ylabel('Summed Spikes/Sec')
title('Total (per second) spike counts across all cells of each type')
subplot(1,2,2)
normsumrawE = bwnormalize(sum(Ephasedistros_rawpersec'));
normsumrawI = bwnormalize(sum(Iphasedistros_rawpersec'));
bar(phasebins,normsumrawE);
hold on
plot(phasebins,normsumrawI,'m');
legend('E','I')
xlim([0 2*pi])
ylim([0 1])
plot([0:0.05:2*pi],cos([0:0.05:2*pi])*0.05+0.9,'color',[.7 .7 .7])
xlabel('Phase')
ylabel('Normalized Summed Spikes/Sec')
title('Total (per second) spike counts across all cells of each type')

wilcoxp = ranksum(normsumrawE,normsumrawI);
text(.05*pi,.7,{'WilcoxP=';num2str(wilcoxp)})

set(h(end),'name','TotalEVsISpikesByPhase')

%% Sessionwise means of phasemod and mean p's
% - StatsByLabel - but add ANOVA
th = KruskalByLabel(Emodsignif,NumECells,SessionNames);
    set(th(1),'name','EModSignifBySession_Table')
    set(th(2),'name','EModSignifBySession_BoxPlots')
    set(get(findobj('Type','Axes','Parent',th(2)),'YLabel'),'String','p value')
    set(th(3),'name','EModSignifBySession_CIRankOverlapPlot')
    AboveTitle('Ranks on X Axis',th(3))
    h = cat(2,h,th);
th = KruskalByLabel(Imodsignif,NumICells,SessionNames);
    set(th(1),'name','IModSignifBySession_Table')
    set(th(2),'name','IModSignifBySession_BoxPlots')
    set(get(findobj('Type','Axes','Parent',th(2)),'YLabel'),'String','p value')
    set(th(3),'name','IModSignifBySession_CIRankOverlapPlot')
    AboveTitle('Ranks on X Axis',th(3))
    h = cat(2,h,th);

th = KruskalByLabel(Ephasedistros,NumECells,SessionNames);
    set(th(1),'name','EPhasesBySession_Table')
    set(th(2),'name','EPhasesBySession_BoxPlots')
    set(get(findobj('Type','Axes','Parent',th(2)),'YLabel'),'String','p value')
    set(th(3),'name','EPhasesBySession_CIRankOverlapPlot')
    AboveTitle('Ranks on X Axis',th(3))
    h = cat(2,h,th);
th = KruskalByLabel(Iphasedistros,NumICells,SessionNames);
    set(th(1),'name','IPhasesBySession_Table')
    set(th(2),'name','IPhasesBySession_BoxPlots')
    set(get(findobj('Type','Axes','Parent',th(2)),'YLabel'),'String','p value')
    set(th(3),'name','IPhasesBySession_CIRankOverlapPlot')
    AboveTitle('Ranks on X Axis',th(3))
    h = cat(2,h,th);

%% Ratwise & ANOVAs
% - StatsByLabel - but add ANOVA
th = KruskalByLabel(Emodsignif,NumECells,RatNames);
    set(th(1),'name','EModSignifByRat_Table')
    set(th(2),'name','EModSignifByRat_BoxPlots')
    set(get(findobj('Type','Axes','Parent',th(2)),'YLabel'),'String','p value')
    set(th(3),'name','EModSignifByRat_CIRankOverlapPlot')
    AboveTitle('Ranks on X Axis',th(3))
    h = cat(2,h,th);
th = KruskalByLabel(Imodsignif,NumICells,RatNames);
    set(th(1),'name','IModSignifByRat_Table')
    set(th(2),'name','IModSignifByRat_BoxPlots')
    set(get(findobj('Type','Axes','Parent',th(2)),'YLabel'),'String','p value')
    set(th(3),'name','IModSignifByRat_CIRankOverlapPlot')
    AboveTitle('Ranks on X Axis',th(3))
    h = cat(2,h,th);

th = KruskalByLabel(Ephasedistros,NumECells,RatNames);
    set(th(1),'name','EPhaseByRat_Table')
    set(th(2),'name','EPhaseByRat_BoxPlots')
    set(get(findobj('Type','Axes','Parent',th(2)),'YLabel'),'String','p value')
    set(th(3),'name','EPhaseByRat_CIRankOverlapPlot')
    AboveTitle('Ranks on X Axis',th(3))
    h = cat(2,h,th);
th = KruskalByLabel(Iphasedistros,NumICells,RatNames);
    set(th(1),'name','IPhaseByRat_Table')
    set(th(2),'name','IPhaseByRat_BoxPlots')
    set(get(findobj('Type','Axes','Parent',th(2)),'YLabel'),'String','p value')
    set(th(3),'name','IPhaseByRat_CIRankOverlapPlot')
    AboveTitle('Ranks on X Axis',th(3))
    h = cat(2,h,th);

%% Anatomywise ANOVAs
th = KruskalByLabel(Emodsignif,NumECells,Anatomies);
    set(th(1),'name','EModSignifByAnatomy_Table')
    set(th(2),'name','EModSignifByAnatomy_BoxPlots')
    set(get(findobj('Type','Axes','Parent',th(2)),'YLabel'),'String','p value')
    set(th(3),'name','EModSignifByAnatomy_CIRankOverlapPlot')
    AboveTitle('Ranks on X Axis',th(3))
    h = cat(2,h,th);
th = KruskalByLabel(Imodsignif,NumICells,Anatomies);
    set(th(1),'name','IModSignifByAnatomy_Table')
    set(th(2),'name','IModSignifByAnatomy_BoxPlots')
    set(get(findobj('Type','Axes','Parent',th(2)),'YLabel'),'String','p value')
    set(th(3),'name','IModSignifByAnatomy_CIRankOverlapPlot')
    AboveTitle('Ranks on X Axis',th(3))
    h = cat(2,h,th);

th = KruskalByLabel(Ephasedistros,NumECells,Anatomies);
    set(th(1),'name','EPhaseByAnatomy_Table')
    set(th(2),'name','EPhaseByAnatomy_BoxPlots')
    set(get(findobj('Type','Axes','Parent',th(2)),'YLabel'),'String','p value')
    set(th(3),'name','EPhaseByAnatomy_CIRankOverlapPlot')
    AboveTitle('Ranks on X Axis',th(3))
    h = cat(2,h,th);
th = KruskalByLabel(Iphasedistros,NumICells,Anatomies);
    set(th(1),'name','IPhaseByAnatomy_Table')
    set(th(2),'name','IPhaseByAnatomy_BoxPlots')
    set(get(findobj('Type','Axes','Parent',th(2)),'YLabel'),'String','p value')
    set(th(3),'name','IPhaseByAnatomy_CIRankOverlapPlot')
    AboveTitle('Ranks on X Axis',th(3))
    h = cat(2,h,th);

%% save figures
od = cd;
savedir = '/mnt/brendon4/Dropbox/Data/Spindles/SpindleModulationData';
if ~exist(savedir,'dir')
    mkdir(savedir)
end
cd(savedir)
savefigsasname(h,'fig');
% close(h)
cd(od)