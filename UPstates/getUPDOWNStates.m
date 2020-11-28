function UPDOWNIntervals = getUPDOWNStates(varargin)
% Finds "UP" and "DOWN" states during nonREM sleep epochs.  Uses a
% combination of spiking and LFP to do this.  Starts by finding phases of
% silence vs firing ("ON and OFF" phases as in Vyazovskiy 2009) and then
% verifies overlap of the OFF phases with periods of reduced gamma-band
% power, resulting in DOWN states.  Finally UP states are determined as
% periods between DOWN states.  All states have max and min durations
% hardcoded.
%
% USAGE
%
%    UPDOWNIntervals = getUPDOWNStates(varargin)
% 
% INPUTS - 'name',value pairs
%
%    basepath        -path to recording (where sessionInfo, spikes .lfp /etc files are)
%    noPrompts       -logical (default=false) to supress any user prompts
%    forceRedetect   -logical (default=false) to force loading from
%    saveMat         -logical (default=false) to save in buzcode format
%    UPStateChannel  -number of LFP channel on which to detect LFP events and to use
%                       as seed for finding local spikes.  Default is 
%                       sessionInfo.ChannelTags.UPStateChannel, or 1
%    spikeTrain      -list of spike times to use in seconds. This will determine 
%                       ON/OFF/UP/DOWN states.  (Default is to auto-load 
%                       all spikes in region or shank of UPChannel
%    NREMRestrict  -logical(default=true) determining whether to restrict
%                       all states to nonREM, based on SleepState.states.mat
%    screenUpsBySpikeNum - logical(default=true) whether or not to only
%                       keep UP states with minimum number of spikes (as 
%                       determined by constant minProportionOfExpectedSpikes
%    
% OUTPUTS
%
%    UPDOWNIntervals - Event type struct with the following fields
%       .OFFInts - Periods of neuronal silence
%       .ONInts - Times not inside OFFInts - periods when neurons fired
%       .GammaInts - LFP-based metric of times of reduced high gamma power
%                      (>100Hz)
%       .DNInts - OFFInts overlaping with GammaInts
%       .UPInts - Times between DNInts
% %       .detectorInfo - sub-struct with following fields
% %           .detectorname
% %           .detectorparms    struct with input parameters given
% %                                      to the detector, as well as min,max
% %                                      values and restriction intervals
% %                                      used
% %           .detectiondate
%
% NOTES
%
% This function can be used to either initially detect states or to load
% previously detected ones.
% 
% 
% first usage recommendation:
% 
%    UPDOWNIntervals = getUPDOWNStates('basepath',cd,'saveMat,true);
%           Detects up/downs in the current directory and saves results
%
% other examples:
%
%    UPDOWNIntervals = getUPDOWNStates('forceRedetect',true);
%       Redetects states, despite existence of previous 
%           Detects up/downs in the current directory and saves results
%
% written by Brendon Watson, 2015 & 2018





%% Get zero-level inputs taken care of (to check existence of previous UP/DOWN intervals
p = inputParser;
addParameter(p,'basepath',pwd,@isstr);
addParameter(p,'forceRedetect',false,@islogical);
addParameter(p,'saveMat',true,@islogical);
addParameter(p,'UPStateChannel',[],@isvector);
addParameter(p,'NREMRestrict',true,@islogical)
addParameter(p,'noPrompts',false,@islogical);
addParameter(p,'screenUpsBySpikeNum',true,@islogical)

parse(p,varargin{:})

basepath = p.Results.basepath;
saveMat = p.Results.saveMat;
forceRedetect = p.Results.forceRedetect;
UPStateChannel = p.Results.UPStateChannel;
NREMRestrict = p.Results.NREMRestrict;
noPrompts = p.Results.noPrompts;
screenUpsBySpikeNum = p.Results.screenUpsBySpikeNum;

basename = bz_BasenameFromBasepath(basepath);
[sessionInfo] = bz_getSessionInfo(basepath, 'noPrompts', noPrompts);

%% If state intervals already exist, just load those and exit
tfilename = fullfile(basepath,[basename '.UPDOWNIntervals.mat']);
if exist(tfilename,'file') && forceRedetect == false
    disp('loading UP/DOWN/GAMMAs from existing .mat.  No new detection needed.')
    disp('To re-detect set forceRedetect to true')
    load(tfilename)
    %Check that the structure is right
else
    disp('Starting to detect UP/DOWN/GAMMAs')

    %% Constants and related parameters
    % lfpsampfreq = 1250;

    minOFFDur_ms = 75;%milliseconds
    maxOFFDur_ms = 1250;
    minONDur_ms = 200;
    maxONDur_ms = 4000;
    % minONSpikes = 10;
    % minONSpikes = length(S)/3;
    minOKProportionOfExpectedSpikes = .5;

    maxOFFSpikesPerSecPerCell = 0.1; %mean spike rate per cell in frontal cx is 0.7 based on Watson 2016
    MostCommonOFF = 200; %From Watson 2016 Supp Fig4.  %geomean([minOFFDur maxOFFDur]);

    gammapowerthreshz = -.5;%zscore cutoff for low gamma power
    mingammaoffoverlap = minOFFDur_ms;
    secondsPerSpurious = 5;%number of seconds long each spurious LFP period will be smoothed with

    merging = 0;%whether to merge nearby DOWNs with minimal spiking between... or not (1=yes merge, 0=no)

    minDNDur_ms = minOFFDur_ms;
    maxDNDur_ms = maxOFFDur_ms;
    minUPDur_ms = minONDur_ms;
    maxUPDur_ms = maxONDur_ms;
    % minUPSpikes = minONSpikes;
    % lowpasscutoff = 4;%Hz for lowpass cutoff

    %% More input handling
    % get up state channel
    if isempty(UPStateChannel)
        if isfield(sessionInfo,'ChannelTags')
            if isfield(sessionInfo.ChannelTags,'UPChannel')
                UPChannel = sessionInfo.ChannelTags.UPChannel;
                disp(['UP/DOWN/Gamma channnel is ' num2str(UPChannel)])
            end
        else
            UPChannel = 1; % default
            disp(['Channel for detecting UP/DOWN/Gamma states is not found in sessionInfo,ChannelTags - using default value of channnel 1'])
        end
    end
    
    %Spikes... 
    spikes = bz_GetSpikes('basepath',basepath);
    %get spikes in region local to UPChannel if possible, or in local spike group
    regionsworked_boolean = 0;
    if isfield(sessionInfo,'region')
        try
            unitidxs = FindUnitsInThisRegion(UPChannel,spikes,sessionInfo);
            regionsworked_boolean = 1;
        catch
            disp('Use of Region info for unit collection failed - using shank')
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

    % get LFP
    lfpraw = bz_GetLFP(UPChannel,'basepath',basepath);
    lfpsampfreq = sessionInfo.lfpSampleRate;

    %% Calculating some more things based on constants and inputs
    poprate = length(allspikes)/(max(allspikes)-min(allspikes));
    maxOFFSpikes = maxOFFSpikesPerSecPerCell*NumCells*MostCommonOFF/1000;%
    spikesBetweenMergableDowns = round(0.05*NumCells);

    %% Convert seconds to milliseconds for binning
    ms_okintervals = okintervals*1000;
    ms_allspikes = allspikes*1000;
    % oki2 = scale(okintervals,1/10);

    %% Set up: OFF period starts and stops, based on binning to 1ms
    %while histcounts is recommended it's much slower than histc
    [ms_allspikesBinned] = histc(ms_allspikes,[0:1:max(ms_allspikes)]);%1ms binning... get spikes per millisecond for each millisecond
    % [ms_allspikesBinned2] = histcounts(ms_allspikes,[0:1:max(ms_allspikes)]);%1ms binning
    
    SpikesConvolved = conv(ms_allspikesBinned,ones(minOFFDur_ms,1));%find all times where was OFF for the minimum time
    OFFBinary = SpikesConvolved<=maxOFFSpikes;

    ms_OFFInts = continuousabove2(OFFBinary,0.5);
    ms_OFFInts(:,1) = ms_OFFInts(:,1)- (minOFFDur_ms-2);

    if NREMRestrict
        ms_OFFInts = IntersectEpochs(ms_OFFInts,ms_okintervals);
    end
    toolong = diff(ms_OFFInts,[],2)>maxOFFDur_ms;%get rid of those longer than max
    ms_OFFInts(toolong,:) = [];
    tooshort = diff(ms_OFFInts,[],2)<minOFFDur_ms;%get rid of those longer than max
    ms_OFFInts(tooshort,:) = [];

    clear OFFStarts OFFStops
    %% To LFP now - Find bouts of decreased gamma (ie DOWN states)... will match these with above OFFs

    %% Extract just the chunks from the right epochs (ie SWS/NREM) for filtering and zscoring to just in that interval
    status = InIntervals(lfpraw.timestamps,okintervals);
    lfpraw = double(lfpraw.data(status));

    [b,a] = butter(4,([100/(0.5*lfpsampfreq)]),'high');%create highpass filter for high gamma >100Hz
    gamma = filtfilt(b,a,lfpraw);%filter
    gamma = convtrim(abs(gamma),(1/250)*ones(1,250));%250ms rolling avg of 100+Hz signal
    gz = zscore(gamma);%zscore for standardization
    %Get rid of spurious times with super high gamma
    toohighwindow = secondsPerSpurious*lfpsampfreq;%number of samples long each spurious period must be
    smoothed = smooth(gz,toohighwindow);
    toohigh = continuousabove2(smoothed,0.5,toohighwindow,inf);%find times where it was too high
    spans = FindSettleBack(toohigh,smoothed,0.5);%find full span where above theshold of 2SD
    for a = 1:size(spans,1)
        gz(spans(a,1):spans(a,2)) = 0;
        smoothed(spans(a,1):spans(a,2)) = 0;
    end
    gz = zscore(gz);%zscore for standardization
    gz = gz-smooth(gz,lfpsampfreq);%get rid of 1sec timescale fluctuations

    gzt = zeros(round(max(max(okintervals))*1000),1);%in ms bins
    rix = find(status);
    gzt(round(rix*1000/lfpsampfreq)) = gz;

    minpts = mingammaoffoverlap*1000/lfpsampfreq;
    maxpts = maxOFFDur_ms*1000/lfpsampfreq;
    ms_dg = continuousbelow2(gzt,gammapowerthreshz,minpts,maxpts);%find periods of gamma below XSDs below mean... in time points
    % dg = round(dg*1000/eegsampfreq); %convert to ms

    clear lfpraw gamma smoothed toohigh spans gz gzt rix

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

    %% Combine OFFs and low Gamma periods
    % %old stuff for convexity I think
    % dcl = zeros(round(size(raw)*100afterDN = find(DN(:,1)>=ONStops(a) & DN(:,1)<DNStarts=(ONStops(a)+5));0/sampfreq));
    % for a = 1:size(dc,1);
    %     dcl(dc(a,1):dc(a,2)) = 1;
    % end

    % making logicals for fast comparison of overlap
    dgl = zeros(round(max(max(okintervals)))*1000,1);%millisecond bins which will be filled with gamma status
    offl = zeros(round(max(max(okintervals)))*1000,1);%millisecond bins which will be filled with OFF status
    for a = 1:size(ms_dg,1)
        dgl(ms_dg(a,1):ms_dg(a,2)) = 1;%set times of low gamma to 1
    end

    for a = 1:size(ms_OFFInts,1)
        offl(round(ms_OFFInts(a,1)):round(ms_OFFInts(a,2))) = 1;%set times of OFF to 1
    end
    if length(offl)>length(dgl)
        offl = offl(1:length(dgl));
    end

    ms_DN1 = dgl & offl;%look for overlap of lowgamma+OFF in ms
    ms_DN1 = continuousabove2(ms_DN1,1,minOFFDur_ms,maxOFFDur_ms);

    %% Merge nearaby DOWNstates separted by 2 spikes or less and spanning no more than maxoffdur
    if merging
        a = size(ms_DN1,1);
        ms_DNInts = [];
        while a>0
            thisstop = ms_DN1(a,2);
            thesedns = find(ms_DN1(:,1)>thisstop-maxOFFDur_ms & (1:length(ms_DN1))'<=a);%find all downs starting within maxOFFDur before end of this one
            a = thesedns(1)-1;%for next iteration of loop... may need to do this one at at time, but doubt it
            if length(thesedns)>1 %if some other downs found before this one
                for b = length(thesedns):-1:2%one at a time going backwards from the end
                    if ms_DN1(thesedns(b),1)-ms_DN1(thesedns(b)-1,2) < 25 %if the prior one ends less than 25ms before this one starts
                        spikecount = sum(AllUnits<=ms_DN1(thesedns(b),2) & AllUnits>=ms_DN1(thesedns(b)-1,1));
                        if spikecount<spikesBetweenMergableDowns%if dns are close and have 2 or fewer spikes between them, combine them
                            ms_DN1(thesedns(b)-1,:) = [ms_DN1(thesedns(b)-1,1) ms_DN1(thesedns(b),2)];
                            ms_DN1(thesedns(b),:) = [];
                            thesedns(b) = [];
                        end
                    end
                end
            end

            thesedns(thesedns>size(ms_DN1,1)) = [];%eliminate any indices that are now beyond the end of the number of DNs... rare problem
            for b = length(thesedns):-1:1%for all dns, regardless of whether singular or combined above
                theseoffs = find(ms_DN1(thesedns(b),2)>=ms_OFFInts(:,1) & ms_DN1(thesedns(b),1)<=OFFStops);
                ms_DNInts(end+1,:) = [ms_OFFInts(theseoffs(1),1) ms_OFFInts(theseoffs(end),2)];
            end
        end
        ms_DNInts = flipud(ms_DNInts);
        clear DN1
    else
        ms_DNInts = ms_DN1;
    end

    %% Freshly assess our new DOWN states according to max and min durs... after finding and manipulting them
    ms_DNTimes = zeros(size(SpikesConvolved));
    for a = 1:size(ms_DNInts,1)
        ms_DNTimes(ms_DNInts(a,1):ms_DNInts(a,2)) = 1;
    end
    ms_DNInts = continuousabove2(ms_DNTimes,1,minOFFDur_ms,maxOFFDur_ms);

    %% Go back and make sure each DN has timing defined by the OFF it overlaps with, not as above by it's overlap duration with gamma
    if NumCells>20
        [~, OFFidxs]=IntervalOverlaps(ms_DNInts, ms_OFFInts);
        ms_DNInts = [ms_OFFInts(OFFidxs,1) ms_OFFInts(OFFidxs,2)];%should be OK, since DNs should be shorter versions of OFFs and any double overlaps should be that 2 dns overlap 1 off
    else%... unless fewer than 20 units, then better to define using gamma times
        [~, Gammaidxs]=IntervalOverlaps(ms_DNInts, ms_dg);
        ms_DNInts = [ms_dg(Gammaidxs,1) ms_dg(Gammaidxs,2)];%should be OK, since DNs should be shorter versions of OFFs and any double overlaps should be that 2 dns overlap 1 off
    end    

    ms_DNInts = unique(ms_DNInts,'rows');
    toolong = diff(ms_DNInts,[],2)>maxDNDur_ms;%get rid of those longer than max
    ms_DNInts(toolong,:) = [];
    tooshort = diff(ms_DNInts,[],2)<minDNDur_ms;%get rid of those longer than max
    ms_DNInts(tooshort,:) = [];

    %% Find ON times based on DN States
    ms_ONInts = [ms_OFFInts(1:end-1,2) ms_OFFInts(2:end,1)];
    if NREMRestrict
        ms_ONInts = IntersectEpochs(ms_ONInts,ms_okintervals);
    end
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


    %% Find valid UP states, ie must be bounded by validated DOWN state...
     % Validated off must overlap with gamma power increase
%     ms_UPInts = ms_ONInts;%UPs start as ONs
%     [UPidxs, ~]=IntervalOverlaps([ms_UPInts(:,1)-minDNDur_ms ms_UPInts(:,1)],ms_DNInts);
%     %look for ups just about immediately preceded by DOWN states... 5ms
%     %interval ok (though in fact may not need this tolerance given how they are
%     %generated)
%     ms_UPInts = ms_UPInts(UPidxs,:);%only those preceded by good UPs
% 
%     %below not necesary since ONs are already restricted by length
%     % toolong = diff(ms_UPInts,[],2)>maxONDur_ms;%get rid of those longer than max
%     % ms_UPInts(toolong,:) = [];
%     % tooshort = diff(ms_UPInts,[],2)<minONDur_ms;%get rid of those longer than max
%     % ms_UPInts(tooshort,:) = [];


    ms_UPInts = [ms_DNInts(1:end-1,2) ms_DNInts(2:end,1)];
    if NREMRestrict
        ms_UPInts = IntersectEpochs(ms_UPInts,ms_okintervals);
    end
    toolong = diff(ms_UPInts,[],2)>maxUPDur_ms;%get rid of those longer than max
    ms_UPInts(toolong,:) = [];
    tooshort = diff(ms_UPInts,[],2)<minUPDur_ms;%get rid of those longer than max
    ms_UPInts(tooshort,:) = [];

    %screen for number of spikes
    if screenUpsBySpikeNum %if desired, Default = yes
        badUPs = zeros(size(ms_UPInts,1),1);
        UPstarts = ms_UPInts(:,1);
        UPstops = ms_UPInts(:,2);
        for a = 1:length(UPstarts)
            t = ms_allspikes>=UPstarts(a) & ms_allspikes<=UPstops(a);
            ExpectedBasedOnDur = (UPstops(a)-UPstarts(a))/1000*poprate;
            MinOKSpikesThisEvt = ExpectedBasedOnDur*minOKProportionOfExpectedSpikes;
            if sum(t)<MinOKSpikesThisEvt
                badUPs(a) = 1;
            end
        end
        ms_UPInts(find(badUPs),:) = [];
        clear UPstarts ONstops
    end    
    
    %% Milliseconds to seconds for final output
    UPInts = ms_UPInts/1000;%ms to seconds
    DNInts = ms_DNInts/1000;
    ONInts = ms_ONInts/1000;%ms to seconds
    OFFInts = ms_OFFInts/1000;%ms to seconds
    GammaInts = [ms_dg(:,1)/1000 ms_dg(:,2)/1000];

    %% Saving detection info
    detectorname = 'getUPDOWNStates.m';
    detectorvarargin = varargin;
    detectiondate = date;
    detectionparms = v2struct(minOFFDur_ms,maxOFFDur_ms,minONDur_ms,maxONDur_ms,...
        minOKProportionOfExpectedSpikes,maxOFFSpikesPerSecPerCell,MostCommonOFF,...
        gammapowerthreshz,mingammaoffoverlap,secondsPerSpurious,...
        merging,minDNDur_ms,maxDNDur_ms,minUPDur_ms,maxUPDur_ms);
    detectorInfo = v2struct(detectorname,detectorvarargin,detectiondate,detectionparms);
    
    %% Save
    UPDOWNIntervals = v2struct(UPInts,DNInts,ONInts, OFFInts, GammaInts,detectorInfo);
    if saveMat
        save (fullfile(basepath,[basename '.UPDOWNIntervals.mat']))
    end
end


%% Subfunctions
function eliminateduplicatespans(spans);

for a = length(spans):1
    thisspan = spans(a,:);
    otherspans = spans(1:a-1,:);
    thisspan = repmat(thisspan,[size(otherspans,1) 1]);
    diffs = ~logical(thisspan-otherspans);
    duplicates = diffs(:,1) & diffs(:,1);
    
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

function [i1,i2] = IntervalOverlaps(int1,int2)
% startstop pairs of rows int1 and int2 are inputs.
% function will output indices of overlapping intervals: i1 are indices of
% int1 that overlap with int2 elements.  i2 is indices of int2 that overlap
% with int1 elements.  

% starting with principle that a pair of intervals can be quickly
% determined to overlap if the start of one is before the stop of two AND
% the start of two is before the stop of one
[m11,m12]=meshgrid(int1(:,1),int2(:,2));%make repeating matrix of starts of 1 and stops of 2
m1 = (m12-m11)>=0;%find cases where start of 1 less than stop of 2
[m21,m22]=meshgrid(int1(:,2),int2(:,1));%make repeating matrix of starts of 2 and stops of 1
m2 = (m21-m22)>=0;%find cases where start of 2 less than stop of 1
m = m1.*m2;%find cases of full overlap using logicals

i1 = find(sum(m,1));
i1 = i1(:);
i2 = find(sum(m,2));
i2 = i2(:);
    

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



%% ARCHIVE
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
