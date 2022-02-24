function HighLowFRRatioData = HighLowFRRatio(basepath,rankbasisstate,binwidthsecs,smoothingnumpoints,numgroups,filtered)
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
% Buzcode version Brendon Watson 2019

%% Constants
if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end
basename = bz_BasenameFromBasepath(basepath);
if ~exist('rankbasisstate','var')
    rankbasisstate = 'all';
end
if ~exist('binwidthsecs','var')
    binwidthsecs = 5;
end
if ~exist('smoothingnumpoints','var')
    smoothingnumpoints = 1;
end
if ~exist('numgroups','var')
    numgroups = 6;
end
if ~exist('filtered','var')
    filtered = true;  %David, change this to false when not testing
end
sampfreq = 1;%for ts objects
plotting = 1;
savingfigs = 1;

%% Variables and Loading
spikes = bz_GetSpikes('basepath',basepath);
CellClass = bz_LoadCellinfo(basepath,'CellClass');
states = bz_LoadStates(basepath,'SleepState');
ints = states.ints;

numEcells = sum(CellClass.pE);
numIcells = sum(CellClass.pI);

sieve = 1;
if filtered
    load([basepath, '/goodUnitsCurated.mat']);
    load([basepath, '/goodUnitsDaviolin.mat']);
    load([basepath, '/', basename, '_InjectionComparisionIntervals.mat']);
    [lol,hah,goodUnitsBoth] = UnitsCompare(goodUnits,goodUnitsDaviolin);
    sieve = {goodUnits,goodUnitsDaviolin,goodUnitsBoth};
    sievenames = {'Max Choices', 'David Choices', 'Collab Choices'};
end       

for s = 1:length(sieve)
    if filtered
    subsieve = sieve{s};
    conservedSpikes = spikes;
    conservedCellClass = CellClass;
    rankbasis = 0;
    for p = flip(1:length(spikes.UID))
        if ~ismember(p,subsieve)
           spikes.UID(p) = [];
           spikes.times(p) = [];
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


switch rankbasisstate
    case 'all'
        duration = states.idx.timestamps(end)-states.idx.timestamps(1);
        for cidx = 1:length(spikes.times)
            rankbasis(cidx) = length(spikes.times{cidx})/duration;
        end
    otherwise
        %find matching state to that requested
        fn = fieldnames(states.ints);
        for fidx = 1:length(fn)
            if strcmp(lower(rankbasisstate),lower(fn{fidx}(1:length(rankbasisstate))))
                break
            end
        end
        try
            tstatename = fn{fidx};
        catch
            disp('RankBasisStateName does not match state names in this states struct')
        end
        tintervals = getfield(states.ints,tstatename);
        %get duration of that state
        duration = sum(diff(tintervals,[],2));
        %get spikes for that state
        for cidx = 1:length(spikes.times)
            tspikes = InIntervals(spikes.times{cidx},tintervals);
            tspikes = spikes.times{cidx}(tspikes);
            rankbasis(cidx) = length(tspikes)/duration;
        end
end

% sr = load(fullfile(basepath,[basename '_StateRates.mat']));
% rankbasis = sr.StateRates.EREMRates;

%% Get ranked cells
bads = find(rankbasis<=0);
goods = find(rankbasis>0);
rankbasis(bads) = [];

pE = CellClass.pE(goods);

rankidxs = GetQuartilesByRank(rankbasis,numgroups);
highidxs = find(rankidxs==numgroups);
lowidxs = find(rankidxs==1);
numHigh = sum(rankidxs==numgroups);
numLow = sum(rankidxs==1);


%% Get binned spikes
[spikemat] = bz_SpktToSpkmat(spikes, 'binsize',binwidthsecs,'dt',binwidthsecs);
bincenters = spikemat.timestamps;

hr = spikemat.data(:,highidxs);
hr = sum(hr,2);
zhr = nanzscore(hr);

lr = spikemat.data(:,lowidxs);
lr = sum(lr,2);
zlr = nanzscore(lr);

hrlr = hr./(hr+lr); %te/(te+ti)
zhrlr = nanzscore(hrlr);


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
% bincenters = mean([binstartends(1:end-1)' binstartends(2:end)'],2);
% binstartends = binstartends * sampfreq;
% binInts = intervalSet(binstartends(1:end-1),binstartends(2:end));
% 
% %% Bin and Divide to get spiking (non-normalized)
% hr = MakeQfromTsd(oneSeries(Se(highidxs)),binInts);
% hr = Data(hr);
% hr = hr./binwidthsecs/numHigh;
% zhr = nanzscore(hr);

% lr = MakeQfromTsd(oneSeries(Se(lowidxs)),binInts);
% lr = Data(lr);
% lr = lr./binwidthsecs/numLow;
% zlr = nanzscore(lr);
% 
% hrlr = hr./(hr+lr); %te/(te+ti)
% zhrzlr = zhr/zlr;

% PCEI = (hr/numEcells) ./ ((hr/numEcells) + (lr/numIcells));
% zhrlr = nanzscore(hrlr);
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
%     if exist(fullfile(basepath,[basename '-states.mat']),'file')    
%         t = load(fullfile(basepath,[basename '-states.mat']));%from GatherStateIntervalSets.m
%         ints = IDXtoINT(t.states);
%         for a = 1:5;
%             ints{a} = intervalSet(ints{a}(:,1),ints{a}(:,2));
%         end
%     elseif exist(fullfile(basepath,[basename '_SleepScore.mat']),'file')
%         ints = load(fullfile(basepath,[basename '_SleepScore.mat']));
%         ints = ints.StateIntervals;
%     elseif exist(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']),'file')
%         ints = load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']));
%     else
%         ints = [];
%     end


%     load(fullfile(basepath,[basename '_Motion.mat']))
%     m = tsd(sampfreq*[1:length(motiondata.motion)]',motiondata.motion');
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

    figname = [basename '_HighLowRatioBin' num2str(binwidthsecs) 'Smooth' num2str(smoothingnumpoints)];
    h = figure('position',[100 100 600 600],'name',figname);    
    subplot(5,1,1:2,'yscale','log')
        hold on;
        axis tight
        plot(bincenters,hr);
        plot(bincenters,lr);
        plotIntervalsStrip(gca,ints,1)
        ylabel('HighFR, LowFR per cell')
        title(['High/Low Ratio. Binning:' num2str(binwidthsecs) 'sec. Smooth By: ' num2str(smoothingnumpoints)  'points. File:' basename '.'],'fontsize',8,'fontweight','normal')
    subplot(5,1,3:4,'yscale','log');
        hold on;
        axis tight
        plot(bincenters,hrlr,'k')
        ylabel('HighFR/(HighFR+LowFR) Ratio')
        plotIntervalsStrip(gca,ints,1)
    subplot(5,1,5)
        plot(bincenters,m,'color',[.4 .4 .4])
        hold on
        axis tight
        yl = ylim;
        plot([yl(2)*.75 yl(2)*.75],'-.','color',[.5 .5 .5])
        ylabel('EMG')
%% save figure
    if savingfigs
%         savedir = fullfile(getdropbox,'BW OUTPUT','SleepProject','HighLowFRRatio',['Bin' num2str(binwidthsecs) 'Smooth' num2str(smoothingnumpoints)]);
        savedir = fullfile(basepath,'Figures');
        if filtered
            h.Name = [h.Name sievenames{s}];
        end
        MakeDirSaveFigsThereAs(savedir,h,'fig')
        MakeDirSaveFigsThereAs(savedir,h,'png')
    end
end
end

HighLowFRRatioData = v2struct(hrlr,zhrlr,hr,lr,binwidthsecs,bincenters,smoothingnumpoints,highidxs,lowidxs);
save(fullfile(basepath,[basename '_HighLowFRRatio.mat']),'HighLowFRRatioData')

if filtered
    spikes = conservedSpikes;
    CellClass = conservedCellClass;
end
end






%% Old tsdarray version
% %% Constants
% if ~exist('binwidthsecs','var')
%     binwidthsecs = 5;
% end
% if ~exist('smoothingnumpoints','var')
%     smoothingnumpoints = 1;
% end
% if ~exist('numgroups','var')
%     numgroups = 6;
% end
% sampfreq = 1;%for ts objects
% plotting = 1;
% savingfigs = 1;
% 
% %% Variables and Loading
% if ~exist('basepath','var')
%     [~,basename,~] = fileparts(cd);
%     basepath = cd;
% end
% load(fullfile(basepath,[basename '_SSubtypes.mat']))
% numEcells = length(Se);
% numIcells = length(Si);
% sr = load(fullfile(basepath,[basename '_StateRates.mat']));
% % 
% % if isfield(sr.StateRates,'EWSWakeRates')
% %     rankbasis = sr.StateRates.EWSWakeRates;
% % elseif isfield(sr.StateRates,'EWakeRates')
% %     rankbasis = sr.StateRates.EWakeRates;
% % end
% % rankbasis = sr.StateRates.ESWSRates;
% rankbasis = sr.StateRates.EREMRates;
% % rankbasis = sr.StateRates.EWakeARates;
% % rankbasis = sr.StateRates.EAllRates;
% % rankbasis = sr.StateRates.EWSWakeRates;
% 
%     
% bads = find(rankbasis<=0);
% goods = find(rankbasis>0);
% rankbasis(bads) = [];
% Se = Se(goods);
% 
% rankidxs = GetQuartilesByRank(rankbasis,numgroups);
% highidxs = find(rankidxs==numgroups);
% lowidxs = find(rankidxs==1);
% numHigh = sum(rankidxs==numgroups);
% numLow = sum(rankidxs==1);
% 
% 
% %% Generate bins
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
% spikemat.timestamps = mean([binstartends(1:end-1)' binstartends(2:end)'],2);
% binstartends = binstartends * sampfreq;
% binInts = intervalSet(binstartends(1:end-1),binstartends(2:end));
% 
% %% Bin and Divide to get EIRatio (non-normalized)
% hr = MakeQfromTsd(oneSeries(Se(highidxs)),binInts);
% hr = Data(hr);
% hr = hr./binwidthsecs/numHigh;
% zhr = nanzscore(hr);
% 
% lr = MakeQfromTsd(oneSeries(Se(lowidxs)),binInts);
% lr = Data(lr);
% lr = lr./binwidthsecs/numLow;
% zlr = nanzscore(lr);
% 
% hrlr = hr./(hr+lr); %te/(te+ti)
% % zhrzlr = zhr/zlr;
% 
% % PCEI = (hr/numEcells) ./ ((hr/numEcells) + (lr/numIcells));
% zhrlr = nanzscore(hrlr);
% % ZPCEI = nanzscore(PCEI);
% 
% %% Smooth
% hrlr = smooth(hrlr,smoothingnumpoints);
% zhrlr = smooth(zhrlr,smoothingnumpoints);
% % PCEI = smooth(PCEI,smoothingnumpoints);
% % ZPCEI = smooth(ZPCEI,smoothingnumpoints);
% hr = smooth(hr,smoothingnumpoints);
% lr = smooth(lr,smoothingnumpoints);
% 
% %% Plot
% if plotting
%     if exist(fullfile(basepath,[basename '-states.mat']),'file')    
%         t = load(fullfile(basepath,[basename '-states.mat']));%from GatherStateIntervalSets.m
%         ints = IDXtoINT(t.states);
%         for a = 1:5;
%             ints{a} = intervalSet(ints{a}(:,1),ints{a}(:,2));
%         end
%     elseif exist(fullfile(basepath,[basename '_SleepScore.mat']),'file')
%         ints = load(fullfile(basepath,[basename '_SleepScore.mat']));
%         ints = ints.StateIntervals;
%     elseif exist(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']),'file')
%         ints = load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']));
%     else
%         ints = [];
%     end
% %     load(fullfile(basepath,[basename '_Motion.mat']))
% %     m = tsd(sampfreq*[1:length(motiondata.motion)]',motiondata.motion');
% %     m = tsdArray(m);
% %     m = MakeSummedValQfromS(m,binInts);
% %     m = Data(m);
% %     m(isnan(m))=0;
% %     m = smooth(m,smoothingnumpoints);
%     if exist(fullfile(basepath,[basename '_EMGCorr.mat']))
%         load(fullfile(basepath,[basename '_EMGCorr.mat']))
%         m = tsd(EMGCorr(:,1),EMGCorr(:,2));
%     else
%         load(fullfile(basepath,[basename '.eegstates.mat']))
%         m = StateInfo.motion;
%         m = tsd(1:length(m),m);
%     end
%     m = tsdArray(m);
%     m = MakeSummedValQfromS(m,binInts);
%     m = Data(m);
%     m(isnan(m))=0;
%     m = smooth(m,smoothingnumpoints);
% 
%     figname = [basename '_HighLowRatioBin' num2str(binwidthsecs) 'Smooth' num2str(smoothingnumpoints)];
%     h = figure('position',[100 100 600 600],'name',figname);    
%     subplot(5,1,1:2,'yscale','log')
%         hold on;
%         axis tight
%         plot(spikemat.timestamps,hr);
%         plot(spikemat.timestamps,lr);
%         plotIntervalsStrip(gca,ints,1)
%         ylabel('HighFR, LowFR per cell')
%         title(['High/Low Ratio. Binning:' num2str(binwidthsecs) 'sec. Smooth By: ' num2str(smoothingnumpoints)  'points. File:' basename '.'],'fontsize',8,'fontweight','normal')
%     subplot(5,1,3:4,'yscale','log');
%         hold on;
%         axis tight
%         plot(spikemat.timestamps,hrlr,'k')
%         ylabel('HighFR/(HighFR+LowFR) Ratio')
%         plotIntervalsStrip(gca,ints,1)
%     subplot(5,1,5)
%         plot(spikemat.timestamps,m,'color',[.4 .4 .4])
%         hold on
%         axis tight
%         yl = ylim;
%         plot([yl(2)*.75 yl(2)*.75],'-.','color',[.5 .5 .5])
%         ylabel('EMG')
% %% save figure
%     if savingfigs
% %         savedir = fullfile(getdropbox,'BW OUTPUT','SleepProject','HighLowFRRatio',['Bin' num2str(binwidthsecs) 'Smooth' num2str(smoothingnumpoints)]);
%         savedir = cd;
%         MakeDirSaveFigsThereAs(savedir,h,'png')
%     end
% end
% 
% HighLowFRRatioData = v2struct(hrlr,zhrlr,hr,lr,binwidthsecs,spikemat.timestamps,smoothingnumpoints,highidxs,lowidxs);
save(fullfile(basepath,[basename '_HighLowFRRatio.mat']),'HighLowFRRatioData')
