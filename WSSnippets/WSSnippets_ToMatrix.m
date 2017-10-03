function [WSMatrix,labels] = WSSnippets_ToMatrix
% function WSSnippets_ToMatrix
% Gathers data in a per-WakeSleep episode fashion so that a matrix of
% wake-sleep episode data points can be used to make comparisons.  Gathers
% from all recordings meeting criteria specified via
% SleepAnalysis_GetDatasetNameDirsFromSleepSessionMatrix.
%
% Brendon Watson 2015

%% Set up
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

%% Gather directories and get rat names per session
ws = 1;
synapses = 0;
spindles = 1;
[names,dirs] = SleepAnalysis_GetDatasetNameDirsFromSleepSessionMatrix(ws,synapses,spindles);

RatNames = {};
for a = 1:length(dirs);
    basename = names{a};
    basepath = dirs{a};
    slashes = strfind(basepath,'/');
    ratname = basepath(slashes(3)+1:slashes(4)-1);
    RatNames{end+1} = ratname;
end
[uRatNames,RatStartSess,uRatNamesBySession] = unique(RatNames);
PerRatSessNums = [];
for a=1:length(RatStartSess)
    if a~=length(RatStartSess)
        tdiff = RatStartSess(a+1)-RatStartSess(a);
    else
        tdiff = length(uRatNamesBySession)-RatStartSess(a)+1;
    end
    PerRatSessNums = cat(1,PerRatSessNums,[1:tdiff]');
end
% NumRats = length(uRatNames);


%% Set up each recording
counter = 1;
lastratnum = 0;
for a = 1:length(dirs);
    basepath = dirs{a};
    basename = names{a};
    ws = load(fullfile(basepath,[basename '_WSWEpisodes2']));
    
    upspmotionfname = fullfile(basepath,'WSSnippets',ep1,[basename '_UPSpindleMotionWSSnippets.mat']);
    spkfname = fullfile(basepath,'WSSnippets',ep1,[basename '_SpikeRateWSSnippets.mat']);
    synfname = fullfile(basepath,'WSSnippets',ep1,[basename '_SynCorrWSSnippets.mat']);
    assfname = fullfile(basepath,'WSSnippets',ep1,[basename '_WakeBAssWSSnippets.mat']);
    
    thisratnum = uRatNamesBySession(a);
    if thisratnum ~=lastratnum
        peranimalsleepcounter = 0;
    end
    
    for b = 1:length(ws.WSEpisodes)%for each episode, make sure it's in the good sleep interval
        wst = intersect(ws.WSEpisodes{b},ws.GoodSleepInterval);
        if tot_length(wst)>0 %if good WS (and within GoodSleepInterval)
            peranimalsleepcounter = peranimalsleepcounter + 1;
            twsm = [];
            labels = {};%totally wasteful system, but I don't care since it also serves as commenting
            
%%            basic session info
            labels{end+1} = 'AnimalNumber';
            twsm(end+1) = uRatNamesBySession(a);
            labels{end+1} = 'OverallSessionNumber';
            twsm(end+1) = a;
            labels{end+1} = 'RatSessionNumber';
            twsm(end+1) = PerRatSessNums(a);%     
            labels{end+1} = 'RatSleepEpNumber';
            twsm(end+1) = peranimalsleepcounter;
            labels{end+1} = 'SessionSleepEpNumber';
            twsm(end+1) = b;

%%          motion
            t = load(upspmotionfname);
            usmws = t.UPSpindleMotionWSSnippets;
            labels{end+1} = 'PreSleepMotion';
            twsm(end+1) = usmws.motionSecsSums(b);
            
%%          spike rates
            %E cells
            t = load(spkfname);
            spkws = t.SpikeRateWSSnippets;
            %E cells
            [v,l] = CalcMedianValsFromPrePostVectors(spkws.ratePreSpikesE(:,b),spkws.ratePostSpikesE(:,b),'ECellRates');
            twsm = cat(2,twsm,v');
            labels = cat(2,labels,l');

            %I cells
            [v,l] = CalcMedianValsFromPrePostVectors(spkws.ratePreSpikesI(:,b),spkws.ratePostSpikesI(:,b),'ICellRates');
            twsm = cat(2,twsm,v');
            labels = cat(2,labels,l');
            
%%              Synaptic timescale correlations
            t = load(synfname);
            synws = t.SynCorrWSSnippets;

            % E type cnxns
            labels{end+1} = 'NumESynapticCorrs';
            twsm(end+1) = size(synws.medianPreSynapseDiffsE,1);
            [v,l] = CalcMedianValsFromPrePostVectors(synws.medianPreSynapseDiffsE(:,b),synws.medianPostSynapseDiffsE(:,b),'ESynapticCorrDiffs');
            twsm = cat(2,twsm,v(2:end)');
            labels = cat(2,labels,l(2:end)');
            
            [v,l] = CalcMedianValsFromPrePostVectors(synws.medianPreSynapseRatiosE(:,b),synws.medianPostSynapseRatiosE(:,b),'ESynapticCorrRatios');
            twsm = cat(2,twsm,v(2:end)');
            labels = cat(2,labels,l(2:end)');

            % I type cnxns
            labels{end+1} = 'NumISynapticCorrs';
            twsm(end+1) = size(synws.medianPreSynapseDiffsI,1);
            [v,l] = CalcMedianValsFromPrePostVectors(synws.medianPreSynapseDiffsI(:,b),synws.medianPostSynapseDiffsI(:,b),'ISynapticCorrDiffs');
            twsm = cat(2,twsm,v(2:end)');
            labels = cat(2,labels,l(2:end)');
            
            [v,l] = CalcMedianValsFromPrePostVectors(synws.medianPreSynapseRatiosI(:,b),synws.medianPostSynapseRatiosI(:,b),'ISynapticCorrRatios');
            twsm = cat(2,twsm,v(2:end)');
            labels = cat(2,labels,l(2:end)');
            
            % EE type connections
            f = load(fullfile(basepath,[basename,'_funcsynapsesMoreStringent.mat']));
            f = f.funcsynapses;
            if ~isempty(f.ConnectionsEE)
                EEofE = ismember(f.ConnectionsEE,f.ConnectionsE,'rows');
            else
                EEofE = [];
            end
            labels{end+1} = 'NumEESynapticCorrs';
            twsm(end+1) = sum(EEofE);
            [v,l] = CalcMedianValsFromPrePostVectors(synws.medianPreSynapseDiffsE(EEofE,b),synws.medianPostSynapseDiffsE(EEofE,b),'EESynapticCorrDiffs');
            twsm = cat(2,twsm,v(2:end)');
            labels = cat(2,labels,l(2:end)');
            
            [v,l] = CalcMedianValsFromPrePostVectors(synws.medianPreSynapseRatiosE(EEofE,b),synws.medianPostSynapseRatiosE(EEofE,b),'EESynapticCorrRatios');
            twsm = cat(2,twsm,v(2:end)');
            labels = cat(2,labels,l(2:end)');
            
            % EI type connections
            if ~isempty(f.ConnectionsEI)
                EIofE = ismember(f.ConnectionsEI,f.ConnectionsE,'rows');
            else
                EIofE = [];
            end
            labels{end+1} = 'NumEISynapticCorrs';
            twsm(end+1) = sum(EIofE);
            [v,l] = CalcMedianValsFromPrePostVectors(synws.medianPreSynapseDiffsE(EIofE,b),synws.medianPostSynapseDiffsE(EIofE,b),'EISynapticCorrDiffs');
            twsm = cat(2,twsm,v(2:end)');
            labels = cat(2,labels,l(2:end)');
            
            [v,l] = CalcMedianValsFromPrePostVectors(synws.medianPreSynapseRatiosE(EIofE,b),synws.medianPostSynapseRatiosE(EIofE,b),'EISynapticCorrRatios');
            twsm = cat(2,twsm,v(2:end)');
            labels = cat(2,labels,l(2:end)');

            % IE type connections
            if ~isempty(f.ConnectionsIE)
                IEofI = ismember(f.ConnectionsIE,f.ConnectionsI,'rows');
            else
                IEofI = [];
            end
            labels{end+1} = 'NumIESynapticCorrs';
            twsm(end+1) = sum(IEofI);
            [v,l] = CalcMedianValsFromPrePostVectors(synws.medianPreSynapseDiffsI(IEofI,b),synws.medianPostSynapseDiffsI(IEofI,b),'IESynapticCorrDiffs');
            twsm = cat(2,twsm,v(2:end)');
            labels = cat(2,labels,l(2:end)');
            
            [v,l] = CalcMedianValsFromPrePostVectors(synws.medianPreSynapseRatiosI(IEofI,b),synws.medianPostSynapseRatiosI(IEofI,b),'IESynapticCorrRatios');
            twsm = cat(2,twsm,v(2:end)');
            labels = cat(2,labels,l(2:end)');

            % II type connections
            if ~isempty(f.ConnectionsII)
                IIofI = ismember(f.ConnectionsII,f.ConnectionsI,'rows');
            else
                IIofI = [];
            end
            labels{end+1} = 'NumIISynapticCorrs';
            twsm(end+1) = sum(IIofI);
            [v,l] = CalcMedianValsFromPrePostVectors(synws.medianPreSynapseDiffsI(IIofI,b),synws.medianPostSynapseDiffsI(IIofI,b),'IISynapticCorrDiffs');
            twsm = cat(2,twsm,v(2:end)');
            labels = cat(2,labels,l(2:end)');
            
            [v,l] = CalcMedianValsFromPrePostVectors(synws.medianPreSynapseRatiosI(IIofI,b),synws.medianPostSynapseRatiosI(IIofI,b),'IISynapticCorrRatios');
            twsm = cat(2,twsm,v(2:end)');
            labels = cat(2,labels,l(2:end)');

%% PCA-based assemlblies from pre-wake            
            t = load(assfname);
            assws = t.WakeBAssWSSnippets;
            [v,l] = CalcMedianValsFromPrePostVectors(assws.medianPreWakeBAss(:,b),assws.medianPostWakeBAss(:,b),'PreWakeBAss');
            twsm = cat(2,twsm,v');
            labels = cat(2,labels,l');
            
            
%% UP state stats
            % UP incidence rate
            [v,l] = CalcBasicFromPrePostPoints(usmws.medianPreUPIncRate(:,b),usmws.medianPostUPIncRate(:,b),'MedianUPStatesPerSec');
            v = cat(1,length(usmws.preUPs{b}{1}),length(usmws.postUPs{b}{1}),v);
            l = cat(1,'NumPreUPs','NumPostUPs',l);
            twsm = cat(2,twsm,v');
            labels = cat(2,labels,l');
            
            % UP duration
            [v,l] = CalcBasicFromPrePostPoints(usmws.medianPreUPDur(:,b),usmws.medianPostUPDur(:,b),'MedianUPStateDuration');
            twsm = cat(2,twsm,v');
            labels = cat(2,labels,l');
            
            % intra-UP spike rate
            [v,l] = CalcBasicFromPrePostPoints(usmws.medianPreUPSpkRate(:,b),usmws.medianPostUPSpkRate(:,b),'MedianUPStateSpikeRate');
            twsm = cat(2,twsm,v');
            labels = cat(2,labels,l');

%% Spindle Stats
            % Spindle incidence rate
            [v,l] = CalcBasicFromPrePostPoints(usmws.medianPreSpindleIncRate(:,b),usmws.medianPostSpindleIncRate(:,b),'MedianSpindlesPerSec');
            v = cat(1,length(usmws.preSpindles{b}{1}),length(usmws.postSpindles{b}{1}),v(2:end));
            l = cat(1,'NumPreSpindles','NumPostSpindles',l(2:end));
            twsm = cat(2,twsm,v');
            labels = cat(2,labels,l');

            % Spindle duration
            [v,l] = CalcBasicFromPrePostPoints(usmws.medianPreSpindleDur(:,b),usmws.medianPostSpindleDur(:,b),'MedianSpindleDuration');
            twsm = cat(2,twsm,v');
            labels = cat(2,labels,l');

            % Spindle Max Amplitude
            [v,l] = CalcBasicFromPrePostPoints(usmws.medianPreSpindleAmp(:,b),usmws.medianPostSpindleAmp(:,b),'MedianSpindleAmplitude');
            twsm = cat(2,twsm,v');
            labels = cat(2,labels,l');

            % Spindle Freq @ Max Amplitude
            [v,l] = CalcBasicFromPrePostPoints(usmws.medianPreSpindleFreq(:,b),usmws.medianPostSpindleFreq(:,b),'MedianSpindleFrequency');
            twsm = cat(2,twsm,v');
            labels = cat(2,labels,l');

            % intra-Spindle spike rate
            [v,l] = CalcBasicFromPrePostPoints(usmws.medianPreSpindleSpkRate(:,b),usmws.medianPostSpindleSpkRate(:,b),'MedianSpindleSpikeRate');
            twsm = cat(2,twsm,v');
            labels = cat(2,labels,l');


%     later
%     up state median partic chg
%     up state median ratecorr chg
%     up state median normratecorr chg
            WSMatrix(counter,:) = twsm';
            counter = counter+1;
            
            disp([basename ' Sleep Session # ' num2str(b) ' Done'])
            
        end
    end
end


%% Save Matrix
save(fullfile('/mnt/brendon4/Dropbox/BW OUTPUT/WSSnippets','WSSnippetMatrix'),'WSMatrix','labels')


%%
function [vect,labels] = CalcMedianValsFromPrePostVectors(pre,post,labelsbase)
% takes 2 vectors, pre and post, and then saves:
% 1) number of measures/cells/etc in vector
% 2) median pre
% 3) median post
% 4) median diff post-pre
% 5) geomedian proportion change
% 6) median percent change
% unless either vector is empty, in which case values are set to NaN

vect(1,1) = numel(pre);

if vect>0
    vect(2,1) = nanmedian(pre);
    vect(3,1) = nanmedian(post);
    vect(4,1) = nanmedian(post - pre);
    vect(5,1) = nanmedian(ConditionedPercentChange(pre,post));
    vect(6,1) = nanmedian(ConditionedProportion(pre,post));
else
    vect(2,1) = nan;
    vect(3,1) = nan;
    vect(4,1) = nan;
    vect(5,1) = nan;
    vect(6,1) = nan;
end

labels{1,1} = ['Num' labelsbase];
labels{2,1} = ['Median' labelsbase 'Pre'];
labels{3,1} = ['Median' labelsbase 'Post'];
labels{4,1} = ['Median' labelsbase 'Diff'];
labels{5,1} = ['Median' labelsbase 'PctChg'];
labels{6,1} = ['Median' labelsbase 'Prop'];


function [vect,labels] = CalcBasicFromPrePostPoints(pre,post,labelsbase)
% takes 2 vectors, pre and post, and then saves:
% 1) number of measures/cells/etc in vector
% 2) median pre
% 3) median post
% 4) median diff post-pre
% 5) geomedian proportion change
% 6) median percent change
% unless either vector is empty, in which case values are set to NaN

% vect(1,1) = numel(pre);

vect(1,1) = (pre);
vect(2,1) = (post);
vect(3,1) = (post - pre);
vect(4,1) = (ConditionedPercentChange(pre,post));
vect(5,1) = (ConditionedProportion(pre,post));

% labels{1,1} = ['Num' labelsbase];
labels{1,1} = [labelsbase 'Pre'];
labels{2,1} = [labelsbase 'Post'];
labels{3,1} = [labelsbase 'Diff'];
labels{4,1} = [labelsbase 'PctChg'];
labels{5,1} = [labelsbase 'Prop'];

