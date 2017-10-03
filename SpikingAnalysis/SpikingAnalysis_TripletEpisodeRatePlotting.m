function [episodeAvgRates,episodeIndividRates] = SpikingAnalysis_TripletEpisodeRatePlotting(episodes,S)


for a = 1:size(episodes,2)%for every interval
    preSWSints = regIntervals(subset(episodes{a},1),3);
    REMints = regIntervals(subset(episodes{a},2),3);
    postSWSints = regIntervals(subset(episodes{a},3),3);
    for b = 1:3;
        %% averages
        preSWSAvgRates(a,b) = Data(intervalRate(oneSeries(S),preSWSints{b}))/size(S,1);%avg cellular firing rate
        REMAvgRates(a,b) = Data(intervalRate(oneSeries(S),REMints{b}))/size(S,1);%avg cellular firing rate
        postSWSAvgRates(a,b) = Data(intervalRate(oneSeries(S),postSWSints{b}))/size(S,1);%avg cellular firing rate    
        %% individual cells
        preSWSIndividRates(a,b,:) = reshape(Rate(S,preSWSints{b}),[1,1,size(S,1)]);%per cell firing rate
        REMIndividRates(a,b,:) = reshape(Rate(S,REMints{b}),[1,1,size(S,1)]);%per cell firing rate
        postSWSIndividRates(a,b,:) = reshape(Rate(S,postSWSints{b}),[1,1,size(S,1)]);%per cell firing rate  
    end
end

episodeAvgRates = cat(2,preSWSAvgRates,REMAvgRates,postSWSAvgRates);
smax = max(mean(episodeAvgRates,1));
smin = min(mean(episodeAvgRates,1));

episodeIndividRates = cat(2,preSWSIndividRates,REMIndividRates,postSWSIndividRates);

plot_meanSD_line(episodeAvgRates)
hold on
plot([3.5 6.5;3.5 6.5],[0.8*smin 1.2*smax;1.2*smax 0.8*smin],'color','r','linestyle','--')
ylim([0.8*smin 1.2*smax])
