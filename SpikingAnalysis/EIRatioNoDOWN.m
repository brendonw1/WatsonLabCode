function EIRatio(binsecs,smoothingnumpoints,basepath,basename)

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
if numIcells<3
    return
end
load(fullfile(basepath,[basename '_GoodSleepInterval.mat']))
gsr = StartEnd(GoodSleepInterval,'s');
load(fullfile(basepath,[basename '_Intervals.mat']))
load(fullfile(basepath,[basename '_Motion.mat']))
m = tsd(10000*[1:length(motiondata.motion)]',motiondata.motion');
m = tsdArray(m);
load(fullfile(basepath,[basename '_UPDOWNIntervals.mat']))

%% Generate bins
binmax = min([End(GoodSleepInterval,'s') max(TimePoints(oneSeries(Se),'s')) max(TimePoints(oneSeries(Si),'s'))]);

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
er = Data(er)/binsecs/numEcells;
ir = MakeQfromTsd(oneSeries(Si),binIs);
ir = Data(ir)/binsecs/numIcells;

% EIRatio = ConditionedProportion(ir,er); %te/ti
EIRatio = er./(er+ir); %te/(te+ti)
e = EIRatio;

m = MakeSummedValQfromS(m,binIs);
m = Data(m);

%% Take care of max/min cases?... ie if bins are short enough to catch some 0's esp during DOWN States
% EIRatio(er==0) = nan;
% EIRatio(ir==0) = nan;

%% Take out DOWN states
% subEI = tsd(bincentertimes,ones(size(bincentertimes)));
% d = intervalSet((Start(DNInts,'s')-binsecs/2)*10000, (End(DNInts,'s')+binsecs/2)*10000);% DN states extended to not include bad bins
d = intervalSet((Start(DNInts,'s')-binsecs)*10000, (End(DNInts,'s')+binsecs)*10000);% DN states extended to not include bad bins
totalSess = intervalSet(0,binstartends(end));
allbutdown = minus(totalSess,d);

EIRatio = tsd(bincentertimes*10000,EIRatio);
EIRatio = Restrict(EIRatio,allbutdown);

% u = intervalSet(Start(UPInts,'s')+binsecs/2, End(UPInts,'s')-binsecs/2);% UP states trunkated to not include bad bins

%% Normalize
% zscore-based
% EIRatio = nanzscore(EIRatio);
% % te = nanzscore(te);
% % ti = nanzscore(ti);
% normstring = 'ZScore';

% median zscore-based
EIRatio = nanmedianzscore(EIRatio);
% te = nanzscore(te);
% ti = nanzscore(ti);
m = nanmedianzscore(m);
normstring = 'MedianZScore';

%% Smooth
EIRatio = smooth(EIRatio,smoothingnumpoints);
er = smooth(er,smoothingnumpoints);
ir = smooth(ir,smoothingnumpoints);
m(isnan(m))=0;
m = smooth(m,smoothingnumpoints);

%% Plot
% bintimes = mean([bintimes(1:end-1);bintimes(2:end)])/sampfreq;
if isinf(gsr(2))
    gsr(2) = binstartends(end);
end

if plotting
    figname = [basename '_EIRatioBin' num2str(binsecs) 'Smooth' num2str(smoothingnumpoints) 'Norm' normstring];
    h = figure('position',[100 100 600 600],'name',figname);
    subplot(4,1,1)
        plot(bincentertimes,EIRatio,'k')
        hold on
        axis tight
        plotIntervalsStrip(gca,intervals,1)
        yl = ylim;
        plot(gsr,[yl(2)*.75 yl(2)*.75],'-.','color',[.5 .5 .5])
        axis tight
        ylabel('EIRatio')
        title(['E/I Ratio. Binning:' num2str(binsecs) 'sec. Smooth By: ' num2str(smoothingnumpoints)  'points. Norm By:' normstring '. File:' basename '.'],'fontsize',8,'fontweight','normal')
    subplot(4,1,2)
        plot(bincentertimes,er,'b')
        hold on
        axis tight
        yl = ylim;
        plot(gsr,[yl(2)*.75 yl(2)*.75],'-.','color',[.5 .5 .5])
        ylabel('E Rate(Hz)')
    subplot(4,1,3)
        plot(bincentertimes,ir,'r')
        hold on
        axis tight
        yl = ylim;
        plot(gsr,[yl(2)*.75 yl(2)*.75],'-.','color',[.5 .5 .5])
        ylabel('I Rate(Hz)')
    subplot(4,1,4)
        plot(bincentertimes,m,'color',[.4 .4 .4])
        hold on
        axis tight
        yl = ylim;
        plot(gsr,[yl(2)*.75 yl(2)*.75],'-.','color',[.5 .5 .5])
        ylabel('Motion')
%% save figure
    if savingfigs
        savedir = ['/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/EIRatioNoDOWNs/Bin' num2str(binsecs) 'Smooth' num2str(smoothingnumpoints) 'Norm' normstring];
        MakeDirSaveFigsThereAs(savedir,h,'png')
    end
end

EIRatios = v2struct(EIRatio,er,bincentertimes,ir,m, binsecs,smoothingnumpoints,numEcells,numIcells);
save(fullfile(basepath,[basename '_EIRatioND.mat']),'EIRatios')