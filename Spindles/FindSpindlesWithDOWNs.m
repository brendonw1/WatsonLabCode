function SpindlesNoDown = FindSpindlesWithDOWNs(basepath,basename)
% Find which ups are spindle ups, partial spindle ups etc
% also save those events.


if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

%% get Spindles info
load(fullfile(basepath,'Spindles','SpindleData.mat'),'SpindleData')
normspindles = SpindleData.normspindles;
sp_starts = normspindles(:,1);
sp_stops = normspindles(:,3);
DetectionParams = SpindleData.DetectionParams;

%% get ups
t = load(fullfile(basepath,[basename, '_UPDOWNIntervals']));
UPints = t.UPInts;
UPstarts = Start(UPints,'s');
UPstops = End(UPints,'s');


%% for each spindle, get periods inside ups only / or toss outside ups
changedpeak = [];
for a = 1:length(sp_starts)
%     find first upstops after this start
    endupidxs = find(UPstops>sp_starts(a));%find all stops after this start.  But in case two UPs in same spindle...
    endupidx = find(UPstops(endupidxs)<sp_stops(a),1,'last');%of those starting after this, find the last one ending before the stop
    endupidx = endupidxs(endupidx);
    newspstop = min([sp_stops(a) UPstops(endupidx)]);%trunkate this sp_stop by this upstop
    
%     find last upstarts before ths stop
    startupidxs = find(UPstarts<sp_stops(a));%find all starts before this stop.  But in case two UPs in same spindle...
    startupidx = find(UPstarts(startupidxs)>sp_starts(a),1,'first');%of those starting after this, find the last one ending before the stop
    startupidx = startupidxs(startupidx);
    newspstart = max([sp_starts(a) UPstarts(startupidx)]); %trunkate this sp_start by this upstart

    % if spindle spans end of one up to start of next (so last end is
    % before first start)
    if ~isempty(startupidx) && ~isempty(endupidx)
        if endupidx<startupidx
            newspstart = sp_starts(a);%just take the start of the spindle as the start
        end
    end
    
% makes sure peak is still remaining in spindle
    tsppeak = normspindles(a,2);
    if tsppeak>newspstart && tsppeak<newspstop
        newsppeak = tsppeak;
    else
%... if not, call it the start or stop, depending on which was closer to it
        starttopeakdist = abs(tsppeak-newspstart);
        stoptopeakdist = abs(tsppeak-newspstop);
        if starttopeakdist < stoptopeakdist
            newsppeak = newspstart+0.001;%add a millisecond because some stat computations get messed up if not
            changedpeak(end+1) = a;
        elseif starttopeakdist > stoptopeakdist
            newsppeak = newspstop-0.001;%as 
            changedpeak(end+1) = a;
        end
    end
%     save normspindles all the same, just edit the spindle info... unless max point is gone
    SpindlesNoDown(a,:) = [newspstart newsppeak newspstop];  %% NOTE not keeping the spectral power... will keep the actual amplitude in uV later
end

normspindles = SpindlesNoDown;%Replace normaspindles
normspindles = cat(2,normspindles,zeros(size(normspindles,1),1));

%% Get Zugaro stats
t = load(fullfile(basepath,[basename '_BasicMetaData.mat']));
numchans = t.Par.nChannels;
detectionchan = t.Spindlechannel;
voltsperunit = t.voltsperunit;

[maps,data,stats] = SpindleStatsWrapper(numchans, detectionchan, normspindles);
data.peakAmplitude = data.peakAmplitude * voltsperunit;
maps.amplitude = maps.amplitude * voltsperunit;

% Save
SpindleData = v2struct(normspindles,...
    maps,data,stats,detectionchan,DetectionParams);
save(fullfile('Spindles','SpindleDataNoDOWN.mat'),'SpindleData')
