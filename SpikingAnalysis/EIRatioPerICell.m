function EIRatioPerICell(binsecs,smoothingnumpoints,basepath,basename)

%% Constants
if ~exist('binsecs','var')
    binsecs = 5;
end
if ~exist('smoothingnumpoints','var')
    smoothingnumpoints = 1;
end

sampfreq = 10000;
plotting = 1;
savingfigs = 1;


%% Variables and Loading
if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end
load(fullfile(basepath,[basename '_SSubtypes.mat']))
numEcells = length(Se);
numIcells = length(Si);
IRs = Rate(Si);
if numIcells<3
    return
end
load(fullfile(basepath,[basename '_GoodSleepInterval.mat']))
gsi = StartEnd(GoodSleepInterval,'s');
load(fullfile(basepath,[basename '_Intervals.mat']))
load(fullfile(basepath,[basename '_Motion.mat']))
m = tsd(10000*[1:length(motiondata.motion)]',motiondata.motion');
m = tsdArray(m);
load(fullfile(basepath,[basename '_CellIDs.mat']))


%% Generate bins
binmax = min([End(GoodSleepInterval) max(TimePoints(oneSeries(Se),'s')) max(TimePoints(oneSeries(Si),'s'))]);

binstartends = Start(GoodSleepInterval):binsecs:binmax;
binstartends(end+1) = binstartends(end)+binsecs;
if binstartends(end) == binstartends(end-1)
    binstartends(end) = [];
end
binstartends = binstartends * sampfreq;

binIs = intervalSet(binstartends(1:end-1),binstartends(2:end));

%% Bin and Divide to get EIRatio (non-normalized)
er = MakeQfromTsd(oneSeries(Se),binIs);
bincentertimes = TimePoints(er,'s');
ir = MakeQfromTsd(oneSeries(Si),binIs);
erRaw = sum(Data(er),2)/numEcells;%save this for later single I cell computations
er = sum(Data(er),2);
ir = sum(Data(ir),2);
EI = er./(er+ir); %te/(te+ti)

er = er/binsecs/numEcells;
ir = ir/binsecs/numIcells;

m = MakeSummedValQfromS(m,binIs);
m = Data(m);

%% Take care of max/min cases?... ie if bins are short enough to catch some 0's esp during DOWN States
% EI(er==0) = nan;
% EI(ir==0) = nan;

%% Normalize
% zscore-based
% EIRatio = nanzscore(EIRatio);
% % te = nanzscore(te);
% % ti = nanzscore(ti);
% normstring = 'ZScore';

% median zscore-based
% EI = nanmedianzscore(EI);
% m = nanmedianzscore(m);
% normstring = 'MedianZScore';

% none
normstring = 'NA';

%% Smooth
EI = smooth(EI,smoothingnumpoints);
er = smooth(er,smoothingnumpoints);
ir = smooth(ir,smoothingnumpoints);
m(isnan(m))=0;
m = smooth(m,smoothingnumpoints);

%% Per-I cell computation, against average I cell
for a = 1:numIcells
    irt = MakeQfromTsd(Si{a},binIs);
    irt = Data(irt);
    EIt = erRaw./(erRaw+irt); %te/(te+ti) but divided by num e cells
    irt = irt/binsecs;
    EIpI(:,a) = smooth(EIt,smoothingnumpoints);
    irpI(:,a) = smooth(irt,smoothingnumpoints);
end

%% Plot
if plotting
    if isinf(gsi(2))
        gsi(2) = bincentertimes(end);
    end

    plotidxs = bincentertimes>=gsi(1) & bincentertimes<=gsi(2);
    pbc = bincentertimes(plotidxs);
    per = er(plotidxs);
    pm = m(plotidxs);
    pEI = EI(plotidxs);
    pir = ir(plotidxs);
    pEIpI = EIpI(plotidxs,:);
    pirpI = irpI(plotidxs,:);
    
    figname = [basename '_EIRatioBin' num2str(binsecs) 'Smooth' num2str(smoothingnumpoints) 'Norm' normstring];
    h = figure('position',[32 1 1409 823],'name',figname);
    
    numplots = 2+numIcells;
    subplot(numplots,1,1)% top plot: E Cell pop rate, Motion, State scoring
        plot(pbc,per/max(per),'b')
        hold on
        axis tight
        plot(pbc,pm/max(pm),'color',[.4 .4 .4])
        xl = xlim;
        plotIntervalsStrip(gca,intervals,1)
        xlim(xl);
%         yl = ylim;
%         plot(gsi,[yl(2)*.75 yl(2)*.75],'-.','color',[.5 .5 .5])
%         ylabel('EIRatio')
%         title(['E/I Ratio. Binning:' num2str(binsecs) 'sec. Smooth By: ' num2str(smoothingnumpoints)  'points. Norm By:' normstring '. File:' basename '.'],'fontsize',8,'fontweight','normal')
    subplot(numplots,1,2)% top plot: E Cell pop rate, Motion, State scoring
        plot(pbc,pir/max(pir),'r')
        hold on
        axis tight
        plot(pbc,pEI,'color','k')
        xl = xlim;
        plotIntervalsStrip(gca,intervals,1)
        xlim(xl);
%         yl = ylim;
%         plot(gsi,[yl(2)*.75 yl(2)*.75],'-.','color',[.5 .5 .5])
%         ylabel('EIRatio')
%         title(['E/I Ratio. Binning:' num2str(binsecs) 'sec. Smooth By: ' num2str(smoothingnumpoints)  'points. Norm By:' normstring '. File:' basename '.'],'fontsize',8,'fontweight','normal')
    for a = 1:numIcells
        subplot(numplots,1,a+2)
            plot(pbc,pEIpI(:,a),'k')
            hold on
            plot(pbc,pirpI(:,a)/max(pirpI(:,a)),'color',[1 .6 .6])
            axis tight
            xl = xlim;
            plotIntervalsStrip(gca,intervals,1)
            xlim(xl);
            yl = ylim;
%             plot(gsi,[yl(2)*.75 yl(2)*.75],'-.','color',[.5 .5 .5])
            ylabel({'Pink:Rate(Hz)';'Bk:EIVAvgECell'},'fontsize',8)
            textstr = [' I#' num2str(a) 'All#(' num2str(CellIDs.IAll(a)) ') RateHz:' num2str(IRs(a))];
            text((xl(1)+0.05*diff(xl)),(yl(1)+.25*diff(yl)),textstr,'color','b','fontweight','bold')
    end
        
    %% save figure
    if savingfigs
        savedir = ['/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/EIRatioPerICell/Bin' num2str(binsecs) 'Smooth' num2str(smoothingnumpoints) 'Norm' normstring];
        MakeDirSaveFigsThereAs(savedir,h,'png')
    end
end

% EIRatios = v2struct(EI,er,ir,m, binsecs,bincentertimes,smoothingnumpoints,numEcells,numIcells);
% save(fullfile(basepath,[basename '_EIRatio.mat']),'EIRatios')