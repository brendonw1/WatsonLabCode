function [changingcells,changedirections,ps] = SpikeRateDistribChangeOverIntervals(S,int1,int2,binseconds)
% Uses wilcoxan rank sum test to assess for change in distribution (median)
% of spike rates across two intervals.  Spike rates are calculated bin-wise
% for each cell within each interval and the distributions of the binned
% rates are compared across the two time intervals for each cell.  Wilcoxan
% signrank test (Mann-Whitney) is used to generate p-values to determine
% which cells show significant difference across the specified intervals.
% 
% INPUTS
% S = tsdarray of spike trains of cells (from TSToolbox)
% int1 & int2 = intervalSets specifying time ranges to compare across (from
%     TSToolbox)
% binseconds (optional) - binwidth in seconds to be used in calculations
%     (default is 10seconds, which is used if no binseconds is given)
%
% OUTPUTS
% changingcells = binary vector with one element per cell - 1 if changed
%     spiking over the two intervals, 0 if not
% changedirections = 0 if no change, 1 if increase from int1 to int2, -1 if
% decrease
% ps = vector of p values for each cell
%
% Brendon Watson Nov 2014

if ~exist('binseconds','var')
    binseconds = 5;
end

sampfreq = 10000;
plotting = 0;

binpoints = binseconds * sampfreq;

S1 = Restrict(S,int1);
S2 = Restrict(S,int2);

b1 = Data(MakeQfromS(S1,binpoints))/binseconds;%binned rates (ie in Hz)
b2 = Data(MakeQfromS(S2,binpoints))/binseconds;%binned rates (ie in Hz)

changingcells = zeros(size(S,1),1);
ps = zeros(size(S,1),1);
changedirections = zeros(size(S,1),1);
for a = 1:size(b1,2)%for each cell
% for a = 1:10
    t1 = b1(:,a);
    t2 = b2(:,a);
    
    [p,diffhyp] = ranksum(t1,t2);
    ps(a) = p;
    changingcells(a) = diffhyp;
    if diffhyp
        if mean(t1)<mean(t2)
            changedirections(a) = 1;%getting bigger in second interval
        else
            changedirections(a) = -1;%getting smaller
        end
    end
    
    
    if plotting
        figure;
        subplot(2,1,1)
        hist(t1,25)
        if diffhyp
            set(gca,'Color',[.7 1 .7])
        end
        title(['p=' num2str(p)])

        subplot(2,1,2)
        hist(t2,25)
        if diffhyp
            set(gca,'Color',[.7 1 .7])
        end
    end
end