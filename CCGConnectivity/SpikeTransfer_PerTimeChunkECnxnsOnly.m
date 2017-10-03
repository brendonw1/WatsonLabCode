function SpikeTransfer_Per1MinuteECnxnsOnly(basepath,basename)

% Assemblies_BigScript
if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

% load('BWRat19_032513_ConnectionsE_ForRachana');
% load('BWRat19_032513_SStable_ForRachana');
t = load(fullfile(basepath,[basename '_SStable.mat']));
S = t.S;

t = load(fullfile(basepath,[basename '_funcsynapses.mat']));
funcsynapses = t.funcsynapses;
shank = funcsynapses.CellShanks;
PrePostPairs = funcsynapses.ConnectionsE;
ConnectionStarts = funcsynapses.CnxnStartTimesVsRefSpk;
ConnectionEnds = funcsynapses.CnxnEndTimesVsRefSpk;
Flips = funcsynapses.FlippedCnxns;

binsize = 0.0005;%in seconds
ConvWidth = 12;%number of bins for convolution
ConvWidth = ConvWidth*binsize;%... now in seconds
duration = 0.030;%width of ccg
window = 1 * 60;%(minutes) seconds per chunk analyzed

% how to input time restrictions?... or none just take from whole data
% manually set times and give them as inputs as start and stop
% what the heck is x
% get out prespikesperbin, postspikesperbin
% save all appropriately

% Gathering function 
% must create intervalsets
% can be intervals{}
% can be eval'd... make a special function to call to yield an intervalset
% that gets called via eval


for i= 1:size(PrePostPairs,1)
   pre = PrePostPairs(i, 1);
   post = PrePostPairs(i, 2);
   times1 = Range(S{pre},'s');
   times2 = Range(S{post},'s');
   thisstart = ConnectionStarts(pre, post);
   thisend = ConnectionEnds(pre, post);
   if Flips(pre,post)
       thisstart = -thisstart;
       thisend = -thisend;
   end
   if shank(pre)==shank(post)
       sameshank = 1;
   else
       sameshank = 0;
   end
   [tccg, tbincenters, tstrengthbyratio, tstrengthbyratechg,tnumprespikes, tnumpostspikes, tmeasured, texpected] = ...
       ShortTimeCCG_rb(times1, times2, thisstart, thisend, ConvWidth, sameshank,...
       'binSize', binsize, 'duration', duration,'window',window);
   if i == 1;
       binstarts = tbincenters - window/2;
       binstops = tbincenters + window/2;
   end
   ccgs(:,:,i) = tccg;
   ratios(i,:) = tstrengthbyratio;
   ratechgs(i,:) = tstrengthbyratechg;
   expecteds(i,:) = texpected;
   measureds(i,:) = tmeasured;
   numprespikes(1,:) = tnumprespikes;
   numpostspikes(1,:) = tnumpostspikes;
end

% ncollratio = bwnormalize_array(collratio); %normalize to between 0 and 1
% ncollratechg = bwnormalize_array(collratechg); %normalize to between 0 and 1
zratios = nanzscore(ratios,[],2); %zscore
zratechgs = nanzscore(ratechgs,[],2); %zscore


SpikeTransferPer1Minute = v2struct(binstarts,binstops,binsize,window,duration,ConvWidth,...
    PrePostPairs,ccgs,expecteds,measureds,numprespikes,numpostspikes,...
    ratios,ratechgs,zratios,zratechgs);

save(fullfile(basepath,[basename '_SpikeTransferPer1Minute.mat']),'SpikeTransferPer1Minute');
