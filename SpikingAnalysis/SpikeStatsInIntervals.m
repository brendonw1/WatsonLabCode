function [IntervalSpikeStats,s] = SpikeStatsInIntervals(S,ints,peaks)
% Uses S (tsdarray)) and ints (intervalSet) from TSToolbox to extract spike
% counts, cell counts and timing stats for each cell in each interval in ints.
% time units all in seconds, except for s

if ~exist('peaks','var')%may or may not want an input for peaks... will output blank varibles for peaks if no peak time inputs
    peaks = [];
    peakbool = 0;
else
    peakbool = 1;
end

sampfreq = 10000;
maxdurcap = 0.200;%200ms min length (based on luczak 2007)

%Get numbers of intervals and cells
numints = length(length(ints));
numcells = size(S,1);

% Preallocate variables
spkts = cell(numints,numcells);
spkbools = zeros(numints,numcells);
spkcounts = zeros(numints,numcells);
spkrates = zeros(numints,numcells);
meanspktsfromstart = nan(numints,numcells);%
firstspktsfromstart = nan(numints,numcells);%
meanspktsfrompeak = nan(numints,numcells);
firstspktsfrompeak = nan(numints,numcells);
meanspktsfromstart_capped = nan(numints,numcells);
meanspktsfrompeak_capped = nan(numints,numcells);
% cellspikeranksbymean_fromstart = nan(numints,numcells);
% cellspikeranksbyfirst_fromstart = nan(numints,numcells);
% cellspikeranksbymean_frompeak = nan(numints,numcells);
% cellspikeranksbyfirst_frompeak = nan(numints,numcells);

rates = Rate(S)';

%Get interval times in vector form... in seconds
intstarts = Start(ints)/sampfreq;
intends = End(ints)/sampfreq;

%Exctract spikes from intervals
for a = 1:numints
    s{a} = Restrict(S,subset(ints,a));
% Get times in seconds
    for b = 1:numcells
        ts = TimePoints(s{a}{b})/sampfreq;
        spkts{a,b} = ts;
        spkbools(a,b) = ~isempty(ts);
        spkcounts(a,b) = length(ts);
        spkrates(a,b) = length(ts)/(intends(a)-intstarts(a));
        if spkbools(a,b)%if there were spikes
            meanspktsfromstart(a,b) = mean(ts)-intstarts(a);
            firstspktsfromstart(a,b) = ts(1)-intstarts(a);
            if peakbool
%                 meanspktsfrompeak(a,b) = mean(ts)-(intstarts(a)+(peaks(a)-intstarts(a));
%                 firstspktsfrompeak(a,b) = ts(1)-(intstarts(a)+peaks(a));
                meanspktsfrompeak(a,b) = mean(ts)-peaks(a);
                firstspktsfrompeak(a,b) = ts(1)-peaks(a);

                rt = ts-peaks(a);
                rt(rt>maxdurcap) = [];
                meanspktsfrompeak_capped(a,b) = mean(rt);
            end
            
            rt = ts-intstarts(a);
            rt(rt>maxdurcap) = [];
            meanspktsfromstart_capped(a,b) = mean(rt);
            
        end
    end
    if rem(a,100) == 0
        disp([num2str(a) ' out of ' num2str(numints) ' intervals done'])    
    end
%     %getting sequences
%     [ts,seq] = sort(meanspktsfromstart(a,~isnan(meanspktsfromstart(a,:))));%sort only non-nan's
%     cellspikeranksbymean_fromstart(a,1:length(seq)) = seq;
%     if a == 2;
%         x = meanspktsfromstart(1,:);
%         y = meanspktsfromstart(2,:);
%         overlap = logical(x.*y);
%         x(~overlap) = 0;
%         y(~overlap) = 0;
%         [ts1,seq1] = sort(x);
%         [ts2,seq2] = sort(y);
%     end    
end
%getting participant overlaps
% prod of logicals


intcellcounts = sum(spkbools,2);
intspkcounts = sum(spkcounts,2);
spkrelativerates = spkrates./repmat(rates,[numints 1]);

IntervalSpikeStats = v2struct(S,ints,intstarts,intends,...
    intcellcounts,intspkcounts,...
    spkts,spkbools,spkcounts,spkrates,spkrelativerates,...
    meanspktsfromstart, firstspktsfromstart,...
    meanspktsfrompeak, firstspktsfrompeak,...
    meanspktsfrompeak_capped, meanspktsfromstart_capped);
% ,...
%     cellspikeranksbymean_fromstart, cellspikeranksbyfirst_fromstart,...
%     cellspikeranksbymean_frompeak, cellspikeranksbyfirst_frompeak);
