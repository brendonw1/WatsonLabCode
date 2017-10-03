function h = SpikingAnalysis_TransferRatesOverSleep_Plot(TransferStrengthsOverSleep)

h1 = PrePostWakePlots(TransferStrengthsOverSleep);
h2 = FirstLastThirdSleepPlots(TransferStrengthsOverSleep);

h = cat(2,h1,h2);
% TransferStrengthsOverSleep = mergestruct(PrePostWakeTransferMeasures,FirstLastThirdSleepTransferMeasures);

% Comparisons of before/early vs after/late sleep epochs, all related to
% presleep


% %save figs
% if ~exist(fullfile(basepath,'TransferStrengthsOverSleepFigs'),'dir')
%     mkdir(fullfile(basepath,'TransferStrengthsOverSleepFigs'))
% end
% cd(fullfile(basepath,'TransferStrengthsOverSleepFigs'))
% saveallfigsas('fig')
% cd(basepath)


% clear h x y ...
%     PreWakeEStrengths PreWakeIStrengths...
%     PreWakeEEStrengths PreWakeEIStrengths...
%     PreWakeIEStrengths PreWakeIIStrengths...
%     PostWakeEStrengths PostWakeIStrengths...
%     PostWakeEEStrengths PostWakeEIStrengths...
%     PostWakeIEStrengths PostWakeIIStrengths...
%     ESynPercentChangesPreWakeVsPostWake ISynPercentChangesPreWakeVsPostWake...
%     ESynAbsoluteChangesPreWakeVsPostWake ISynAbsoluteChangesPreWakeVsPostWake



function h = PrePostWakePlots(TransferStrengthsOverSleep)
% preWake = subset(WSW{1},1);
% postWake = subset(WSW{1},3);
% % prepresleepWakes = find(End(intervals{1})<=FirstTime(WSW.presleepInt));
% % postpresleepWakes = find(Start(intervals{1})>=LastTime(WSW.presleepInt));

% 
% PreWakeEStrengths = spikeTransfer_InPairSeries(Restrict(S,preWake),...
%     funcsynapses.ConnectionsE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,byratio,raw);
% PreWakeIStrengths = spikeTransfer_InPairSeries(Restrict(S,preWake),...
%     funcsynapses.ConnectionsI,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,byratio,raw);
% PreWakeEEStrengths = spikeTransfer_InPairSeries(Restrict(S,preWake),...
%     funcsynapses.ConnectionsEE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,byratio,raw);
% PreWakeEIStrengths = spikeTransfer_InPairSeries(Restrict(S,preWake),...
%     funcsynapses.ConnectionsEI,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,byratio,raw);
% PreWakeIEStrengths = spikeTransfer_InPairSeries(Restrict(S,preWake),...
%     funcsynapses.ConnectionsIE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,byratio,raw);
% PreWakeIIStrengths = spikeTransfer_InPairSeries(Restrict(S,preWake),...
%     funcsynapses.ConnectionsII,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,byratio,raw);
% 
% PostWakeEStrengths = spikeTransfer_InPairSeries(Restrict(S,postWake),...
%     funcsynapses.ConnectionsE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,byratio,raw);
% PostWakeIStrengths = spikeTransfer_InPairSeries(Restrict(S,postWake),...
%     funcsynapses.ConnectionsI,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,byratio,raw);
% PostWakeEEStrengths = spikeTransfer_InPairSeries(Restrict(S,postWake),...
%     funcsynapses.ConnectionsEE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,byratio,raw);
% PostWakeEIStrengths = spikeTransfer_InPairSeries(Restrict(S,postWake),...
%     funcsynapses.ConnectionsEI,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,byratio,raw);
% PostWakeIEStrengths = spikeTransfer_InPairSeries(Restrict(S,postWake),...
%     funcsynapses.ConnectionsIE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,byratio,raw);
% PostWakeIIStrengths = spikeTransfer_InPairSeries(Restrict(S,postWake),...
%     funcsynapses.ConnectionsII,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,byratio,raw);


v2struct(TransferStrengthsOverSleep)
if raw
    rt = '-raw';
elseif byratio
    rt = '-normratio';
else
    rt = '-normratechg';
end
h = [];

% 
% FirstThirdPresleepREM = intersect(PrePostSleepMetaData.presleepREMlist, ...
%     find(End(intervals{5})<=EndFirstThirdPresleep));
% FirstPresleepREMEStrengths = Rate(Se,subset(intervals{5},FirstThirdPresleepREM));
% LastThirdPresleepREM = intersect(PrePostSleepMetaData.presleepREMlist, ...
%     find(Start(intervals{5})>=StartLastThirdPresleep));
% LastPresleepREMEStrengths = Rate(Se,subset(intervals{5},LastThirdPresleepREM));

%% Prepare data by eliminating cases of NaN or Inf or -Inf
[PreWakeEStrengths,PostWakeEStrengths] = ElimAnyNanInf(PreWakeEStrengths,PostWakeEStrengths);
[PreWakeIStrengths,PostWakeIStrengths] = ElimAnyNanInf(PreWakeIStrengths,PostWakeIStrengths);
[PreWakeEEStrengths,PostWakeEEStrengths] = ElimAnyNanInf(PreWakeEEStrengths,PostWakeEEStrengths);
[PreWakeEIStrengths,PostWakeEIStrengths] = ElimAnyNanInf(PreWakeEIStrengths,PostWakeEIStrengths);
[PreWakeIEStrengths,PostWakeIEStrengths] = ElimAnyNanInf(PreWakeIEStrengths,PostWakeIEStrengths);
[PreWakeIIStrengths,PostWakeIIStrengths] = ElimAnyNanInf(PreWakeIIStrengths,PostWakeIIStrengths);


%% Overall population normalized synapitc changes
h(end+1) = figure;
    subplot(1,2,1)
    plot_meanSD_bars(PreWakeEStrengths',PostWakeEStrengths');
    title(['E:Pre-Presleep Waking vs Post-Presleep Waking',rt])
    subplot(1,2,2)
    plot_meanSEM_bars(PreWakeEStrengths',PostWakeEStrengths');
    title('SEM')
    set(h(end),'name',[basename,'_EPopSynapseStrengthChanges-PreVsPostWake',rt])
h(end+1) = figure;
    subplot(1,2,1)
    plot_meanSD_bars(PreWakeIStrengths',PostWakeIStrengths');
    title(['I:Pre-Presleep Waking vs Post-Presleep Waking',rt])
    subplot(1,2,2)
    plot_meanSEM_bars(PreWakeIStrengths',PostWakeIStrengths');
    title('SEM')
    set(h(end),'name',[basename,'_IPopSynapseStrengthChanges-PreVsPostWake',rt])
h(end+1) = figure;
    subplot(1,2,1)
    plot_meanSD_bars(PreWakeEEStrengths',PostWakeEEStrengths');
    title(['EE:Pre-Presleep Waking vs Post-Presleep Waking',rt])
    subplot(1,2,2)
    plot_meanSEM_bars(PreWakeEEStrengths',PostWakeEEStrengths');
    title('SEM')
    set(h(end),'name',[basename,'_EEPopSynapseStrengthChanges-PreVsPostWake',rt])
h(end+1) = figure;
    subplot(1,2,1)
    plot_meanSD_bars(PreWakeEIStrengths',PostWakeEIStrengths');
    title(['EI:Pre-Presleep Waking vs Post-Presleep Waking',rt])
    subplot(1,2,2)
    plot_meanSEM_bars(PreWakeEIStrengths',PostWakeEIStrengths');
    title('SEM')
    set(h(end),'name',[basename,'_EIPopSynapseStrengthChanges-PreVsPostWake',rt])
h(end+1) = figure;
    subplot(1,2,1)
    plot_meanSD_bars(PreWakeIEStrengths',PostWakeIEStrengths');
    title(['IE:Pre-Presleep Waking vs Post-Presleep Waking',rt])
    subplot(1,2,2)
    plot_meanSEM_bars(PreWakeEStrengths',PostWakeIEStrengths');
    title('SEM')
    set(h(end),'name',[basename,'_IEPopSynapseStrengthChanges-PreVsPostWake',rt])
h(end+1) = figure;
    subplot(1,2,1)
    plot_meanSD_bars(PreWakeIIStrengths',PostWakeIIStrengths');
    title(['II:Pre-Presleep Waking vs Post-Presleep Waking',rt])
    subplot(1,2,2)
    plot_meanSEM_bars(PreWakeIIStrengths',PostWakeIIStrengths');
    title('SEM')
    set(h(end),'name',[basename,'_IIPopSynapseStrengthChanges-PreVsPostWake',rt])



%% Syn-by-Syn changes in rates over various intervals in various states 
%>(see BWRat20 analysis)
% use above to do simple 2 point plots for each comparison


h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(PreWakeEStrengths',PostWakeEStrengths');
    subplot(1,2,1)
    title(['E:Pre-Presleep Waking vs Post-Presleep Waking Per Synapse',rt])
    subplot(1,2,2)
    title('Log scale')
    set(h(end),'name',[basename,'_ESynapseStrengthChanges-PreVsPostWake',rt])

h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(PreWakeIStrengths',PostWakeIStrengths');
    subplot(1,2,1)
    title(['I:Pre-Presleep Waking vs Post-Presleep Waking Per Synapse',rt])
    subplot(1,2,2)
    title('Log scale')
    set(h(end),'name',[basename,'_ISynapseStrengthChanges-PreVsPostWake',rt])

h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(PreWakeEEStrengths',PostWakeEEStrengths');
    subplot(1,2,1)
    title(['EE:Pre-Presleep Waking vs Post-Presleep Waking Per Synapse',rt])
    subplot(1,2,2)
    title('Log scale')
    set(h(end),'name',[basename,'_EESynapseStrengthChanges-PreVsPostWake',rt])

h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(PreWakeEIStrengths',PostWakeEIStrengths');
    subplot(1,2,1)
    title(['EI:Pre-Presleep Waking vs Post-Presleep Waking Per Synapse',rt])
    subplot(1,2,2)
    title('Log scale')
    set(h(end),'name',[basename,'_EISynapseStrengthChanges-PreVsPostWake',rt])

h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(PreWakeIEStrengths',PostWakeIEStrengths');
    subplot(1,2,1)
    title(['IE:Pre-Presleep Waking vs Post-Presleep Waking Per Synapse',rt])
    subplot(1,2,2)
    title('Log scale')
    set(h(end),'name',[basename,'_IESynapseStrengthChanges-PreVsPostWake',rt])

h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(PreWakeIIStrengths',PostWakeIIStrengths');
    subplot(1,2,1)
    title(['II:Pre-Presleep Waking vs Post-Presleep Waking Per Synapse',rt])
    subplot(1,2,2)
    title('Log scale')
    set(h(end),'name',[basename,'_IISynapseStrengthChanges-PreVsPostWake',rt])



%looking at percent changes per cell
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

%histograms of those percent changes
h(end+1)=figure;
    hist(ESynPercentChangesPreWakeVsPostWake',50)
    title(['Histogram of E syn Percent Strength changes from: Wake before to After presleep',rt])
    set(h(end),'name',[basename,'_HistoOfESynRateChanges-PreVsPostWake',rt])
h(end+1)=figure;
    hist(ISynPercentChangesPreWakeVsPostWake',50)
    title(['Histogram of I syn Percent Strength changes from: Wake before to After presleep',rt])
    set(h(end),'name',[basename,'_HistoOfISynRateChanges-PreVsPostWake',rt])

h(end+1)=figure;
    hist(EESynAbsoluteChangesPreWakeVsPostWake',50)
    title(['Histogram of EE syn Absolute Strength changes from: Wake before to After presleep',rt])
    set(h(end),'name',[basename,'_HistoOfEESynRateChanges-PreVsPostWake',rt])
h(end+1)=figure;
    hist(EISynAbsoluteChangesPreWakeVsPostWake',50)
    title(['Histogram of EI syn Absolute Strength changes from: Wake before to After presleep',rt])
    set(h(end),'name',[basename,'_HistoOfEISynRateChanges-PreVsPostWake',rt])

h(end+1)=figure;
    hist(IESynPercentChangesPreWakeVsPostWake',50)
    title(['Histogram of IE syn Percent Strength changes from: Wake before to After presleep',rt])
    set(h(end),'name',[basename,'_HistoOfIESynRateChanges-PreVsPostWake',rt])
h(end+1)=figure;
    hist(IISynPercentChangesPreWakeVsPostWake',50)
    title(['Histogram of II syn Percent Strength changes from: Wake before to After presleep',rt])
    set(h(end),'name',[basename,'_HistoOfIISynRateChanges-PreVsPostWake',rt])

%percent change in relation to intial spike ratehttp://klusters.sourceforge.net/howto.html

% Wipe out the corrections done above
v2struct(TransferStrengthsOverSleep)


h(end+1)=figure;
    x = PreWakeEStrengths;
    y = ESynPercentChangesPreWakeVsPostWake;
    [x,y] = ElimAnyNanInf(x,y);

    plot(x,y,'marker','.','Line','none');
    [yfit,r2] =  RegressAndFindR2(x,y,1);
    hold on;plot(x,yfit,'r')
    text(0.8*max(x),0.8*max(y),['r2=',num2str(r2)])
    title(['ESyns Percent change in Syn Strength in pre vs post wake VS initial spike rate',rt])
    xlabel('Initial synapse strength')
    ylabel('Proportion of change')
    set(h(end),'name',[basename,'_ChangeInPrePostWakeVsInitialStrength-ESyns',rt])

h(end+1)=figure;
    x = PreWakeIStrengths;
    y = ISynPercentChangesPreWakeVsPostWake;
    [x,y] = ElimAnyNanInf(x,y);

    plot(x,y,'marker','.','Line','none');
    [yfit,r2] =  RegressAndFindR2(x,y,1);
    hold on;plot(x,yfit,'r')
    text(0.8*max(x),0.8*max(y),['r2=',num2str(r2)])
    title(['ISyns Percent change in Syn Strength in pre vs post wake VS initial spike rate',rt])
    xlabel('Initial synapse strength')
    ylabel('Proportion of change')
    set(h(end),'name',[basename,'_ChangeInPrePostWakeVsInitialStrength-ISyns',rt])

h(end+1)=figure;
    x = PreWakeEEStrengths;
    y = EESynPercentChangesPreWakeVsPostWake;
    [x,y] = ElimAnyNanInf(x,y);

    plot(x,y,'marker','.','Line','none');
    [yfit,r2] =  RegressAndFindR2(x,y,1);
    hold on;plot(x,yfit,'r')
    text(0.8*max(x),0.8*max(y),['r2=',num2str(r2)])
    title(['EESyns Percent change in Syn Strength in pre vs post wake VS initial spike rate',rt])
    xlabel('Initial synapse strength')
    ylabel('Proportion of change')
    set(h(end),'name',[basename,'_ChangeInPrePostWakeVsInitialStrength-EESyns',rt])

h(end+1)=figure;
    x = PreWakeEIStrengths;
    y = EISynPercentChangesPreWakeVsPostWake;
    [x,y] = ElimAnyNanInf(x,y);

    plot(x,y,'marker','.','Line','none');
    [yfit,r2] =  RegressAndFindR2(x,y,1);
    hold on;plot(x,yfit,'r')
    text(0.8*max(x),0.8*max(y),['r2=',num2str(r2)])
    title(['EISyns Percent change in Syn Strength in pre vs post wake VS initial spike rate',rt])
    xlabel('Initial synapse strength')
    ylabel('Proportion of change')
    set(h(end),'name',[basename,'_ChangeInPrePostWakeVsInitialStrength-EISyns',rt])

h(end+1)=figure;
    x = PreWakeIEStrengths;
    y = IESynPercentChangesPreWakeVsPostWake;
    [x,y] = ElimAnyNanInf(x,y);
    
    plot(x,y,'marker','.','Line','none');
    [yfit,r2] =  RegressAndFindR2(x,y,1);
    hold on;plot(x,yfit,'r')
    text(0.8*max(x),0.8*max(y),['r2=',num2str(r2)])
    title(['IESyns Percent change in Syn Strength in pre vs post wake VS initial spike rate',rt])
    xlabel('Initial synapse strength')
    ylabel('Proportion of change')
    set(h(end),'name',[basename,'_ChangeInPrePostWakeVsInitialStrength-IESyns',rt])

h(end+1)=figure;
    x = PreWakeIIStrengths;
    y = IISynPercentChangesPreWakeVsPostWake;
    [x,y] = ElimAnyNanInf(x,y);

    plot(x,y,'marker','.','Line','none');
    [yfit,r2] =  RegressAndFindR2(x,y,1);
    hold on;plot(x,yfit,'r')
    text(0.8*max(x),0.8*max(y),['r2=',num2str(r2)])
    title(['IISyns Percent change in Syn Strength in pre vs post wake VS initial spike rate',rt])
    xlabel('Initial synapse strength')
    ylabel('Proportion of change')
    set(h(end),'name',[basename,'_ChangeInPrePostWakeVsInitialStrength-IISyns',rt])

% load([basename '_SynRateVariables.mat'])
% 
% PrePostWakeTransferMeasures = v2struct(PreWakeEStrengths,PreWakeIStrengths,...
%     PreWakeEEStrengths,PreWakeEIStrengths,...
%     PreWakeIEStrengths,PreWakeIIStrengths,...
%     PostWakeEStrengths,PostWakeIStrengths,...
%     PostWakeEEStrengths,PostWakeEIStrengths,...
%     PostWakeIEStrengths,PostWakeIIStrengths,...
%     ESynPercentChangesPreWakeVsPostWake, ISynPercentChangesPreWakeVsPostWake,...
%     ESynAbsoluteChangesPreWakeVsPostWake, ISynAbsoluteChangesPreWakeVsPostWake,...
%     EESynPercentChangesPreWakeVsPostWake, EISynPercentChangesPreWakeVsPostWake,...
%     EESynAbsoluteChangesPreWakeVsPostWake, EISynAbsoluteChangesPreWakeVsPostWake,...
%     IESynPercentChangesPreWakeVsPostWake, IISynPercentChangesPreWakeVsPostWake,...
%     IESynAbsoluteChangesPreWakeVsPostWake, IISynAbsoluteChangesPreWakeVsPostWake);


function h = FirstLastThirdSleepPlots(TransferStrengthsOverSleep)
% SleepThirds = regIntervals(subset(WSW{1},2),3);
% FirstThird = SleepThirds{1};
% LastThird = SleepThirds{3};
% if raw
%     rt = '-raw';
% elseif byratio
%     rt = '-normratio';
% else
%     rt = '-normratechg';
% end
% 
% FirstThirdSleepEStrengths = spikeTransfer_InPairSeries(Restrict(S,FirstThird),...
%     funcsynapses.ConnectionsE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,byratio,raw);
% FirstThirdSleepIStrengths = spikeTransfer_InPairSeries(Restrict(S,FirstThird),...
%     funcsynapses.ConnectionsI,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,byratio,raw);
% FirstThirdSleepEEStrengths = spikeTransfer_InPairSeries(Restrict(S,FirstThird),...
%     funcsynapses.ConnectionsEE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,byratio,raw);
% FirstThirdSleepEIStrengths = spikeTransfer_InPairSeries(Restrict(S,FirstThird),...
%     funcsynapses.ConnectionsEI,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,byratio,raw);
% FirstThirdSleepIEStrengths = spikeTransfer_InPairSeries(Restrict(S,FirstThird),...
%     funcsynapses.ConnectionsIE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,byratio,raw);
% FirstThirdSleepIIStrengths = spikeTransfer_InPairSeries(Restrict(S,FirstThird),...
%     funcsynapses.ConnectionsII,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,byratio,raw);
% 
% LastThirdSleepEStrengths = spikeTransfer_InPairSeries(Restrict(S,LastThird),...
%     funcsynapses.ConnectionsE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,byratio,raw);
% LastThirdSleepIStrengths = spikeTransfer_InPairSeries(Restrict(S,LastThird),...
%     funcsynapses.ConnectionsI,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,byratio,raw);
% LastThirdSleepEEStrengths = spikeTransfer_InPairSeries(Restrict(S,LastThird),...
%     funcsynapses.ConnectionsEE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,byratio,raw);
% LastThirdSleepEIStrengths = spikeTransfer_InPairSeries(Restrict(S,LastThird),...
%     funcsynapses.ConnectionsEI,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,byratio,raw);
% LastThirdSleepIEStrengths = spikeTransfer_InPairSeries(Restrict(S,LastThird),...
%     funcsynapses.ConnectionsIE,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,byratio,raw);
% LastThirdSleepIIStrengths = spikeTransfer_InPairSeries(Restrict(S,LastThird),...
%     funcsynapses.ConnectionsII,funcsynapses,funcsynapses.CnxnStartTimesVsRefSpk,funcsynapses.CnxnEndTimesVsRefSpk,byratio,raw);
% 
% % 
% % FirstThirdPresleepREM = intersect(PrePostSleepMetaData.presleepREMlist, ...
% %     find(End(intervals{5})<=EndFirstThirdPresleep));
% % FirstPresleepREMEStrengths = Rate(Se,subset(intervals{5},FirstThirdPresleepREM));
% % LastThirdPresleepREM = intersect(PrePostSleepMetaData.presleepREMlist, ...
% %     find(Start(intervals{5})>=StartLastThirdPresleep));
% % LastPresleepREMEStrengths = Rate(Se,subset(intervals{5},LastThirdPresleepREM));

v2struct(TransferStrengthsOverSleep) %unpacks all variables needed below
if raw
    rt = '-raw';
elseif byratio
    rt = '-normratio';
else
    rt = '-normratechg';
end

h = [];
%% Prepare data by eliminating cases of NaN or Inf or -Inf
[FirstThirdSleepEStrengths,LastThirdSleepEStrengths] = ElimAnyNanInf(FirstThirdSleepEStrengths,LastThirdSleepEStrengths);    
[FirstThirdSleepIStrengths,LastThirdSleepIStrengths] = ElimAnyNanInf(FirstThirdSleepIStrengths,LastThirdSleepIStrengths);    
[FirstThirdSleepEEStrengths,LastThirdSleepEEStrengths] = ElimAnyNanInf(FirstThirdSleepEEStrengths,LastThirdSleepEEStrengths);    
[FirstThirdSleepEIStrengths,LastThirdSleepEIStrengths] = ElimAnyNanInf(FirstThirdSleepEIStrengths,LastThirdSleepEIStrengths);    
[FirstThirdSleepIEStrengths,LastThirdSleepIEStrengths] = ElimAnyNanInf(FirstThirdSleepIEStrengths,LastThirdSleepIEStrengths);    
[FirstThirdSleepIIStrengths,LastThirdSleepIIStrengths] = ElimAnyNanInf(FirstThirdSleepIIStrengths,LastThirdSleepIIStrengths);    


%% Overall population normalized synapitc changes
h(end+1) = figure;
    subplot(1,2,1)
    plot_meanSD_bars(FirstThirdSleepEStrengths',LastThirdSleepEStrengths');
    title(['E:First vs Last third of sleep population synapse strength',rt])
    subplot(1,2,2)
    plot_meanSEM_bars(PreWakeEStrengths',PostWakeEStrengths');
    title('SEM')
    set(h(end),'name',[basename,'_EPopSynapseStrengthChanges-FirstVsLastThirdSleep',rt])
h(end+1) = figure;
    subplot(1,2,1)
    plot_meanSD_bars(FirstThirdSleepIStrengths',LastThirdSleepIStrengths');
    title(['I:First vs Last third of sleep population synapse strength',rt])
    subplot(1,2,2)
    plot_meanSEM_bars(PreWakeIStrengths',PostWakeIStrengths');
    title('SEM')
    set(h(end),'name',[basename,'_IPopSynapseStrengthChanges-FirstVsLastThirdSleep',rt])
h(end+1) = figure;
    subplot(1,2,1)
    plot_meanSD_bars(FirstThirdSleepEEStrengths',LastThirdSleepEEStrengths');
    title(['EE:First vs Last third of sleep population synapse strength',rt])
    subplot(1,2,2)
    plot_meanSEM_bars(PreWakeEEStrengths',PostWakeEEStrengths');
    title('SEM')
    set(h(end),'name',[basename,'_EPopSynapseStrengthChanges-FirstVsLastThirdSleep',rt])
h(end+1) = figure;
    subplot(1,2,1)
    plot_meanSD_bars(FirstThirdSleepEIStrengths',LastThirdSleepEIStrengths');
    title(['EI:First vs Last third of sleep population synapse strength',rt])
    subplot(1,2,2)
    plot_meanSEM_bars(PreWakeEIStrengths',PostWakeEIStrengths');
    title('SEM')
    set(h(end),'name',[basename,'_EIPopSynapseStrengthChanges-FirstVsLastThirdSleep',rt])
h(end+1) = figure;
    subplot(1,2,1)
    plot_meanSD_bars(FirstThirdSleepIEStrengths',LastThirdSleepIEStrengths');
    title(['IE:First vs Last third of sleep population synapse strength',rt])
    subplot(1,2,2)
    plot_meanSEM_bars(PreWakeIEStrengths',PostWakeIEStrengths');
    title('SEM')
    set(h(end),'name',[basename,'_IEPopSynapseStrengthChanges-FirstVsLastThirdSleep',rt])
h(end+1) = figure;
    subplot(1,2,1)
    plot_meanSD_bars(FirstThirdSleepIIStrengths',LastThirdSleepIIStrengths');
    title(['II:First vs Last third of sleep population synapse strength',rt])
    subplot(1,2,2)
    plot_meanSEM_bars(PreWakeIIStrengths',PostWakeIIStrengths');
    title('SEM')
    set(h(end),'name',[basename,'_IIPopSynapseStrengthChanges-FirstVsLastThirdSleep',rt])

    
%% Syn-by-cell changes in rates over various intervals in various states 
h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(FirstThirdSleepEStrengths',LastThirdSleepEStrengths');
    subplot(1,2,1)
    title(['E:First vs Last Third of sleep Strength Per Synapse',rt])
    subplot(1,2,2)
    title('Log scale')
    set(h(end),'name',[basename,'_ESynapseStrengthChanges-FirstVsLastThirdSleep',rt])

h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(FirstThirdSleepIStrengths',LastThirdSleepIStrengths');
    subplot(1,2,1)
    title(['I:First vs Last Third of sleep Strength Per Synapse',rt])
    subplot(1,2,2)
    title('Log scale')
    set(h(end),'name',[basename,'_ISynapseStrengthChanges-FirstVsLastThirdSleep',rt])

h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(FirstThirdSleepEEStrengths',LastThirdSleepEEStrengths');
    subplot(1,2,1)
    title(['EE:First vs Last Third of sleep Strength Per Synapse',rt])
    subplot(1,2,2)
    title('Log scale')
    set(h(end),'name',[basename,'_EESynapseStrengthChanges-FirstVsLastThirdSleep',rt])

h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(FirstThirdSleepEIStrengths',LastThirdSleepEIStrengths');
    subplot(1,2,1)
    title(['EI:First vs Last Third of sleep Strength Per Synapse',rt])
    subplot(1,2,2)
    title('Log scale')
    set(h(end),'name',[basename,'_EISynapseStrengthChanges-FirstVsLastThirdSleep',rt])

h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(FirstThirdSleepIEStrengths',LastThirdSleepIEStrengths');
    subplot(1,2,1)
    title(['IE:First vs Last Third of sleep Strength Per Synapse',rt])
    subplot(1,2,2)
    title('Log scale')
    set(h(end),'name',[basename,'_IESynapseStrengthChanges-FirstVsLastThirdSleep',rt])

h(end+1) = SpikingAnalysis_PairsPlotsWMeanLinearAndLog(FirstThirdSleepIIStrengths',LastThirdSleepIIStrengths');
    subplot(1,2,1)
    title(['II:First vs Last Third of sleep Strength Per Synapse',rt])
    subplot(1,2,2)
    title('Log scale')
    set(h(end),'name',[basename,'_IISynapseStrengthChanges-FirstVsLastThirdSleep',rt])

% 
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
% 

%histograms of those percent changes
h(end+1)=figure;
    hist(ESynPercentChangesFirstVsLastThirdSleep',50)
    title(['Histogram of E syn Percent Strength changes from: First to Last Third of Sleep',rt])
    set(h(end),'name',[basename,'_HistoOfESynRateChanges-FirstVsLastThirdSleep',rt])
h(end+1)=figure;
    hist(ISynPercentChangesFirstVsLastThirdSleep',50)
    title(['Histogram of I syn Percent Strength changes from: First to Last Third of Sleep',rt])
    set(h(end),'name',[basename,'_HistoOfISynRateChanges-FirstVsLastThirdSleep',rt])

h(end+1)=figure;
    hist(EESynAbsoluteChangesFirstVsLastThirdSleep',50)
    title(['Histogram of EE syn Absolute Strength changes from: First to Last Third of Sleep',rt])
    set(h(end),'name',[basename,'_HistoOfEESynRateChanges-FirstVsLastThirdSleep',rt])
h(end+1)=figure;
    hist(EISynAbsoluteChangesFirstVsLastThirdSleep',50)
    title(['Histogram of EI syn Absolute Strength changes from: First to Last Third of Sleep',rt])
    set(h(end),'name',[basename,'_HistoOfEISynRateChanges-FirstVsLastThirdSleep',rt])

h(end+1)=figure;
    hist(IESynPercentChangesFirstVsLastThirdSleep',50)
    title(['Histogram of IE syn Percent Strength changes from: First to Last Third of Sleep',rt])
    set(h(end),'name',[basename,'_HistoOfIESynRateChanges-FirstVsLastThirdSleep',rt])
h(end+1)=figure;
    hist(IISynPercentChangesFirstVsLastThirdSleep',50)
    title(['Histogram of II syn Percent Strength changes from: First to Last Third of Sleep',rt])
    set(h(end),'name',[basename,'_HistoOfIISynRateChanges-FirstVsLastThirdSleep',rt])

%percent change in relation to intial spike rate
% Wipe out the corrections done above
v2struct(TransferStrengthsOverSleep)

h(end+1)=figure;
    x = FirstThirdSleepEStrengths;
    y = ESynPercentChangesFirstVsLastThirdSleep;
    [x,y] = ElimAnyNanInf(x,y);

    plot(x,y,'marker','.','Line','none');
    [yfit,r2] =  RegressAndFindR2(x,y,1);
    hold on;plot(x,yfit,'r')
    text(0.8*max(x),0.8*max(y),['r2=',num2str(r2)])
    title(['ESyns Percent change in Syn Strength in first vs last third sleep VS initial spike rate',rt])
    xlabel('Initial synapse strength')
    ylabel('Proportion of change')
    set(h(end),'name',[basename,'_ChangeInSleepThirdsVsInitialStrength-ESyns',rt])

h(end+1)=figure;
    x = FirstThirdSleepIStrengths;
    y = ISynPercentChangesFirstVsLastThirdSleep;
    [x,y] = ElimAnyNanInf(x,y);

    plot(x,y,'marker','.','Line','none');
    [yfit,r2] =  RegressAndFindR2(x,y,1);
    hold on;plot(x,yfit,'r')
    text(0.8*max(x),0.8*max(y),['r2=',num2str(r2)])
    title(['ISyns Percent change in Syn Strength in first vs last third sleep VS initial spike rate',rt])
    xlabel('Initial synapse strength')
    ylabel('Proportion of change')
    set(h(end),'name',[basename,'_ChangeInSleepThirdsVsInitialStrength-ISyns',rt])

h(end+1)=figure;
    x = FirstThirdSleepEEStrengths;
    y = EESynPercentChangesFirstVsLastThirdSleep;
    [x,y] = ElimAnyNanInf(x,y);

    plot(x,y,'marker','.','Line','none');
    [yfit,r2] =  RegressAndFindR2(x,y,1);
    hold on;plot(x,yfit,'r')
    text(0.8*max(x),0.8*max(y),['r2=',num2str(r2)])
    title(['EESyns Percent change in Syn Strength in first vs last third sleep VS initial spike rate',rt])
    xlabel('Initial synapse strength')
    ylabel('Proportion of change')
    set(h(end),'name',[basename,'_ChangeInSleepThirdsVsInitialStrength-EESyns',rt])

h(end+1)=figure;
    x = FirstThirdSleepEIStrengths;
    y = EISynPercentChangesFirstVsLastThirdSleep;
    [x,y] = ElimAnyNanInf(x,y);

    plot(x,y,'marker','.','Line','none');
    [yfit,r2] =  RegressAndFindR2(x,y,1);
    hold on;plot(x,yfit,'r')
    text(0.8*max(x),0.8*max(y),['r2=',num2str(r2)])
    title(['EISyns Percent change in Syn Strength in first vs last third sleep VS initial spike rate',rt])
    xlabel('Initial synapse strength')
    ylabel('Proportion of change')
    set(h(end),'name',[basename,'_ChangeInSleepThirdsVsInitialStrength-EISyns',rt])

h(end+1)=figure;
    x = FirstThirdSleepIEStrengths;
    y = IESynPercentChangesFirstVsLastThirdSleep;
    [x,y] = ElimAnyNanInf(x,y);

    plot(x,y,'marker','.','Line','none');
    [yfit,r2] =  RegressAndFindR2(x,y,1);
    hold on;plot(x,yfit,'r')
    text(0.8*max(x),0.8*max(y),['r2=',num2str(r2)])
    title(['IESyns Percent change in Syn Strength in first vs last third sleep VS initial spike rate',rt])
    xlabel('Initial synapse strength')
    ylabel('Proportion of change')
    set(h(end),'name',[basename,'_ChangeInSleepThirdsVsInitialStrength-IESyns',rt])

h(end+1)=figure;
    x = FirstThirdSleepIIStrengths;
    y = IISynPercentChangesFirstVsLastThirdSleep;
    [x,y] = ElimAnyNanInf(x,y);
    
    plot(x,y,'marker','.','Line','none');
    [yfit,r2] =  RegressAndFindR2(x,y,1);
    hold on;plot(x,yfit,'r')
    text(0.8*max(x),0.8*max(y),['r2=',num2str(r2)])
    title(['IISyns Percent change in Syn Strength in first vs last third sleep VS initial spike rate',rt])
    xlabel('Initial synapse strength')
    ylabel('Proportion of change')
    set(h(end),'name',[basename,'_ChangeInSleepThirdsVsInitialStrength-IISyns',rt])
% 
% % load([basename '_SynRateVariables.mat'])
% 
% FirstLastThirdSleepTransferMeasures = v2struct(FirstThirdSleepEStrengths,FirstThirdSleepIStrengths,...
%     FirstThirdSleepEEStrengths,FirstThirdSleepEIStrengths,...
%     FirstThirdSleepIEStrengths,FirstThirdSleepIIStrengths,...
%     LastThirdSleepEStrengths,LastThirdSleepIStrengths,...
%     LastThirdSleepEEStrengths,LastThirdSleepEIStrengths,...
%     LastThirdSleepIEStrengths,LastThirdSleepIIStrengths,...
%     ESynPercentChangesFirstVsLastThirdSleep, ISynPercentChangesFirstVsLastThirdSleep,...
%     ESynAbsoluteChangesFirstVsLastThirdSleep, ISynAbsoluteChangesFirstVsLastThirdSleep,...
%     EESynPercentChangesFirstVsLastThirdSleep, EISynPercentChangesFirstVsLastThirdSleep,...
%     EESynAbsoluteChangesFirstVsLastThirdSleep, EISynAbsoluteChangesFirstVsLastThirdSleep,...
%     IESynPercentChangesFirstVsLastThirdSleep, IISynPercentChangesFirstVsLastThirdSleep,...


function [x,y] = ElimAnyNanInf(x,y)

bad = any(isnan(cat(1,x,y)),1) | any((cat(1,x,y)==Inf),1)| any((cat(1,x,y)==-Inf),1);
x = x(~bad);
y = y(~bad);



%     IESynAbsoluteChangesFirstVsLastThirdSleep, IISynAbsoluteChangesFirstVsLastThirdSleep);