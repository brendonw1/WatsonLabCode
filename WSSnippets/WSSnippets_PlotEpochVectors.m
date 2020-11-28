function WSSnippets_PlotEpochVectors(ep1,ep2,RestrictIntMinutes,normby)

if ~exist('ep1','var')
    ep1 = 'WSSleep';
end
if ~exist('ep2','var')
    ep2 = [];
end
if ~exist('RestrictIntMinutes','var')
    RestrictIntMinutes = 20;
end
if ~exist('normby','var')
    normby = 'firstmin';
end
numbinsecs = 1;
plotsmoothmin = 1;

% binsperepoch = RestrictIntMinutes*60/numbinsecs;
IntSecs = RestrictIntMinutes*60;
binwidth = numbinsecs*10000;

SpikeWSSnippets = WSSnippets_GatherAllSpikeMedians(ep1,ep2);
StateRates = SpikingAnalysis_GatherAllStateRates;

nsess = length(SpikeWSSnippets.preSpikesE);
allvects = [];



for a = 1:nsess
    nwss = length(SpikeWSSnippets.postSpikesE{a});
    for b = 1:nwss
        ttsd = SpikeWSSnippets.postSpikesE{a}{b};
%         tstart = Start(SpikeWSSnippets.postEpoch{a}{b});
%         tend = IntSecs*10000+tstart;
        tstart = 0;
        tend = IntSecs*10000;
        RestrictInt = intervalSet(tstart,tend);
        ttsd = Restrict(ttsd,RestrictInt);
        bins = intervalSet(tstart:binwidth:tend-binwidth,tstart+binwidth:binwidth:tend);
        
        ttsd = MakeQfromS(ttsd,bins);
        if a == 1;
            times = Range(ttsd);
            times = times-times(1);
        end
        ttsd = Data(ttsd);
        if b == 1;
            tarray = ttsd;
        else
            tarray = cat(3,tarray,ttsd);
        end
    end
    tarray = mean(tarray,3);
    allvects = cat(1,allvects,tarray');
end

switch normby
    case 'zscore'
        
    case 'firstmin'
        normmin = 1;
        denoms = nanmean(allvects(:,1:round(normmin*60/numbinsecs)),2);
        denoms(denoms==0) = 1;
        av = bsxfun(@rdivide,allvects,denoms);
end

if plotsmoothmin == 0 | plotsmoothmin/numbinsecs<0.5
    binspersmooth = 1;
else
    binspersmooth = round(plotsmoothmin/numbinsecs);
end

%divide each vect by it's first value
qrk = GetQuartilesByRank(StateRates.EAllRates);
h = figure;
plot(smooth(mean(av(qrk==1,:),2),binspersmooth),'b')
hold on;
plot(smooth(mean(av(qrk==2,:),2),binspersmooth),'c')
plot(smooth(mean(av(qrk==3,:),2),binspersmooth),'g')
plot(smooth(mean(av(qrk==4,:),2),binspersmooth),'r')
legend({'q1(lowest)','q2','q3','q4(highest)'})
1;