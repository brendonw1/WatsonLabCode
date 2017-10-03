function TransferStrengthsOverSleep = SpikingAnalysis_TransferRatesOverSleep(WSWEpisodes,S,intervals,funcsynapses,basename,basepath,raw, byratio)


numWSWEpisodes = size(WSWEpisodes,2);
numUniqueECnxns = size(funcsynapses.ConnectionsE,1);
numUniqueICnxns = size(funcsynapses.ConnectionsI,1);
numUniqueEECnxns = size(funcsynapses.ConnectionsEE,1);
numUniqueEICnxns = size(funcsynapses.ConnectionsEI,1);
numUniqueIECnxns = size(funcsynapses.ConnectionsIE,1);
numUniqueIICnxns = size(funcsynapses.ConnectionsII,1);

%% Gather basic session and movement info once 
%(cannot replicate anyway when doing final struct merging)
for a = 1:numWSWEpisodes;
    preWake = subset(WSWEpisodes{a},1);
    postWake = subset(WSWEpisodes{a},3);
    
    %Gather motion data for each wake: pre&post
%     pm = fullfile(basepath,[basename '_Motion.mat']);
    pm = [basename '_Motion.mat'];
    tm = load(pm);
    thr = tm.motiondata.thresholdedsecs;
    prw = subset(WSWEpisodes{a},1);%prewake
    prw = round([Start(prw) End(prw)]/10000);    
    PreWakeMovingSecs(a) = sum(thr(prw(1):prw(2)));
    WSWPreMotionBool(a) = PreWakeMovingSecs>=200;
    pow = subset(WSWEpisodes{a},3);%prewake
    pow = round([Start(pow) End(pow)]/10000);    
    PostWakeMovingSecs(a) = sum(thr(pow(1):pow(2)));
    WSWPostMotionBool(a) = PostWakeMovingSecs>=200;
end
WSWAndSessionInfo = v2struct(basename,raw,byratio,...
    numWSWEpisodes, numUniqueECnxns, numUniqueICnxns, numUniqueEECnxns,...
    numUniqueEICnxns, numUniqueIECnxns, numUniqueIICnxns,...
    PreWakeMovingSecs, WSWPreMotionBool, PostWakeMovingSecs, WSWPostMotionBool);

%% Gather synaptic info
PrePostWakeTransferMeasures = PrePostWakePlots(WSWEpisodes,S,intervals,funcsynapses,basename,raw, byratio);
FirstLastThirdSleepTransferMeasures = FirstLastThirdSleepPlots(WSWEpisodes,S,intervals,funcsynapses,basename,raw, byratio);
FirstLastSWSTransferMeasures = FirstLastSWSPlots(WSWEpisodes,S,intervals,funcsynapses,basename,raw, byratio);

%% Merge for Final Save
TransferStrengthsOverSleep = mergestruct(WSWAndSessionInfo,...
    PrePostWakeTransferMeasures,FirstLastThirdSleepTransferMeasures,...
    FirstLastSWSTransferMeasures);


function PrePostWakeTransferMeasures = PrePostWakePlots(WSWEpisodes,S,intervals,funcsynapses,basename,raw, byratio)
% prepresleepWakes = find(End(intervals{1})<=FirstTime(WSW.presleepInt));
% postpresleepWakes = find(Start(intervals{1})>=LastTime(WSW.presleepInt));
if raw
    rt = '-raw';
elseif byratio
    rt = '-normratio';
else
    rt = '-normratechg';
end
numWSWEpisodes = size(WSWEpisodes,2);


for a = 1:numWSWEpisodes;
    preWake = subset(WSWEpisodes{a},1);
    postWake = subset(WSWEpisodes{a},3);

    PreWakeEStrengths = spikeTransfer_InPairSeries(Restrict(S,preWake),...
        funcsynapses.ConnectionsE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    PreWakeIStrengths = spikeTransfer_InPairSeries(Restrict(S,preWake),...
        funcsynapses.ConnectionsI,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    PreWakeEEStrengths = spikeTransfer_InPairSeries(Restrict(S,preWake),...
        funcsynapses.ConnectionsEE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    PreWakeEIStrengths = spikeTransfer_InPairSeries(Restrict(S,preWake),...
        funcsynapses.ConnectionsEI,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    PreWakeIEStrengths = spikeTransfer_InPairSeries(Restrict(S,preWake),...
        funcsynapses.ConnectionsIE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    PreWakeIIStrengths = spikeTransfer_InPairSeries(Restrict(S,preWake),...
        funcsynapses.ConnectionsII,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);

    PostWakeEStrengths = spikeTransfer_InPairSeries(Restrict(S,postWake),...
        funcsynapses.ConnectionsE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    PostWakeIStrengths = spikeTransfer_InPairSeries(Restrict(S,postWake),...
        funcsynapses.ConnectionsI,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    PostWakeEEStrengths = spikeTransfer_InPairSeries(Restrict(S,postWake),...
        funcsynapses.ConnectionsEE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    PostWakeEIStrengths = spikeTransfer_InPairSeries(Restrict(S,postWake),...
        funcsynapses.ConnectionsEI,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    PostWakeIEStrengths = spikeTransfer_InPairSeries(Restrict(S,postWake),...
        funcsynapses.ConnectionsIE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    PostWakeIIStrengths = spikeTransfer_InPairSeries(Restrict(S,postWake),...
        funcsynapses.ConnectionsII,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    % 
    % %looking at percent changes per cell
    % ESynPercentChangesPreWakeVsPostWake = (PostWakeEStrengths-PreWakeEStrengths)./PreWakeEStrengths;
    % ISynPercentChangesPreWakeVsPostWake = (PostWakeIStrengths-PreWakeIStrengths)./PreWakeIStrengths;
    % ESynAbsoluteChangesPreWakeVsPostWake = (PostWakeEStrengths-PreWakeEStrengths);
    % ISynAbsoluteChangesPreWakeVsPostWake = (PostWakeIStrengths-PreWakeIStrengths);
    % %
    % EESynPercentChangesPreWakeVsPostWake = (PostWakeEEStrengths-PreWakeEEStrengths)./PreWakeEEStrengths;
    % EISynPercentChangesPreWakeVsPostWake = (PostWakeEIStrengths-PreWakeEIStrengths)./PreWakeEIStrengths;
    % EESynAbsoluteChangesPreWakeVsPostWake = (PostWakeEEStrengths-PreWakeEEStrengths);
    % EISynAbsoluteChangesPreWakeVsPostWake = (PostWakeEIStrengths-PreWakeEIStrengths);
    % %
    % IESynPercentChangesPreWakeVsPostWake = (PostWakeIEStrengths-PreWakeIEStrengths)./PreWakeIEStrengths;
    % IISynPercentChangesPreWakeVsPostWake = (PostWakeIIStrengths-PreWakeIIStrengths)./PreWakeIIStrengths;
    % IESynAbsoluteChangesPreWakeVsPostWake = (PostWakeIEStrengths-PreWakeIEStrengths);
    % IISynAbsoluteChangesPreWakeVsPostWake = (PostWakeIIStrengths-PreWakeIIStrengths);
    % 
    % %Correcting errors based on 0 values
    % ESynPercentChangesPreWakeVsPostWake(ESynPercentChangesPreWakeVsPostWake==Inf) = 1;
    % ISynPercentChangesPreWakeVsPostWake(ISynPercentChangesPreWakeVsPostWake==Inf) = 1;
    % ESynPercentChangesPreWakeVsPostWake(PreWakeEStrengths==0 & ESynAbsoluteChangesPreWakeVsPostWake==0) = 0;
    % ISynPercentChangesPreWakeVsPostWake(PreWakeIStrengths==0 & ISynAbsoluteChangesPreWakeVsPostWake==0) = 0;
    % % 
    % EESynPercentChangesPreWakeVsPostWake(EESynPercentChangesPreWakeVsPostWake==Inf) = 1;
    % EISynPercentChangesPreWakeVsPostWake(EISynPercentChangesPreWakeVsPostWake==Inf) = 1;
    % EESynPercentChangesPreWakeVsPostWake(PreWakeEEStrengths==0 & EESynAbsoluteChangesPreWakeVsPostWake==0) = 0;
    % EISynPercentChangesPreWakeVsPostWake(PreWakeEIStrengths==0 & EISynAbsoluteChangesPreWakeVsPostWake==0) = 0;
    % %
    % IESynPercentChangesPreWakeVsPostWake(IESynPercentChangesPreWakeVsPostWake==Inf) = 1;
    % IISynPercentChangesPreWakeVsPostWake(IISynPercentChangesPreWakeVsPostWake==Inf) = 1;
    % IESynPercentChangesPreWakeVsPostWake(PreWakeIEStrengths==0 & IESynAbsoluteChangesPreWakeVsPostWake==0) = 0;
    % IISynPercentChangesPreWakeVsPostWake(PreWakeIIStrengths==0 & IISynAbsoluteChangesPreWakeVsPostWake==0) = 0;
end
    
PrePostWakeTransferMeasures = v2struct(preWake,postWake,...
    PreWakeEStrengths,PreWakeIStrengths,...
    PreWakeEEStrengths,PreWakeEIStrengths,...
    PreWakeIEStrengths,PreWakeIIStrengths,...
    PostWakeEStrengths,PostWakeIStrengths,...
    PostWakeEEStrengths,PostWakeEIStrengths,...
    PostWakeIEStrengths,PostWakeIIStrengths);%,...
%     ESynPercentChangesPreWakeVsPostWake, ISynPercentChangesPreWakeVsPostWake,...
%     ESynAbsoluteChangesPreWakeVsPostWake, ISynAbsoluteChangesPreWakeVsPostWake,...
%     EESynPercentChangesPreWakeVsPostWake, EISynPercentChangesPreWakeVsPostWake,...
%     EESynAbsoluteChangesPreWakeVsPostWake, EISynAbsoluteChangesPreWakeVsPostWake,...
%     IESynPercentChangesPreWakeVsPostWake, IISynPercentChangesPreWakeVsPostWake,...
%     IESynAbsoluteChangesPreWakeVsPostWake, IISynAbsoluteChangesPreWakeVsPostWake);


function FirstLastThirdSleepTransferMeasures = FirstLastThirdSleepPlots(WSWEpisodes,S,intervals,funcsynapses,basename,raw, byratio)
if raw
    rt = '-raw';
elseif byratio
    rt = '-normratio';
else
    rt = '-normratechg';
end
numWSWEpisodes = size(WSWEpisodes,2);

for a = 1:numWSWEpisodes;
    SleepThirds = regIntervals(subset(WSWEpisodes{a},2),3);
    FirstThird = SleepThirds{1};
%     FirstThird = intersect(intervals{3},FirstThird);
    LastThird = SleepThirds{3};
%     LastThird = intersect(intervals{3},LastThird);
    
    FirstThirdSleepEStrengths = spikeTransfer_InPairSeries(Restrict(S,FirstThird),...
        funcsynapses.ConnectionsE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    FirstThirdSleepIStrengths = spikeTransfer_InPairSeries(Restrict(S,FirstThird),...
        funcsynapses.ConnectionsI,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    FirstThirdSleepEEStrengths = spikeTransfer_InPairSeries(Restrict(S,FirstThird),...
        funcsynapses.ConnectionsEE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    FirstThirdSleepEIStrengths = spikeTransfer_InPairSeries(Restrict(S,FirstThird),...
        funcsynapses.ConnectionsEI,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    FirstThirdSleepIEStrengths = spikeTransfer_InPairSeries(Restrict(S,FirstThird),...
        funcsynapses.ConnectionsIE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    FirstThirdSleepIIStrengths = spikeTransfer_InPairSeries(Restrict(S,FirstThird),...
        funcsynapses.ConnectionsII,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);

    LastThirdSleepEStrengths = spikeTransfer_InPairSeries(Restrict(S,LastThird),...
        funcsynapses.ConnectionsE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    LastThirdSleepIStrengths = spikeTransfer_InPairSeries(Restrict(S,LastThird),...
        funcsynapses.ConnectionsI,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    LastThirdSleepEEStrengths = spikeTransfer_InPairSeries(Restrict(S,LastThird),...
        funcsynapses.ConnectionsEE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    LastThirdSleepEIStrengths = spikeTransfer_InPairSeries(Restrict(S,LastThird),...
        funcsynapses.ConnectionsEI,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    LastThirdSleepIEStrengths = spikeTransfer_InPairSeries(Restrict(S,LastThird),...
        funcsynapses.ConnectionsIE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    LastThirdSleepIIStrengths = spikeTransfer_InPairSeries(Restrict(S,LastThird),...
        funcsynapses.ConnectionsII,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    % 
    % %looking at percent changes per cell
    % ESynPercentChangesFirstVsLastThirdSleep = (LastThirdSleepEStrengths-FirstThirdSleepEStrengths)./FirstThirdSleepEStrengths;
    % ISynPercentChangesFirstVsLastThirdSleep = (LastThirdSleepIStrengths-FirstThirdSleepIStrengths)./FirstThirdSleepIStrengths;
    % ESynAbsoluteChangesFirstVsLastThirdSleep = (LastThirdSleepEStrengths-FirstThirdSleepEStrengths);
    % ISynAbsoluteChangesFirstVsLastThirdSleep = (LastThirdSleepIStrengths-FirstThirdSleepIStrengths);
    % %
    % EESynPercentChangesFirstVsLastThirdSleep = (LastThirdSleepEEStrengths-FirstThirdSleepEEStrengths)./FirstThirdSleepEEStrengths;
    % EISynPercentChangesFirstVsLastThirdSleep = (LastThirdSleepEIStrengths-FirstThirdSleepEIStrengths)./FirstThirdSleepEIStrengths;
    % EESynAbsoluteChangesFirstVsLastThirdSleep = (LastThirdSleepEEStrengths-FirstThirdSleepEEStrengths);
    % EISynAbsoluteChangesFirstVsLastThirdSleep = (LastThirdSleepEIStrengths-FirstThirdSleepEIStrengths);
    % %
    % IESynPercentChangesFirstVsLastThirdSleep = (LastThirdSleepIEStrengths-FirstThirdSleepIEStrengths)./FirstThirdSleepIEStrengths;
    % IISynPercentChangesFirstVsLastThirdSleep = (LastThirdSleepIIStrengths-FirstThirdSleepIIStrengths)./FirstThirdSleepIIStrengths;
    % IESynAbsoluteChangesFirstVsLastThirdSleep = (LastThirdSleepIEStrengths-FirstThirdSleepIEStrengths);
    % IISynAbsoluteChangesFirstVsLastThirdSleep = (LastThirdSleepIIStrengths-FirstThirdSleepIIStrengths);
    % 
    % %Correcting errors based on 0 values
    % ESynPercentChangesFirstVsLastThirdSleep(ESynPercentChangesFirstVsLastThirdSleep==Inf) = 1;
    % ISynPercentChangesFirstVsLastThirdSleep(ISynPercentChangesFirstVsLastThirdSleep==Inf) = 1;
    % ESynPercentChangesFirstVsLastThirdSleep(FirstThirdSleepEStrengths==0 & ESynAbsoluteChangesFirstVsLastThirdSleep==0) = 0;
    % ISynPercentChangesFirstVsLastThirdSleep(FirstThirdSleepIStrengths==0 & ISynAbsoluteChangesFirstVsLastThirdSleep==0) = 0;
    % % 
    % EESynPercentChangesFirstVsLastThirdSleep(EESynPercentChangesFirstVsLastThirdSleep==Inf) = 1;
    % EISynPercentChangesFirstVsLastThirdSleep(EISynPercentChangesFirstVsLastThirdSleep==Inf) = 1;
    % EESynPercentChangesFirstVsLastThirdSleep(FirstThirdSleepEEStrengths==0 & EESynAbsoluteChangesFirstVsLastThirdSleep==0) = 0;
    % EISynPercentChangesFirstVsLastThirdSleep(FirstThirdSleepEIStrengths==0 & EISynAbsoluteChangesFirstVsLastThirdSleep==0) = 0;
    % %
    % IESynPercentChangesFirstVsLastThirdSleep(IESynPercentChangesFirstVsLastThirdSleep==Inf) = 1;
    % IISynPercentChangesFirstVsLastThirdSleep(IISynPercentChangesFirstVsLastThirdSleep==Inf) = 1;
    % IESynPercentChangesFirstVsLastThirdSleep(FirstThirdSleepIEStrengths==0 & IESynAbsoluteChangesFirstVsLastThirdSleep==0) = 0;
    % IISynPercentChangesFirstVsLastThirdSleep(FirstThirdSleepIIStrengths==0 & IISynAbsoluteChangesFirstVsLastThirdSleep==0) = 0;

end

FirstLastThirdSleepTransferMeasures = v2struct(FirstThird,LastThird,...
    FirstThirdSleepEStrengths,FirstThirdSleepIStrengths,...
    FirstThirdSleepEEStrengths,FirstThirdSleepEIStrengths,...
    FirstThirdSleepIEStrengths,FirstThirdSleepIIStrengths,...
    LastThirdSleepEStrengths,LastThirdSleepIStrengths,...
    LastThirdSleepEEStrengths,LastThirdSleepEIStrengths,...
    LastThirdSleepIEStrengths,LastThirdSleepIIStrengths);%,...
%     ESynPercentChangesFirstVsLastThirdSleep, ISynPercentChangesFirstVsLastThirdSleep,...
%     ESynAbsoluteChangesFirstVsLastThirdSleep, ISynAbsoluteChangesFirstVsLastThirdSleep,...
%     EESynPercentChangesFirstVsLastThirdSleep, EISynPercentChangesFirstVsLastThirdSleep,...
%     EESynAbsoluteChangesFirstVsLastThirdSleep, EISynAbsoluteChangesFirstVsLastThirdSleep,...
%     IESynPercentChangesFirstVsLastThirdSleep, IISynPercentChangesFirstVsLastThirdSleep,...
%     IESynAbsoluteChangesFirstVsLastThirdSleep, IISynAbsoluteChangesFirstVsLastThirdSleep);


function FirstLastSWSTransferMeasures = FirstLastSWSPlots(WSWEpisodes,S,intervals,funcsynapses,basename,raw, byratio)
if raw
    rt = '-raw';
elseif byratio
    rt = '-normratio';
else
    rt = '-normratechg';
end
numWSWEpisodes = size(WSWEpisodes,2);

for a = 1:numWSWEpisodes;
    FirstSWS = intersect(intervals{3},subset(WSWEpisodes{1},2));
    FirstSWS = subset(FirstSWS,1);
    LastSWS = intersect(intervals{3},subset(WSWEpisodes{1},2));
    t = length(length(LastSWS));
    LastSWS = subset(LastSWS,t);

    FirstSWSEStrengths = spikeTransfer_InPairSeries(Restrict(S,FirstSWS),...
        funcsynapses.ConnectionsE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    FirstSWSIStrengths = spikeTransfer_InPairSeries(Restrict(S,FirstSWS),...
        funcsynapses.ConnectionsI,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    FirstSWSEEStrengths = spikeTransfer_InPairSeries(Restrict(S,FirstSWS),...
        funcsynapses.ConnectionsEE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    FirstSWSEIStrengths = spikeTransfer_InPairSeries(Restrict(S,FirstSWS),...
        funcsynapses.ConnectionsEI,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    FirstSWSIEStrengths = spikeTransfer_InPairSeries(Restrict(S,FirstSWS),...
        funcsynapses.ConnectionsIE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    FirstSWSIIStrengths = spikeTransfer_InPairSeries(Restrict(S,FirstSWS),...
        funcsynapses.ConnectionsII,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);

    LastSWSEStrengths = spikeTransfer_InPairSeries(Restrict(S,LastSWS),...
        funcsynapses.ConnectionsE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    LastSWSIStrengths = spikeTransfer_InPairSeries(Restrict(S,LastSWS),...
        funcsynapses.ConnectionsI,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    LastSWSEEStrengths = spikeTransfer_InPairSeries(Restrict(S,LastSWS),...
        funcsynapses.ConnectionsEE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    LastSWSEIStrengths = spikeTransfer_InPairSeries(Restrict(S,LastSWS),...
        funcsynapses.ConnectionsEI,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    LastSWSIEStrengths = spikeTransfer_InPairSeries(Restrict(S,LastSWS),...
        funcsynapses.ConnectionsIE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    LastSWSIIStrengths = spikeTransfer_InPairSeries(Restrict(S,LastSWS),...
        funcsynapses.ConnectionsII,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,raw, byratio);
    % 
    % %looking at percent changes per cell
    % ESynPercentChangesFirstVsLastThirdSleep = (LastThirdSleepEStrengths-FirstThirdSleepEStrengths)./FirstThirdSleepEStrengths;
    % ISynPercentChangesFirstVsLastThirdSleep = (LastThirdSleepIStrengths-FirstThirdSleepIStrengths)./FirstThirdSleepIStrengths;
    % ESynAbsoluteChangesFirstVsLastThirdSleep = (LastThirdSleepEStrengths-FirstThirdSleepEStrengths);
    % ISynAbsoluteChangesFirstVsLastThirdSleep = (LastThirdSleepIStrengths-FirstThirdSleepIStrengths);
    % %
    % EESynPercentChangesFirstVsLastThirdSleep = (LastThirdSleepEEStrengths-FirstThirdSleepEEStrengths)./FirstThirdSleepEEStrengths;
    % EISynPercentChangesFirstVsLastThirdSleep = (LastThirdSleepEIStrengths-FirstThirdSleepEIStrengths)./FirstThirdSleepEIStrengths;
    % EESynAbsoluteChangesFirstVsLastThirdSleep = (LastThirdSleepEEStrengths-FirstThirdSleepEEStrengths);
    % EISynAbsoluteChangesFirstVsLastThirdSleep = (LastThirdSleepEIStrengths-FirstThirdSleepEIStrengths);
    % %
    % IESynPercentChangesFirstVsLastThirdSleep = (LastThirdSleepIEStrengths-FirstThirdSleepIEStrengths)./FirstThirdSleepIEStrengths;
    % IISynPercentChangesFirstVsLastThirdSleep = (LastThirdSleepIIStrengths-FirstThirdSleepIIStrengths)./FirstThirdSleepIIStrengths;
    % IESynAbsoluteChangesFirstVsLastThirdSleep = (LastThirdSleepIEStrengths-FirstThirdSleepIEStrengths);
    % IISynAbsoluteChangesFirstVsLastThirdSleep = (LastThirdSleepIIStrengths-FirstThirdSleepIIStrengths);
    % 
    % %Correcting errors based on 0 values
    % ESynPercentChangesFirstVsLastThirdSleep(ESynPercentChangesFirstVsLastThirdSleep==Inf) = 1;
    % ISynPercentChangesFirstVsLastThirdSleep(ISynPercentChangesFirstVsLastThirdSleep==Inf) = 1;
    % ESynPercentChangesFirstVsLastThirdSleep(FirstThirdSleepEStrengths==0 & ESynAbsoluteChangesFirstVsLastThirdSleep==0) = 0;
    % ISynPercentChangesFirstVsLastThirdSleep(FirstThirdSleepIStrengths==0 & ISynAbsoluteChangesFirstVsLastThirdSleep==0) = 0;
    % % 
    % EESynPercentChangesFirstVsLastThirdSleep(EESynPercentChangesFirstVsLastThirdSleep==Inf) = 1;
    % EISynPercentChangesFirstVsLastThirdSleep(EISynPercentChangesFirstVsLastThirdSleep==Inf) = 1;
    % EESynPercentChangesFirstVsLastThirdSleep(FirstThirdSleepEEStrengths==0 & EESynAbsoluteChangesFirstVsLastThirdSleep==0) = 0;
    % EISynPercentChangesFirstVsLastThirdSleep(FirstThirdSleepEIStrengths==0 & EISynAbsoluteChangesFirstVsLastThirdSleep==0) = 0;
    % %
    % IESynPercentChangesFirstVsLastThirdSleep(IESynPercentChangesFirstVsLastThirdSleep==Inf) = 1;
    % IISynPercentChangesFirstVsLastThirdSleep(IISynPercentChangesFirstVsLastThirdSleep==Inf) = 1;
    % IESynPercentChangesFirstVsLastThirdSleep(FirstThirdSleepIEStrengths==0 & IESynAbsoluteChangesFirstVsLastThirdSleep==0) = 0;
    % IISynPercentChangesFirstVsLastThirdSleep(FirstThirdSleepIIStrengths==0 & IISynAbsoluteChangesFirstVsLastThirdSleep==0) = 0;
end

FirstLastSWSTransferMeasures = v2struct(FirstSWS,LastSWS,...
    FirstSWSEStrengths,FirstSWSIStrengths,...
    FirstSWSEEStrengths,FirstSWSEIStrengths,...
    FirstSWSIEStrengths,FirstSWSIIStrengths,...
    LastSWSEStrengths,LastSWSIStrengths,...
    LastSWSEEStrengths,LastSWSEIStrengths,...
    LastSWSIEStrengths,LastSWSIIStrengths);%,...
%     ESynPercentChangesFirstVsLastThirdSleep, ISynPercentChangesFirstVsLastThirdSleep,...
%     ESynAbsoluteChangesFirstVsLastThirdSleep, ISynAbsoluteChangesFirstVsLastThirdSleep,...
%     EESynPercentChangesFirstVsLastThirdSleep, EISynPercentChangesFirstVsLastThirdSleep,...
%     EESynAbsoluteChangesFirstVsLastThirdSleep, EISynAbsoluteChangesFirstVsLastThirdSleep,...
%     IESynPercentChangesFirstVsLastThirdSleep, IISynPercentChangesFirstVsLastThirdSleep,...
%     IESynAbsoluteChangesFirstVsLastThirdSleep, IISynAbsoluteChangesFirstVsLastThirdSleep);


