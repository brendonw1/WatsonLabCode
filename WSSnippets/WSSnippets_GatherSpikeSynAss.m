function WSSnippets_GatherSpikeSynIAss(ep1,ep2)
% Gathers vector traces and medians of spike rates, Synaptic Timescale 
% Correlations and wake-generated assembly projections from timespans 
% around Wake-Sleep Episodes. 
% Available inputs to specify times around WS:
%         - '5mIn' - gather first 5min IN sleep vs last 5 IN sleep
%         - '5mInSWS' - gather first 5min SWS min vs last 5 SWS min
%         - '5mOut' - gather last 5min wake BEFORE sleep vs first 5 min wake AFTER sleep
%         - 'FLSWS' - gather first vs last SWS episodes
%         - '13SWS' - gather SWS from vs vs last third of sleep
%         - 'WakeBA' - Look at wake before vs wake after
%
% Brendon Watson 2015

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

if ~exist('ep1','var')
    ep1 = '13sws';
end
if ~exist('ep2','var')
    ep2 = '[]';
end

if isnumeric(ep1)
    ep1str = inputdlg('Enter string to depict snippet timing');
else
    ep1str = ep1;
end


mkdir(fullfile(basepath,'WSSnippets'))
mkdir(fullfile(basepath,'WSSnippets',ep1str))

%% Spikes
%Extract
load(fullfile(basepath,[basename '_SSubtypes.mat']));
[preSpikesE,postSpikesE] = GatherVectorsFromEpochPairs(Se,ep1,ep2);
[preSpikesI,postSpikesI] = GatherVectorsFromEpochPairs(Si,ep1,ep2);

ESpkh = [];
ISpkh = [];
% Prep & Plot simple per-cell vector medians
for a = 1:length(preSpikesE) % for each WS
    ESpkr{a} = [];
    ESpkp{a} = [];
    ESpkcoeffs{a} = [];
    ISpkr{a} = [];
    ISpkp{a} = [];
    ISpkcoeffs{a} = [];

    ratePreSpikesE(:,a) = Rate(preSpikesE{a});
    ratePostSpikesE(:,a) = Rate(postSpikesE{a});
    ratePreSpikesI(:,a) = Rate(preSpikesI{a});
    ratePostSpikesI(:,a) = Rate(postSpikesI{a});

    eval(['ECellRatesPreWS' num2str(a) '  = ratePreSpikesE(:,a);'])
    eval(['ECellRatesPostWS' num2str(a) ' = ratePostSpikesE(:,a);'])
    eval(['[th,tr,tp,tcoeffs] = PlotPrePost(ECellRatesPreWS' num2str(a) ',ECellRatesPostWS' num2str(a) ');'])
    ESpkh = cat(1,ESpkh,th(:));
    ESpkr{a} = cat(1,ESpkr{a},tr);ESpkp{a} = cat(1,ESpkp{a},tp);ESpkcoeffs{a} = cat(2,ESpkcoeffs{a},tcoeffs);
    
    eval(['ICellRatesPreWS' num2str(a) '  = ratePreSpikesI(:,a);'])
    eval(['ICellRatesPostWS' num2str(a) ' = ratePostSpikesI(:,a);'])
    eval(['[th,tr,tp,tcoeffs] = PlotPrePost(ICellRatesPreWS' num2str(a) ',ICellRatesPostWS' num2str(a) ');'])
    ISpkh = cat(1,ISpkh,th);
    ISpkr{a} = cat(1,ISpkr{a},tr);ISpkp{a} = cat(1,ISpkp{a},tp);ISpkcoeffs{a} = cat(2,ISpkcoeffs{a},tcoeffs);

%     % Save
%     ... in some new folder PrePostJune2015
%     save figs
%     save rates
end

%saving Spike stuff
figsavedir = fullfile(basepath,'WSSnippets',ep1str,'SpikeRateFigs');
savefilename = fullfile(basepath,'WSSnippets',ep1str,[basename '_SpikeRateWSSnippets']);

mkdir(figsavedir)
MakeDirSaveFigsThereAs(figsavedir,ESpkh,'fig')
MakeDirSaveFigsThereAs(figsavedir,ISpkh,'fig')
SpikeRateWSSnippets = v2struct(preSpikesE,postSpikesE,preSpikesI,postSpikesI,... %raw tsdarray vectors
    ratePreSpikesE,ratePostSpikesE,ratePreSpikesI,ratePostSpikesI,... %cell-wise rates
    ESpkr, ESpkp, ESpkcoeffs, ISpkr, ISpkp, ISpkcoeffs);%correlation/fit data
save(savefilename,'SpikeRateWSSnippets')

%% Synapse stuff
%Extract
load(fullfile(basepath,[basename '_SpikeTransferPer1MinuteE.mat']));
load(fullfile(basepath,[basename '_SpikeTransferPer1MinuteI.mat']));
[preSynapseRatiosETsds,postSynapseRatiosETsds] = GatherVectorsFromEpochPairs(SpikeTransferPer1MinuteE.ratios,ep1,ep2,60);
[preSynapseRatiosITsds,postSynapseRatiosITsds] = GatherVectorsFromEpochPairs(SpikeTransferPer1MinuteI.ratios,ep1,ep2,60);
[preSynapseDiffsETsds,postSynapseDiffsETsds] = GatherVectorsFromEpochPairs(SpikeTransferPer1MinuteE.ratechgs,ep1,ep2,60);
[preSynapseDiffsITsds,postSynapseDiffsITsds] = GatherVectorsFromEpochPairs(SpikeTransferPer1MinuteI.ratechgs,ep1,ep2,60);

EsynRatioh = [];
EsynDiffh = [];
IsynRatioh = [];
IsynDiffh = [];

% Prep
for a = 1:length(preSynapseRatiosETsds)%for each epoch
    EsynRatior{a} = [];
    EsynRatiop{a} = [];
    EsynRatiocoeffs{a} = [];
    EsynDiffr{a} = [];
    EsynDiffp{a} = [];
    EsynDiffcoeffs{a} = [];

    IsynRatior{a} = [];
    IsynRatiop{a} = [];
    IsynRatiocoeffs{a} = [];
    IsynDiffr{a} = [];
    IsynDiffp{a} = [];
    IsynDiffcoeffs{a} = [];
    
    preSynapseRatiosE{a} = DataFromAlignedTsdArray(preSynapseRatiosETsds{a});
    postSynapseRatiosE{a} = DataFromAlignedTsdArray(postSynapseRatiosETsds{a});
    preSynapseDiffsE{a} = DataFromAlignedTsdArray(preSynapseDiffsETsds{a});
    postSynapseDiffsE{a} = DataFromAlignedTsdArray(postSynapseDiffsETsds{a});

    medianPreSynapseRatiosE(:,a) = nanmedian(preSynapseRatiosE{a});
    medianPostSynapseRatiosE(:,a) = nanmedian(postSynapseRatiosE{a});
    medianPreSynapseDiffsE(:,a) = nanmedian(preSynapseDiffsE{a});
    medianPostSynapseDiffsE(:,a) = nanmedian(postSynapseDiffsE{a});

    preSynapseRatiosI{a} = DataFromAlignedTsdArray(preSynapseRatiosITsds{a});
    postSynapseRatiosI{a} = DataFromAlignedTsdArray(postSynapseRatiosITsds{a});
    preSynapseDiffsI{a} = DataFromAlignedTsdArray(preSynapseDiffsITsds{a});
    postSynapseDiffsI{a} = DataFromAlignedTsdArray(postSynapseDiffsITsds{a});

    medianPreSynapseRatiosI(:,a) = nanmedian(preSynapseRatiosI{a});
    medianPostSynapseRatiosI(:,a) = nanmedian(postSynapseRatiosI{a});
    medianPreSynapseDiffsI(:,a) = nanmedian(preSynapseDiffsI{a});
    medianPostSynapseDiffsI(:,a) = nanmedian(postSynapseDiffsI{a});

    % Plot and save fit stats
    eval(['ESynapseMeanRatiosPreWS' num2str(a) ' = medianPreSynapseRatiosE(:,a);'])
    eval(['ESynapseMeanRatiosPostWS' num2str(a) ' = medianPostSynapseRatiosE(:,a);'])
    eval(['[th,tr,tp,tcoeffs] = PlotPrePost(ESynapseMeanRatiosPreWS' num2str(a) ',ESynapseMeanRatiosPostWS' num2str(a) ');'])
    EsynRatioh = cat(1,EsynRatioh(:),th(:));
    EsynRatior{a} = cat(1,EsynRatior{a},tr);EsynRatiop{a} = cat(1,EsynRatiop{a},tp);EsynRatiocoeffs{a} = cat(2,EsynRatiocoeffs{a},tcoeffs);

    eval(['ISynapseMeanRatiosPreWS' num2str(a) ' = medianPreSynapseRatiosI(:,a);'])
    eval(['ISynapseMeanRatiosPostWS' num2str(a) ' = medianPostSynapseRatiosI(:,a);'])
    eval(['[th,tr,tp,tcoeffs] = PlotPrePost(ISynapseMeanRatiosPreWS' num2str(a) ',ISynapseMeanRatiosPostWS' num2str(a) ');'])
    IsynRatioh = cat(1,IsynRatioh(:),th(:));
    IsynRatior{a} = cat(1,IsynRatior{a},tr);IsynRatiop{a} = cat(1,IsynRatiop{a},tp);IsynRatiocoeffs{a} = cat(2,IsynRatiocoeffs{a},tcoeffs);

    eval(['ESynapseMeanDiffsPreWS' num2str(a) ' = medianPreSynapseDiffsE(:,a);'])
    eval(['ESynapseMeanDiffsPostWS' num2str(a) ' = medianPostSynapseDiffsE(:,a);'])
    eval(['[th,tr,tp,tcoeffs] = PlotPrePost(ESynapseMeanDiffsPreWS' num2str(a) ',ESynapseMeanDiffsPostWS' num2str(a) ');'])
    EsynDiffh = cat(1,EsynDiffh(:),th(:));
    EsynDiffr{a} = cat(1,EsynDiffr{a},tr);EsynDiffp{a} = cat(1,EsynDiffp{a},tp);EsynDiffcoeffs{a} = cat(2,EsynDiffcoeffs{a},tcoeffs);

    eval(['ISynapseMeanDiffsPreWS' num2str(a) ' = medianPreSynapseDiffsI(:,a);'])
    eval(['ISynapseMeanDiffsPostWS' num2str(a) ' = medianPostSynapseDiffsI(:,a);'])
    eval(['[th,tr,tp,tcoeffs] = PlotPrePost(ISynapseMeanDiffsPreWS' num2str(a) ',ISynapseMeanDiffsPostWS' num2str(a) ');'])
    IsynDiffh = cat(1,IsynDiffh(:),th(:));
    IsynDiffr{a} = cat(1,IsynDiffr{a},tr);IsynDiffp{a} = cat(1,IsynDiffp{a},tp);IsynDiffcoeffs{a} = cat(2,IsynDiffcoeffs{a},tcoeffs);
end

%saving Spike stuff
figsavedir = fullfile(basepath,'WSSnippets',ep1str,'SynapseDataFigs');
savefilename = fullfile(basepath,'WSSnippets',ep1str,[basename '_SynCorrWSSnippets']);

mkdir(figsavedir)
MakeDirSaveFigsThereAs(figsavedir,EsynRatioh,'fig')
MakeDirSaveFigsThereAs(figsavedir,EsynDiffh,'fig')
MakeDirSaveFigsThereAs(figsavedir,IsynRatioh,'fig')
MakeDirSaveFigsThereAs(figsavedir,IsynDiffh,'fig')

SynCorrWSSnippets = v2struct(preSynapseRatiosETsds,postSynapseRatiosETsds,...
    preSynapseRatiosITsds,postSynapseRatiosITsds,preSynapseDiffsETsds,postSynapseDiffsETsds,...
    preSynapseDiffsITsds,postSynapseDiffsITsds,...
    preSynapseRatiosE,postSynapseRatiosE,preSynapseDiffsE, postSynapseDiffsE,...
    preSynapseRatiosI,postSynapseRatiosI,preSynapseDiffsI,postSynapseDiffsI,...
    medianPreSynapseRatiosE,medianPostSynapseRatiosE,medianPreSynapseDiffsE,medianPostSynapseDiffsE,...
    medianPreSynapseRatiosI,medianPostSynapseRatiosI,medianPreSynapseDiffsI,medianPostSynapseDiffsI,...
    EsynRatior,EsynRatiop,EsynRatiocoeffs,EsynDiffr,EsynDiffp,EsynDiffcoeffs,...
    IsynRatior,IsynRatiop,IsynRatiocoeffs,IsynDiffr,IsynDiffp,IsynDiffcoeffs);
save(savefilename,'SynCorrWSSnippets')


%% Assemblies - Written as of now to grab ICA-based 100sec bin E-cell only assemblies
t = load(fullfile(basepath,'Assemblies','WakeBasedICA','AssemblyBasicDataWakeDetect'));
aa = t.AssemblyBasicDataWakeDetect.AssemblyActivities;
[preWakeBIAss,postWakeBIAss] = GatherVectorsFromEpochPairs(aa,ep1,ep2);

WakeBIAssh = [];

% Prep & Plot simple per-cell vector medians
for a = 1:length(preWakeBIAss) % for each WS
    WakeBIAssr{a} = [];
    WakeBIAssp{a} = [];
    WakeBIAsscoeffs{a} = [];

    for b = 1:length(preWakeBIAss{a})
        medianPreWakeBIAss(b,a) = nanmedian(Data(preWakeBIAss{a}{b}));
        medianPostWakeBIAss(b,a) = nanmedian(Data(postWakeBIAss{a}{b}));
    end
    
    eval(['WakeBasedICAAssPreActWS' num2str(a) ' = medianPreWakeBIAss(:,a);'])
    eval(['WakeBasedICAAssPostActWS' num2str(a) ' = medianPostWakeBIAss(:,a);'])
    eval(['[th,tr,tp,tcoeffs] = PlotPrePost(WakeBasedICAAssPreActWS' num2str(a) ',WakeBasedICAAssPostActWS' num2str(a) ');'])
    WakeBIAssh = cat(1,WakeBIAssh,th(:));
    WakeBIAssr{a} = cat(1,WakeBIAssr{a},tr);WakeBIAssp{a} = cat(1,WakeBIAssp{a},tp);WakeBIAsscoeffs{a} = cat(2,WakeBIAsscoeffs{a},tcoeffs);
end

%saving Spike stuff
figsavedir = fullfile(basepath,'WSSnippets',ep1str,'WakeBIAssFigs');
savefilename = fullfile(basepath,'WSSnippets',ep1str,[basename '_WakeBIAssWSSnippets']);

mkdir(figsavedir)
MakeDirSaveFigsThereAs(figsavedir,WakeBIAssh,'fig')
WakeBIAssWSSnippets = v2struct(preWakeBIAss,postWakeBIAss,... %raw tsdarray vectors
    medianPreWakeBIAss,medianPostWakeBIAss,... %cell-wise rates
    WakeBIAssr, WakeBIAssp, WakeBIAsscoeffs);%correlation/fit data
save(savefilename,'WakeBIAssWSSnippets')

