function SpikeTransfer_PerREMThirdAllSubtypes(basepath,basename)
% Gets Synaptic connectivity strength for every minute oft he recording
% for the entire span of S.
% Brendon Watson 2015

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

numtimedivisions = 3;%value of 3 corresponds to thirds of rem
t = load(fullfile(basepath,[basename '_SStable.mat']));
S = t.S;

load(fullfile(basepath,[basename '_funcsynapsesMoreStringent.mat']));
load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']),'REMEpisodeInts');
shank = funcsynapses.CellShanks;
typenames = {'E','I','EE','EI','IE','II'};
for ix = 1:length(typenames)
    eval(['PrePostPairsAll{ix} = funcsynapses.Connections' typenames{ix} ';'])
end
ConnectionStarts = funcsynapses.CnxnStartTimesVsRefSpk;
ConnectionEnds = funcsynapses.CnxnEndTimesVsRefSpk;
Flips = funcsynapses.FlippedCnxns;

%% constants
binsize = 0.0005;%in seconds
ConvWidth = 12;%number of bins for convolution
ConvWidth = ConvWidth*binsize;%... now in seconds
duration = 0.030;%width of ccg
% window = 1 * 60;%(minutes) seconds per chunk analyzed
windowstarts = cell(0,0); 
windowends = cell(0,0); 
for r = 1:length(length(REMEpisodeInts));
    tint = StartEnd(subset(REMEpisodeInts,r),'s');
    windowdurations = (tint(2)-tint(1))/numtimedivisions;
    windowstarts{r} = tint(1)+(0:numtimedivisions-1)*windowdurations;  
    windowends{r} = tint(1)+(1:numtimedivisions)*windowdurations;  
end

for ix = 1:length(PrePostPairsAll)
    PrePostPairs = PrePostPairsAll{ix};
    cnxnstartms = [];
    cnxnendms = [];
    ccgs = [];
    ratios = [];
    ratechgs = [];
    expecteds = [];
    measureds = [];
    numprespikes = [];
    numpostspikes = [];
    zratios = [];
    zratechgs = [];
    if ~isempty(PrePostPairs)
        for i= 1:size(PrePostPairs,1)
           pre = PrePostPairs(i, 1);
           post = PrePostPairs(i, 2);
           times1 = Range(S{pre},'s');
           times2 = Range(S{post},'s');
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
            
           for r = 1:length(length(REMEpisodeInts));
               [tccg, tstrengthbyratio, tstrengthbyratechg,tnumprespikes, tnumpostspikes, tmeasured, texpected] = ...
                   ShortTimeCCG_rb(times1, times2, cnxnstartms, cnxnendms, ConvWidth, sameshank,...
                   windowstarts{r},windowends{r},'binSize', binsize, 'duration', duration);
               ccgs(:,:,i,r) = tccg;
               ratios(i,:,r) = tstrengthbyratio;
               ratechgs(i,:,r) = tstrengthbyratechg;
               expecteds(i,:,r) = texpected;
               measureds(i,:,r) = tmeasured;
               numprespikes(i,:) = tnumprespikes;
               numpostspikes(i,:,r) = tnumpostspikes;
           end
        end
    end
%     zratios = nanzscore(ratios,[],2); %zscore
%     zratechgs = nanzscore(ratechgs,[],2); %zscore
    t = v2struct(numtimedivisions,windowstarts,windowends,...
        PrePostPairs,cnxnstartms,cnxnendms,...
        binsize,duration,ConvWidth,ccgs,...
        expecteds,measureds,numprespikes,numpostspikes,...
        ratios,ratechgs);
    eval(['SpikeTransferPerREMThirdAll.' typenames{ix} ' = t;'])
end

save(fullfile(basepath,[basename '_SpikeTransferPerREMThirdAll.mat']),'SpikeTransferPerREMThirdAll');
