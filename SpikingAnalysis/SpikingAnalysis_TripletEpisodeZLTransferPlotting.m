function [episodestrengths,preSWSstrengths,REMstrengths,postSWSstrengths] = SpikingAnalysis_ZLTripletEpisodeTransferPlotting(episodes,S,pairs,funcsynapses,percell,normalize)

if ~exist('normalize','var')
    normalize = 0;
end
if ~exist('percell','var')
    percell = 0;
end

for a = 1:size(episodes,2)%for every episode
    preSWSints = regIntervals(subset(episodes{a},1),3);
    REMints = regIntervals(subset(episodes{a},2),3);
    postSWSints = regIntervals(subset(episodes{a},3),3);
    for b = 1:3;
        preSWSstrengths(:,a,b) = spikeTransfer_InPairSeries(Restrict(S,preSWSints{b}),pairs,funcsynapses.ZeroLag.BinMs,funcsynapses.ZeroLag.CnxnStartTimesVsRefSpk,funcsynapses.ZeroLag.CnxnEndTimesVsRefSpk);
        REMstrengths(:,a,b) = spikeTransfer_InPairSeries(Restrict(S,REMints{b}),pairs,funcsynapses.ZeroLag.BinMs,funcsynapses.ZeroLag.CnxnStartTimesVsRefSpk,funcsynapses.ZeroLag.CnxnEndTimesVsRefSpk);
        postSWSstrengths(:,a,b) = spikeTransfer_InPairSeries(Restrict(S,postSWSints{b}),pairs,funcsynapses.ZeroLag.BinMs,funcsynapses.ZeroLag.CnxnStartTimesVsRefSpk,funcsynapses.ZeroLag.CnxnEndTimesVsRefSpk);
        
%         preSWSrates(a,b) = Data(intervalRate(oneSeries(S),preSWSints{b}))/size(S,1);%avg cellular firing rate
%         REMrates(a,b) = Data(intervalRate(oneSeries(S),REMints{b}))/size(S,1);%avg cellular firing rate
%         postSWSrates(a,b) = Data(intervalRate(oneSeries(S),postSWSints{b}))/size(S,1);%avg cellular firing rate    
    end
end

%% Normalize by the average transfer rate of each synapse (from whole recording)
if normalize
    for a = 1:length(pairs)
        avgTransfers(a) = funcsynapses.ZeroLag.TransferWeights(pairs(a,1),pairs(a,2));
    end
    avgTransfers = repmat(avgTransfers',[1,size(REMstrengths,2),size(REMstrengths,3)]);
    preSWSstrengths = preSWSstrengths./avgTransfers;
    REMstrengths = REMstrengths./avgTransfers;
    postSWSstrengths = postSWSstrengths./avgTransfers;
end
%%

% preSWSstrengths(isnan(preSWSstrengths)) = 0;
% REMstrengths(isnan(REMstrengths)) = 0;
% postSWSstrengths(isnan(postSWSstrengths)) = 0;
% preSWSstrengths(preSWSstrengths==Inf) = 1;
% REMstrengths(REMstrengths==Inf) = 1;
% postSWSstrengths(postSWSstrengths==Inf) = 1;

preSWSstrengthsPerCellAcrossSess = squeeze(mean(preSWSstrengths,2));
REMstrengthsPerCellAcrossSess = squeeze(mean(REMstrengths,2));
postSWSstrengthsPerCellAcrossSess = squeeze(mean(postSWSstrengths,2));

episodestrengths = cat(2,preSWSstrengthsPerCellAcrossSess,REMstrengthsPerCellAcrossSess,postSWSstrengthsPerCellAcrossSess);
smax = max(mean(episodestrengths,1));
smin = min(mean(episodestrengths,1));

plot_meanSEM_line(episodestrengths)
hold on
plot([3.5 6.5;3.5 6.5],[0.8*smin 1.2*smax;1.2*smax 0.8*smin],'color','r','linestyle','--')
ylim([0.8*smin 1.2*smax])
1;
