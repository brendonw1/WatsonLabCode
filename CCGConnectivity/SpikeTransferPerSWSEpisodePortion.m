function SpikeTransferPerSWSEpisodePortion = SpikeTransferPerSWSEpisodePortion(basepath,basename,numdivisions)

warning off
if ~exist('numdivisions','var')
    numdivisions = 10;
end
if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']),'SWSPacketInts');
load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']),'SWSEpisodeInts');
tocut = SWSEpisodeInts;
numeps = length(length(tocut));
t = load(fullfile(basepath,[basename '_SStable.mat']));
S = t.S;

t = load(fullfile(basepath,[basename '_funcsynapsesMoreStringent.mat']));
funcsynapses = t.funcsynapses;
shank = funcsynapses.CellShanks;
EPairs = funcsynapses.ConnectionsE;
IPairs = funcsynapses.ConnectionsI;
ConnectionStarts = funcsynapses.CnxnStartTimesVsRefSpk;
ConnectionEnds = funcsynapses.CnxnEndTimesVsRefSpk;
Flips = funcsynapses.FlippedCnxns;

for a  = 1:numeps
    regints = regIntervals(subset(tocut,a),numdivisions);
    for b = 1:numdivisions
        bintimes{a}(b) = mean(StartEnd(regints{b},'s'),2);
    end
    bintimes{a} = bintimes{a} - Start(subset(tocut,a),'s');
    normtimes{a} = bintimes{a}/Data(length(subset(tocut,a),'s'));
    
    if ~isempty(EPairs);%calculate strengths for pairs in each cycle
        for b = 1:numdivisions
            tpack = intersect(regints{b},SWSPacketInts);
            [ccgsE(:,:,b,a),strengthbyratiosE(b,:,a),strengthbyratechgsE(b,:,a),expectedsE(b,:,a),measuredsE(b,:,a),numprespikesE(b,:,a),numpostspikesE(b,:,a)] = ...
                LocalGrabIntervalCCGCorrOverAllPairs(S,EPairs,ConnectionStarts,ConnectionEnds,Flips,shank,tpack);
        end
    else
        ccgsE = [];
        strengthbyratiosE = [];
        strengthbyratechgsE = [];
        expectedsE = [];
        measuredsE = [];
        numprespikesE = [];
        numpostspikesE = [];
    end
    
    if ~isempty(IPairs);
        for b = 1:numdivisions
            tpack = intersect(regints{b},SWSPacketInts);
            [ccgsI(:,:,b,a),strengthbyratiosI(b,:,a),strengthbyratechgsI(b,:,a),expectedsI(b,:,a),measuredsI(b,:,a),numprespikesI(b,:,a),numpostspikesI(b,:,a)] = ...
                LocalGrabIntervalCCGCorrOverAllPairs(S,IPairs,ConnectionStarts,ConnectionEnds,Flips,shank,tpack);
        end
    else
        ccgsI = [];
        strengthbyratiosI = [];
        strengthbyratechgsI = [];
        expectedsI = [];
        measuredsI = [];
        numprespikesI = [];
        numpostspikesI = [];
    end
end

%slopes for each pair for metric over each WS
[RatioSlopesAbsE,RatioSlopesNormE,MedianRatioSlopesAbsE,MedianRatioSlopesNormE] = ...
    localgetslopes(numeps,EPairs,strengthbyratiosE,bintimes,normtimes);
[RateChgSlopesAbsE,RateChgSlopesNormE,MedianRateChgSlopesAbsE,MedianRateChgSlopesNormE] = ...
    localgetslopes(numeps,EPairs,strengthbyratechgsE,bintimes,normtimes);
[MeasuredsSlopesAbsE,MeasuredsSlopesNormE,MedianMeasuredsSlopesAbsE,MedianMeasuredsSlopesNormE] = ...
    localgetslopes(numeps,EPairs,measuredsE,bintimes,normtimes);
[ExpectedsSlopesAbsE,ExpectedsSlopesNormE,MedianExpectedsSlopesAbsE,MedianExpectedsSlopesNormE] = ...
    localgetslopes(numeps,EPairs,expectedsE,bintimes,normtimes);
[NumprespikesSlopesAbsE,NumprespikesSlopesNormE,MedianNumprespikesSlopesAbsE,MedianNumprespikesSlopesNormE] = ...
    localgetslopes(numeps,EPairs,numprespikesE,bintimes,normtimes);
[NumpostspikesSlopesAbsE,NumpostspikesSlopesNormE,MedianNumpostspikesSlopesAbsE,MedianNumpostspikesSlopesNormE] = ...
    localgetslopes(numeps,EPairs,numpostspikesE,bintimes,normtimes);

[RatioSlopesAbsI,RatioSlopesNormI,MedianRatioSlopesAbsI,MedianRatioSlopesNormI] = ...
    localgetslopes(numeps,IPairs,strengthbyratiosI,bintimes,normtimes);
[RateChgSlopesAbsI,RateChgSlopesNormI,MedianRateChgSlopesAbsI,MedianRateChgSlopesNormI] = ...
    localgetslopes(numeps,IPairs,strengthbyratechgsI,bintimes,normtimes);
[MeasuredsSlopesAbsI,MeasuredsSlopesNormI,MedianMeasuredsSlopesAbsI,MedianMeasuredsSlopesNormI] = ...
    localgetslopes(numeps,IPairs,measuredsI,bintimes,normtimes);
[ExpectedsSlopesAbsI,ExpectedsSlopesNormI,MedianExpectedsSlopesAbsI,MedianExpectedsSlopesNormI] = ...
    localgetslopes(numeps,IPairs,expectedsI,bintimes,normtimes);
[NumprespikesSlopesAbsI,NumprespikesSlopesNormI,MedianNumprespikesSlopesAbsI,MedianNumprespikesSlopesNormI] = ...
    localgetslopes(numeps,IPairs,numprespikesI,bintimes,normtimes);
[NumpostspikesSlopesAbsI,NumpostspikesSlopesNormI,MedianNumpostspikesSlopesAbsI,MedianNumpostspikesSlopesNormI] = ...
    localgetslopes(numeps,IPairs,numpostspikesI,bintimes,normtimes);

% medians over WS for each measure for each pair
ccgsWSMedianE = median(ccgsE,4);
strengthbyratiosWSMedianE = median(strengthbyratiosE,3);
strengthbyratechgsWSMedianE = median(strengthbyratechgsE,3);
expectedsWSMedianE = median(expectedsE,3);
measuredsWSMedianE = median(measuredsE,3);
numprespikesWSMedianE = median(numprespikesE,3);
numpostspikesWSMedianE = median(numpostspikesE,3);

ccgsWSMedianI = median(ccgsI,4);
strengthbyratiosWSMedianI = median(strengthbyratiosI,3);
strengthbyratechgsWSMedianI = median(strengthbyratechgsI,3);
expectedsWSMedianI = median(expectedsI,3);
measuredsWSMedianI = median(measuredsI,3);
numprespikesWSMedianI = median(numprespikesI,3);
numpostspikesWSMedianI = median(numpostspikesI,3);


SpikeTransferPerSWSEpisodePortion = v2struct(EPairs,IPairs,ConnectionStarts,ConnectionEnds,Flips,...
    bintimes,normtimes,...
    MedianRatioSlopesNormE,MedianRatioSlopesAbsE,MedianRatioSlopesNormI,MedianRatioSlopesAbsI,...
    MedianRateChgSlopesNormE,MedianRateChgSlopesAbsE,MedianRateChgSlopesNormI,MedianRateChgSlopesAbsI,...
    MedianMeasuredsSlopesNormE,MedianMeasuredsSlopesAbsE,MedianMeasuredsSlopesNormI,MedianMeasuredsSlopesAbsI,...
    MedianExpectedsSlopesNormE,MedianExpectedsSlopesAbsE,MedianExpectedsSlopesNormI,MedianExpectedsSlopesAbsI,...
    MedianNumprespikesSlopesNormE,MedianNumprespikesSlopesAbsE,MedianNumprespikesSlopesNormI,MedianNumprespikesSlopesAbsI,...
    MedianNumpostspikesSlopesNormE,MedianNumpostspikesSlopesAbsE,MedianNumpostspikesSlopesNormI,MedianNumpostspikesSlopesAbsI,...
    RatioSlopesNormE,RatioSlopesAbsE,RatioSlopesNormI,RatioSlopesAbsI,...
    RateChgSlopesNormE,RateChgSlopesAbsE,RateChgSlopesNormI,RateChgSlopesAbsI,...
    MeasuredsSlopesNormE,MeasuredsSlopesAbsE,MeasuredsSlopesNormI,MeasuredsSlopesAbsI,...
    ExpectedsSlopesNormE,ExpectedsSlopesAbsE,ExpectedsSlopesNormI,ExpectedsSlopesAbsI,...
    NumprespikesSlopesNormE,NumprespikesSlopesAbsE,NumprespikesSlopesNormI,NumprespikesSlopesAbsI,...
    NumpostspikesSlopesNormE,NumpostspikesSlopesAbsE,NumpostspikesSlopesNormI,NumpostspikesSlopesAbsI,...
    ccgsWSMedianE,ccgsWSMedianI,ccgsE,ccgsI,...
    strengthbyratiosWSMedianE,strengthbyratiosE,strengthbyratiosWSMedianI,strengthbyratiosI,...
    strengthbyratechgsWSMedianE,strengthbyratechgsE,strengthbyratechgsWSMedianI,strengthbyratechgsI,...
    measuredsWSMedianE,measuredsE,measuredsWSMedianI,measuredsI,...
    expectedsWSMedianE,expectedsE,expectedsWSMedianI,expectedsI,...
    numprespikesWSMedianE,numprespikesE,numprespikesWSMedianI,numprespikesI,...
    numpostspikesWSMedianE,numpostspikesE,numpostspikesWSMedianI,numpostspikesI);

save(fullfile(basepath,[basename '_SpikeTransferPerSWSEpisodePortion.mat']),'SpikeTransferPerSWSEpisodePortion')


function [ccgs,ratios,ratechgs,expecteds,measureds,numprespikes,numpostspikes] = ...
    LocalGrabIntervalCCGCorrOverAllPairs(S,PrePostPairs,ConnectionStarts,ConnectionEnds,Flips,shank,iSet)

% constants
binSize = 0.0005;%in seconds
ConvWidth = 12;%number of bins for convolution
ConvWidth = ConvWidth*binSize;%... now in seconds
duration = 0.030;%width of ccg

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

function [SlopesAbs,SlopesNorm,medianSlopesAbs,medianSlopesNorm] = localgetslopes(numeps,Pairs,datamtx,bintimes,normtimes)
SlopesAbs = [];
SlopesNorm = [];
for a = numeps
    for b = 1:size(Pairs,1)
        t = datamtx(:,b,a);
        t = t/nanmean(t);
        gt = t(~isnan(t));
        gbt = bintimes{a}(~isnan(t));
        gnt = normtimes{a}(~isnan(t));
        if ~isempty(gbt)
            p = polyfit(gbt(:),gt(:),1);
    %         figure;plot(bintimes,t);hold on;plot(bintimes,polyval(p,bintimes));
            SlopesAbs(b,a) = p(1);
            p = polyfit(gnt(:),gt(:),1);
            SlopesNorm(b,a) = p(1);
        else
            SlopesAbs(b,a) = nan;
            SlopesNorm(b,a) = nan;
        end
    end
end
       
medianSlopesAbs = nanmedian(SlopesAbs,2);
medianSlopesNorm = nanmedian(SlopesNorm,2);
