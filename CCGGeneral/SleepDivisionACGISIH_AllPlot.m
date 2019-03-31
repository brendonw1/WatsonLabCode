function SleepDivisionACGISIH_AllPlot(NumSleepDivisions)
% Run GatherStateIntervalSets.m on everything
% Run StateRates_all.m
% Run ACGCCGGenerate.m on everything to pull out state-specific ACGs, ISIHs
% and CCGs
% This just uses the 300ms ACG/ISIH... no CCG... no other timescales for
% now.


%% Input management
if ~exist('NumSleepDivisions','var')
    NumSleepDivisions= 4;
end

%% Constants
DesiredWidth = 1000;%ie which of CCGHalfWidths do we want?
warning off

%% Basic setup
[names,dirs] = GetDefaultDataset;
CellIDMatrix = GatherAllCellClassMatrix;
ECells = CellIDMatrix(:,1);
ICells = CellIDMatrix(:,2);
StateRates = SpikingAnalysis_GatherAllStateRates;
NumRateGroups = 5;
% rategroups = getcellsubsetpercentiles(size(CellIDMatrix,1),ECells,StateRates.EWakeRates);
rategroupsE = getcellsubsetpercentiles(size(CellIDMatrix,1),ECells,StateRates.EWakeRates,NumRateGroups);
rategroupsI = getcellsubsetpercentiles(size(CellIDMatrix,1),ICells,StateRates.IWakeRates,NumRateGroups);


%% Gather data
for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};
    load(fullfile(basepath,[basename '_ACGCCGsBySleepDiv' num2str(NumSleepDivisions) '.mat']))
    tt = find(ACGCCGsBySleepDiv.CCGHalfWidthsinMs==DesiredWidth);
    slnames = ACGCCGsBySleepDiv.slnames;
    
    for sl = 1:length(slnames);
        for b = 1:ACGCCGsBySleepDiv.NumSleepDiv;
            if a == 1
                eval(['ACGs_' slnames{sl} '{b} = ACGCCGsBySleepDiv.' slnames{sl} 'ACGs{b,tt}'';'])
                eval(['ISIHs_' slnames{sl} '{b} = ACGCCGsBySleepDiv.' slnames{sl} 'ISIHs{b,tt}'';'])
                times = ACGCCGsBySleepDiv.Times{1,tt};
                times = times(ceil(length(times)/2):end);
%                 eval(['BurstIndices4_' slnames{sl} '{b} = ACGCCGsBySleepDiv.' slnames{sl} 'BurstIndex4(b,:);'])
%                 eval(['BurstIndices10_' slnames{sl} '{b} = ACGCCGsBySleepDiv.' slnames{sl} 'BurstIndex10(b,:);'])
                eval(['BurstIndices15_' slnames{sl} '{b} = ACGCCGsBySleepDiv.' slnames{sl} 'BurstIndex15(b,:);'])
%                 eval(['BurstIndices20_' slnames{sl} '{b} = ACGCCGsBySleepDiv.' slnames{sl} 'BurstIndex20(b,:);'])
                eval(['BurstMaxPoint_' slnames{sl} '{b} = ACGCCGsBySleepDiv.' slnames{sl} 'BurstMaxPoint(b,:);'])
                eval(['BurstDec = ACGCCGsBySleepDiv.' slnames{sl} 'BurstDecay.ExponentCI(b,:);'])
                eval(['BurstDecay_' slnames{sl} '{b} = BurstDec;'])
            else 
                eval(['ACGs_' slnames{sl} '{b}=cat(1,ACGs_' slnames{sl} '{b},ACGCCGsBySleepDiv.' slnames{sl} 'ACGs{b,tt}'');'])
                eval(['ISIHs_' slnames{sl} '{b}=cat(1,ISIHs_' slnames{sl} '{b},ACGCCGsBySleepDiv.' slnames{sl} 'ISIHs{b,tt}'');'])
%                 eval(['BurstIndices4_' slnames{sl} '{b} = cat(2,BurstIndices4_' slnames{sl} '{b} ,ACGCCGsBySleepDiv.' slnames{sl} 'BurstIndex4(b,:));'])
%                 eval(['BurstIndices10_' slnames{sl} '{b} = cat(2,BurstIndices10_' slnames{sl} '{b} ,ACGCCGsBySleepDiv.' slnames{sl} 'BurstIndex10(b,:));'])
                eval(['BurstIndices15_' slnames{sl} '{b} = cat(2,BurstIndices15_' slnames{sl} '{b} ,ACGCCGsBySleepDiv.' slnames{sl} 'BurstIndex15(b,:));'])
%                 eval(['BurstIndices20_' slnames{sl} '{b} = cat(2,BurstIndices20_' slnames{sl} '{b} ,ACGCCGsBySleepDiv.' slnames{sl} 'BurstIndex20(b,:));'])
                eval(['BurstMaxPoint_' slnames{sl} '{b} = cat(2,BurstMaxPoint_' slnames{sl} '{b} ,ACGCCGsBySleepDiv.' slnames{sl} 'BurstMaxPoint(b,:));'])
                eval(['BurstDec = ACGCCGsBySleepDiv.' slnames{sl} 'BurstDecay.ExponentCI(b,:);'])
                eval(['BurstDecay_' slnames{sl} '{b} = cat(2,BurstDecay_' slnames{sl} '{b},BurstDec);'])
            end
        end
    end
end
for sl = 1:length(slnames);
    ACGNames{sl} = ['ACGs_' slnames{sl}];
    ISIHNames{sl} = ['ISIHs_' slnames{sl}];
end


%% Looking at some cells with high 3ms peaks
% ICellDiv3SleepISIHs = ISIHs_Sleep{3}(ICells,:);
% ICellDiv3SleepISIHs_meannorm = localnormalizebymean_nanforlowcount(ICellDiv3SleepISIHs);
% figure;imagesc(log10(ICellDiv3SleepISIHs_meannorm(:,1:100)))
% 
% badcells = [9,10,15,17,18];
% s = SpikingAnalysis_GatherAllStateRates;
% badcellsessions = s.SessNumPerICell(badcells);
% badcellsessionsIStableID = s.SessCellNumPerICell(badcells);
% for a = 1:length(badcells)
%     basepath = dirs{badcellsessions(a)};
%     basename = names{badcellsessions(a)};
% 
%     load(fullfile(basepath,[basename,'_CellIDs.mat']));
%     badcellsessionsOverallStableID(a,1) = CellIDs.IAll(badcellsessionsIStableID(a));
%     
%     ss = load(fullfile(basepath,[basename,'_SStable.mat']));
%     badcellshanks(a,1) = ss.shank(badcellsessionsOverallStableID(a));
%     badcellshanksCellNum(a,1) = ss.cellIx(badcellsessionsOverallStableID(a));
% end
% 
% disp(['sessnum shanknum shankcellnum'])
% disp([badcellsessions badcellshanks badcellshanksCellNum])

%%
c = PurpleColors(ACGCCGsBySleepDiv.NumSleepDiv);
% c = RainbowColors(length(slnames));
% 6 figures: Sleep,SWS,REM x E,I
h(1) = figure('name',['ECellACGsBySleepDiv' num2str(ACGCCGsBySleepDiv.NumSleepDiv) '_AllSleep']);%E figure
sp111 = subplot(2,2,1,'NextPlot','Add','XScale','Log');
sp112 = subplot(2,2,2,'NextPlot','Add','XScale','Log');
sp113 = subplot(2,2,3,'NextPlot','Add','XScale','Log');
sp114 = subplot(2,2,4,'NextPlot','Add','XScale','Log');
h(2) = figure('name',['ECellACGsBySleepDiv' num2str(ACGCCGsBySleepDiv.NumSleepDiv) '_SWS']);%E figure
sp121 = subplot(2,2,1,'NextPlot','Add','XScale','Log');
sp122 = subplot(2,2,2,'NextPlot','Add','XScale','Log');
sp123 = subplot(2,2,3,'NextPlot','Add','XScale','Log');
sp124 = subplot(2,2,4,'NextPlot','Add','XScale','Log');
h(3) = figure('name',['ECellACGsBySleepDiv' num2str(ACGCCGsBySleepDiv.NumSleepDiv) '_REM']);%E figure
sp131 = subplot(2,2,1,'NextPlot','Add','XScale','Log');
sp132 = subplot(2,2,2,'NextPlot','Add','XScale','Log');
sp133 = subplot(2,2,3,'NextPlot','Add','XScale','Log');
sp134 = subplot(2,2,4,'NextPlot','Add','XScale','Log');

h(4) = figure('name',['ICellACGsBySleepDiv' num2str(ACGCCGsBySleepDiv.NumSleepDiv) '_AllSleep']);%E figure
sp241 = subplot(2,2,1,'NextPlot','Add','XScale','Log');
sp242 = subplot(2,2,2,'NextPlot','Add','XScale','Log');
sp243 = subplot(2,2,3,'NextPlot','Add','XScale','Log');
sp244 = subplot(2,2,4,'NextPlot','Add','XScale','Log');
h(5) = figure('name',['ICellACGsBySleepDiv' num2str(ACGCCGsBySleepDiv.NumSleepDiv) '_SWS']);%E figure
sp251 = subplot(2,2,1,'NextPlot','Add','XScale','Log');
sp252 = subplot(2,2,2,'NextPlot','Add','XScale','Log');
sp253 = subplot(2,2,3,'NextPlot','Add','XScale','Log');
sp254 = subplot(2,2,4,'NextPlot','Add','XScale','Log');
h(6) = figure('name',['ICellACGsBySleepDiv' num2str(ACGCCGsBySleepDiv.NumSleepDiv) '_REM']);%E figure
sp261 = subplot(2,2,1,'NextPlot','Add','XScale','Log');
sp262 = subplot(2,2,2,'NextPlot','Add','XScale','Log');
sp263 = subplot(2,2,3,'NextPlot','Add','XScale','Log');
sp264 = subplot(2,2,4,'NextPlot','Add','XScale','Log');

for a = 1:ACGCCGsBySleepDiv.NumSleepDiv
    lengendstring{a} = num2str(a);
end

% Loop through state and sleep div
for a = 1:length(ACGNames);%every state, grab that variable, plot the average ACG, average ISIH
    for b = 1:ACGCCGsBySleepDiv.NumSleepDiv;
        tn = ACGNames{a};
        eval(['tacgs = ' ACGNames{a} '{b}'';'])
        eval(['tisihs = ' ISIHNames{a} '{b}'';'])
        tacgs = tacgs(end-(length(times)-1):end,:);

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
        eval(['semilogx(times,mntacgsE,''color'',c(b,:),''linewidth'',2,''parent'',sp1' num2str(a) '1);'])
            eval(['title(sp1' num2str(a) '1,''Mean of Mean-Normalized ACGs, E Cells'')'])
        eval(['semilogx(times,mntisihsE,''color'',c(b,:),''linewidth'',2,''parent'',sp1' num2str(a) '2);'])
            eval(['title(sp1' num2str(a) '2,''Mean of Mean-Normalized ISIHs, E Cells'')'])
        eval(['semilogx(times,mmntacgsE,''color'',c(b,:),''linewidth'',2,''parent'',sp1' num2str(a) '3);'])
            eval(['title(sp1' num2str(a) '3,''Mean of Max-Normalized ACGs, E Cells'')'])
        eval(['semilogx(times,mmntisihsE,''color'',c(b,:),''linewidth'',2,''parent'',sp1' num2str(a) '4);'])
            eval(['title(sp1' num2str(a) '4,''Mean of Max-Normalized ISIHs, E Cells'')'])
        % I Cell plots
        eval(['semilogx(times,mntacgsI,''color'',c(b,:),''linewidth'',2,''parent'',sp2' num2str(a+3) '1);'])
            eval(['title(sp2' num2str(a+3) '1,''Mean of Mean-Normalized ACGs, I Cells'')'])
        eval(['semilogx(times,mntisihsI,''color'',c(b,:),''linewidth'',2,''parent'',sp2' num2str(a+3) '2);'])
            eval(['title(sp2' num2str(a+3) '2,''Mean of Mean-Normalized ISIHs, I Cells'')'])
        eval(['semilogx(times,mmntacgsI,''color'',c(b,:),''linewidth'',2,''parent'',sp2' num2str(a+3) '3);'])
            eval(['title(sp2' num2str(a+3) '3,''Mean of Max-Normalized ACGs, I Cells'')'])
        eval(['semilogx(times,mmntisihsI,''color'',c(b,:),''linewidth'',2,''parent'',sp2' num2str(a+3) '4);'])
            eval(['title(sp2' num2str(a+3) '4,''Mean of Max-Normalized ISIHs, I Cells'')'])
    end
end
% 
legend(sp114,lengendstring,'location','northEast')
legend(sp124,lengendstring,'location','northEast')
legend(sp134,lengendstring,'location','northEast')
legend(sp244,lengendstring,'location','northEast')
legend(sp254,lengendstring,'location','northEast')
legend(sp264,lengendstring,'location','northEast')
figureaxestight(h(1))
figureaxestight(h(2))
figureaxestight(h(3))
figureaxestight(h(4))
figureaxestight(h(5))
figureaxestight(h(6))
AboveTitle('E Cell AllSleep',h(1))
AboveTitle('E Cell SWS',h(2))
AboveTitle('E Cell REM',h(3))
AboveTitle('I Cell AllSleep',h(4))
AboveTitle('I Cell SWS',h(5))
AboveTitle('I Cell REM',h(6))

%% Get burst index data, plot it
% th = plotBIData(BurstIndices4_Sleep,BurstIndices4_SWS,BurstIndices4_REM,NumRateGroups,NumSleepDivisions,ECells,ICells,rategroupsE,rategroupsI,slnames);
% h = cat(2,h,th);
% th = plotBIData(BurstIndices10_Sleep,BurstIndices10_SWS,BurstIndices10_REM,NumRateGroups,NumSleepDivisions,ECells,ICells,rategroupsE,rategroupsI,slnames);
% h = cat(2,h,th);
th = plotBIData(BurstIndices15_Sleep,BurstIndices15_SWS,BurstIndices15_REM,NumRateGroups,NumSleepDivisions,ECells,ICells,rategroupsE,rategroupsI,slnames);
h = cat(2,h,th);
% th = plotBIData(BurstIndices20_Sleep,BurstIndices20_SWS,BurstIndices20_REM,NumRateGroups,NumSleepDivisions,ECells,ICells,rategroupsE,rategroupsI,slnames);
% h = cat(2,h,th);
th = plotBIData(BurstMaxPoint_Sleep,BurstMaxPoint_SWS,BurstMaxPoint_REM,NumRateGroups,NumSleepDivisions,ECells,ICells,rategroupsE,rategroupsI,slnames);
h = cat(2,h,th);
th = plotBIData(BurstDecay_Sleep,BurstDecay_SWS,BurstDecay_REM,NumRateGroups,NumSleepDivisions,ECells,ICells,rategroupsE,rategroupsI,slnames);
h = cat(2,h,th);

%%
MakeDirSaveFigsThereAs(['/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/Correlograms/SleepChunks' num2str(NumSleepDivisions)],h,'fig')
MakeDirSaveFigsThereAs(['/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/Correlograms/SleepChunks' num2str(NumSleepDivisions)],h,'png')


function figureaxestight(h)
ax = findobj('type','axes','parent',h);
for a = 1:length(ax)
    axis(ax(a),'tight')
end

function normalized=localnormalizebymean_nanforlowcount(array)
%normalizes pixel values in a 3D moviematrix of multiple movies... 
%each movie is normalized within itself

minNum = 5;
bad = sum(array,2)<=minNum;

me=mean(array,2);
me = repmat(me,1,size(array,2));
normalized=array./me;

normalized(bad,:) = nan;


function rategroups = getcellsubsetpercentiles(totallen,class,rates,numrategroups)
% numrategroups = 5;
orig = zeros(totallen,1);
[~,idx] = sort(rates);
ranks = GetQuartilesByRank(rates,numrategroups);
orig(class) = ranks;

for a = 1:numrategroups
    rategroups(:,a) = orig==a;
end


function h = plotBIData(BurstIndicesSleep,BurstIndicesSWS,BurstIndicesREM,NumRateGroups,NumSleepDivisions,ECells,ICells,rategroupsE,rategroupsI,slnames)

h = [];
bin{1} = inputname(1);
bin{2} = inputname(2);
bin{3} = inputname(3);

color = BlueGreenColors(NumRateGroups);
for sl = 1:length(slnames)
    % plot basic medians
    bie = [];
    bii = [];
    for a = 1:NumSleepDivisions
        eval(['bie = cat(1,bie,BurstIndices' slnames{sl} '{a}(ECells));'])
        eval(['bii = cat(1,bii,BurstIndices' slnames{sl} '{a}(ICells));'])
    end
    h(end+1) = figure('name',[bin{sl} 'OverSleepChunks']);
    ax = subplot(1,2,1);
%     bplot(bei','std');%for mean+SD... messier
    bplot(bie');
%     plot_nanmedianSD_bars(bie');
    title (['Median ' bin{sl} ' - ECells'])
    ax = subplot(1,2,2);
%     bplot(bii','std');%for mean+SD... messier
    bplot(bii');
%     plot_nanmedianSD_bars(bii');
    title (['Median ' bin{sl} ' - ICells'])
end

h(end+1) = figure('name',[bin{sl} 'change by Rate Percentile']);
for sl = 1:length(slnames)
    for a = 1:NumRateGroups
        berg{a}=[];
        birg{a}=[];
    end
    %ECell plot of BI per Rate group over sleep
    ph = [];
    ax = subplot(3,2,(sl-1)*2+1,'NextPlot','Add');
    for a = 1:NumRateGroups
        for b = 1:NumSleepDivisions
            eval(['tbi = BurstIndices' slnames{sl} '{b};'])
            berg{a}(b,:) = tbi(rategroupsE(:,a));
        end
        hold on
        ph(a) = plot(ax,nanmean(berg{a},2),'color',color(a,:),'LineWidth',2);
    end
    title([bin{sl} ' - ECells'])
    %ICell plot of BI per Rate group over sleep
    ph = [];
    ax = subplot(3,2,(sl-1)*2+2,'NextPlot','Add');
    for a = 1:NumRateGroups
        for b = 1:NumSleepDivisions
            eval(['tbi = BurstIndices' slnames{sl} '{b};'])
            birg{a}(b,:) = tbi(rategroupsI(:,a));
        end
        hold on
        ph(a) = plot(ax,nanmean(birg{a},2),'color',color(a,:),'LineWidth',2);
    end
    title([bin{sl} ' - ICells'])
    if sl == length(slnames)
        legend(fliplr(ph),'plot1','plot2','plot3','plot4','plot5',{'Highest Rate','4','3','2','LowestRate'})
    end
end

