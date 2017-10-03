function SpikeTransfer_Per1MinuteICnxnsOnly(basepath,basename)
% Gets Synaptic connectivity strength for every minute oft he recording
% for the entire span of S.
% Brendon Watson 2015

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

t = load(fullfile(basepath,[basename '_SStable.mat']));
S = t.S;

t = load(fullfile(basepath,[basename '_funcsynapsesMoreStringent.mat']));
funcsynapses = t.funcsynapses;
shank = funcsynapses.CellShanks;
PrePostPairs = funcsynapses.ConnectionsI;
ConnectionStarts = funcsynapses.CnxnStartTimesVsRefSpk;
ConnectionEnds = funcsynapses.CnxnEndTimesVsRefSpk;
Flips = funcsynapses.FlippedCnxns;

%% constants
binsize = 0.0005;%in seconds
ConvWidth = 12;%number of bins for convolution
ConvWidth = ConvWidth*binsize;%... now in seconds
duration = 0.030;%width of ccg
window = 1 * 60;%(minutes) seconds per chunk analyzed

SessStart = 0;
SessEnd = End(timeSpan(S),'s');
numbins = ceil((SessEnd-SessStart)/window);
windowstarts = (0:numbins-1)*window;
windowends = (1:numbins)*window;

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

       [tccg, tstrengthbyratio, tstrengthbyratechg,tnumprespikes, tnumpostspikes, tmeasured, texpected] = ...
           ShortTimeCCG_rb(times1, times2, cnxnstartms, cnxnendms, ConvWidth, sameshank,...
           windowstarts,windowends,'binSize', binsize, 'duration', duration);
       ccgs(:,:,i) = tccg;
       ratios(i,:) = tstrengthbyratio;
       ratechgs(i,:) = tstrengthbyratechg;
       expecteds(i,:) = texpected;
       measureds(i,:) = tmeasured;
       numprespikes(i,:) = tnumprespikes;
       numpostspikes(i,:) = tnumpostspikes;
    end
end

% ncollratio = bwnormalize_array(collratio); %normalize to between 0 and 1
% ncollratechg = bwnormalize_array(collratechg); %normalize to between 0 and 1
zratios = nanzscore(ratios,[],2); %zscore
zratechgs = nanzscore(ratechgs,[],2); %zscore


SpikeTransferPer1MinuteI = v2struct(window,windowstarts,windowends,...
    PrePostPairs,cnxnstartms,cnxnendms,...
    binsize,duration,ConvWidth,ccgs,...
    expecteds,measureds,numprespikes,numpostspikes,...
    ratios,ratechgs,zratios,zratechgs);

save(fullfile(basepath,[basename '_SpikeTransferPer1MinuteI.mat']),'SpikeTransferPer1MinuteI');
