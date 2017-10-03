function [ONInts, OFFInts] = DetectONAndOFFInSWS(S,okintervals)
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
minoffdur = 50;%milliseconds
maxoffdur = 1250;
minondur = 50;
maxondur = 4000;
% minONSpikes = length(S)/3;
minONSpikes = 10;

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

% OFFStarts = Start(OFFInts);
% OFFStops = End(OFFInts);
OFFInts = scale(OFFInts,10);%scale back from ms to 10000 points per sec for output

%% Find ON times based on OFF States... in normal intervalSet timescales
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
    if sum(t)>=minONSpikes
        goodONs(end+1) = a;
    end
end
ONInts = subset(ONInts,goodONs);

1;


