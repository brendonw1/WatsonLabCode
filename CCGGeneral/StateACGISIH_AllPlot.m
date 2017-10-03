function StateACGISIH_AllPlot
% Run GatherStateIntervalSets.m on everything
% Run StateRates_all.m
% Run ACGCCGGenerate.m on everything to pull out state-specific ACGs, ISIHs
% and CCGs
% This just uses the 300ms ACG/ISIH... no CCG... no other timescales for
% now.
warning off

%% Constants
DesiredWidth = 1000;

%% Basic setup
[names,dirs] = GetDefaultDataset;
CellIDMatrix = GatherAllCellClassMatrix;
ECells = CellIDMatrix(:,1);
ICells = CellIDMatrix(:,2);
% stnames = {'Wake';'MWake';'NMWake';'REM';'SWS';'UPstates';'Spindles';'FSWS';'LSWS'};
stnames = {'WSWake';'SWS';'REM'};

%% Gather data
for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};
    load(fullfile(basepath,[basename '_ACGCCGsAll.mat']))%raw data in hz
    load(fullfile(basepath,[basename '_StateIntervals.mat']));
    tt = find(ACGCCGsAll.CCGHalfWidthsinMs==DesiredWidth);
    % s = SpikingAnalysis_GatherAllStateRates;
    
%     stnames = fieldnames(StateIntervals);
%     [~,t]=ismember('NDSpindles',stnames);
%     stnames(t)=[];


    for st = 1:length(stnames);
        if a == 1
            eval(['ACGs_' stnames{st} ' = ACGCCGsAll.' stnames{st} 'ACGs{tt}'';'])
            eval(['ISIHs_' stnames{st} ' = ACGCCGsAll.' stnames{st} 'ISIHs{tt}'';'])
            times = ACGCCGsAll.Times{tt};
            times = times(ceil(length(times)/2):end);
        else 
            eval(['ACGs_' stnames{st} '=cat(1,ACGs_' stnames{st} ',ACGCCGsAll.' stnames{st} 'ACGs{tt}'');'])
            eval(['ISIHs_' stnames{st} '=cat(1,ISIHs_' stnames{st} ',ACGCCGsAll.' stnames{st} 'ISIHs{tt}'');'])
        end
    end
end
for st = 1:length(stnames);
    ACGNames{st} = ['ACGs_' stnames{st}];
    ISIHNames{st} = ['ISIHs_' stnames{st}];
end

h = [];
% c = PurpleColors(length(stnames));
c = RainbowColors(length(stnames));
h(end+1) = figure('name','RawE&ICellACGsByState');%E figure
sp31 = subplot(2,2,1,'NextPlot','Add','XScale','Log');
ylabel('Hz')
% sp32 = subplot(2,2,2,'NextPlot','Add','XScale','Log');
% sp33 = subplot(2,2,3,'NextPlot','Add','XScale','Log');
sp34 = subplot(2,2,4,'NextPlot','Add','XScale','Log');
ylabel('Hz')

c = StateColors;
h(end+1) = figure('name','ECellACGsByState');%E figure
sp11 = subplot(2,2,1,'NextPlot','Add','XScale','Log');
sp12 = subplot(2,2,2,'NextPlot','Add','XScale','Log');
sp13 = subplot(2,2,3,'NextPlot','Add','XScale','Log');
sp14 = subplot(2,2,4,'NextPlot','Add','XScale','Log');

h(end+1) = figure('name','ICellACGsByState');%I figure
sp21 = subplot(2,2,1,'NextPlot','Add','XScale','Log');
sp22 = subplot(2,2,2,'NextPlot','Add','XScale','Log');
sp23 = subplot(2,2,3,'NextPlot','Add','XScale','Log');
sp24 = subplot(2,2,4,'NextPlot','Add','XScale','Log');

for a = 1:length(ACGNames);%every state, grab that variable, plot the average ACG, average ISIH
    tn = ACGNames{a};
    eval(['tacgs = ' ACGNames{a} ''';'])
    eval(['tisihs = ' ISIHNames{a} ''';'])
    tacgs = tacgs(end-(length(times)-1):end,:);
    
    rawacgsE = mean(tacgs(:,ECells),2);
    rawacgsI = mean(tacgs(:,ICells),2);
    
    mztacgsE = mean(zscore(tacgs(:,ECells)),2);
    mztisihsE = mean(zscore(tisihs(:,ECells)),2);
    mztacgsI = mean(zscore(tacgs(:,ICells)),2);
    mztisihsI = mean(zscore(tisihs(:,ICells)),2);

    mntacgsE = nanmean(localnormalizebymean_nanforlowcount(tacgs(:,ECells)'),1);
    mntisihsE = nanmean(localnormalizebymean_nanforlowcount(tisihs(:,ECells)'),1);
    mntacgsI = nanmean(localnormalizebymean_nanforlowcount(tacgs(:,ICells)'),1);
    mntisihsI = nanmean(localnormalizebymean_nanforlowcount(tisihs(:,ICells)'),1);

    mmntacgsE = nanmean(bwnormalize_array(tacgs(:,ECells)'),1);
    mmntisihsE = nanmean(bwnormalize_array(tisihs(:,ECells)'),1);
    mmntacgsI = nanmean(bwnormalize_array(tacgs(:,ICells)'),1);
    mmntisihsI = nanmean(bwnormalize_array(tisihs(:,ICells)'),1);
    
    if strcmp(tn,'FSWS')
        fsws_acgs = tacgs;
        fsws_isihs = tisihs;
    elseif strcmp(tn,'LSWS')
        lsws_acgs = tacgs;
        lsws_isihs = tisihs;
    end
    
    
    % E Cell plots
    semilogx(times,rawacgsE,'color',c(a,:),'linewidth',2.5,'parent',sp31)
    semilogx(times,rawacgsI,'color',c(a,:),'linewidth',2.5,'parent',sp34)
    
    % E Cell plots
    semilogx(times,mntacgsE,'color',c(a,:),'linewidth',2.5,'parent',sp11)
    semilogx(times,mntisihsE,'color',c(a,:),'linewidth',2.5,'parent',sp12)
    semilogx(times,mmntacgsE,'color',c(a,:),'linewidth',2.5,'parent',sp13)
    semilogx(times,mmntisihsE,'color',c(a,:),'linewidth',2.5,'parent',sp14)
    % I Cell plots
    semilogx(times,mntacgsI,'color',c(a,:),'linewidth',2.5,'parent',sp21)
    semilogx(times,mntisihsI,'color',c(a,:),'linewidth',2.5,'parent',sp22)
    semilogx(times,mmntacgsI,'color',c(a,:),'linewidth',2.5,'parent',sp23)
    semilogx(times,mmntisihsI,'color',c(a,:),'linewidth',2.5,'parent',sp24)
end
% 
legend(sp34,stnames,'location','southEast')
title(sp31,'Raw Summed ACGs, E Cells')
title(sp34,'Raw Summed ACGs, I Cells')
axis(sp31,'tight')
axis(sp34,'tight')

legend(sp14,stnames,'location','northEast')
title(sp11,'Mean of Mean-Normalized ACGs, E Cells')
title(sp12,'Mean of Mean-Normalized ISIHs, E Cells')
title(sp13,'Mean of Max-Normalized ACGs, E Cells')
title(sp14,'Mean of Max-Normalized ISIHs, E Cells')
axis(sp11,'tight')
axis(sp12,'tight')
axis(sp13,'tight')
axis(sp14,'tight')
legend(sp24,stnames,'location','northEast')
title(sp21,'Mean of Mean-Normalized ACGs, I Cells')
title(sp22,'Mean of Mean-Normalized ISIHs, I Cells')
title(sp23,'Mean of Max-Normalized ACGs, I Cells')
title(sp24,'Mean of Max-Normalized ISIHs, I Cells')
axis(sp21,'tight')
axis(sp22,'tight')
axis(sp23,'tight')
axis(sp24,'tight')


%% Some state-wise stats
burstindexms = 15;
bilim = find(times<=burstindexms,1,'last');

for a = 1:length(ACGNames);%every state, grab that variable, plot the average ACG, average ISIH
    tn = ACGNames{a};
    eval(['tacgs = ' ACGNames{a} ''';'])
    eval(['tisihs = ' ISIHNames{a} ''';'])
    tacgs = tacgs(end-(length(times)-1):end,:);
    tisihs = tisihs(end-(length(times)-1):end,:);
   
    tacgsE = tacgs(:,ECells);
    tacgsI = tacgs(:,ICells);
    tisihsE = tisihs(:,ECells);
    tisihsI = tisihs(:,ICells);
    
    % burst indices
    biE{a} = sum(tisihsE(1:bilim,:))./sum(tisihsE(bilim+1:end,:));
    biI{a} = sum(tisihsI(1:bilim,:))./sum(tisihsI(bilim+1:end,:));

    % burst decays
    BurstDecayE{a} = FitExponentialsToBurstDecays(tacgsE,times/1000,burstindexms*2);
    BurstDecayI{a} = FitExponentialsToBurstDecays(tacgsI,times/1000,burstindexms*2);
end


be = [];
bi = [];
de = [];
di = [];
for a = 1:length(biE);
    be = cat(1,be,biE{a});
    bi = cat(1,bi,biI{a});
    de = cat(1,de,BurstDecayE{a}.ExponentVal);
    di = cat(1,di,BurstDecayI{a}.ExponentVal);
end
h(end+1) = figure('name','BurstIntervalByState');
subplot(2,2,1)
    bplot(be')'
    set(gca,'XTick',1:length(ACGNames),'XTickLabel',stnames)
    title('ECells','fontweight','normal')
    ylabel('BurstIndex')
subplot(2,2,2)
    hax = plot_stats_bars(be','central','median','variance','std');
    set(hax,'XTick',1:length(ACGNames),'XTickLabel',stnames)
subplot(2,2,3)
    bplot(bi')'
    set(gca,'XTick',1:length(ACGNames),'XTickLabel',stnames)
    title('ICells','fontweight','normal')
    ylabel('BurstIndex')
subplot(2,2,4)
    hax = plot_stats_bars(bi','central','median','variance','std');
    set(hax,'XTick',1:length(ACGNames),'XTickLabel',stnames)
AboveTitle(['Burst Index @ ' num2str(burstindexms) 'ms']);

t = be';
[p,pairwiseCIs,th] = KruskalByLabel(t(:),size(t,1)*ones(1,length(stnames)),stnames);
pause(.5)
delete(th(2));th(2)=[];
t = get(get(gca,'title'),'string');
t{1} = 'ECellBurstIdx';
title(t)
set(th(1),'name','KruskalStatsEBurstIdx')
h = cat(2,h,th);

t = bi';
[p,pairwiseCIs,th] = KruskalByLabel(t(:),size(t,1)*ones(1,length(stnames)),stnames);
pause(.5)
delete(th(2));th(2)=[];
t = get(get(gca,'title'),'string');
t{1} = 'ICellBurstIdx';
title(t)
set(th(1),'name','KruskalStatsIBurstIdx')
h = cat(2,h,th);


h(end+1) = figure('name','BurstACGDecaySlope');
subplot(2,2,1)
    bplot(de')'
    set(gca,'XTick',1:length(ACGNames),'XTickLabel',stnames,'yscale','log')
    title('ECells','fontweight','normal')
    ylabel('DecayExponent')
subplot(2,2,2)
    hax = plot_stats_bars(de','central','median','variance','std');
    set(hax,'XTick',1:length(ACGNames),'XTickLabel',stnames)
subplot(2,2,3)
    bplot(di')'
    set(gca,'XTick',1:length(ACGNames),'XTickLabel',stnames,'yscale','log')
    title('ICells','fontweight','normal')
    ylabel('DecayExponent')
subplot(2,2,4)
    hax = plot_stats_bars(di','central','median','variance','std');
    set(hax,'XTick',1:length(ACGNames),'XTickLabel',stnames)
AboveTitle(['Burst Decay (ACG) @ ' num2str(burstindexms) 'ms']);
    
t = de';
[p,pairwiseCIs,th] = KruskalByLabel(t(:),size(t,1)*ones(1,length(stnames)),stnames);
pause(.5)
delete(th(2));th(2)=[];
t = get(get(gca,'title'),'string');
t{1} = 'ECellBurstDecayExponent';
title(t)
set(th(1),'name','KruskalStatsEBurstDecay')
h = cat(2,h,th);

t = di';
[p,pairwiseCIs,th] = KruskalByLabel(t(:),size(t,1)*ones(1,length(stnames)),stnames);
pause(.5)
delete(th(2));th(2)=[];
t = get(get(gca,'title'),'string');
t{1} = 'ICellBurstDecayExponent';
title(t)
set(th(1),'name','KruskalStatsIBurstDecay')
h = cat(2,h,th);

1;


%%
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/Correlograms/',h,'fig')
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/Correlograms/',h,'png')
MakeDirSaveFigsThereAs('/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/Correlograms/',h,'svg')



function normalized=localnormalizebymean_nanforlowcount(array)
%normalizes pixel values in a 3D moviematrix of multiple movies... 
%each movie is normalized within itself

minNum = 200;
bad = sum(array,2)<=minNum;

me=mean(array,2);
me = repmat(me,1,size(array,2));
normalized=array./me;

normalized(bad,:) = nan;