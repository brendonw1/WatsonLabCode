function SleepDataset_CellRateDistribsAndChanges_ByMotionBoolean

savefigsbool = 0;

cellFSEy = [];
cellFSEn = [];
cellLSEy = [];
cellLSEn = [];
cellFSIy = [];
cellFSIn = [];
cellLSIy = [];
cellLSIn = [];
epmoy = [];
epmon = [];

%% get dataset info from directory
[names,dirs] = SleepDataset_GetDatasetsDirs_WSWCells;

%% gather actual data
for a = 1:length(dirs);
    py = fullfile(dirs{a},[names{a} '_CellRateVariablesByYesMotion.mat']);
    ty = load(py);
    cy = ty.CellRateVariables;
    pn = fullfile(dirs{a},[names{a} '_CellRateVariablesByNoMotion.mat']);
    tn = load(pn);
    cn = tn.CellRateVariables;
    
    cellFSEy = cat(2,cellFSEy,CellRateCountsBySWSEpisode(cy,'FirstSWSESpikeRates'));
    cellFSEn = cat(2,cellFSEn,CellRateCountsBySWSEpisode(cn,'FirstSWSESpikeRates'));
    cellLSEy = cat(2,cellLSEy,CellRateCountsBySWSEpisode(cy,'LastSWSESpikeRates'));
    cellLSEn = cat(2,cellLSEn,CellRateCountsBySWSEpisode(cn,'LastSWSESpikeRates'));
    cellFSIy = cat(2,cellFSIy,CellRateCountsBySWSEpisode(cy,'FirstSWSISpikeRates'));
    cellFSIn = cat(2,cellFSIn,CellRateCountsBySWSEpisode(cn,'FirstSWSISpikeRates'));
    cellLSIy = cat(2,cellLSIy,CellRateCountsBySWSEpisode(cy,'LastSWSISpikeRates'));
    cellLSIn = cat(2,cellLSIn,CellRateCountsBySWSEpisode(cn,'LastSWSISpikeRates'));
    epmoy = cat(1,epmoy,cy.PreWakeMovingSecs);
    epmon = cat(1,epmon,cn.PreWakeMovingSecs);
    
%     fny = fieldnames(cy);
%     fnn = fieldnames(cn);
    f = fieldnames(cy);
    if a == 1;
        CellRateVariablesY = cy;
        CellRateVariablesN = cn;
    else
        for b = 1:length(f)
%             ty = fny{b};
%             tn = fnn{b};
            t = f{b};
            if ~strcmp(t,'basename') & ~strcmp(t,'basepath')
               eval(['CellRateVariablesY.' t '= cat(1,CellRateVariablesY.' t ',cy.' t ');']); 
               eval(['CellRateVariablesN.' t '= cat(1,CellRateVariablesN.' t ',cn.' t ');']); 
            end
        end
    end
end

CellRateVariablesY.basename = ['SleepDataset' date];
CellRateVariablesY.basepath = cd;
CellRateVariablesN.basename = ['SleepDataset' date];
CellRateVariablesN.basepath = cd;

%% Comparision plotting
cn = CellRateVariablesN;
cy = CellRateVariablesY;
preEy = cy.FirstSWSESpikeRates;
preEn = cn.FirstSWSESpikeRates;
preIy = cy.FirstSWSISpikeRates;
preIn = cn.FirstSWSISpikeRates;
postEy = cy.LastSWSESpikeRates;
postEn = cn.LastSWSESpikeRates;
postIy = cy.LastSWSISpikeRates;
postIn = cn.LastSWSISpikeRates;

numECellsy = length(preEy);
numICellsy = length(preIy);
numbinsEy = round(numECellsy/5);
numbinsIy = round(numICellsy/5);
numECellsn = length(preEn);
numICellsn = length(preIn);
numbinsEn = round(numECellsn/5);
numbinsIn = round(numICellsn/5);

diffEy = postEy-preEy;
diffEn = postEn-preEn;
diffIy = postIy-preIy;
diffIn = postIn-preIn;
ratioEy = 10.^ConditionedLogOfRatio(postEy,preEy);
ratioEn = 10.^ConditionedLogOfRatio(postEn,preEn);
ratioIy = 10.^ConditionedLogOfRatio(postIy,preIy);
ratioIn = 10.^ConditionedLogOfRatio(postIn,preIn);

h=[];

% Bar graphs of population trends
h(end+1) = figure;
subplot(1,2,1)
plot_meanSD_bars(diffEn,0,diffEy)
[difftest,p] = ttest2(diffEy,diffEn);
ylabel('Hz Change Per Cell (Post-Pre)')
set(gca,'XTickLabel',{'','LowMvmt','','HighMvmt',''})
ylim([-1.5 .2])
title(['ECells.  T-Test p=' num2str(p)])
subplot(1,2,2)
plot_meanSEM_bars(diffEn,0,diffEy)
ylabel('Hz Change Per Cell (Post-Pre)')
set(gca,'XTickLabel',{'LowMvmt','','HighMvmt',''})
ylim([-.5 .1])

h(end+1) = figure;
subplot(1,2,1)
plot_meanSD_bars(diffIn,0,diffIy)
[difftest,p] = ttest2(diffIy,diffIn);
ylabel('Hz Change Per Cell (Post-Pre)')
set(gca,'XTickLabel',{'','LowMvmt','','HighMvmt',''})
ylim([-1.5 .2])
title(['ICells.  T-Test p=' num2str(p)])
subplot(1,2,2)
plot_meanSEM_bars(diffIn,0,diffIy)
ylabel('Hz Change Per Cell (Post-Pre)')
set(gca,'XTickLabel',{'LowMvmt','','HighMvmt',''})
ylim([-.5 .1])


%ratios
h(end+1) = figure;
subplot(1,2,1)
plot_geomeanoflogofratiosSD_bars(ratioEn,-Inf,ratioEy)
[difftest,p] = ttest2(ratioEy,ratioEn);
ylabel('Post:PreRatio Per Cell (Post-Pre)')
set(gca,'XTickLabel',{'','LowMvmt','','HighMvmt',''})
% ylim([-1.5 .2])
title(['ECells.  T-Test p=' num2str(p)])
subplot(1,2,2)
plot_geomeanoflogofratiosSEM_bars(diffEn,-Inf,diffEy)
ylabel('Post:PreRatio Per Cell (Post-Pre)')
set(gca,'XTickLabel',{'LowMvmt','','HighMvmt',''})
% ylim([-.5 .1])

h(end+1) = figure;
subplot(1,2,1)
plot_geomeanoflogofratiosSD_bars(ratioIn,-Inf,ratioIy)
[difftest,p] = ttest2(ratioIy,ratioIn);
ylabel('Post:PreRatio Per Cell (Post-Pre)')
set(gca,'XTickLabel',{'','LowMvmt','','HighMvmt',''})
% ylim([-1.5 .2])
title(['ICells.  T-Test p=' num2str(p)])
subplot(1,2,2)
plot_geomeanoflogofratiosSEM_bars(diffIn,-Inf,diffIy)
ylabel('Post:PreRatio Per Cell (Post-Pre)')
set(gca,'XTickLabel',{'LowMvmt','','HighMvmt',''})
% ylim([-.5 .1])


% Cell By Cell changes
h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(preEy,postEy);
    subplot(1,2,1)
    title('E:First SWS Rates vs Last SWS Rates')
    subplot(1,2,2)
    title('Log scale')
    set(h(end),'name',['ECellByCellRateChanges-FirstVsLastSWS_YMotion'])
% Quartiles
% qixs = GetQuartiles(preEy);
% h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLogByQuartile(preEy,postEy,qixs);
%     subplot(1,2,1)
%     title('E:First SWS Rates vs Last SWS Rates')
%     subplot(1,2,2)
%     title('Log scale')
%     set(h(end),'name',['ECellByCellRateChanges-FirstVsLastSWS'])
h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(preEn,postEn);
    subplot(1,2,1)
    title('E:First SWS Rates vs Last SWS Rates')
    subplot(1,2,2)
    title('Log scale')
    set(h(end),'name',['ECellByCellRateChanges-FirstVsLastSWS_NMotion'])

h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(preIy,postIy);
    subplot(1,2,1)
    title('I:First SWS Rates vs Last SWS Rates')
    subplot(1,2,2)
    title('Log scale')
    set(h(end),'name',['ICellByCellRateChanges-FirstVsLastSWS_YMotion'])
h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(preIn,postIn);
    subplot(1,2,1)
    title('I:First SWS Rates vs Last SWS Rates')
    subplot(1,2,2)
    title('Log scale')
    set(h(end),'name',['ICellByCellRateChanges-FirstVsLastSWS_NMotion'])

%Regress against motion
adE = collectavgdifferences_In(cellLSEy,cellFSEy,cellLSEn,cellFSEn);
adI = collectavgdifferences_In(cellLSIy,cellFSIy,cellLSIn,cellFSIn);
epmo=[epmoy;epmon];

x = epmo; y = adE;
figure;
plot(x,y,'.')
[yfit,r2,p] =  RegressAndFindR2(x,y,1);
hold on;
plot(x,yfit,'r')
text(0.8*max(x),0.8*max(y),{['r2=',num2str(r2)];['p=',num2str(p)]})
xlabel('Second with Movement in presleep')
ylabel('Average Hz Drop per session')
title('E Cells with WSW')

x = epmo; y = adI;
figure;
plot(x,y,'.')
[yfit,r2,p] =  RegressAndFindR2(x,y,1);
hold on;
plot(x,yfit,'r')
text(0.8*max(x),0.8*max(y),{['r2=',num2str(r2)];['p=',num2str(p)]})
xlabel('Second with Movement in presleep')
ylabel('Average Hz Drop per session')
title('I Cells with WSW')

h(end+1) = SpikingAnalysis_PlotRateDistributionsLinearAndLog(postEy,'numbins',numbinsEy,'color',[.6 .6 .6]);
[~] = SpikingAnalysis_OverlayRateDistributionsLinearAndLog(h(end),postEn,'numbins',numbinsEn,'color','k');
subplot(2,1,1);title('Gray is High Mvmt, Black is Low Movement')
xlabel('Spike rates');ylabel('Cell Counts')

% h(end+1) = SpikingAnalysis_PlotRateDistributionsLinearAndLog(diffEy,'numbins',numbinsEy,'color',[.6 .6 .6]);
% [~] = SpikingAnalysis_OverlayRateDistributionsLinearAndLog(h(end),diffEn,'numbins',numbinsEn,'color','k');
% subplot(2,1,1);title('Gray is High Mvmt, Black is Low Movement')
% xlabel('Spike rate Diffs');ylabel('Cell Counts')

h(end+1) = SpikingAnalysis_PlotRateDistributionsLinearAndLog(ratioEy,'numbins',numbinsEy,'color',[.6 .6 .6]);
[~] = SpikingAnalysis_OverlayRateDistributionsLinearAndLog(h(end),ratioEn,'numbins',numbinsEn,'color','k');
subplot(2,1,1);title('Gray is High Mvmt, Black is Low Movement')
xlabel('Spike rate ratios');ylabel('Cell Counts')

%% Ratios


h(end+1) = figure;
SpikingAnalysis_PlotAgainstAndRegressLinearAndLog(preEy,ratioEy)
h(end+1) = figure;
SpikingAnalysis_PlotAgainstAndRegressLinearAndLog(preEn,ratioEn)
h(end+1) = figure;
SpikingAnalysis_PlotAgainstAndRegressLinearAndLog(preIy,ratioIy)
h(end+1) = figure;
SpikingAnalysis_PlotAgainstAndRegressLinearAndLog(preIn,ratioIn)


%% plotting all plots, but not comparing

% h = SpikingAnalysis_IndividalCellRatesAnalysesWithSleep_Plot(CellRateVariablesY);
% h = SpikingAnalysis_IndividalCellRatesAnalysesWithSleep_Plot(CellRateVariablesN);

%% Output
% if savefigsbool
%     n = ['CellRateDstribsAndChanges_On_' date];
% 
%     CellStringToTextFile(names,[n,'.txt'])%save names of datasets used on this date
%     save(n,'CellRateVariables')
% 
%     savethesefigsas(h,'eps')
%     ! rm -R CellRateDistributionFigs/
% end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ad = collectavgdifferences_In(preratesY,postratesY,preratesN,postratesN)

ad = [];
for a = 1:length(preratesY);
    ad(end+1) = mean(preratesY{a}-postratesY{a});
end
for a = 1:length(postratesN);
    ad(end+1) = mean(postratesN{a}-preratesN{a});
end
