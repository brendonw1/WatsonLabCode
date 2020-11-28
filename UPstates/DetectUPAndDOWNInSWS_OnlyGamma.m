function [UPInts, DNInts] = DetectUPAndDOWNInSWS(basename)
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
% Brendon Watson Feb 2014

% ADRIEN'S VERSION:
% % Load the MUA (cluster 1) of shank ii% [UPInts, DNInts] = DetectUPAndDOWNInSWS(S,intervals,Par.nChannels,goodeegchannel,basename);

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
minondur = 75;
maxondur = 4000;
lowpasscutoff = 4;%Hz for lowpass cutoff

%% Set up: gathering spike times and binning to 1ms
% AllUnits = oneSeries(spikestsd);
% AllUnits = TimePoints(AllUnits);%get spiketimes as a vector
% 
% [AllUnitsB,ind] = histc(AllUnits,[0:10:max(AllWriteEventFileFromIntervalSet (UPInts,[basename,'.UP1.evt'])
% 
% %% Get OFF period starts and stops, based on cell firing
% OFFTimes = conv(AllUnitsB,ones(minoffdur,1))==0;%find all times where was OFF for the minimum time
% 
% OFFStarts = find(diff(OFFTimes)>0);
% OFFStarts = OFFStarts - (minoffdur-2);
% OFFStops = find(diff(OFFTimes)<0)-1;
% % nofiring = AllUnits==0;
% % nofiringstarts = find(diff(nofiring)<0);
% % nofiringstops = find(diff(nofiring)>0);
% % intervallengths =  nofiringstops - nofiringstarts; 
% % keepers = find(intervallengths>=500);
% if OFFStarts(1)>OFFStops(1)%if start of file was a period without SWS spikes
%     OFFStops(1) = [];%delete spurious point
% end
% if OFFStarts(end)>OFFStops(end)%if end of file was a period without SWS spikes
%     OFFStarts(end) = [];%delete spurious point
% end
% 
% OFFIntervals = intervalSet(OFFStarts,OFFStops);
% OFFIntervals = intersect(OFFIntervals,scale(intervals{3},0.1));
% OFFStarts = Start(OFFIntervals);
% OFFStops = End(OFFIntervals);
% 

%% Grab LFP to look at correlates with OFF states... to eventually define DOWN states
 
% % basename = 'BWRat20_101513';
% if ~strcmp(basename(end-3:end),'.eeg') && ~strcmp(basename(end-3:end),'.lfp')
    if exist([basename,'.eeg'],'file');
        filename = [basename,'.eeg'];
    elseif exist([basename,'.lfp'],'file');
        filename = [basename,'.lfp'];
    end
% end
 
% totalnumchannels = 72;
% ChanToUse = 48;
% raw = LoadLfp(filename,totalnumchannels,ChanToUse);
t = load([basename '_BasicMetaData.mat']);
totalnumchannels = t.Par.nChannels;
ChanToUse = t.UPstatechannel;
vpm = t.voltsperunit;

raw = LoadBinary(filename,'frequency',eegsampfreq,'nchannels',totalnumchannels,'channels',ChanToUse);
raw = double(raw);

raw = raw*vpm;

intervals = load([basename '_Intervals']);
intervals = intervals.intervals;

%% Find bouts of decreased gamma (ie DOWN states)
[b,a] = butter(4,([100/(0.5*eegsampfreq)]),'high');%create highpass filter for high gamma >100Hz
gamma = filtfilt(b,a,raw);%filter
gamma = convtrim(abs(gamma),(1/250)*ones(1,250));%250ms rolling avg of 100+Hz signal
gz = zscore(gamma);%zscore for standardization
dg = continuousbelow2(gz,-1,minoffdur*1000/eegsampfreq,maxoffdur*1000/eegsampfreq);%find 50-500ms periods of gamma below 1SD below mean
dg = round(dg*1000/eegsampfreq); %convert to ms
%BELOW: Gamma convexity stuff, not using: too complex and not necessary,%but seemingly accurate
dgi = intervalSet(dg(:,1),dg(:,2));
dgi = intersect(dgi,scale(intervals{3},0.1));
dg2 = [Start(dgi) End(dgi)];

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

dgl = zeros(round(size(raw)*1000/eegsampfreq));
for a = 1:size(dg2,1);
    dgl(dg2(a,1):dg2(a,2)) = 1;
end

% offl = zeros(round(size(raw)*1000/eegsampfreq));
% for a = 1:size(OFFStarts,1)
%     offl(round(OFFStarts(a)):round(OFFStops(a))) = 1;
% endWriteEventFileFromIntervalSet (UPInts,[basename,'.UP1.evt'])
% 
% DN1 = dgl & dcl & offl;
% DN1 = continuousabove2(DN1,1,5,eegsampfreq);
% DN1 = dgl & offl;
% DN1 = continuousabove2(DN1,1,5,eegsampfreq);
% WriteEventFileFromTwoColumnEvents (initialdowns/1.25,[basename,'.fnl'])

%% Handle messy cases, clean up downstates
% a = size(DN1,1);
% DN = [];
% while a>0
% %     disp(0);
%     thisstart = DN1(a,1);
%     thisstop = DN1(a,2);
%     thesedns = find(DN1(:,1)>thisstop-1000 & (1:length(DN1))'<=a);%find all downs withn 1sec before end of this one
%     a = thesedns(1)-1;%for next iteration of loop... may need to do this one at at time, but doubt it
% %     disp(1);
%     if length(thesedns)>=2 %if some other downs found before this one
% %     disp(2);DNStarts
%         for b = length(thesedns):-1:2;%one at a time going backwards from the end
% %     disp(3);
%                 
%                
%             if DN1(thesedns(b),1)-DN1(thesedns(b)-1,2) < 25; %if the prior one ends less than 15ms before this ones starts
% %     disp(4);@
%                 spikecount = sum(AllUnits<=DN1(thesedns(b),2) & AllUnits>=DN1(thesedns(b)-1,1));
%                 if spikecount<2;%if dns close and have 2 or fewer spikes between them, combine them
% %     disp(5);
%                     DN1(thesedns(b)-1,:) = [DN1(thesedns(b)-1,1) DN1(thesedns(b),2)];
%                     DN1(thesedns(b),:) = [];
%                     thesedns(b) = [];
% %     disp(6);
% 
% %                 else %if not, do nothing... later will scrre
%                 end
%             end
%         end
% %     else%if this dn is isolate wi% a = size(DN1,1);
% DN = [];
% while a>0
% %     disp(0);
%     thisstart = DN1(a,1);
%     thisstop = DN1(a,2);
%     thesedns = find(DN1(:,1)>thisstop-1000 & (1:length(DN1))'<=a);%find all downs withn 1sec before end of this one
%     a = thesedns(1)-1;%for next iteration of loop... may need to do this one at at time, but doubt it
% %     disp(1);
%     if length(thesedns)>=2 %if some other downs found before this one
% %     disp(2);DNStarts
%         for b = length(thesedns):-1:2;%one at a time going backwards from the end
% %     disp(3);
%                 
%                
%             if DN1(thesedns(b),1)-DN1(thesedns(b)-1,2) < 25; %if the prior one ends less than 15ms before this ones starts
% %     disp(4);@
%                 spikecount = sum(AllUnits<=DN1(thesedns(b),2) & AllUnits>=DN1(thesedns(b)-1,1));
%                 if spikecount<2;%if dns close and have 2 or fewer spikes between them, combine them
% %     disp(5);
%                     DN1(thesedns(b)-1,:) = [DN1(thesedns(b)-1,1) DN1(thesedns(b),2)];
%                     DN1(thesedns(b),:) = [];
%                     thesedns(b) = [];
% %     disp(6);
% 
% %                 else %if not, do nothing... later will scrre
%                 end
%             end
%         end
% %     else%if this dn is isolate without others before it
%     end
%   Times
% %     %%Define based on offs they overlap with... combine all overalapped
% %     %multiple%OFFs (each is at least 50ms, so this guarantees 50ms, won't add spikes to the 2 spikes above)
% %     disp(7);
%     for b = length(thesedns):-1:1%for all dns, regardless of whether singular or combined above
% %     disp(7.5);
%         theseoffs = find(DN1(thesedns(b),2)>=OFFStarts & DN1(thesedns(b),1)<=OFFStops);
% %         if OFFStarts(theseoffs(1)) == 3149996;in
% %             1;
% %         end
%         DN(end+1,:) = [OFFStarts(theseoffs(1)) OFFStops(theseoffs(end))];
%     end
% end
% DN = flipud(DN);
% clear DN1 sorry I'll miss the kids - perhaps we'll cross paths in Ann Arbor over the summer or fall?

% 
% DNTimes = zeros(size(OFFTimes));
% % DNStarts = DN(:,1);
% % DNStops = DN(:,2);
% for a = 1:size(DN,1)
%     DNTimes(DN(a,1):DN(a,2)) = 1;
% end
% 
% %clean up this messy thing more
% DN = continuousabove2(DNTimes,1,minoffdur,maxoffdur);
%         
% %overall: must have offs >50ms overlapping with LDNStartsFP convexity+low gamma
% % if within 15ms of each other may be combined, given LFP evidenece of down
% % state, but if >2spikes, will be tossed
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % %% Find prominent positive delta waves
% % deltas = DetectDeltaWaves(basename);
% % deltas = round(deltas/eegsampfreq*1000);%convert to milliseconds to match with ONs/OFFs
% 
% % %% Determine which OFFs are coincident with delta waves
% % DNStarts = [];
% % DNStops = [];
% % DNTimes = zeros(size(OFFTimes));Times
% % for a = 1:length(OFFStarts);
% %     overlap = 0;
% %     thisdelta = find(deltas(:,2)>OFFStarts(a) & deltas(:,1)<OFFStops(a));
% %     if ~isempty(thisdelta)
% %         for b = 1:length(thisdelta)
% %             thisdeltatimes = deltas(thisdelta,:);
% %             overlap(b) = length(intersect([OFFStarts(a):OFFStops(a)],[thisdeltatimes(1):thisdeltatimes(2)]));
% %         end
% %     end
% %     overlap = max(overlap);
% %     if overlap>50
% %         DNStarts(end+1) = OFFStarts(a);
% %         DNStops(end+1) = OFFStops(a);
% %         DNTimes(DNStarts(end):DNStops(end)) = 1;
% %     end
% % end
%     end
%   
% %     %%Define based on offs they overlap with... combine all overalapped
% %     %multiple%OFFs (each is at least 50ms, so this guarantees 50ms, won't add spikes to the 2 spikes above)
% %     disp(7);
%     for b = length(thesedns):-1:1%for all dns, regardless of whether singular or combined above
% %     disp(7.5);
%         theseoffs = find(DN1(thesedns(b),2)>=OFFStarts & DN1(thesedns(b),1)<=OFFStops);
% %         if OFFStarts(theseoffs(1)) == 3149996;
% %             1;
% %         end
%         DN(end+1,:) = [OFFStarts(theseoffs(1)) OFFStops(theseoffs(end))];
%     end
% end
% DN = flipud(DN);
% clear DN1
% 
% DNTimes = zeros(size(OFFTimes));
% % DNStarts = DN(:,1);
% % DNStops = DN(:,2);
% for a = 1:size(DN,1)
%     DNTimes(DN(a,1):DN(a,2)) = 1;
% end
% 
% %clean up this messy thing more
% DN = continuousabove2(DNTimes,1,minoffdur,maxoffdur);
%         
% %overall: must have offs >50ms overlapping with LDNStartsFP convexity+low gamma
% % if within 15ms of each other may be combined, given LFP evidenece of down
% % state, but if >2spikes, will be tossed
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % %% Find prominent positive delta waves
% % deltas = DetectDeltaWaves(raw);
% % deltas = round(deltas/eegsampfreq*1000);%convert to milliseconds to match with ONs/OFFs
% % 
% % %% Determine which OFFs are coincident with delta waves
% % DNStarts = [];
% % DNStops = [];
% % DNTimes = zeros(size(OFFTimes));
% % for a = 1:length(OFFStarts);
% %     overlap = 0;
% %     thisdelta = find(deltas(:,2)>OFFStarts(a) & deltas(:,1)<OFFStops(a));
% %     if ~isempty(thisdelta)
% %         for b = 1:length(thisdelta)
% %             thisdeltatimes = deltas(thisdelta,:);
% %             overlap(b) = length(intersect([OFFStarts(a):OFFStops(a)],[thisdeltatimes(1):thisdeltatimes(2)]));
% %         end
% %     end
% %     overlap = max(overlap); sorry I'll miss the kids - perhaps we'll cross paths in Ann Arbor over the summer or fall?
% %     if overlap>50
% %         DNStarts(end+1) = OFFStarts(a);
% %         DNStops(end+1) = OFFStops(a);
% %         DNTimes(DNStarts(end):DNStops(end)) = 1;
% %     end
% % end

DNStartStop = continuousabove2(dgl,0.5,minoffdur,maxoffdur);
DNTimes = zeros(round(size(raw)*1000/eegsampfreq));
for a = 1:size(DNStartStop,1);
    DNTimes(DNStartStop(a,1):DNStartStop(a,2)) = 1;
end

%% Find ON times based on DN Statesin
ONTimes = ~DNTimes;%Candidate on-times are opposite of off-times
ONStarts = find(diff(ONTimes)>0)+1;%find starts and shift appropriately
ONStops = find(diff(ONTimes)<0);
% ONStops = ONStops - (minoffdur-1);
if ONStarts(1)>ONStops(1)%if start of file was a period with SWS spikes
    ONStops(1) = [];%delete spurious point
end
if ONStarts(end)>ONStops(end)%if end of file was a period with SWS spikes
    ONStarts(end) = [];%delete spurious point
end
% %% Determine which OFFs are coincident with delta waves
% DNStarts = [];
% DNStops = [];
% DNTimes = zeros(size(OFFTimes));
% for a = 1:le% DNStarts = DN(:,1);DNStarts
% DNStops = DN(:,2);
% ngth(OFFStarts);
%     overlap = 0;
%     thisdelta = find(deltas(:,2)>OFFStarts(a) & deltas(:,1)<OFFStops(a));
%     if ~isempty(thisdelta)
%         for b = 1:length(thisdelta)
%             thisdeltatimes = deltas(thisdelta,:);
%             overlap(b) = length(intersect([OFFStarts(a):OFFStops(a)],[thisdeltatimes(1):thisdeltatimes(2)]));
%         end
%     end
%     overlap = max(overlap);
%     if overlap>50
%         DNStarts(end+1) = OFFStarts(a);
%         DNStops(end+1) = OFFStops(a);
%         DNTimes(DNStarts(end):DNStops(end)) = 1;
%     end
% end

%screen for duration
goodONs = ((ONStops-ONStarts)>=minondur & (ONStops-ONStarts)<=maxondur);%keep only ON periods with between the desired durations
ONStarts = ONStarts(goodONs);
ONStops = ONStops(goodONs);

% %screen for number of spikes
% for a=size(ONStarts,1):-1:1
%     if sum(AllUnitsB(ONStarts(a):ONStops(a)))<10
%         ONStarts(a)=[];
%         ONStops(a)=[];
%     end
% end


%% Find valid ON states, ie must be bounded by validated OFF state...
 % Validated off must overlap with delta
UPStarts = [];
UPStops = [];
for a = 1:length(ONStarts) 
    beforeDN = find(DNStartStop(:,2)<=ONStarts(a) & DNStartStop(:,2)>=(ONStarts(a)-5));
    afterDN = find(DNStartStop(:,1)>=ONStops(a) & DNStartStop(:,1)<=(ONStops(a)+5));

    if ~isempty(beforeDN) && ~isempty(afterDN)
        UPStarts(end+1) = ONStarts(a);
        UPStops(end+1) = ONStops(a);
    end
    %     Look for neighboring off that is interesecting with delta
end

%% Format for output... was at ms resolution, increase to 0.1ms resolution timestamps

UPInts = intervalSet(UPStarts*10, UPStops*10);%convert to intervals, at 10000hz, was a 1ms resolution
DNInts = intervalSet(DNStartStop(:,1)*10, DNStartStop(:,2)*10);




% function eliminateduplicatespans(spans);
% 
% for a = length(spans):1
%     thisspan = spans(a,:);
%     otherspans = spans(1:a-1,:);
%     thisspan = repmat(thisspan,[size(otherspans,1) 1]);
%     diffs = ~logical(thisspan-otherspans);
%     duplicates = diffs(:,1) & diffs(:,1);
%     
% end


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