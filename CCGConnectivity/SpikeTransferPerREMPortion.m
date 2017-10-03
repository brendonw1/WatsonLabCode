function SpikeTransferPerREMPortion = SpikeTransferPerREMPortion(basepath,basename,numdivisions)
% Does not rely on the per1minute .mats

warning off
if ~exist('numdivisions','var')
    numdivisions = 3;
end
if ~exist('binshiftpercent','var')
    binshiftpercent = 1;%1 is no overlap .2 is 80% overlap
end
if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

load(fullfile(basepath,[basename '_WSRestrictedIntervals.mat']),'REMEpisodeInts');
tocut = REMEpisodeInts;
numeps = length(length(tocut));
t = load(fullfile(basepath,[basename '_SStable.mat']));
S = t.S;

t = load(fullfile(basepath,[basename '_funcsynapsesMoreStringent.mat']));
funcsynapses = t.funcsynapses;
shank = funcsynapses.CellShanks;
EPairs = funcsynapses.ConnectionsE;
IPairs = funcsynapses.ConnectionsI;
EEPairs = funcsynapses.ConnectionsEE;
EIPairs = funcsynapses.ConnectionsEI;
IEPairs = funcsynapses.ConnectionsIE;
IIPairs = funcsynapses.ConnectionsII;
ConnectionStarts = funcsynapses.CnxnStartTimesVsRefSpk;
ConnectionEnds = funcsynapses.CnxnEndTimesVsRefSpk;
Flips = funcsynapses.FlippedCnxns;

if numeps>0
    for a  = 1:numeps
        %Will restrict this sleep to only SWS parts and then compress SWS time
        %to that period without interruptions: compres spikes and then make a
        %simple intervalSet with just span equalling the total number of
        %seconds of SWS time.  They will not be sync'd and can be cleanly cut
        %into proportions.
        int = subset(REMEpisodeInts,a);
        s = CompressSpikeTrainsToIntervals(S,int,'firsttime');%spikes only in SWS, intervals compressed back to back
        int = intervalSet(FirstTime(int),FirstTime(int)+tot_length(int));
    %     regints = regIntervals(int);
    %     for b = 1:numdivisions
    %         bintimes{a}(b) = mean(StartEnd(regints{b},'s'),2);
    %     end
    %     numbins = numdivisions;

        epstart = Start(int,'s');
        epend = End(int,'s');
        epdur = Data(length(int,'s'));
    %     binsse = makebinsforsliding_byproportion(epstart-epdur/numdivisions,epend+epdur/numdivisions,1/(numdivisions+2),binshiftpercent);
        binsse = makebinsforsliding_byproportion(epstart,epend,1/(numdivisions),binshiftpercent);
        numbins = size(binsse,1);
        bintimes{a} = mean(binsse,2);
        bintimes{a} = bintimes{a} - FirstTime(int,'s');
        normtimes{a} = bintimes{a}/epdur;

        if ~isempty(EPairs);%calculate strengths for pairs in each cycle
            for b = 1:numbins
    %             tpack = regints{b};
                tpack = intervalSet(binsse(b,1)*10000,binsse(b,2)*10000);
                [ccgsE(:,:,b,a),strengthbyratiosE(b,:,a),strengthbyratediffsE(b,:,a),expectedsE(b,:,a),measuredsE(b,:,a),numprespikesE(b,:,a),numpostspikesE(b,:,a)] = ...
                    LocalGrabIntervalCCGCorrOverAllPairs(s,EPairs,ConnectionStarts,ConnectionEnds,Flips,shank,tpack);
            end
        else
            ccgsE = [];
            strengthbyratiosE = [];
            strengthbyratediffsE = [];
            expectedsE = [];
            measuredsE = [];
            numprespikesE = [];
            numpostspikesE = [];
        end

        if ~isempty(IPairs);
            for b = 1:numbins
    %             tpack = regints{b};
                tpack = intervalSet(binsse(b,1)*10000,binsse(b,2)*10000);
                [ccgsI(:,:,b,a),strengthbyratiosI(b,:,a),strengthbyratediffsI(b,:,a),expectedsI(b,:,a),measuredsI(b,:,a),numprespikesI(b,:,a),numpostspikesI(b,:,a)] = ...
                    LocalGrabIntervalCCGCorrOverAllPairs(s,IPairs,ConnectionStarts,ConnectionEnds,Flips,shank,tpack);
            end
        else
            ccgsI = [];
            strengthbyratiosI = [];
            strengthbyratediffsI = [];
            expectedsI = [];
            measuredsI = [];
            numprespikesI = [];
            numpostspikesI = [];
        end

        if ~isempty(EEPairs);
            for b = 1:numbins
    %             tpack = regints{b};
                tpack = intervalSet(binsse(b,1)*10000,binsse(b,2)*10000);
                [ccgsEE(:,:,b,a),strengthbyratiosEE(b,:,a),strengthbyratediffsEE(b,:,a),expectedsEE(b,:,a),measuredsEE(b,:,a),numprespikesEE(b,:,a),numpostspikesEE(b,:,a)] = ...
                    LocalGrabIntervalCCGCorrOverAllPairs(s,EEPairs,ConnectionStarts,ConnectionEnds,Flips,shank,tpack);
            end
        else
            ccgsEE = [];
            strengthbyratiosEE = [];
            strengthbyratediffsEE = [];
            expectedsEE = [];
            measuredsEE = [];
            numprespikesEE = [];
            numpostspikesEE = [];
        end

        if ~isempty(EIPairs);
            for b = 1:numbins
    %             tpack = regints{b};
                tpack = intervalSet(binsse(b,1)*10000,binsse(b,2)*10000);
                [ccgsEI(:,:,b,a),strengthbyratiosEI(b,:,a),strengthbyratediffsEI(b,:,a),expectedsEI(b,:,a),measuredsEI(b,:,a),numprespikesEI(b,:,a),numpostspikesEI(b,:,a)] = ...
                    LocalGrabIntervalCCGCorrOverAllPairs(s,EIPairs,ConnectionStarts,ConnectionEnds,Flips,shank,tpack);
            end
        else
            ccgsEI = [];
            strengthbyratiosEI = [];
            strengthbyratediffsEI = [];
            expectedsEI = [];
            measuredsEI = [];
            numprespikesEI = [];
            numpostspikesEI = [];
        end


        if ~isempty(IEPairs);
            for b = 1:numbins
    %             tpack = regints{b};
                tpack = intervalSet(binsse(b,1)*10000,binsse(b,2)*10000);
                [ccgsIE(:,:,b,a),strengthbyratiosIE(b,:,a),strengthbyratediffsIE(b,:,a),expectedsIE(b,:,a),measuredsIE(b,:,a),numprespikesIE(b,:,a),numpostspikesIE(b,:,a)] = ...
                    LocalGrabIntervalCCGCorrOverAllPairs(s,IEPairs,ConnectionStarts,ConnectionEnds,Flips,shank,tpack);
            end
        else
            ccgsIE = [];
            strengthbyratiosIE = [];
            strengthbyratediffsIE = [];
            expectedsIE = [];
            measuredsIE = [];
            numprespikesIE = [];
            numpostspikesIE = [];
        end

        if ~isempty(IIPairs);
            for b = 1:numbins
    %             tpack = regints{b};
                tpack = intervalSet(binsse(b,1)*10000,binsse(b,2)*10000);
                [ccgsII(:,:,b,a),strengthbyratiosII(b,:,a),strengthbyratediffsII(b,:,a),expectedsII(b,:,a),measuredsII(b,:,a),numprespikesII(b,:,a),numpostspikesII(b,:,a)] = ...
                    LocalGrabIntervalCCGCorrOverAllPairs(s,IIPairs,ConnectionStarts,ConnectionEnds,Flips,shank,tpack);
            end
        else
            ccgsII = [];
            strengthbyratiosII = [];
            strengthbyratediffsII = [];
            expectedsII = [];
            measuredsII = [];
            numprespikesII = [];
            numpostspikesII = [];
        end

    end

    %slopes for each pair for metric over each WS
    % for now not doing EI, IE etc
    [RatioSlopesAbsE,RatioSlopesNormE,MedianRatioSlopesAbsE,MedianRatioSlopesNormE] = ...
        localgetslopes(numeps,EPairs,strengthbyratiosE,bintimes,normtimes);
    [RateDiffSlopesAbsE,RateDiffSlopesNormE,MedianRateDiffSlopesAbsE,MedianRateDiffSlopesNormE] = ...
        localgetslopes(numeps,EPairs,strengthbyratediffsE,bintimes,normtimes);
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
    [RateDiffSlopesAbsI,RateDiffSlopesNormI,MedianRateDiffSlopesAbsI,MedianRateDiffSlopesNormI] = ...
        localgetslopes(numeps,IPairs,strengthbyratediffsI,bintimes,normtimes);
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
    strengthbyratediffsWSMedianE = median(strengthbyratediffsE,3);
    expectedsWSMedianE = median(expectedsE,3);
    measuredsWSMedianE = median(measuredsE,3);
    numprespikesWSMedianE = median(numprespikesE,3);
    numpostspikesWSMedianE = median(numpostspikesE,3);

    ccgsWSMedianI = median(ccgsI,4);
    strengthbyratiosWSMedianI = median(strengthbyratiosI,3);
    strengthbyratediffsWSMedianI = median(strengthbyratediffsI,3);
    expectedsWSMedianI = median(expectedsI,3);
    measuredsWSMedianI = median(measuredsI,3);
    numprespikesWSMedianI = median(numprespikesI,3);
    numpostspikesWSMedianI = median(numpostspikesI,3);

    ccgsWSMedianEE = median(ccgsEE,4);
    strengthbyratiosWSMedianEE = median(strengthbyratiosEE,3);
    strengthbyratediffsWSMedianEE = median(strengthbyratediffsEE,3);
    expectedsWSMedianEE = median(expectedsEE,3);
    measuredsWSMedianEE = median(measuredsEE,3);
    numprespikesWSMedianEE = median(numprespikesEE,3);
    numpostspikesWSMedianEE = median(numpostspikesEE,3);

    ccgsWSMedianEI = median(ccgsEI,4);
    strengthbyratiosWSMedianEI = median(strengthbyratiosEI,3);
    strengthbyratediffsWSMedianEI = median(strengthbyratediffsEI,3);
    expectedsWSMedianEI = median(expectedsEI,3);
    measuredsWSMedianEI = median(measuredsEI,3);
    numprespikesWSMedianEI = median(numprespikesEI,3);
    numpostspikesWSMedianEI = median(numpostspikesEI,3);

    ccgsWSMedianIE = median(ccgsIE,4);
    strengthbyratiosWSMedianIE = median(strengthbyratiosIE,3);
    strengthbyratediffsWSMedianIE = median(strengthbyratediffsIE,3);
    expectedsWSMedianIE = median(expectedsIE,3);
    measuredsWSMedianIE = median(measuredsIE,3);
    numprespikesWSMedianIE = median(numprespikesIE,3);
    numpostspikesWSMedianIE = median(numpostspikesIE,3);

    ccgsWSMedianII = median(ccgsII,4);
    strengthbyratiosWSMedianII = median(strengthbyratiosII,3);
    strengthbyratediffsWSMedianII = median(strengthbyratediffsII,3);
    expectedsWSMedianII = median(expectedsII,3);
    measuredsWSMedianII = median(measuredsII,3);
    numprespikesWSMedianII = median(numprespikesII,3);
    numpostspikesWSMedianII = median(numpostspikesII,3);



    SpikeTransferPerREMPortion = v2struct(EPairs,IPairs,ConnectionStarts,ConnectionEnds,Flips,...
        bintimes,normtimes,...
        MedianRatioSlopesNormE,MedianRatioSlopesAbsE,MedianRatioSlopesNormI,MedianRatioSlopesAbsI,...
        MedianRateDiffSlopesNormE,MedianRateDiffSlopesAbsE,MedianRateDiffSlopesNormI,MedianRateDiffSlopesAbsI,...
        MedianMeasuredsSlopesNormE,MedianMeasuredsSlopesAbsE,MedianMeasuredsSlopesNormI,MedianMeasuredsSlopesAbsI,...
        MedianExpectedsSlopesNormE,MedianExpectedsSlopesAbsE,MedianExpectedsSlopesNormI,MedianExpectedsSlopesAbsI,...
        MedianNumprespikesSlopesNormE,MedianNumprespikesSlopesAbsE,MedianNumprespikesSlopesNormI,MedianNumprespikesSlopesAbsI,...
        MedianNumpostspikesSlopesNormE,MedianNumpostspikesSlopesAbsE,MedianNumpostspikesSlopesNormI,MedianNumpostspikesSlopesAbsI,...
        RatioSlopesNormE,RatioSlopesAbsE,RatioSlopesNormI,RatioSlopesAbsI,...
        RateDiffSlopesNormE,RateDiffSlopesAbsE,RateDiffSlopesNormI,RateDiffSlopesAbsI,...
        MeasuredsSlopesNormE,MeasuredsSlopesAbsE,MeasuredsSlopesNormI,MeasuredsSlopesAbsI,...
        ExpectedsSlopesNormE,ExpectedsSlopesAbsE,ExpectedsSlopesNormI,ExpectedsSlopesAbsI,...
        NumprespikesSlopesNormE,NumprespikesSlopesAbsE,NumprespikesSlopesNormI,NumprespikesSlopesAbsI,...
        NumpostspikesSlopesNormE,NumpostspikesSlopesAbsE,NumpostspikesSlopesNormI,NumpostspikesSlopesAbsI,...
        ccgsWSMedianE,ccgsWSMedianI,ccgsE,ccgsI,...
        ccgsWSMedianEE,ccgsWSMedianEI,ccgsEE,ccgsEI,...
        ccgsWSMedianIE,ccgsWSMedianII,ccgsIE,ccgsII,...
        strengthbyratiosWSMedianE,strengthbyratiosE,strengthbyratiosWSMedianI,strengthbyratiosI,...
        strengthbyratediffsWSMedianE,strengthbyratediffsE,strengthbyratediffsWSMedianI,strengthbyratediffsI,...
        strengthbyratiosWSMedianEE,strengthbyratiosEE,strengthbyratiosWSMedianEI,strengthbyratiosEI,...
        strengthbyratediffsWSMedianEE,strengthbyratediffsEE,strengthbyratediffsWSMedianEI,strengthbyratediffsEI,...
        strengthbyratiosWSMedianIE,strengthbyratiosIE,strengthbyratiosWSMedianII,strengthbyratiosII,...
        strengthbyratediffsWSMedianIE,strengthbyratediffsIE,strengthbyratediffsWSMedianII,strengthbyratediffsII,...
        measuredsWSMedianE,measuredsE,measuredsWSMedianI,measuredsI,...
        expectedsWSMedianE,expectedsE,expectedsWSMedianI,expectedsI,...
        measuredsWSMedianEE,measuredsEE,measuredsWSMedianEI,measuredsEI,...
        expectedsWSMedianEE,expectedsEE,expectedsWSMedianEI,expectedsEI,...
        measuredsWSMedianIE,measuredsIE,measuredsWSMedianII,measuredsII,...
        expectedsWSMedianIE,expectedsIE,expectedsWSMedianII,expectedsII,...
        numprespikesWSMedianE,numprespikesE,numprespikesWSMedianI,numprespikesI,...
        numpostspikesWSMedianE,numpostspikesE,numpostspikesWSMedianI,numpostspikesI,...
        numprespikesWSMedianEE,numprespikesEE,numprespikesWSMedianEI,numprespikesEI,...
        numpostspikesWSMedianEE,numpostspikesEE,numpostspikesWSMedianEI,numpostspikesEI,...
        numprespikesWSMedianIE,numprespikesIE,numprespikesWSMedianII,numprespikesII,...
        numpostspikesWSMedianIE,numpostspikesIE,numpostspikesWSMedianII,numpostspikesII);
else
    SpikeTransferPerREMPortion = [];
end

save(fullfile(basepath,[basename '_SpikeTransferPerREMPortion.mat']),'SpikeTransferPerREMPortion')


function [ccgs,ratios,ratediffs,expecteds,measureds,numprespikes,numpostspikes] = ...
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
    ratediffs = [];
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

%        [tccg, tstrengthbyratio, tstrengthbyratediff,tnumprespikes, tnumpostspikes, tmeasured, texpected] = ...
%            ShortTimeCCG_rb(times1, times2, cnxnstartms, cnxnendms, ConvWidth, sameshank,...
%            windowstarts,windowends,'binSize', binsize, 'duration', duration);
       
       [strengthbyratio, strengthbyratediff, ccg, measured, expected] =...
            SpikeTransfer_Norm2(times1,times2,binSize,duration,[cnxnstartms cnxnendms],ConvWidth,sameshank,1);

        ccgs(:,i) = ccg;
        ratios(i) = strengthbyratio;
        ratediffs(i) = strengthbyratediff;
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
