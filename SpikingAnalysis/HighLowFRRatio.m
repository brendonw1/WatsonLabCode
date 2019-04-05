function HighLowFRRatioData = HighLowFRRatio(binwidthsecs,smoothingnumpoints,numgroups,basepath,basename)
% Calculates ratio of highest firing rate group to lowest firing rate
% group.  Groups are defined by 1/6ths by default.
% Fix XXXXXXXXXXXXX
% XXX is pure ratio of E num spikes/ I num spikes per bin
% ZEI is zscored version of that
% PCEI is ratePerECell/ratePerICell (normalized by number of cells)
% ZPCEI is zscored version of that - gives best comparability across
% sessions
% er and ir are E and I rates within each bin for total population
% numEcells, numIcells: self-explanatory
%
% Brendon Watson 2016

%% Constants
if ~exist('binwidthsecs','var')
    binwidthsecs = 5;
end
if ~exist('smoothingnumpoints','var')
    smoothingnumpoints = 1;
end
if ~exist('numgroups','var')
    numgroups = 6;
end
sampfreq = 1;%for ts objects
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
sr = load(fullfile(basepath,[basename '_StateRates.mat']));
% 
% if isfield(sr.StateRates,'EWSWakeRates')
%     rankbasis = sr.StateRates.EWSWakeRates;
% elseif isfield(sr.StateRates,'EWakeRates')
%     rankbasis = sr.StateRates.EWakeRates;
% end
% rankbasis = sr.StateRates.ESWSRates;
rankbasis = sr.StateRates.EREMRates;
% rankbasis = sr.StateRates.EWakeARates;
% rankbasis = sr.StateRates.EAllRates;
% rankbasis = sr.StateRates.EWSWakeRates;

    
bads = find(rankbasis<=0);
goods = find(rankbasis>0);
rankbasis(bads) = [];
Se = Se(goods);

rankidxs = GetQuartilesByRank(rankbasis,numgroups);
highidxs = find(rankidxs==numgroups);
lowidxs = find(rankidxs==1);
numHigh = sum(rankidxs==numgroups);
numLow = sum(rankidxs==1);


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
hr = MakeQfromTsd(oneSeries(Se(highidxs)),binInts);
hr = Data(hr);
hr = hr./binwidthsecs/numHigh;
zhr = nanzscore(hr);

lr = MakeQfromTsd(oneSeries(Se(lowidxs)),binInts);
lr = Data(lr);
lr = lr./binwidthsecs/numLow;
zlr = nanzscore(lr);

hrlr = hr./(hr+lr); %te/(te+ti)
% zhrzlr = zhr/zlr;

% PCEI = (hr/numEcells) ./ ((hr/numEcells) + (lr/numIcells));
zhrlr = nanzscore(hrlr);
% ZPCEI = nanzscore(PCEI);

%% Smooth
hrlr = smooth(hrlr,smoothingnumpoints);
zhrlr = smooth(zhrlr,smoothingnumpoints);
% PCEI = smooth(PCEI,smoothingnumpoints);
% ZPCEI = smooth(ZPCEI,smoothingnumpoints);
hr = smooth(hr,smoothingnumpoints);
lr = smooth(lr,smoothingnumpoints);

%% Plot
if plotting
    if exist(fullfile(basepath,[basename '-states.mat']),'file')    
        t = load(fullfile(basepath,[basename '-states.mat']));%from GatherStateIntervalSets.m
        ints = IDXtoINT(t.states);
        for a = 1:5;
            ints{a} = intervalSet(ints{a}(:,1),ints{a}(:,2));
        end
    elseif exist(fullfile(basepath,[basename '_SleepScore.mat']),'file')
        ints = load(fullfile(basepath,[basename '_SleepScore.mat']));
        ints = ints.StateIntervals;
    elseif exist(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']),'file')
        ints = load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']));
    else
        ints = [];
    end
%     load(fullfile(basepath,[basename '_Motion.mat']))
%     m = tsd(sampfreq*[1:length(motiondata.motion)]',motiondata.motion');
%     m = tsdArray(m);
%     m = MakeSummedValQfromS(m,binInts);
%     m = Data(m);
%     m(isnan(m))=0;
%     m = smooth(m,smoothingnumpoints);
    if exist(fullfile(basepath,[basename '_EMGCorr.mat']))
        load(fullfile(basepath,[basename '_EMGCorr.mat']))
        m = tsd(EMGCorr(:,1),EMGCorr(:,2));
    else
        load(fullfile(basepath,[basename '.eegstates.mat']))
        m = StateInfo.motion;
        m = tsd(1:length(m),m);
    end
    m = tsdArray(m);
    m = MakeSummedValQfromS(m,binInts);
    m = Data(m);
    m(isnan(m))=0;
    m = smooth(m,smoothingnumpoints);

    figname = [basename '_HighLowRatioBin' num2str(binwidthsecs) 'Smooth' num2str(smoothingnumpoints)];
    h = figure('position',[100 100 600 600],'name',figname);    
    subplot(5,1,1:2,'yscale','log')
        hold on;
        axis tight
        plot(bincentertimes,hr);
        plot(bincentertimes,lr);
        plotIntervalsStrip(gca,ints,1)
        ylabel('HighFR, LowFR per cell')
        title(['High/Low Ratio. Binning:' num2str(binwidthsecs) 'sec. Smooth By: ' num2str(smoothingnumpoints)  'points. File:' basename '.'],'fontsize',8,'fontweight','normal')
    subplot(5,1,3:4,'yscale','log');
        hold on;
        axis tight
        plot(bincentertimes,hrlr,'k')
        ylabel('HighFR/(HighFR+LowFR) Ratio')
        plotIntervalsStrip(gca,ints,1)
    subplot(5,1,5)
        plot(bincentertimes,m,'color',[.4 .4 .4])
        hold on
        axis tight
        yl = ylim;
        plot([yl(2)*.75 yl(2)*.75],'-.','color',[.5 .5 .5])
        ylabel('EMG')
%% save figure
    if savingfigs
%         savedir = fullfile(getdropbox,'BW OUTPUT','SleepProject','HighLowFRRatio',['Bin' num2str(binwidthsecs) 'Smooth' num2str(smoothingnumpoints)]);
        savedir = cd;
        MakeDirSaveFigsThereAs(savedir,h,'png')
    end
end

HighLowFRRatioData = v2struct(hrlr,zhrlr,hr,lr,binwidthsecs,bincentertimes,smoothingnumpoints,highidxs,lowidxs);
save(fullfile(basepath,[basename '_HighLowFRRatio.mat']),'HighLowFRRatioData')