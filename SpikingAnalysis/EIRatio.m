function EIRatioData = EIRatio(binwidthsecs,smoothingnumpoints,basepath,basename)
% EI is pure ratio of E num spikes/ I num spikes per bin
% ZEI is zscored version of that
% PCEI is ratePerECell/ratePerICell (normalized by number of cells)
% ZPCEI is zscored version of that - gives best comparability across
% sessions
% er and ir are E and I rates within each bin for total population
% numEcells, numIcells: self-explanatory

%% Constants
if ~exist('binwidthsecs','var')
    binwidthsecs = 5;
end
if ~exist('smoothingnumpoints','var')
    smoothingnumpoints = 1;
end
sampfreq = 1;
plotting = 0;
savingfigs = 1;

%% Variables and Loading
if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end
load(fullfile(basepath,[basename '_SSubtypes.mat']))

if ~exist('Se','var') & exist('Se_TsdArrayFormat');
    Se = Se_TsdArrayFormat;
end
if ~exist('Si','var') & exist('Si_TsdArrayFormat');
    Si = Si_TsdArrayFormat;
end

numEcells = length(Se);
numIcells = length(Si);
% if numIcells<3
%     return
% end
% load(fullfile(basepath,[basename '_GoodSleepInterval.mat']))
% gsr = StartEnd(GoodSleepInterval,'s');

clear Se_TsdArrayFormat SeDef_TsdArrayFormat SeLike_TsdArrayFormat Si_TsdArrayFormat SiDef_TsdArrayFormat SiLike_TsdArrayFormat
clear Se_CellFormat SeDef_CellFormat SeLike_CellFormat Si_CellFormat SiDef_CellFormat SiLike_CellFormat


%% Generate bins
if numIcells>0
    maxbin = min([max(TimePoints(oneSeries(Se),'s')) max(TimePoints(oneSeries(Si),'s'))]);%because of Inf as max of some Good Sleeps
else
    maxbin = max(TimePoints(oneSeries(Se),'s'));%because of Inf as max of some Good Sleeps
end
binstartends = 0:binwidthsecs:maxbin;
binstartends(end+1) = binstartends(end)+binwidthsecs;
if binstartends(end) == binstartends(end-1)
    binstartends(end) = [];
end
bincentertimes = mean([binstartends(1:end-1)' binstartends(2:end)'],2);
binstartends = binstartends * sampfreq;
binInts = intervalSet(binstartends(1:end-1),binstartends(2:end));

%% Bin and Divide to get EIRatio (non-normalized)
er = MakeQfromTsd(oneSeries(Se),binInts);
er = sum(Data(er),2);
er = er./binwidthsecs;
% er = er./numEcells;
if numIcells > 0
    ir = MakeQfromTsd(oneSeries(Si),binInts);
    ir = sum(Data(ir),2);
    ir = ir./binwidthsecs;
%     ir = ir./numIcells;
else
    ir = nan(size(er,1),1);
end

EI = er./(er+ir); %te/(te+ti)
PCEI = (er/numEcells) ./ ((er/numEcells) + (ir/numIcells));
ZEI = nanzscore(EI);
ZPCEI = nanzscore(PCEI);

%% Smooth
EI = smooth(EI,smoothingnumpoints);
ZEI = smooth(ZEI,smoothingnumpoints);
PCEI = smooth(PCEI,smoothingnumpoints);
ZPCEI = smooth(ZPCEI,smoothingnumpoints);
er = smooth(er,smoothingnumpoints);
ir = smooth(ir,smoothingnumpoints);

%% Plot
if plotting
    load(fullfile(basepath,[basename '_Intervals.mat']))
    load(fullfile(basepath,[basename '_Motion.mat']))
    m = tsd(10000*[1:length(motiondata.motion)]',motiondata.motion');
    m = tsdArray(m);
    m = MakeSummedValQfromS(m,binInts);
    m = Data(m);
    m(isnan(m))=0;
    m = smooth(m,smoothingnumpoints);

    figname = [basename '_EIRatioBin' num2str(binwidthsecs) 'Smooth' num2str(smoothingnumpoints) 'Norm' normstring];
    h = figure('position',[100 100 600 600],'name',figname);
    subplot(4,1,1)
        plot(bincentertimes,EI,'k')
        hold on
        axis tight
        plotIntervalsStrip(gca,intervals,1)
        yl = ylim;
        plot([yl(2)*.75 yl(2)*.75],'-.','color',[.5 .5 .5])
        axis tight
        ylabel('EIRatio')
        title(['E/I Ratio. Binning:' num2str(binwidthsecs) 'sec. Smooth By: ' num2str(smoothingnumpoints)  'points. Norm By:' normstring '. File:' basename '.'],'fontsize',8,'fontweight','normal')
    subplot(4,1,2)
        plot(bincentertimes,er,'b')
        hold on
        axis tight
        yl = ylim;
        plot([yl(2)*.75 yl(2)*.75],'-.','color',[.5 .5 .5])
        ylabel('E Rate(Hz)')
    subplot(4,1,3)
        plot(bincentertimes,ir,'r')
        hold on
        axis tight
        yl = ylim;
        plot([yl(2)*.75 yl(2)*.75],'-.','color',[.5 .5 .5])
        ylabel('I Rate(Hz)')
    subplot(4,1,4)
        plot(bincentertimes,m,'color',[.4 .4 .4])
        hold on
        axis tight
        yl = ylim;
        plot([yl(2)*.75 yl(2)*.75],'-.','color',[.5 .5 .5])
        ylabel('Motion')
%% save figure
    if savingfigs
        savedir = ['/mnt/brendon4/Dropbox/BW OUTPUT/SleepProject/EIRatio/Bin' num2str(binwidthsecs) 'Smooth' num2str(smoothingnumpoints)];
        MakeDirSaveFigsThereAs(savedir,h,'png')
    end
end

EIRatioData = v2struct(EI,ZEI,PCEI,ZPCEI,er,ir,binwidthsecs,bincentertimes,smoothingnumpoints,numEcells,numIcells);
save(fullfile(basepath,[basename '_EIRatio_Bin' num2str(binwidthsecs) 'Smooth' num2str(smoothingnumpoints) '.mat']),'EIRatioData')