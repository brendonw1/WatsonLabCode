function EIRatioData = EIRatio(basepath,binwidthsecs,smoothingnumpoints,filtered)
% EI is pure ratio of E num spikes/ I num spikes per bin
% ZEI is zscored version of that
% PCEI is ratePerECell/ratePerICell (normalized by number of cells)
% ZPCEI is zscored version of that - gives best comparability across
% sessions
% er and ir are E and I rates within each bin for total population
% numEcells, numIcells: self-explanatory

%Modified: 02/07/2022 by David 
%Added the 'filtered' argument. This toggles the extra functionality of
%selecting specific units. If you wish not to use this, make filtered 0,
%and this function will behave completely normally

%% Constants
if ~exist('binwidthsecs','var')
    binwidthsecs = 5;
end
if ~exist('smoothingnumpoints','var')
    smoothingnumpoints = 1;
end
if ~exist('filtered','var')
    filtered = 0;
end

sampfreq = 1;
plotting = 1;
savingfigs = 1;

%% Variables and Loading
if ~exist('basepath','var')
    basepath = cd;
end
basename = bz_BasenameFromBasepath(basepath);

spikes = bz_GetSpikes('basepath',basepath);
CellClass = bz_LoadCellinfo(basepath,'CellClass');
states = bz_LoadStates(basepath,'SleepState');
ints = states.ints;

numEcells = sum(CellClass.pE);
numIcells = sum(CellClass.pI);

% load(fullfile(basepath,[basename '_SSubtypes.mat']))
% 
% if ~exist('Se','var') & exist('Se_TsdArrayFormat');
%     Se = Se_TsdArrayFormat;
% end
% if ~exist('Si','var') & exist('Si_TsdArrayFormat');
%     Si = Si_TsdArrayFormat;
% end
% 
% numEcells = length(Se);
% numIcells = length(Si);
% if numIcells<3
%     return
% end
% load(fullfile(basepath,[basename '_GoodSleepInterval.mat']))
% gsr = StartEnd(GoodSleepInterval,'s');


%% Generate bins
% if numIcells>0
%     maxbin = min([max(TimePoints(oneSeries(Se),'s')) max(TimePoints(oneSeries(Si),'s'))]);%because of Inf as max of some Good Sleeps
% else
%     maxbin = max(TimePoints(oneSeries(Se),'s'));%because of Inf as max of some Good Sleeps
% end
% binstartends = 0:binwidthsecs:maxbin;
% binstartends(end+1) = binstartends(end)+binwidthsecs;
% if binstartends(end) == binstartends(end-1)
%     binstartends(end) = [];
% end

sieve = 1;
if filtered
    load('goodUnitsCurated.mat');
    load('goodUnitsDaviolin.mat');
    load([basename, '_InjectionComparisionIntervals.mat']);
    [lol,hah,goodUnitsBoth] = UnitsCompare(goodUnits,goodUnitsDaviolin);
    sieve = {goodUnits,goodUnitsDaviolin,goodUnitsBoth};
    sievenames = {'Max Choices', 'David Choices', 'Collab Choices'};
end            
    
    
for s = 1:length(sieve)
    if filtered
    subsieve = sieve{s};
    conservedSpikes = spikes;
    conservedCellClass = CellClass;
    for p = flip(1:length(spikes.UID))
        if ~ismember(p,subsieve)
           spikes.UID(p) = [];
           spikes.times(p) = [];
           %spikes.cluID(p) = [];
           spikes.rawWaveform(p) = [];
           spikes.maxWaveformCh(p) = [];
           CellClass.UID(p) = [];
           CellClass.pE(p) = [];
           CellClass.pI(p) = [];
           CellClass.label(p) = [];
        end
    end
    end
%end

[spikemat] = bz_SpktToSpkmat(spikes, 'binsize',binwidthsecs,'dt',binwidthsecs);
bincenters = spikemat.timestamps;
binstarts = bincenters-(binwidthsecs*0.5);
binends = bincenters+(binwidthsecs*0.5);

% binstartends = binstartends * sampfreq;
% binInts = intervalSet(binstartends(1:end-1),binstartends(2:end));

%% Bin and Divide to get EIRatio (non-normalized)
er = spikemat.data(:,CellClass.pE);
er = sum(er,2);

% er = MakeQfromTsd(oneSeries(Se),binInts);
% er = sum(Data(er),2);
er = er./binwidthsecs;



% er = er./numEcells;
if numIcells > 0
    ir = spikemat.data(:,CellClass.pI);
    ir = sum(ir,2);

    % er = MakeQfromTsd(oneSeries(Se),binInts);
    % er = sum(Data(er),2);
    ir = ir./binwidthsecs;
else
    ir = nan(size(ir,1),1);
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
%     load(fullfile(basepath,[basename '_Intervals.mat']))
%     load(fullfile(basepath,[basename '_Motion.mat']))
%     m = tsd(10000*[1:length(motiondata.motion)]',motiondata.motion');
%     m = tsdArray(m);
%     m = MakeSummedValQfromS(m,binInts);
%     m = Data(m);
%     m(isnan(m))=0;
%     m = smooth(m,smoothingnumpoints);
    if exist(fullfile(basepath,[basename '.EMGFromLFP.LFP.mat']))
        load(fullfile(basepath,[basename '.EMGFromLFP.LFP.mat']),'EMGFromLFP')
        m = EMGFromLFP.data;
    elseif exist(fullfile(basepath,[basename '_EMGCorr.mat']))
        load(fullfile(basepath,[basename '_EMGCorr.mat']))
        m = tsd(EMGCorr(:,1),EMGCorr(:,2));
    else
        load(fullfile(basepath,[basename '.eegstates.mat']))
        m = StateInfo.motion;
        m = tsd(1:length(m),m);
    end
%     m = tsdArray(m);
%     m = MakeSummedValQfromS(m,binInts);
%     m = Data(m);
%     m(isnan(m))=0;
%     m = smooth(m,smoothingnumpoints);
    if ~isempty(spikes.UID)
        m = ResampleTolerant(m,length(bincenters),length(m));
    
%     figname = [basename '_EIRatioBin' num2str(binwidthsecs) 'Smooth' num2str(smoothingnumpoints) 'Norm' normstring];
    figname = [basename '_EIRatioBin' num2str(binwidthsecs) 'Smooth' num2str(smoothingnumpoints)];
    h = figure('position',[100 100 600 600],'name',figname);
    subplot(4,1,1)
        plot(bincenters,EI,'k')
        hold on
        axis tight
        plotIntervalsStrip(gca,ints,1)
        yl = ylim;
        plot([yl(2)*.75 yl(2)*.75],'-.','color',[.5 .5 .5])
        axis tight
        ylabel('EIRatio')
        if filtered
            hold on;
            xline(InjectionComparisionIntervals.BaselineEndRecordingSeconds,'-',{'KetInj'});     
            xline(InjectionComparisionIntervals.BaselineP24StartRecordingSeconds, '-', {'BaseLStart'});
        end
        title(['E/I Ratio. Binning:' num2str(binwidthsecs) 'sec. Smooth By: ' num2str(smoothingnumpoints)  'points. File:' basename '.'],'fontsize',8,'fontweight','normal')
    subplot(4,1,2)
        plot(bincenters,er,'b')
        hold on
        axis tight
        yl = ylim;
        plot([yl(2)*.75 yl(2)*.75],'-.','color',[.5 .5 .5])
        ylabel('E Rate(Hz)')
        if filtered
            hold on;
            xline(InjectionComparisionIntervals.BaselineEndRecordingSeconds,'-',{'KetInj'});     
            xline(InjectionComparisionIntervals.BaselineP24StartRecordingSeconds, '-', {'BaseLStart'});
        end
    subplot(4,1,3)
        plot(bincenters,ir,'r')
        hold on
        axis tight
        yl = ylim;
        plot([yl(2)*.75 yl(2)*.75],'-.','color',[.5 .5 .5])
        ylabel('I Rate(Hz)')
        if filtered
            hold on;
            xline(InjectionComparisionIntervals.BaselineEndRecordingSeconds,'-',{'KetInj'});     
            xline(InjectionComparisionIntervals.BaselineP24StartRecordingSeconds, '-', {'BaseLStart'});
        end
    subplot(4,1,4)
        plot(bincenters,m,'color',[.4 .4 .4])
        hold on
        axis tight
        yl = ylim;
        plot([yl(2)*.75 yl(2)*.75],'-.','color',[.5 .5 .5])
        ylabel('Motion')
        if filtered
            hold on;
            xline(InjectionComparisionIntervals.BaselineEndRecordingSeconds,'-',{'KetInj'});     
            xline(InjectionComparisionIntervals.BaselineP24StartRecordingSeconds, '-', {'BaseLStart'});
            sgtitle(sievenames(s));
        end
%% save figure
    if savingfigs
        savedir = fullfile(basepath,'Figures');
        if filtered
            h.Name = [h.Name sievenames{s}];
        end
        MakeDirSaveFigsThereAs(savedir,h,'fig')
        MakeDirSaveFigsThereAs(savedir,h,'png')
    end
    end
end
spikes = conservedSpikes;
CellClass = conservedCellClass;
EIRatioData = v2struct(EI,ZEI,PCEI,ZPCEI,er,ir,binwidthsecs,bincenters,smoothingnumpoints,numEcells,numIcells);
save(fullfile(basepath,[basename '_EIRatio_Bin' num2str(binwidthsecs) 'Smooth' num2str(smoothingnumpoints) '.mat']),'EIRatioData')

end