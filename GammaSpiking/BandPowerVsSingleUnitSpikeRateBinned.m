function BandPowerVsSingleUnitSpikeRateBinned(basepath,plotting)
% Individual cells correlated against various frequency bands.  Each cell
% vs each band.  Also population and broadband data used too.
% Brendon Watson 2017

%% Constants
numspikerategroups = 6;
% % gammabandstarts = [0:1:19 20:2:38 40:5:195]';
% % gammabandstops = [1:1:20 22:2:40 45:5:200]';
% % gammabandmeans = mean([gammabandstarts gammabandstops],2);
% % gammabands = cat(2,gammabandstarts,gammabandstops);
% bandmeans = unique(round(logspace(0,log10(650),50)));%1 to 650, log spaced except elim some repetitive values near 1-4Hz

% binwidthseclist = [5 10 20];
binwidthseclist = [0.01,0.02,0.05,0.1,0.2,0.5,1,2,5,10,20,50,100,200];
broadbandgammarange = [50 180];
plotbinwidth = 1;%bin width to do some example plots by default

%% Input handling
if ~exist('basepath','var')
    basepath = cd;
end
basename = bz_BasenameFromBasepath(basepath);

if ~exist('plotting','var')
    plotting = 0;
end

%% Loading up
load(fullfile(basepath,[basename '_WaveletForGamma.mat']),'amp')
load(fullfile(basepath,[basename '_WaveletForGamma.mat']),'bandmeans')
load(fullfile(basepath,[basename '_WaveletForGamma.mat']),'sampfreq')
load(fullfile(basepath,[basename '_SSubtypes.mat']))
if exist('Se_TsdArrayFormat','var')
    Se = Se_TsdArrayFormat;
    Si = Si_TsdArrayFormat;
end

% load(fullfile(basepath,[basename '_EIRatio.mat']))
if ~exist(fullfile(basepath,[basename '_StateRates.mat']),'file')
    StateRates(basepath,basename);
end
sr = load(fullfile(basepath,[basename '_StateRates.mat']));
%     load([basename '_EMGCorr.mat'])

%% Bins/Timing: getting state-restricted second-wise bins to use for many purposes
load(fullfile(basepath,[basename '-states.mat']))

%restrict to good sleep interval, always thus far has been a single
%start-stop interval
load(fullfile(basepath,[basename '_GoodSleepInterval.mat']))
states((1:length(states))>GoodSleepInterval.timePairFormat(2)) = [];
states((1:length(states))<GoodSleepInterval.timePairFormat(1)) = [];
load(fullfile(basepath,[basename '_Motion']),'motiondata')

%extract intervals of states
ss = IDXtoINT(states);
AllTSecsIN = [1 length(states)];
WakeSecsIN = ss{1};
MaSecsIN = ss{2};
NremSecsIN = ss{3};
if length(ss)<5 
    RemSecsIN = [];
else
    RemSecsIN = ss{5};
end

AllTSecsIS = intervalSet(AllTSecsIN(:,1),AllTSecsIN(:,2));
NremSecsIS = intervalSet(NremSecsIN(:,1),NremSecsIN(:,2));
MaSecsIS = intervalSet(MaSecsIN(:,1),MaSecsIN(:,2));
WakeSecsIS = intervalSet(WakeSecsIN(:,1),WakeSecsIN(:,2));
if ~isempty(RemSecsIN)
    RemSecsIS = intervalSet(RemSecsIN(:,1),RemSecsIN(:,2));
else
    RemSecsIS = intervalSet([],[]);
end
MinMoveSecs = 5;
MinNonmoveSecs = 5;
WakeMove5SecsIN = continuousabove2_v2(motiondata.thresholdedsecs,0.5,MinMoveSecs,Inf);
%     WakeMove5IS = intervalSet(WakeMove5IN(:,1),WakeMove5IN(:,2));
%     WakeMove5IS = intersect(WakeMove5IS,WakeSecsIS);
%     WakeMove5IN = [Start(WakeMove5IS) End(WakeMove5IS)];
WakeMove5SecsIN = IntersectEpochs(WakeMove5SecsIN,WakeSecsIN);

WakeNonmove5SecsIN = continuousbelow2(motiondata.thresholdedsecs,0.5,MinNonmoveSecs,Inf);
%     WakeNonmove5IS = intervalSet(WakeNonmove5IN(:,1),WakeNonmove5IN(:,2));
%     WakeNonmove5IS = intersect(WakeNonmove5IS,WakeSecsIS);
%     WakeNonmove5IN = [Start(WakeNonmove5IS) End(WakeNonmove5IS)];
WakeNonmove5SecsIN = IntersectEpochs(WakeNonmove5SecsIN,WakeSecsIN);

stateslist = {'AllT','Wake','WakeMove5','WakeNonmove5','Nrem','Rem','Ma'};

% wakesecsIDX = INTtoIDX({wakesecsIN},length(spec),1);
% remsecsIDX = INTtoIDX({remsecsIN},length(spec),1);

%% Get sextile rates
% numTotalCells = numEcells+numIcells;

if isfield(sr.StateRates,'EWSWakeRates')
    rankbasis = sr.StateRates.EWSWakeRates;
elseif isfield(sr.StateRates,'EWakeRates')
    rankbasis = sr.StateRates.EWakeRates;
end
bads = find(rankbasis<=0);
goods = find(rankbasis>0);
rankbasis(bads) = [];
Se = Se(goods);
SeRates = Rate(Se);
SiRates = Rate(Si);

rankidxs = GetQuartilesByRank(rankbasis,numspikerategroups);

numEcells = length(Se);
numIcells = length(Si);


for binidx = 1:length(binwidthseclist)
    binwidthsecs = binwidthseclist(binidx);
    %% Restrict to a series of bins and use those same bins for all timing ops thereafter so correlations can be done
    %all
    for stidx = 1:length(stateslist)
        tst = stateslist{stidx};
        starts = [];
        ends = [];
        eval(['tSecsIN = ' tst 'SecsIN;'])
        for sgidx = 1:size(tSecsIN,1)
            t = tSecsIN(sgidx,:);
            ts = (t(1):binwidthsecs:t(2)-binwidthsecs)';
            te = (t(1)+binwidthsecs:binwidthsecs:t(2))';
            starts = cat(1,starts,ts);
            ends = cat(1,ends,te);
        end
        eval([tst 'bins = intervalSet(starts,ends);'])
        

        %% Get per-bin (per-second) spike rates
        eval([tst 'PopSeTsd = MakeQfromTsd(oneSeries(Se),' tst 'bins);'])
        eval([tst 'PopSeBinData = Data(' tst 'PopSeTsd);'])
        eval([tst 'PopSiTsd = MakeQfromTsd(oneSeries(Si),' tst 'bins);'])
        eval([tst 'PopSiBinData = Data(' tst 'PopSiTsd);'])

        %E Unit binned rates
        
        eval(['EUnit' tst 'RatesZ{binidx} = [];'])
        eval(['EUnit' tst 'Rates{binidx} = [];'])

        for sgidx = 1:numEcells
    %         EUnitIdxs{sgidx} = find(rankidxs==sgidx);

            eval(['t = Data(MakeQfromTsd(Se{sgidx},' tst 'bins));'])
            eval(['EUnit' tst 'Rates{binidx}(sgidx,:) = t./binwidthsecs;'])
            eval(['EUnit' tst 'RatesZ{binidx}(sgidx,:) = nanzscore(EUnit' tst 'Rates{binidx}(sgidx,:));'])
        end

        %I Unit binned rates
        eval(['IUnit' tst 'RatesZ{binidx} = [];'])
        eval(['IUnit' tst 'Rates{binidx} = [];'])
        for sgidx = 1:numIcells
            eval(['t = Data(MakeQfromTsd(Si{sgidx},' tst 'bins));'])
            eval(['IUnit' tst 'Rates{binidx}(sgidx,:) = t./binwidthsecs;'])
            eval(['IUnit' tst 'RatesZ{binidx}(sgidx,:) = nanzscore(IUnit' tst 'Rates{binidx}(sgidx,:));'])
        end
    end
    %% data by bands
    for bandidx = 1:length(bandmeans)+1
        if bandidx<=length(bandmeans)%if one of the bands, just gather power for that band
            tbandpower = amp(:,bandidx);
        else% for the case where we are looking at broadband gamma
            minbin = find(bandmeans>broadbandgammarange(1),1,'first');
            maxbin = find(bandmeans<broadbandgammarange(2),1,'last');
            broadbandpower = mean(amp(:,minbin:maxbin),2);
            tbandpower = broadbandpower;
        end
        
        bandpowertsd = tsd((1:length(tbandpower))/sampfreq,tbandpower);
        bandpowertsdArray = tsdArray(bandpowertsd);

        for stidx = 1:length(stateslist)%for each state
            tst = stateslist{stidx};
            eval([tst 'PowerbandTsd = MakeSummedValQfromS(bandpowertsdArray,' tst 'bins);'])
            eval([tst 'PowerbandData = Data(' tst 'PowerbandTsd);'])

            % make final matrices for correlations
            eval(['E' tst 'GeneralMatrix = cat(2,' tst 'PowerbandData,' tst 'PopSeBinData,EUnit' tst 'Rates{binidx}'');'])
            eval(['I' tst 'GeneralMatrix = cat(2,' tst 'PowerbandData,' tst 'PopSiBinData,IUnit' tst 'Rates{binidx}'');'])

            % correlate
            eval(['tgmE = E' tst 'GeneralMatrix;']);
            eval(['tgmI = I' tst 'GeneralMatrix;']);
            if ~isempty(tgmE)
                eval(['rE' tst ' = corr(E' tst 'GeneralMatrix);'])
                eval(['rE' tst '(find(bwdiag(length(rE' tst ')))) = 0;'])%zero the diag
                eval(['r_AllE' tst '(bandidx,binidx) = rE' tst '(1,2);'])
                eval(['r_CellsE' tst '(bandidx,:,binidx) = rE' tst '(1,3:end);'])
            else
                eval(['rE' tst ' = nan;'])
                eval(['r_AllE' tst '(bandidx,binidx) = nan;'])
                eval(['r_CellsE' tst '(bandidx,:,binidx) = nan(1,size(E' tst 'GeneralMatrix,2)-2);'])
            end
            if ~isempty(tgmI)
                eval(['rI' tst ' = corr(I' tst 'GeneralMatrix);'])
                eval(['rI' tst '(find(bwdiag(length(rI' tst ')))) = 0;'])%zero the diag
                eval(['r_AllI' tst '(bandidx,binidx) = rI' tst '(1,2);'])
                eval(['r_CellsI' tst '(bandidx,:,binidx) = rI' tst '(1,3:end);'])
            else
                eval(['rI' tst ' = nan;'])
                eval(['r_AllI' tst '(bandidx,binidx) = nan;'])
                eval(['r_CellsI' tst '(bandidx,:,binidx) = nan(1,size(I' tst 'GeneralMatrix,2)-2);'])
            end
        end
    end

    
    if plotbinwidth == binwidthsecs;%bin width to do some example plots by default
        for stidx = 1:length(stateslist)%for each state
            tst = stateslist{stidx};
            eval(['Example' tst 'SePop = ' tst 'PopSeBinData;'])
            eval(['Example' tst 'SiPop = ' tst 'PopSiBinData;'])
            eval(['Example' tst 'BroadBand = ' tst 'PowerbandData;'])
        end
    end
end



%% save
BandPowerVsSingleUnitSpikeRateData = v2struct(basepath,basename,...
    binwidthseclist,broadbandgammarange,plotbinwidth,bandmeans,...
    numEcells,numIcells,stateslist,SeRates,SiRates,...
    numEcells,numIcells,rankbasis,rankidxs);
    
for stidx = 1:length(stateslist);
    tst = stateslist{stidx};
    eval(['BandPowerVsSingleUnitSpikeRateData.Example' tst 'SePop = Example' tst 'SePop;'])
    eval(['BandPowerVsSingleUnitSpikeRateData.Example' tst 'SiPop = Example' tst 'SiPop;'])
    eval(['BandPowerVsSingleUnitSpikeRateData.Example' tst 'BroadBand = Example' tst 'BroadBand;'])
    eval(['BandPowerVsSingleUnitSpikeRateData.' tst 'SecsIN = ' tst 'SecsIN;'])
    eval(['BandPowerVsSingleUnitSpikeRateData.EUnit' tst 'Rates = EUnit' tst 'Rates;'])
    eval(['BandPowerVsSingleUnitSpikeRateData.EUnit' tst 'RatesZ = EUnit' tst 'RatesZ;'])
    eval(['BandPowerVsSingleUnitSpikeRateData.E' tst 'GeneralMatrix = E' tst 'GeneralMatrix;'])
    eval(['BandPowerVsSingleUnitSpikeRateData.I' tst 'GeneralMatrix = I' tst 'GeneralMatrix;'])
    eval(['BandPowerVsSingleUnitSpikeRateData.r_AllE' tst ' = r_AllE' tst ';'])
    eval(['BandPowerVsSingleUnitSpikeRateData.r_AllI' tst ' = r_AllI' tst ';'])
    eval(['BandPowerVsSingleUnitSpikeRateData.r_CellsE' tst ' = r_CellsE' tst ';'])
    eval(['BandPowerVsSingleUnitSpikeRateData.r_CellsI' tst ' = r_CellsI' tst ';'])
end

%     ExampleAllTSePop, ExampleWakeSePop, ExampleNremSePop,ExampleRemSePop,...
%     ExampleMaSePop,
% 
%     ExampleAllTSiPop,ExampleWakeSiPop,ExampleNremSiPop,...
%     ExampleRemSiPop,ExampleMaSiPop,
% 
%     ExampleAllTBroadBand,ExampleWakeBroadBand,...
%     ExampleNremBroadBand,ExampleRemBroadBand,ExampleMaBroadBand,...
% 
%     AllTSecsIS, NremSecsIS, MaSecsIS,WakeSecsIS,RemSecsIS,...
%         
%     EUnitAllTRatesZ,EUnitAllTRates,EUnitWakeRatesZ,EUnitWakeRates,EUnitMaRatesZ,EUnitMaRates,...
% 
%     EUnitNremRatesZ,EUnitNremRates,EUnitRemRatesZ,EUnitRemRates,...
%     
%     EAllTGeneralMatrix,IAllTGeneralMatrix,EWakeGeneralMatrix,IWakeGeneralMatrix,...
%     EMaGeneralMatrix,IMaGeneralMatrix,ENremGeneralMatrix,INremGeneralMatrix,...
%     ERemGeneralMatrix, IRemGeneralMatrix,...  
%     
%     r_AllEAllT,r_CellsEAllT,r_AllIAllT,r_CellsIAllT,...
%     r_AllEWake,r_CellsEWake,r_AllIWake,r_CellsIWake,...
%     r_AllENrem,r_CellsENrem,r_AllINrem,r_CellsINrem,...
%     r_AllERem,r_CellsERem,r_AllIRem,r_CellsIRem,...
%     r_AllEMa,r_CellsEMa,r_AllIMa,r_CellsIMa);



save(fullfile(basepath,[basename '_BandPowerVsSingleUnitSpikeRateData']),'BandPowerVsSingleUnitSpikeRateData','-v7.3')

%% plot
if plotting
    h = BandPowerVsSingleUnitSpikeRate_Plot(BandPowerVsSingleUnitSpikeRateData);
end
