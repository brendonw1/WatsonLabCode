function [SpindleCountShuffles,SpindleBoolShuffles] = GenerateSurrogateRatesAndBooleansPerEvent(nshuffs,sp,S,origcounts,origbools,basename)

celltype = inputname(2);
switch celltype
    case 'S'
        celltype = 'All';
    case 'Se'
        celltype = 'E';
    case 'Si'
        celltype = 'I';
end        



[surrcounts_byFlatDistrib,surrbools_byFlatDistrib] = ShuffleTotalEventSpikesByWeights(origcounts,ones(1,size(S,1)),nshuffs);

[surrcounts_byOverallRate,surrbools_byOverallRate] = ShuffleTotalEventSpikesByWeights(origcounts,Rate(S),nshuffs);

[surrcounts_bySpindleBinary,surrbools_bySpindleBinary] = ShuffleTotalEventSpikesByWeights(origcounts,mean(origbools,1),nshuffs);

S_inSpindles =  CompressSpikeTrainsToIntervals(S,sp);
[surrcounts_bySpindleRate,surrbools_bySpindleRate] = ShuffleTotalEventSpikesByWeights(origcounts,Rate(S_inSpindles),nshuffs);

intervals = load([basename,'_Intervals.mat']);
S_inWake =  CompressSpikeTrainsToIntervals(S,intervals.intervals{1});
S_inSWS =  CompressSpikeTrainsToIntervals(S,intervals.intervals{3});
S_inREM =  CompressSpikeTrainsToIntervals(S,intervals.intervals{5});
[surrcounts_bySWSRate,surrbools_bySWSRate] = ShuffleTotalEventSpikesByWeights(origcounts,Rate(S_inSWS),nshuffs);

UPs = load([basename,'_UPDOWNIntervals.mat']);
S_inUPs =  CompressSpikeTrainsToIntervals(S,UPs.UPInts);
[surrcounts_byUPRate,surrbools_byUPRate] = ShuffleTotalEventSpikesByWeights(origcounts,Rate(S_inUPs),nshuffs);

SpindleCountShuffles = v2struct(surrcounts_byFlatDistrib,surrcounts_byOverallRate,...
    surrcounts_bySpindleBinary,surrcounts_bySpindleRate,surrcounts_bySWSRate,...
    surrcounts_byUPRate);
SpindleBoolShuffles = v2struct(surrbools_byFlatDistrib,surrbools_byOverallRate,...
    surrbools_bySpindleBinary,surrbools_bySpindleRate,surrbools_bySWSRate,...
    surrbools_byUPRate);
save (['Spindles/' basename '_SpindleCountShuffles_' num2str(nshuffs) '_' celltype],'SpindleCountShuffles')
save (['Spindles/' basename '_SpindleBoolShuffles_' num2str(nshuffs) '_' celltype],'SpindleBoolShuffles')

SConfined = v2struct(S_inWake,S_inSWS,S_inREM,S_inUPs,S_inSpindles);
save ([basename '_SConfined'],'SConfined')

% !make upstate shuffles, why not