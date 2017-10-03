function [UPInts, DNInts, ONInts, OFFInts, GammaInts] = DetectUPAndDOWNInSWS(S,okintervals,totalnumchannels,ChanToUse,basename)
% Finds "ON" and "OFF" intervals during SWS, with intention of relating to
% UP/DOWN states.  However this alorhithm is purely based on spiking: OFF
% periods are 50+ms of no spiking, ON periods are 50-4000ms, have at least
% 10 spikes... (may later want to make su rit is flanked by OFFs)
%
% Inputs
% spikestsd = tsdarray of all spikes from all cells in a dataset
% intervals = a 6 element cell array of all intervalarrays, with cell
%           component {3} being SWS intervals
%
% Outputs
% UPs and DNs are each intervalsets (tstoolbox), each interval in the set
% is an UP state or DOWN state interval, with timestamps at 10000hz, like tsdata
% (Could also output ONs and OFFs, which are based only on spiking, not
% cross validated with delta waves)
%
% OFFs - simple offs within the spans specified (50-1250ms)
% ONs - simple inversion of offs
% DNs - OFFs with low gamma too
% UPs - ONs following a DN and stopped by any OFF
% % % gUPs - UPs where start is based on gamma increase above threshold
%
% Brendon Watson Feb 2014 & Sept 2015

% ADRIEN'S VERSION:
% % Load the MUA (cluster 1) of shank ii
% mua = LoadMUAData(fbasename,ii);
% 
% % Merge it with all the isolated spikes of that shank. Shank is a vector giving shank number of each cell.
% mua = oneSeries([mua;S(shank==ii)]);
% 
% % epSws is the SWS epoch. 20 is an arbitrary minimal firing rate
% if rate(mua,epSws)>20
%        %You have to convert the mergerde ts in a tsdArray for MakeQfromS
%         q = MakeQfromS(tsdArray({mua}),50); 
%         %smooth it with a gaussian window (gausssmooth is a fnction of mine)
%         dq = gausssmooth(Data(q),20);
%         qs =  Restrict(tsd(Range(q),dq),epSws);
% 
%         %Select not too short epochs when smoothed firing rate is below 0.1Hz
%         dwEp{ii} = thresholdIntervals(qs,0.1,'Direction','Below');
%         dwEp{ii} = dropShortIntervals(dwEp{ii},800);
% 
%         %Select among these the epochs when unsmoothed global firing rate is 0 Hz.
%         % Prevent the headache afterDN = find(DN(:,1)>=ONStops(a) & DN(:,1)<DNStarts=(ONStops(a)+5));with single spikes etc etc. Might not be optimal.
%         rdw = Data(intervalRate(mua,dwEp{ii}));
%         dwEp{ii} = subset(dwEp{ii},find(rdw==0));
%     multiple    dwEp{ii} = dropLongIntervals(dwEp{ii},10000);
%       
%   end




%% basic parameters
eegsampfreq = 1250;

minoffdur = 75;%milliseconds
maxoffdur = 1250;
minondur = 200;
maxondur = 4000;
% minONSpikes = 10;
% minONSpikes = length(S)/3;
minOnSpikePropOfExpected = .5;
poprate = rate(oneSeries(S));
gammapowerthreshz = -.5;%zscore cutoff for low gamma power
mingammaoffoverlap = minoffdur;
merging = 0;%whether to merge nearby DOWNs with minimal spiking between... or not (1=yes merge, 0=no)

minDNDur = minoffdur;
maxDNDur = maxoffdur;
minUPDur = minondur;
maxUPDur = maxondur;
% minUPSpikes = minONSpikes;
% lowpasscutoff = 4;%Hz for lowpass cutoff


oki2 = scale(okintervals,1/10);

%% Set up: OFF period starts and stops, based on binning to 1ms
AllUnits = oneSeries(Restrict(S,okintervals));
AllUnits = TimePoints(AllUnits);%get spiketimes as a vector

[AllUnitsB,~] = histc(AllUnits,[0:10:max(AllUnits)]);%1ms binning

OFFTimes = conv(AllUnitsB,ones(minoffdur,1))==0;%find all times where was OFF for the minimum time
OFFStarts = find(diff(OFFTimes)>0);


OFFStarts = OFFStarts - (minoffdur-2);
OFFStops = find(diff(OFFTimes)<0)-1;


%% Housekeeping and saving OFFs as intervalset
if OFFStarts(1)>OFFStops(1)%if start of file was a period without SWS spikes
    OFFStops(1) = [];%delete spurious point
end
if OFFStarts(end)>OFFStops(end)%if end of file was a period without SWS spikes
    OFFStarts(end) = [];%delete spurious point
end

OFFInts = intervalSet(OFFStarts,OFFStops);%just for intersect command, but note these times are scaled by 0.1
OFFInts = intersect(OFFInts,oki2);
OFFInts = dropLongIntervals(OFFInts,maxoffdur);

OFFStarts = Start(OFFInts);
OFFStops = End(OFFInts);
OFFInts = scale(OFFInts,10);%scale back from ms to 10000 points per sec for output


%% Grab LFP to look at correlates with OFF states... to eventually define DOWN states
filename = getSessionEegLfpPath;
%     if exist([basename,'.eeg'],'file');
%         filename = [basename,'.eeg'];
%     elseif exist([basename,'.lfp'],'file');
%         filename = [basename,'.lfp'];
%     end
 
raw = LoadBinary(filename,'frequency',eegsampfreq,'nchannels',totalnumchannels,'channels',ChanToUse);
raw = double(raw);
raw = tsd(1/eegsampfreq*(1:length(raw))'*10000,raw);
[raw,rix] = Restrict(raw,okintervals);
% lfptimes = TimePoints(raw,'s');
raw = Data(raw);

%% Find bouts of decreased gamma (ie DOWN states)
[b,a] = butter(4,([100/(0.5*eegsampfreq)]),'high');%create highpass filter for high gamma >100Hz
gamma = filtfilt(b,a,raw);%filter
gamma = convtrim(abs(gamma),(1/250)*ones(1,250));%250ms rolling avg of 100+Hz signal
gz = zscore(gamma);%zscore for standardization
%Get rid of spurious times with super high gamma
toohighwindow = 5*eegsampfreq;%number of seconds/samples long each spurious period must be
smoothed = smooth(gz,toohighwindow);
toohigh = continuousabove2(smoothed,0.5,toohighwindow,inf);%find times where it was too high
spans = FindSettleBack(toohigh,smoothed,0.5);%find full span where above theshold of 2SD
for a = 1:size(spans,1);
    gz(spans(a,1):spans(a,2)) = 0;
    smoothed(spans(a,1):spans(a,2)) = 0;
end
gz = zscore(gz);%zscore for standardization
gz = gz-smooth(gz,eegsampfreq);%get rid of 1sec timescale fluctuations

gzt = zeros(round(LastTime(okintervals)/10),1);%in ms bins
gzt(round(rix*1000/eegsampfreq)) = gz;

dg = continuousbelow2(gzt,gammapowerthreshz,mingammaoffoverlap*1000/eegsampfreq,maxoffdur*1000/eegsampfreq);%find 50-500ms periods of gamma below 1SD below mean
% dg = round(dg*1000/eegsampfreq); %convert to ms

GammaInts = intervalSet(dg(:,1)*10,dg(:,2)*10);

clear raw gamma smoothed toohigh spans gz gzt rix

%BELOW: Gamma convexity stuff, not using: too complex and not necessary,%but seemingly accurate
%but seemingly accurate
% [b,a] = butter(4,([lowpasscutoff/(0.5*eegsampfreq)]),'low');%now look for ~4hz events
% fg = filtfilt(b,a,gamma);
% cg = diff(fg,2);%% 

%% Find times when the LFP trace has a delta-like deflection (2nd derivative is neg)
% [b,a] = butter(4,([lowpasscutoff/(0.5*eegsampfreq)]),'low');%now look for ~4hz events
% filtered = filtfilt(b,a,raw);
% convexity = diff(filtered,2);%take 2nd diff of LP filtered data
% dc = continuousbelow2(convexity,0,minoffdur*1000*eegsampfreq,0.75*eegsampfreq);
% dc = round(dc*1000/sampfreq); %convert to ms
% %gcratio = -convexity./gamma(1:length(convexity));

%% Handle data to combine it... look for times when OFF+LFPConvex+LowGamma
% dcl = zeros(round(size(raw)*100afterDN = find(DN(:,1)>=ONStops(a) & DN(:,1)<DNStarts=(ONStops(a)+5));0/sampfreq));
% for a = 1:size(dc,1);
%     dcl(dc(a,1):dc(a,2)) = 1;
% end

% making logicals for fast comparison of overlap
dgl = zeros(round(LastTime(okintervals))/10,1);%in ms
for a = 1:size(dg,1);
    dgl(dg(a,1):dg(a,2)) = 1;%set times of low gamma to 1
end

offl = zeros(round(LastTime(okintervals))/10,1);%in ms
for a = 1:size(OFFStarts,1)
    offl(round(OFFStarts(a)):round(OFFStops(a))) = 1;%set times of OFF to 1
end

DN1 = dgl & offl;%look for overlap of lowgamma+OFF in ms
DN1 = continuousabove2(DN1,1,minoffdur,maxoffdur);
% WriteEventFileFromTwoColumnEvents (initialdowns/1.25,[basename,'.fnl'])

%% Merge nearaby DOWNstates separted by 2 spikes or less and spanning no more than maxoffdur
if merging
    a = size(DN1,1);
    DN = [];
    while a>0
        thisstop = DN1(a,2);
        thesedns = find(DN1(:,1)>thisstop-maxoffdur & (1:length(DN1))'<=a);%find all downs starting within 1sec before end of this one
        a = thesedns(1)-1;%for next iteration of loop... may need to do this one at at time, but doubt it
        if length(thesedns)>=2 %if some other downs found before this one
            for b = length(thesedns):-1:2;%one at a time going backwards from the end
                if DN1(thesedns(b),1)-DN1(thesedns(b)-1,2) < 25; %if the prior one ends less than 25ms before this one starts
                    spikecount = sum(AllUnits<=DN1(thesedns(b),2) & AllUnits>=DN1(thesedns(b)-1,1));
                    if spikecount<2;%if dns are close and have 2 or fewer spikes between them, combine them
                        DN1(thesedns(b)-1,:) = [DN1(thesedns(b)-1,1) DN1(thesedns(b),2)];
                        DN1(thesedns(b),:) = [];
                        thesedns(b) = [];
                    end
                end
            end
        end

        thesedns(thesedns>size(DN1,1)) = [];%eliminate any indices that are now beyond the end of the number of DNs... rare problem
        for b = length(thesedns):-1:1%for all dns, regardless of whether singular or combined above
            theseoffs = find(DN1(thesedns(b),2)>=OFFStarts & DN1(thesedns(b),1)<=OFFStops);
            DN(end+1,:) = [OFFStarts(theseoffs(1)) OFFStops(theseoffs(end))];
        end
    end
    DN = flipud(DN);
    clear DN1
else
    DN = DN1;
end

DNTimes = zeros(size(OFFTimes));
for a = 1:size(DN,1)
    DNTimes(DN(a,1):DN(a,2)) = 1;
end

%clean up this messy thing more
DN = continuousabove2(DNTimes,1,minoffdur,maxoffdur);
%overall: must have offs >50ms overlapping with LDNStartsFP convexity+low gamma
% if within 15ms of each other may be combined, given LFP evidenece of down
% state, but if >2spikes, will be tossed

%% Go back and make sure each DN has timing defined by the OFF it overlaps with, not as above by it's overlap duration with gamma
if length(S)>20
    [~, OFFidxs]=IntervalOverlaps(DN,[OFFStarts OFFStops]);
    DN = [OFFStarts(OFFidxs) OFFStops(OFFidxs)];%should be OK, since DNs should be shorter versions of OFFs and any double overlaps should be that 2 dns overlap 1 off
else%... unless fewer than 20 units, then better to define using gamma times
    gammaStarts = Start(GammaInts)/10;
    gammaStops = End(GammaInts)/10;
    [~, Gammaidxs]=IntervalOverlaps(DN,[gammaStarts gammaStops]);
    DN = [gammaStarts(Gammaidxs) gammaStops(Gammaidxs)];%should be OK, since DNs should be shorter versions of OFFs and any double overlaps should be that 2 dns overlap 1 off
end    

DN = unique(DN,'rows');
DNInts = intervalSet(DN(:,1)*10, DN(:,2)*10);
DNInts = dropShortIntervals(DNInts,10*minDNDur);
DNInts = dropLongIntervals(DNInts,10*maxDNDur);

%% Find ON times based on DN States
ONInts = minus(intervalSet(0,LastTime(okintervals)),OFFInts);
ONInts = intersect(ONInts,okintervals);
%screen for duration
ONInts = dropShortIntervals(ONInts,minondur*10);
ONInts = dropLongIntervals(ONInts,maxondur*10);
%screen for number of spikes
AllUnits = TimePoints(oneSeries(S));
goodONs = [];
Osta = Start(ONInts);
Osto = End(ONInts);
for a = 1:length(length(ONInts))
    t = AllUnits>=Osta(a) & AllUnits<=Osto(a);
    ExpectedBasedOnDur = (Osto(a)-Osta(a))/10000*poprate;
    if sum(t)>=ExpectedBasedOnDur*minOnSpikePropOfExpected;
        goodONs(end+1) = a;
    end
%     t = Restrict(AllUnits,subset(ONInts,a));
%     if length(Data(t))>=minONSpikes
%         goodONs(end+1) = a;
%     end
end
ONInts = subset(ONInts,goodONs);


%% Find valid UP states, ie must be bounded by validated OFF state...
 % Validated off must overlap with delta
UPInts = ONInts;
[UPidxs, ~]=IntervalOverlaps([Start(UPInts)-250 Start(UPInts)],[Start(DNInts) End(DNInts)]);%look for ups preceded by DOWN states
UPInts = subset(UPInts,UPidxs);%only those preceded by good UPs
UPInts = dropShortIntervals(UPInts,minUPDur*10);
UPInts = dropLongIntervals(UPInts,maxUPDur*10);



function eliminateduplicatespans(spans);

for a = length(spans):1
    thisspan = spans(a,:);
    otherspans = spans(1:a-1,:);
    thisspan = repmat(thisspan,[size(otherspans,1) 1]);
    diffs = ~logical(thisspan-otherspans);
    duplicates = diffs(:,1) & diffs(:,1);
    
end

function varargout=continuousabove2(data,abovethresh,mintime,maxtime)
% function varargout=continuousabove(data,baseline,abovethresh,mintime,maxtime);
%
% Finds periods in a linear trace that are above some baseline by some
% minimum amount (abovethresh) for between some minimum amount of time
% (mintime) and some maximum amount of time (maxtime).  Output is the
% indices of start and stop of those periods in data.

above=find(data>=abovethresh);

if max(diff(diff(above)))==0 & length(above)>=mintime & length(above)<=maxtime;%if only 1 potential upstate found
    aboveperiods = [above(1) above(end)];
elseif length(above)>0;%if many possible upstates
	ends=find(diff(above)~=1);%find breaks between potential upstates
    ends(end+1)=0;%for the purposes of creating lengths of each potential upstate
    ends(end+1)=length(above);%one of the ends comes at the last found point above baseline
    ends=sort(ends);
    lengths=diff(ends);%length of each potential upstate
    good=find(lengths>=mintime & lengths<=maxtime);%must be longer than 500ms but shorter than 15sec
    ends(1)=[];%lose the 0 added before
    e3=reshape(above(ends(good)),[length(good) 1]);
    l3=reshape(lengths(good)-1,[length(good) 1]);
    aboveperiods(:,2)=e3;%upstate ends according to the averaged reading
    aboveperiods(:,1)=e3-l3;%upstate beginnings according to averaged reading
else
    aboveperiods=[];
end

varargout{1}=aboveperiods;
if nargout==2;
    if isempty(aboveperiods);
        belowperiods = [];
    else
        stops=aboveperiods(:,2);
        stops(2:end+1,1)=stops;
        stops(1)=0;
        stops=stops+1;

        starts=aboveperiods(:,1);
        starts(end+1,1)=length(data)+1;
        starts=starts-1;

        belowperiods=cat(2,stops,starts);

        if belowperiods(1,2)<=belowperiods(1,1);
            belowperiods(1,:)=[];
        end
        if belowperiods(end,2)<=belowperiods(end,1);
            belowperiods(end,:)=[];
        end
    end

    varargout{2}=belowperiods;
end


function varargout=continuousbelow2(data,belowthresh,mintime,maxtime)
% function varargout=continuousbelow(data,baseline,belowthresh,mintime,maxtime);
%
% Finds periods in a linear trace that are below some baseline by some
% minimum amount (belowthresh) for between some minimum amount of time
% (mintime) and some maximum amount of time (maxtime).  Output is the
% indices of start and stop of those periods in data.

below=find(data<=belowthresh);

if max(diff(diff(below)))==0 & length(below)>=mintime & length(below)<=maxtime;%if only 1 potential upstate found
    belowperiods = [below(1) below(end)];
elseif length(below)>0;%if many possible upstates
	ends=find(diff(below)~=1);%find breaks between potential upstates
    ends(end+1)=0;%for the purposes of creating lengths of each potential upstate
    ends(end+1)=length(below);%one of the ends comes at the last found point above baseline
    ends=sort(ends);
    lengths=diff(ends);%length of each potential upstate
    good=find(lengths>=mintime & lengths<=maxtime);%must be longer than 500ms but shorter than 15sec
    ends(1)=[];%lose the 0 added before
    e3=reshape(below(ends(good)),[length(good) 1]);
    l3=reshape(lengths(good)-1,[length(good) 1]);
    belowperiods(:,2)=e3;%upstate ends according to the averaged reading
    belowperiods(:,1)=e3-l3;%upstate beginnings according to averaged reading
else
    belowperiods=[];
end

varargout{1}=belowperiods;
if nargout==2;
    if isempty(belowperiods);
        aboveperiods = [];
    else
        stops=belowperiods(:,2);
        stops(2:end+1,1)=stops;
        stops(1)=0;
        stops=stops+1;

        starts=belowperiods(:,1);
        starts(end+1,1)=length(data)+1;
        starts=starts-1;

        aboveperiods=cat(2,stops,starts);

        if aboveperiods(1,2)<=aboveperiods(1,1);
            aboveperiods(1,:)=[];
        end
        if aboveperiods(end,2)<=aboveperiods(end,1);
            aboveperiods(end,:)=[];
        end
    end

    varargout{2}=aboveperiods;
end
    