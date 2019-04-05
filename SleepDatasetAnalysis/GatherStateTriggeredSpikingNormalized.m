function [normtotalcounts_struct, AvailCells_struct, rawcounts_struct, befaftvals_struct, alldiffsPs_struct, allSpikesAnatomies_struct] = GatherStateTriggeredSpikingNormalized...
        (Scell,intervals,statenumber,beforesample,aftersample,GoodSleepInterval,binsize,SpikesAnatomy)
%normalize by mean of pre-epoch spiking mean&SD
    
    
tssampfreq = 10000;
plotting = 0;

Sbool = 0;
Sebool = 0;
Sibool = 0;
if ~isempty(Scell{1})
    S = Scell{1};
    Sbool = 1;
end
if ~isempty(Scell{2})
    Se = Scell{2};
    Sebool = 1;
end
if ~isempty(Scell{3})
    Si = Scell{3};
    Sibool = 1;
end

pethNumBeforeBins = beforesample/binsize;
pethNumAfterBins = aftersample/binsize;
totalNumBins = pethNumBeforeBins+pethNumAfterBins;
beforebins = 1:pethNumBeforeBins;
afterbins = totalNumBins-(pethNumAfterBins-1):totalNumBins;

befaftvals = {};
diffsPs = [];
SpikesAnatomies = {};
Ebefaftvals = {};
EdiffsPs = [];
ESpikesAnatomies = {};
Ibefaftvals = {};
IdiffsPs = [];
ISpikesAnatomies = {};
BeforeSumTrains = [];
AfterSumTrains = [];
EBeforeSumTrains = [];
EAfterSumTrains = [];
IBeforeSumTrains = [];
IAfterSumTrains = [];
EIRatiobefaftVals = {};
EIRatiodiffsPs = [];
EIRatioSpikesAnatomies = {};

%% gather spiking data from same time
if Sbool
    AvailCells = [];
    rawcounts = [];
    normcounts = [];
    norminterpolatedcounts = [];
    meanBeforenormcounts = [];
    meanAfternormcounts = [];
end
if Sebool
    EAvailCells = [];
    Erawcounts = [];
    Enormcounts = [];
    Enorminterpolatedcounts = [];
    EmeanBeforenormcounts = [];
    EmeanAfternormcounts = [];
end
if Sibool
    IAvailCells = [];
    Irawcounts = [];
    Inormcounts = [];
    Inorminterpolatedcounts = [];
    ImeanBeforenormcounts = [];
    ImeanAfternormcounts = [];
end


intervalstouse = intervals{statenumber};%use the same intervals as above, next line
% get their bounds
[prestarts,poststarts,intervalidxs] = getIntervalStartsWithinBounds(intervalstouse,beforesample,aftersample,GoodSleepInterval,tssampfreq);
for c = 1:length(intervalidxs);        %go through each interval
    tidx = intervalidxs(c);%gather info
    triggerInterval = subset(intervalstouse,tidx);
    preInterval = intervalSet(0,Start(triggerInterval));
    IncludeIntervals = [];
    %execute for each interval
    if Sbool %all cells
        [tstarts,tAvailCells,trawcounts,tnormcounts,tnorminterpolatedcounts] = TriggeredIntervalTransitionSpikingHistogram...
            (triggerInterval,preInterval,beforesample,aftersample,S,IncludeIntervals,tssampfreq,binsize,plotting);
        AvailCells = cat(1,AvailCells,tAvailCells);
        rawcounts = cat(1,rawcounts,trawcounts);%raw counts per bin
        normcounts = cat(1,normcounts,tnormcounts);%normalized by cell overall rate
        norminterpolatedcounts = cat(1,norminterpolatedcounts,tnorminterpolatedcounts);% interpolates between episodes of interest (ie SWS episodes), rather than having nans
%         meanBeforenormcounts(:,end+1) = mean(mean(tnormcounts(:,1:pethNumBeforeBins),2),1);
%         meanAfternormcounts(:,end+1) = mean(mean(tnormcounts(:,end-pethNumAfterBins+1:end),2),1);
    end
    if Sebool % E cells
        [tEstarts,tEAvailCells,tErawcounts,tEnormcounts,tEnorminterpolatedcounts] = TriggeredIntervalTransitionSpikingHistogram...
            (triggerInterval,preInterval,beforesample,aftersample,Se,IncludeIntervals,tssampfreq,binsize,plotting);
        EAvailCells = cat(1,EAvailCells,tEAvailCells);
        Erawcounts = cat(1,Erawcounts,tErawcounts);
        Enormcounts = cat(1,Enormcounts,tEnormcounts);
        Enorminterpolatedcounts = cat(1,Enorminterpolatedcounts,tEnorminterpolatedcounts);
%         EmeanBeforenormcounts(:,end+1) = mean(mean(tEnormcounts(:,1:pethNumBeforeBins),2),1);
%         EmeanAfternormcounts(:,end+1) = mean(mean(tEnormcounts(:,end-pethNumAfterBins+1:end),2),1);
    end
    if Sibool % I cells
        [tIstarts,tIAvailCells,tIrawcounts,tInormcounts,tInorminterpolatedcounts] = TriggeredIntervalTransitionSpikingHistogram...
            (triggerInterval,preInterval,beforesample,aftersample,Si,IncludeIntervals,tssampfreq,binsize,plotting);
        IAvailCells = cat(1,IAvailCells,tIAvailCells);
        Irawcounts = cat(1,Irawcounts,tIrawcounts);
        Inormcounts = cat(1,Inormcounts,tInormcounts);
        Inorminterpolatedcounts = cat(1,Inorminterpolatedcounts,tInorminterpolatedcounts);
%         ImeanBeforenormcounts(:,end+1) = mean(mean(tInormcounts(:,1:pethNumBeforeBins),2),1);
%         ImeanAfternormcounts(:,end+1) = mean(mean(tInormcounts(:,end-pethNumAfterBins+1:end),2),1);
    end
end
%accumulate spike counts, based on how many cells spiked in each bin
%... function below uses norminterpolatedcounts, as of how this fcn
%is currently written norminterpolated exactly equals normcounts
%because include intervals is empty.

if Sbool
    % Spike counts per trial per timebin taking into account the number
    % of available cells in that bin
    AvailAccountedCounts = AccumulateStateTriggeredSpikesOverSessions(AvailCells,rawcounts,normcounts,norminterpolatedcounts,beforesample,aftersample,binsize);
    % Sum of counts across cells&trials
    SumCounts = sum(AvailAccountedCounts,1);
    % Subsets for pre- and post-trigger periods
    BeforeSumTrains(end+1,:) = SumCounts(beforebins);
    AfterSumTrains(end+1,:) = SumCounts(afterbins);

    %for normalizing for display purposes
    normtotalcounts = bwnormalize(SumCounts);
    beforesd = std(normtotalcounts(beforebins));
    beforemean = mean(normtotalcounts(beforebins));
    %normalized by number of 
    normtotalcounts = (normtotalcounts-beforemean)/beforesd;

    %for final summation bar graph
%                 [different,p] = ttest2(meanBeforenormcounts,meanAfternormcounts);
%                 allbefaftmeans{end+1} = meanBeforenormcounts;
%                 allbefaftmeans{end+1} = meanAfternormcounts;
    [different,p] = ttest2(BeforeSumTrains(end,:),AfterSumTrains(end,:));
    befaftvals{end+1} = BeforeSumTrains(end,:);
    befaftvals{end+1} = AfterSumTrains(end,:);
%     befaftvals{end+1} = 0;
    diffsPs(end+1,:) = [different,p];
    SpikesAnatomies{end+1} = SpikesAnatomy;
end
if Sebool
    if sum(sum(EAvailCells))
        EAvailAccountedCounts = AccumulateStateTriggeredSpikesOverSessions(EAvailCells,Erawcounts,Enormcounts,Enorminterpolatedcounts,beforesample,aftersample,binsize);
        ESumCounts = sum(EAvailAccountedCounts,1);
        EBeforeSumTrains(end+1,:) = ESumCounts(beforebins);
        EAfterSumTrains(end+1,:) = ESumCounts(afterbins);

        Enormtotalcounts = bwnormalize(ESumCounts);
        beforesd = std(Enormtotalcounts(beforebins));
        beforemean = mean(Enormtotalcounts(beforebins));
        Enormtotalcounts = (Enormtotalcounts-beforemean)/beforesd;

%                 [different,p] = ttest2(EmeanBeforenormcounts,EmeanAfternormcounts);
%                 Eallbefaftmeans{end+1} = EmeanBeforenormcounts;
%                 Eallbefaftmeans{end+1} = EmeanAfternormcounts;                
        [different,p] = ttest2(EBeforeSumTrains(end,:),EAfterSumTrains(end,:));
        Ebefaftvals{end+1} = EBeforeSumTrains(end,:);
        Ebefaftvals{end+1} = EAfterSumTrains(end,:);                
%         Ebefaftvals{end+1} = 0;
        EdiffsPs(end+1,:) = [different,p];
        ESpikesAnatomies{end+1} = SpikesAnatomy;
    else
        Enormtotalcounts = [];
    end
else
    Enormtotalcounts = [];
end
if Sibool
    if sum(sum(IAvailCells))
        IAvailAccountedCounts = AccumulateStateTriggeredSpikesOverSessions(IAvailCells,Irawcounts,Inormcounts,Inorminterpolatedcounts,beforesample,aftersample,binsize);
        ISumCounts = sum(IAvailAccountedCounts,1);
        IBeforeSumTrains(end+1,:) = ISumCounts(beforebins);
        IAfterSumTrains(end+1,:) = ISumCounts(afterbins);

        Inormtotalcounts = bwnormalize(ISumCounts);
        beforesd = std(Inormtotalcounts(beforebins));
        beforemean = mean(Inormtotalcounts(beforebins));
        Inormtotalcounts = (Inormtotalcounts-beforemean)/beforesd;

%                 [different,p] = ttest2(ImeanBeforenormcounts,ImeanAfternormcounts);
%                 Iallbefaftmeans{end+1} = ImeanBeforenormcounts;
%                 Iallbefaftmeans{end+1} = ImeanAfternormcounts;
        [different,p] = ttest2(IBeforeSumTrains(end,:),IAfterSumTrains(end,:));
        Ibefaftvals{end+1} = IBeforeSumTrains(end,:);
        Ibefaftvals{end+1} = IAfterSumTrains(end,:);
%         Ibefaftvals{end+1} = 0;
        IdiffsPs(end+1,:) = [different,p];
        ISpikesAnatomies{end+1} = SpikesAnatomy;
    else
        Inormtotalcounts = [];
    end
else
    Inormtotalcounts = [];
end
if Sebool && Sibool
    if sum(sum(EAvailCells)) && sum(sum(IAvailCells))
        EIRatiobefaftVals {end+1} = EBeforeSumTrains(end,:)./IBeforeSumTrains(end,:);
        EIRatiobefaftVals {end+1} = EAfterSumTrains(end,:)./IAfterSumTrains(end,:);
        [different,p] = ttest2(EIRatiobefaftVals{end-1},EIRatiobefaftVals{end});
        EIRatiodiffsPs(end+1,:) = [different,p];
        EIRatioSpikesAnatomies{end+1} = SpikesAnatomy;
    end
end
        
        
normtotalcounts_struct = v2struct(normtotalcounts,Enormtotalcounts,Inormtotalcounts);
AvailCells_struct = v2struct(AvailCells,EAvailCells,IAvailCells);
rawcounts_struct = v2struct(rawcounts, Erawcounts, Irawcounts);
befaftvals_struct = v2struct(befaftvals,Ebefaftvals,Ibefaftvals,EIRatiobefaftVals);
alldiffsPs_struct = v2struct(diffsPs,EdiffsPs,IdiffsPs,EIRatiodiffsPs);
allSpikesAnatomies_struct = v2struct(SpikesAnatomies,ESpikesAnatomies,ISpikesAnatomies,EIRatioSpikesAnatomies);
