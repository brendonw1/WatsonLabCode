function SynCorrWSSnippets = WSSnippets_SynapseStrengths(basepath,basename,ep1,ep2,plotting,mode)
% Gathers vector traces and medians of synaptic timescale correlations from
% timespans around Wake-Sleep Episodes. 
% Available inputs to specify times around WS:
%         - '5mIn' - gather first 5min IN sleep vs last 5 IN sleep
%         - '5mInSWS' - gather first 5min SWS min vs last 5 SWS min
%         - '5mOut' - gather last 5min wake BEFORE sleep vs first 5 min wake AFTER sleep
%         - 'FLSWS' - gather first vs last SWS episodes
%         - '13SWS' - gather SWS from vs vs last third of sleep
%         - 'WakeB' - Look at wake before 
%         - 'WSSleep' - Look at all of sleep in a given WS episode
%         - 'WSSWS' - Look at all SWS in a given WS episode
%         - 'WWSREM' - Look at all REM in a given WS episode
%
% mode input can be either tsd or singlepoint.  Single point is default and
%     gathers strength of each synapse within the given epoch.  tsd creates a
%     timeseries of points, one for each minute, based on
%     _SpikeTransferPer1MinuteE.
% Brendon Watson 2015

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end
if ~exist('ep1','var')
    ep1 = 'FLSWS';
end
if ~exist('ep2','var')
    ep2 = '[]';
end

if isnumeric(ep1)
    ep1str = inputdlg('Enter string to depict snippet timing');
else
    ep1str = ep1;
end

if ~exist('plotting','var')
    plotting = 0;
end
if ~exist('mode','var')
    mode = 'singlepoint';
end

warning off
mkdir(fullfile(basepath,'WSSnippets'))
mkdir(fullfile(basepath,'WSSnippets',ep1str))
warning on

typenames = {'E','I','EE','EI','IE','II'};
load(fullfile(basepath,[basename '_SpikeTransferPer1MinuteAll.mat']));

%% Extract
switch mode
    case 'tsd'
        for ix = 1:length(typenames);
            n = typenames{ix};
            eval(['t = SpikeTransferPer1MinuteAll.' n ';'])

            eval(['[preSynapseRatios' n 'Tsds,postSynapseRatios' n 'Tsds] = VectorsFromEpochPairs(t.ratios,ep1,ep2,60);'])
            eval(['[preSynapseDiffs' n 'Tsds,postSynapseDiffs' n 'Tsds] = VectorsFromEpochPairs(t.ratechgs,ep1,ep2,60);'])
            eval(['numWS = size(preSynapseRatios' n ',2);'])
            eval(['neps = length(preSynapseRatios' n 'Tsds);')
            for a = 1:neps%for each epoch get medians
                eval(['preSynapseRatios' n '{a} = DataFromAlignedTsdArray(preSynapseRatios' n 'Tsds{a});'])
                eval(['postSynapseRatios' n '{a} = DataFromAlignedTsdArray(postSynapseRatios' n 'Tsds{a});'])
                eval(['preSynapseDiffs' n '{a} = DataFromAlignedTsdArray(preSynapseDiffs' n 'Tsds{a});'])
                eval(['postSynapseDiffs' n '{a} = DataFromAlignedTsdArray(postSynapseDiffs' n 'Tsds{a});'])

                eval(['medianPreSynapseRatios' n '(:,a) = nanmedian(preSynapseRatios' n '{a},1);'])
                eval(['medianPostSynapseRatios' n '(:,a) = nanmedian(postSynapseRatios' n '{a},1);'])
                eval(['medianPreSynapseDiffs' n '(:,a) = nanmedian(preSynapseDiffs' n '{a},1);'])
                eval(['medianPostSynapseDiffs' n '(:,a) = nanmedian(postSynapseDiffs' n '{a},1);'])
            end
            if ix == 1;
                SynCorrWSSnippets = v2struct(ep1str,numWS);
            end
            eval(['SynCorrWSSnippets.preSynapseRatios' n 'Tsds = preSynapseRatios' n 'Tsds']);
            eval(['SynCorrWSSnippets.postSynapseRatios' n 'Tsds = postSynapseRatios' n 'Tsds']);
            eval(['SynCorrWSSnippets.preSynapseDiffs' n 'Tsds = preSynapseDiffs' n 'Tsds']);
            eval(['SynCorrWSSnippets.postSynapseDiffs' n 'Tsds = postSynapseDiffs' n 'Tsds']);
            eval(['SynCorrWSSnippets.preSynapseRatios' n ' = preSynapseRatios' n ';']);
            eval(['SynCorrWSSnippets.postSynapseRatios' n ' = postSynapseRatios' n ';']);
            eval(['SynCorrWSSnippets.preSynapseDiffs' n ' = preSynapseDiffs' n ';']);
            eval(['SynCorrWSSnippets.postSynapseDiffs' n ' = postSynapseDiffs' n ';']);
            eval(['SynCorrWSSnippets.medianPreSynapseRatios' n ' = medianPreSynapseRatios' n ';']);
            eval(['SynCorrWSSnippets.medianPostSynapseRatios' n ' = medianPostSynapseRatios' n ';']);
            eval(['SynCorrWSSnippets.medianPreSynapseDiffs' n ' = medianPreSynapseDiffs' n ';']);
            eval(['SynCorrWSSnippets.medianPostSynapseDiffs' n ' = medianPostSynapseDiffs' n ';']);
        end
    case 'singlepoint'
            ints = load(fullfile(basepath,[basename '_WSRestrictedIntervals']));
            WSEpisodes = ints.WakeSleep;
            [ep1,ep2] = PrePostIntervalTimes(WSEpisodes,ints,ep1,ep2,basepath,basename);%gives intervalsets for each WS

            t = load(fullfile(basepath,[basename '_SStable.mat']));
            S = t.S;

            t = load(fullfile(basepath,[basename '_funcsynapsesMoreStringent.mat']));
            funcsynapses = t.funcsynapses;
            shank = funcsynapses.CellShanks;
            ConnectionStarts = funcsynapses.CnxnStartTimesVsRefSpk;
            ConnectionEnds = funcsynapses.CnxnEndTimesVsRefSpk;
            Flips = funcsynapses.FlippedCnxns;

        for ix = 1:length(typenames);
            n = typenames{ix};
            eval(['Pairs = funcsynapses.Connections' n ';')
    %         EPairs = 1:size(funcsynapses.ConnectionsE,1);
            if isempty(Pairs)
                eval(['medianPreSynapseRatios' n ' = [];'])
                eval(['medianPostSynapseRatios' n ' = [];'])
                eval(['medianPreSynapseDiffs' n ' = [];'])
                eval(['medianPostSynapseDiffs' n ' = [];'])
            else
                for a = 1:length(ep1)%loop through WS Episodes
                    eval(['[Preccgs' n '(:,:,a),Prestrengthbyratios' n '(a,:),Prestrengthbyratechgs' n '(a,:),Preexpecteds' n '(a,:),Premeasureds' n '(a,:),Prenumprespikes' n '(a,:),Prenumpostspikes' n '(a,:)] = ' ...
                        'LocalGrabIntervalCCGCorrOverAllPairs(S,Pairs,ConnectionStarts,ConnectionEnds,Flips,shank,ep1{a});'])
                    eval(['[Postccgs' n '(:,:,a),Poststrengthbyratios' n '(a,:),Poststrengthbyratechgs' n '(a,:),Postexpecteds' n '(a,:),Postmeasureds' n '(a,:),Postnumprespikes' n '(a,:),Postnumpostspikes' n '(a,:)] = ' ...
                        'LocalGrabIntervalCCGCorrOverAllPairs(S,Pairs,ConnectionStarts,ConnectionEnds,Flips,shank,ep2{a});'])
                end        
                eval(['medianPreSynapseRatios' n ' = Prestrengthbyratios' n ''';'])
                eval(['medianPostSynapseRatios' n ' = PoststrengthbyratiosE' n ''';'])
                eval(['medianPreSynapseDiffs' n ' = Prestrengthbyratechgs' n ''';'])
                eval(['medianPostSynapseDiffs' n ' = Poststrengthbyratechgs' n ''';'])
            end
        end
        
        numWS = length(ep1);
        if ix == 1;
             SynCorrWSSnippets = v2struct(ep1str,numWS);
        end
        eval(['SynCorSnippets.' n 'Pairs = Pairs;'])
        eval(['SynCorSnippets.medianPreSynapseRatios' n ' = medianPreSynapseRatios' n ';'])
        eval(['SynCorSnippets.medianPostSynapseRatios' n ' = medianPostSynapseRatios' n ';'])
        eval(['SynCorSnippets.medianPreSynapseDiffs' n ' = medianPreSynapseDiffs' n ';'])
        eval(['SynCorSnippets.medianPostSynapseDiffs' n ' = medianPostSynapseDiffs' n ';'])
end

%% saving data
savefilename = fullfile(basepath,'WSSnippets',ep1str,[basename '_SynCorrWSSnippets']);
save(savefilename,'SynCorrWSSnippets')


%% get correlations between pre and change for each, and also plot
% for a = 1:numWS%for each epoch
%     EsynRatioh = [];
%     EsynDiffh = [];
%     IsynRatioh = [];
%     IsynDiffh = [];
% 
%     EsynRatior{a} = [];
%     EsynRatiop{a} = [];
%     EsynRatiocoeffs{a} = [];
%     EsynDiffr{a} = [];
%     EsynDiffp{a} = [];
%     EsynDiffcoeffs{a} = [];
% 
%     IsynRatior{a} = [];
%     IsynRatiop{a} = [];
%     IsynRatiocoeffs{a} = [];
%     IsynDiffr{a} = [];
%     IsynDiffp{a} = [];
%     IsynDiffcoeffs{a} = [];
%     
%     % Plot and save fit stats
%     eval(['ESynapseMedianRatiosPreWS' num2str(a) ' = medianPreSynapseRatiosE(:,a);'])
%     eval(['ESynapseMedianRatiosPostWS' num2str(a) ' = medianPostSynapseRatiosE(:,a);'])
%     if plotting
%         eval(['[th,tr,tp,tcoeffs] = PlotPrePost(ESynapseMedianRatiosPreWS' num2str(a) ',ESynapseMedianRatiosPostWS' num2str(a) ');'])
%         EsynRatioh = cat(1,EsynRatioh(:),th(:));
%     else
%         eval(['[tr,tp,tcoeffs] = RegressPreVsPostvpreproportion(ESynapseMedianRatiosPreWS' num2str(a) ',ESynapseMedianRatiosPostWS' num2str(a) ');'])
%     end
%     EsynRatior{a} = cat(1,EsynRatior{a},tr);
%     EsynRatiop{a} = cat(1,EsynRatiop{a},tp);
%     EsynRatiocoeffs{a} = cat(2,EsynRatiocoeffs{a},tcoeffs);
% 
%     eval(['ISynapseMedianRatiosPreWS' num2str(a) ' = medianPreSynapseRatiosI(:,a);'])
%     eval(['ISynapseMedianRatiosPostWS' num2str(a) ' = medianPostSynapseRatiosI(:,a);'])
%     if plotting
%         eval(['[th,tr,tp,tcoeffs] = PlotPrePost(ISynapseMedianRatiosPreWS' num2str(a) ',ISynapseMedianRatiosPostWS' num2str(a) ');'])
%         IsynRatioh = cat(1,IsynRatioh(:),th(:));
%     else
%         eval(['[tr,tp,tcoeffs] = RegressPreVsPostvpreproportion(ISynapseMedianRatiosPreWS' num2str(a) ',ISynapseMedianRatiosPostWS' num2str(a) ');'])
%     end
%     IsynRatior{a} = cat(1,IsynRatior{a},tr);
%     IsynRatiop{a} = cat(1,IsynRatiop{a},tp);
%     IsynRatiocoeffs{a} = cat(2,IsynRatiocoeffs{a},tcoeffs);
% 
%     eval(['ESynapseMedianDiffsPreWS' num2str(a) ' = medianPreSynapseDiffsE(:,a);'])
%     eval(['ESynapseMedianDiffsPostWS' num2str(a) ' = medianPostSynapseDiffsE(:,a);'])
%     if plotting
%         eval(['[th,tr,tp,tcoeffs] = PlotPrePost(ESynapseMedianDiffsPreWS' num2str(a) ',ESynapseMedianDiffsPostWS' num2str(a) ');'])
%         EsynDiffh = cat(1,EsynDiffh(:),th(:));
%     else
%         eval(['[tr,tp,tcoeffs] = RegressPreVsPostvpreproportion(ESynapseMedianDiffsPreWS' num2str(a) ',ESynapseMedianDiffsPostWS' num2str(a) ');'])
%     end
%     EsynDiffr{a} = cat(1,EsynDiffr{a},tr);EsynDiffp{a} = cat(1,EsynDiffp{a},tp);EsynDiffcoeffs{a} = cat(2,EsynDiffcoeffs{a},tcoeffs);
% 
%     eval(['ISynapseMedianDiffsPreWS' num2str(a) ' = medianPreSynapseDiffsI(:,a);'])
%     eval(['ISynapseMedianDiffsPostWS' num2str(a) ' = medianPostSynapseDiffsI(:,a);'])
%     if plotting
%         eval(['[th,tr,tp,tcoeffs] = PlotPrePost(ISynapseMedianDiffsPreWS' num2str(a) ',ISynapseMedianDiffsPostWS' num2str(a) ');'])
%         IsynDiffh = cat(1,IsynDiffh(:),th(:));
%     else
%         eval(['[tr,tp,tcoeffs] = RegressPreVsPostvpreproportion(ISynapseMedianDiffsPreWS' num2str(a) ',ISynapseMedianDiffsPostWS' num2str(a) ');'])
%     end
%     IsynDiffr{a} = cat(1,IsynDiffr{a},tr);
%     IsynDiffp{a} = cat(1,IsynDiffp{a},tp);
%     IsynDiffcoeffs{a} = cat(2,IsynDiffcoeffs{a},tcoeffs);
% % end
% 
% %saving figs
% if plotting
%     figsavedir = fullfile(basepath,'WSSnippets',ep1str,'SynapseDataFigs');
%     MakeDirSaveFigsThereAs(figsavedir,EsynRatioh,'fig')
%     MakeDirSaveFigsThereAs(figsavedir,EsynDiffh,'fig')
%     MakeDirSaveFigsThereAs(figsavedir,IsynRatioh,'fig')
%     MakeDirSaveFigsThereAs(figsavedir,IsynDiffh,'fig')
% end

% %saving data
% savefilename = fullfile(basepath,'WSSnippets',ep1str,[basename '_SynCorrWSSnippets']);
% switch mode
%     case 'tsd'
%         SynCorrWSSnippets = v2struct(ep1str,EPairs,IPairs,numWS,...
%             preSynapseRatiosETsds,postSynapseRatiosETsds,...
%             preSynapseRatiosITsds,postSynapseRatiosITsds,preSynapseDiffsETsds,postSynapseDiffsETsds,...
%             preSynapseDiffsITsds,postSynapseDiffsITsds,...
%             preSynapseRatiosE,postSynapseRatiosE,preSynapseDiffsE, postSynapseDiffsE,...
%             preSynapseRatiosI,postSynapseRatiosI,preSynapseDiffsI,postSynapseDiffsI,...
%             medianPreSynapseRatiosE,medianPostSynapseRatiosE,medianPreSynapseDiffsE,medianPostSynapseDiffsE,...
%             medianPreSynapseRatiosI,medianPostSynapseRatiosI,medianPreSynapseDiffsI,medianPostSynapseDiffsI);
%     case 'singlepoint'
%         SynCorrWSSnippets = v2struct(ep1str,EPairs,IPairs,numWS,...
%             medianPreSynapseRatiosE,medianPostSynapseRatiosE,medianPreSynapseDiffsE,medianPostSynapseDiffsE,...
%             medianPreSynapseRatiosI,medianPostSynapseRatiosI,medianPreSynapseDiffsI,medianPostSynapseDiffsI);
% end
% save(savefilename,'SynCorrWSSnippets')



function [ccgs,ratios,ratechgs,expecteds,measureds,numprespikes,numpostspikes] = ...
    LocalGrabIntervalCCGCorrOverAllPairs(S,PrePostPairs,ConnectionStarts,ConnectionEnds,Flips,shank,iSet)

% constants
binSize = 0.0005;%in seconds
ConvWidth = 12;%number of bins for convolution
ConvWidth = ConvWidth*binSize;%... now in seconds
duration = 0.030;%width of ccg
% window = 1 * 60;%(minutes) seconds per chunk analyzed

% SessStart = 0;
% SessEnd = End(timeSpan(S),'s');
% numbins = ceil((SessEnd-SessStart)/window);
% windowstarts = (0:numbins-1)*window;
% windowends = (1:numbins)*window;

if isempty(PrePostPairs)
    cnxnstartms = [];
    cnxnendms = [];
    ccgs = [];
    ratios = [];
    ratechgs = [];
    expecteds = [];
    measureds = [];
    numprespikes = [];
    numpostspikes = [];
else
    for i= 1:size(PrePostPairs,1)
       pre = PrePostPairs(i, 1);
       post = PrePostPairs(i, 2);
       times1 = Range(Restrict(S{pre},iSet),'s');
       times2 = Range(Restrict(S{post},iSet),'s');
       tnumprespikes = length(times1);
       tnumpostspikes = length(times2);
       cnxnstartms = ConnectionStarts(pre, post);
       cnxnendms = ConnectionEnds(pre, post);
       if Flips(pre,post)
           cnxnstartms = -cnxnstartms;
           cnxnendms = -cnxnendms;
       end
       if shank(pre)==shank(post)
           sameshank = 1;
       else
           sameshank = 0;
       end

%        [tccg, tstrengthbyratio, tstrengthbyratechg,tnumprespikes, tnumpostspikes, tmeasured, texpected] = ...
%            ShortTimeCCG_rb(times1, times2, cnxnstartms, cnxnendms, ConvWidth, sameshank,...
%            windowstarts,windowends,'binSize', binsize, 'duration', duration);
       
       [strengthbyratio, strengthbyratechg, ccg, measured, expected] =...
            SpikeTransfer_Norm2(times1,times2,binSize,duration,[cnxnstartms cnxnendms],ConvWidth,sameshank,1);

        ccgs(:,i) = ccg;
        ratios(i) = strengthbyratio;
        ratechgs(i) = strengthbyratechg;
        expecteds(i) = expected;
        measureds(i) = measured;
        numprespikes(i) = tnumprespikes;
        numpostspikes(i) = tnumpostspikes;

    end
end
            