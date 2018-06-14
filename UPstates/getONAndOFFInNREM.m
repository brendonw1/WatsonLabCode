function ONOFFIntervals = getONAndOFFInNREM(basepath)
% function [ONInts, OFFInts] = DetectONAndOFFInSWS(allspikes,okintervals,NumCells)
% CHANGED INPUT OF S TO A LIST OF SPIKE TIMES OF ALL RELEVANT SPIKES... IN
% SECONDS
% 
% Finds "ON" and "OFF" intervals during SWS, with intention of relating to
% UP/DOWN states.  However this alorhithm is purely based on spiking: OFF
% periods are 50+ms of no spiking, ON periods are 50-4000ms, have at least
% 10 spikes... (may later want to make su rit is flanked by OFFs)
%
% Inputs
% spikestsd = tsdarray of all spikes from all cells in a dataset
% intervals = a 6 element cell array of all intervalarrays, with cell
%           component {3} being SWS intervals
%%    forceReload     -logical (default=false) to force loading from
%                     res/clu/spk files

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


%% Get zero-level inputs taken care of (to check existence of previous UP/DOWN intervals
if ~exist('basepath','var')
    basepath = cd;
    basename = bz_BasenameFromBasepath(basepath);
end
sessionInfo = bz_getSessionInfo(basepath);

%% If state intervals already exist, just load those and exit
tfilename = [basepath filesep basepath '.ONOFFIntervals.mat'];
if exist(tfilename,'file') && forceReload == false
    disp('loading UP/DOWN/GAMMAs from existing .mat.  No new detection needed.')
    load(tfilename)
    %Check that the structure is right
else


    %% basic parameters
    minOFFDur_ms = 75;%milliseconds
    maxOFFDur_ms = 1250;
    minONDur_ms = 200;
    maxONDur_ms = 4000;
    % minONSpikes = NumCells/3;
    minOKProportionOfExpectedSpikes = .5;

    maxOFFSpikesPerSecPerCell = 0.1; %mean spike rate per cell in frontal cx is 0.7 based on Watson 2016
    MostCommonOFF = 200; %From Watson 2016 Supp Fig4.  %geomean([minOFFDur maxOFFDur]);

    %% Input handling
    % get up state channel
    if isfield(sessionInfo,'ChannelTags')
        if isfield(sessionInfo.ChannelTags,'UPChannel')
            UPChannel = sessionInfo.ChannelTags.UPChannel;
            disp(['UP/DOWN/Gamma channnel is ' num2str(UPChannel)])
        end
    else
        UPChannel = 1; % default
        disp(['Channel for detecting UP/DOWN/Gamma states is not found in sessionInfo,ChannelTags - using default value of channnel 1'])
    end

    %Spikes... 
    spikes = bz_GetSpikes('basepath',basepath);
    %get spikes in region local to UPChannel if possible, or in local spike group
    regionsworked_boolean = 0;
    if isfield(sessionInfo,'region')
        try
            unitidxs = FindUnitsInThisRegion(UPChannel,spikes,sessionInfo);
            regionsworked_boolean = 1;
        end
    end
    if regionsworked_boolean == 0
        disp('Using spikes from local shank rather than local region because no region info found in sessionInfo.  Add region info to sessionInfo to improve detection.')
        unitidxs = FindUnitsOnThiShank(UPChannel,spikes,sessionInfo);%function below
    end
    %combine spikes from all relevant cells to one single train
    allspikes = [];
    for a = 1:length(unitidxs)
        allspikes = cat(1,allspikes,spikes.times{unitidxs(a)});
    end
    allspikes = sort(allspikes);
    NumCells = length(unitidxs);

    %get states
    SleepState = bz_LoadStates(basepath,'SleepState');
    okintervals = SleepState.ints.NREMstate;


    %% Calculating some more things based on constants and inputs
    poprate = length(allspikes)/(max(allspikes)-min(allspikes));
    maxOFFSpikes = maxOFFSpikesPerSecPerCell*NumCells*MostCommonOFF/1000;%
    % minONSpikes = 10;


    %% Convert seconds to milliseconds for binning
    ms_okintervals = okintervals*1000;
    ms_allspikes = allspikes*1000;

    %% Set up: OFF period starts and stops, based on binning to 1ms
    %while histcounts is recommended it's much slower than histc
    [ms_allspikesBinned] = histc(ms_allspikes,[0:1:max(ms_allspikes)]);%1ms binning... get spikes per millisecond for each millisecond
    % [ms_allspikesBinned2] = histcounts(ms_allspikes,[0:1:max(ms_allspikes)]);%1ms binning


    SpikesConvolved = conv(ms_allspikesBinned,ones(minOFFDur_ms,1));%find all times where was OFF for the minimum time
    OFFBinary = SpikesConvolved<=maxOFFSpikes;

    ms_OFFInts = continuousabove2(OFFBinary,0.5);
    ms_OFFInts(:,1) = ms_OFFInts(:,1)- (minOFFDur_ms-2);

    ms_OFFInts = IntersectEpochs(ms_OFFInts,ms_okintervals);
    toolong = diff(ms_OFFInts,[],2)>maxOFFDur_ms;%get rid of those longer than max
    ms_OFFInts(toolong,:) = [];
    tooshort = diff(ms_OFFInts,[],2)<minOFFDur_ms;%get rid of those longer than max
    ms_OFFInts(tooshort,:) = [];

    %% Find ON times based on OFF States... in normal intervalSet timescales
    ms_ONInts = [ms_OFFInts(1:end-1,2) ms_OFFInts(2:end,1)];
    ms_ONInts = IntersectEpochs(ms_ONInts,ms_okintervals);

    %screen for duration
    toolong = diff(ms_ONInts,[],2)>maxONDur_ms;%get rid of those longer than max
    ms_ONInts(toolong,:) = [];
    tooshort = diff(ms_ONInts,[],2)<minONDur_ms;%get rid of those longer than max
    ms_ONInts(tooshort,:) = [];

    %screen for number of spikes
    badONs = zeros(size(ms_ONInts,1),1);
    ONstarts = ms_ONInts(:,1);
    ONstops = ms_ONInts(:,2);
    for a = 1:length(ONstarts)
        t = ms_allspikes>=ONstarts(a) & ms_allspikes<=ONstops(a);
        ExpectedBasedOnDur = (ONstops(a)-ONstarts(a))/1000*poprate;
        MinOKSpikesThisEvt = ExpectedBasedOnDur*minOKProportionOfExpectedSpikes;
        if sum(t)<MinOKSpikesThisEvt
            badONs(a) = 1;
        end
    end
    ms_ONInts(find(badONs),:) = [];

    %% Milliseconds to seconds
    OFFInts = ms_OFFInts/1000;%ms to seconds
    ONInts = ms_ONInts/1000;%ms to seconds

    %% Save output
    ONOFFIntervals = v2struct(ONInts, OFFInts);
    save (fullfile(basepath,[basename '.ONOFFIntervals.mat']))
end



function varargout=continuousabove2_v2(data,abovethresh,mintime,maxtime)
% function varargout=continuousabove(data,abovethresh,mintime,maxtime);
%
% Finds periods in a linear trace that are above or equal to some
% minimum amount (abovethresh) for between some minimum amount of time
% (mintime) and some maximum amount of time (maxtime).  
% Output 1 is indices of starts of those periods in data.  If a second
% output is specified, that will be the stoptimes.
% Differs from continuousabove.m by not needing a baseline input variable

if ~exist('mintime','var')
    mintime = 0;
end
if ~exist('maxtime','var')
    maxtime = inf;
end

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

function unitidxs = FindUnitsInThisRegion(startchannel,spikes,sessionInfo)
%find units on channels in the region of startchannel
channelsthisregion = [];
tregion = sessionInfo.region{startchannel};
for a = 1:length(sessionInfo.region)
    if strcmp(tregion,sessionInfo.region{a})
        channelsthisregion(end+1) = a;
    end
end
unitidxs = ismember(spikes.maxWaveformCh,channelsthisregion);
unitidxs = find(unitidxs);


function unitidxs = FindUnitsOnThiShank(startchannel,spikes,sessionInfo)
% find units on shank of startchannel
for a = 1:length(sessionInfo.spikeGroups.groups);
    t = sessionInfo.spikeGroups.groups{a};
    if ismember(startchannel,t);
        tshank = a;
        break
    end
end
% find units on that shank
unitidxs = spikes.shankID==tshank;
unitidxs = find(unitidxs);