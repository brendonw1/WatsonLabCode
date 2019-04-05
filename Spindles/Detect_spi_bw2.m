function [spindles, hv_spindles, normspindles, DetectionParams ] = Detect_spi_bw2(spi_CH, varargin )
%Spindle Detection
% uses FMAtoolbox adapted for detection, file saving, event file
%        saving
% input: 
%       basename = string of pre-suffix name/path to lfp file (as in basename.lfp)
% %       num_CH = total number of channels in recording, channel for spindle analysis
% %          (+1 from neuroscope channel number), ensure .lfp file and -states.mat(from StateEditor) is in the folder
%       spi_CH = index number of channel for spindle detection
%       other inputs: see Properties table below
% output: .mat file (named with basename+spi_CH)
%          column 1 = start; column 2 = peak; column 3 = end; column 4 =
%          power
%         .spi.evt file (named with basename+gam_CH)
%
% Note this depends on FMAToolbox, some modified FMAToolbox functions at
% bottom of this function for portability

%=========================================================================
%     Properties    Values
%    -------------------------------------------------------------------------
%     'spi_thresholds'  thresholds for spindle beginning/end and peak, in multiples
%                   of the stdev (default = [2 2])
%     'hvspi_thresholds' thresholds for high voltage spindle beginning/end
%                   and peak, in multiples of the stdev (default = [7 7])
%     'spindle band' = [start stop] pair of spindle band in hz, default is [10 20]Hz
%     'durations' = [300 3000 200] (min inter-spindle interval, max spindle duration and
%                           min spindle duration, in ms)
%     'state'        select state between NREM, REM, WAKE and allstates -
%                       default = all states
%     'notch60'      boolean, 1 means to do 60Hz notch filter on 1250hz
%                     neural data
% Brendon Watson 2016-8

warning off

%% Parameter defaults
% spi_thresholds = [2 3];
spi_lowThresholdFactor = 2;
spi_highThresholdFactor = 7;
% hvspi_thresholds = [7 12];
hvspi_lowThresholdFactor = 7;
hvspi_highThresholdFactor = 12;
state = 'allstates';
state_name = state;
detector = 'zugaro';
basepath = cd;

spindleband = [10 20];
durations = [300 3000 200];
notch60 = 0;

% if ~exist('basepath','var')
% end

%% Parse parameter list
for i = 1:2:length(varargin)
	if ~ischar(varargin{i})
		error(['Parameter ' num2str(i+2) ' is not a property (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).']);
	end
	switch(lower(varargin{i}))
        case 'basepath'
            basepath = varargin{i+1};
		case 'spi_thresholds'
			spi_thresholds = varargin{i+1};
% 			if ~isivector(spi_thresholds,'#2','>0'),
% 				error('Incorrect value for property ''thresholds'' (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).');
% 			end
			spi_lowThresholdFactor = spi_thresholds(1);
			spi_highThresholdFactor = spi_thresholds(2);
        case 'hvspi_thresholds'
			hvspi_thresholds = varargin{i+1};
% 			if ~isivector(hvspi_thresholds,'#2','>0'),
% 				error('Incorrect value for property ''thresholds'' (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).');
% 			end
			hvspi_lowThresholdFactor = hvspi_thresholds(1);
			hvspi_highThresholdFactor = hvspi_thresholds(2);
        case 'state'
			state = varargin{i+1};
            state_name = state;
            state = lower(state);
			if ~ischar(state) 
				error('Incorrect data type for property ''state''.  Must be a string');
            end
            if ~sum(strcmp(state,{'nrem','rem', 'wake','allstates'}))
				error('Incorrect value for property ''state''. Must be one of these: ''nrem'',''rem'', ''wake'' or ''allstates''');
			end
        case 'durations'
            durations = varargin{i+1};
        case 'detector'
            detector = varargin{i+1};
        case 'notch60'
            durations = varargin{i+1};
        end
end

basename = bz_BasenameFromBasepath(basepath);

DetectionParams = v2struct(spi_lowThresholdFactor,spi_highThresholdFactor,...
    hvspi_lowThresholdFactor,hvspi_highThresholdFactor,detector,...
    spindleband, durations, notch60,state);
            
%% States handling
if ~strcmp(lower(state),'allstates')%if a specified state is entered, load state and restrict to that state... uses states from StateEditor
    ssfn = fullfile(basepath,[basename,'.SleepState.states.mat']);
    if exist(ssfn,'file')
        SleepState = bz_LoadStates(basepath,'SleepState');
        if strcmp(lower(state),'nrem') | strcmp(lower(state),'sws')
            stateints = SleepState.ints.NREMstate;
        elseif strcmp(lower(state), 'rem')
            stateints = SleepState.ints.REMstate;
        else strcmp(lower(state), 'wake')
            stateints = SleepState.ints.WAKEstate;
        end
    else %very old... may want to phase this out - BW 2018
        t = dir('*_WSRestrictedIntervals.mat*');
        t = load (t.name);

        if strcmp(lower(state),'nrem') | strcmp(lower(state),'sws')
            stateints = t.SWSPacketInts;
        elseif strcmp(lower(state), 'rem')
            stateints = t.REMInts;
        else strcmp(lower(state), 'wake')
            stateints = t.WakeInts;
        end
    end
%     lfp = bz_RestrictLFPToIntervals(lfp,stateints);
%         datatimes = Range(Restrict(lfp, stateints), 's');
%         datavalues = Data(Restrict(lfp, stateints));
else % if no state restriction specfied
%     datatimes = Range(lfp, 's');
%     datavalues = double(Data(lfp));
    stateints = [0 inf];
end

%% Open lfp file 
% eeglfppath = findsessioneeglfpfile(basepath,basename);
% lfp = LoadLfp(eeglfppath,num_CH,spi_CH);    
lfp_orig = bz_GetLFP(spi_CH,'basepath',basepath,'intervals',stateints);
lfpdata = [];
lfptime = [];
for idx = 1:size(lfp_orig,2)
    lfpdata = cat(1,lfpdata,lfp_orig(idx).data);
    lfptime = cat(1,lfptime,lfp_orig(idx).timestamps);    
end
lfp = lfp_orig(1);
lfp.data = lfpdata;
lfp.timestamps = lfptime;
clear lfp_orig

%% Filter60Hz if indicated
if notch60
    datavalues = notch60(lfp.data);
end

%% Filter
% fil_sleep = FilterLFP([Range(Restrict(lfp, state), 's') Data(Restrict(lfp, state))], 'passband', spindleband);
filtered = bz_Filter(lfp, 'passband', spindleband);

%% Detect all spindles
switch detector
    case 'zugaro'
        [spindles,sd,bad] = FindSpindlesBW(filtered.data,'thresholds', [spi_lowThresholdFactor spi_highThresholdFactor], 'durations', durations,'frequency',lfp.samplingRate);
    case 'simple'
        [spindles,sd,bad] = SimpleSpindleDetect(filtered,'thresholds', [spi_lowThresholdFactor spi_highThresholdFactor], 'durations', durations);
end
disp(['Total Spindle Detections: ' num2str(size(spindles,1))])
%% Write output re all spindles (normal and High Voltage)
spindle_file = strcat(basename, num2str(spi_CH), state_name, 'spindles');
save (spindle_file, 'spindles')
spindle_events = strcat(basename, num2str(spi_CH), state_name, '.spi.evt');
SaveSpindleEvents(spindle_events,spindles,spi_CH);

%% Detect high voltage spindles
hvfiltered = bz_Filter(lfp, 'passband', [6 9]);
[hv_spindles, sd, bad] = FindSpindlesBW(hvfiltered.data,'thresholds', [hvspi_lowThresholdFactor hvspi_highThresholdFactor], 'durations', durations);
disp(['HV Spindle Detections: ' num2str(size(hv_spindles,1))])

%% Write HVS outputs
hvspindle_file = strcat(basename, num2str(spi_CH), state_name, 'hvspindles');
save (hvspindle_file, 'hv_spindles')
hv_spindle_events = strcat(basename, num2str(spi_CH), state_name, '.hvs.evt');
SaveSpindleEvents(hv_spindle_events,hv_spindles,spi_CH);

%% Detect normal sleep spindles only
normspindles = spindles;
[r, ~] = size(hv_spindles);
for i = length(spindles):-1:1                              %r = # rows in hv_spindles
    for j = 1:r
        if hv_spindles(j, 1) < spindles(i, 3) && spindles(i, 1) < hv_spindles(j, 3)         %test for overlap
            normspindles(i, :) = [];
        end
    end
end

normspindles_index = find(normspindles(:, 1) ~= 0);
normspindles_final = normspindles(normspindles_index, :);
disp(['Total Spindle Detections: ' num2str(size(normspindles,1))])

%% Write NormalSpindles outputs
normspindle_file = strcat(basename, num2str(spi_CH), state_name, 'normspindles');
save (normspindle_file, 'normspindles_final')
normspindle_events = strcat(basename, num2str(spi_CH), state_name, '.nsp.evt');
SaveSpindleEvents(normspindle_events,normspindles_final,spi_CH);



function [spindles,sd,bad] = SimpleSpindleDetect(filtered,varargin)
% Default values
sampFreq = 1250;
show = 'off';
restrict = [];
sd = [];
lowThresholdFactor = 2; % Ripple envoloppe must exceed lowThresholdFactor*stdev
highThresholdFactor = 3; % Ripple peak must exceed highThresholdFactor*stdev
minInterSpindleInterval = 30; % in ms
maxSpindleDuration = 100; % in ms
minSpindleDuration = 20; % in ms
noise = [];

% Check number of parameters
if nargin < 1 || mod(length(varargin),2) ~= 0
  error('Incorrect number of parameters (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).');
end

% Check parameter sizes
if ~isdmatrix(filtered) || size(filtered,2) ~= 2
	error('Parameter ''filtered'' is not a Nx2 matrix (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).');
end

% Parse parameter list
for i = 1:2:length(varargin)
	if ~ischar(varargin{i})
		error(['Parameter ' num2str(i+2) ' is not a property (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).']);
	end
	switch(lower(varargin{i}))
		case 'thresholds'
			thresholds = varargin{i+1};
% 			if ~isivector(thresholds,'#2','>0'),
% 				error('Incorrect value for property ''thresholds'' (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).');
% 			end
			lowThresholdFactor = thresholds(1);
			highThresholdFactor = thresholds(2);
		case 'durations'
			durations = varargin{i+1};
% 			if ~isivector(durations,'#3','>0'),
% 				error('Incorrect value for property ''durations'' (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).');
% 			end
			minInterSpindleInterval = durations(1);
			maxSpindleDuration = durations(2);
			minSpindleDuration = durations(3);
		case 'frequency'
			sampFreq = varargin{i+1};
			if ~isdscalar(sampFreq,'>0')
				error('Incorrect value for property ''frequency'' (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).');
			end
		case 'show'
			show = varargin{i+1};
			if ~isstring(show,'on','off')
				error('Incorrect value for property ''show'' (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).');
			end
		case {'baseline','restrict'}
			restrict = varargin{i+1};
			if ~isempty(restrict) & ~isdvector(restrict,'#2','<'),
				error('Incorrect value for property ''restrict'' (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).');
			end
		case 'stdev'
			sd = varargin{i+1};
			if ~isdscalar(sd,'>0')
				error('Incorrect value for property ''stdev'' (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).');
			end
		case 'noise'
			noise = varargin{i+1};
			if ~isdmatrix(noise) | size(noise,1) ~= size(filtered,1) | size(noise,2) ~= 2,
				error('Incorrect value for property ''noise'' (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).');
			end
        otherwise
			error(['Unknown property ''' num2str(varargin{i}) ''' (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).']);
	end
end


% Parameters
windowLength = round(sampFreq/1250*11);%11 is arbitrary
window = ones(windowLength,1)/windowLength;

% Square and normalize signal
signal = filtered(:,2);
env = hilbertenvelope(filtered(:,2));
% [normenv,sd] = unity(Filter0(window,env),sd,keep);
normenv = zscore(Filter0(window,env));

%find and get rid of artifacts... >10SD above mean when smoothed
denoisewindow = sampFreq/5;%arbitrary smoothing
smoothed = smooth(normenv,denoisewindow);
toohigh = continuousabove2(smoothed,10,1,inf);%find times where it was too high
spans = FindSettleBack(toohigh,smoothed,lowThresholdFactor);%find full span where above theshold of 2SD
for a = 1:size(spans,1);
    normenv(spans(a,1):spans(a,2)) = 0;
end
normenv = zscore(normenv);
sd = std(normenv);
% disp(sd)

evts = continuousabove2(normenv,lowThresholdFactor,minSpindleDuration,maxSpindleDuration);
start = evts(:,1);
stop = evts(:,2);

% Exclude last ripple if it is incomplete
if length(stop) == length(start)-1,
	start = start(1:end-1);
end
% Exclude first ripple if it is incomplete
if length(stop)-1 == length(start),
    stop = stop(2:end);
end
% Correct special case when both first and last ripples are incomplete
if start(1) > stop(1),
	stop(1) = [];
	start(end) = [];
end
firstPass = [start,stop];
if isempty(firstPass),
	disp('Detection by thresholding failed');
	return
% else
% 	disp(['After detection by thresholding: ' num2str(length(firstPass)) ' events.']);
end

% Merge events if inter-spindle period is too short
minInterSpindleSamples = minInterSpindleInterval/1000*sampFreq;
secondPass = [];
spindle = firstPass(1,:);
for i = 2:size(firstPass,1)
	if firstPass(i,1) - spindle(2) < minInterSpindleSamples,
		% Merge
		spindle = [spindle(1) firstPass(i,2)];
	else
		secondPass = [secondPass ; spindle];
		spindle = firstPass(i,:);
	end
end
secondPass = [secondPass ; spindle];
if isempty(secondPass),
	disp('Spindle merge failed');
	return
% else
% 	disp(['After spindle merge: ' num2str(length(secondPass)) ' events.']);
end

% Discard ripples with a peak power < highThresholdFactor
thirdPass = [];
peakNormalizedPower = [];
for i = 1:size(secondPass,1)
	[maxValue,maxIndex] = max(normenv([secondPass(i,1):secondPass(i,2)]));
	if maxValue > highThresholdFactor,
		thirdPass = [thirdPass ; secondPass(i,:)];
		peakNormalizedPower = [peakNormalizedPower ; maxValue];
	end
end
if isempty(thirdPass),
	disp('Peak thresholding failed.');
	return
% else
% 	disp(['After peak thresholding: ' num2str(length(thirdPass)) ' events.']);
end


% Detect negative peak position for each ripple
peakPosition = zeros(size(thirdPass,1),1);
for i=1:size(thirdPass,1),
	[minValue,minIndex] = min(signal(thirdPass(i,1):thirdPass(i,2)));
	peakPosition(i) = minIndex + thirdPass(i,1) - 1;
end

% Discard ripples that are way too long
time = filtered(:,1);
spindles = [time(thirdPass(:,1)) time(peakPosition) time(thirdPass(:,2)) peakNormalizedPower];
duration = spindles(:,3)-spindles(:,1);
spindles(duration>maxSpindleDuration/1000,:) = [];
% disp(['After max duration test: ' num2str(size(spindles,1)) ' events.']);

%Discard ripples that are way too short
duration = spindles(:,3)-spindles(:,1);
spindles(duration<minSpindleDuration/1000,:) = [];
% disp(['After min duration test: ' num2str(size(spindles,1)) ' events.']);


% If a noisy channel was provided, find ripple-like events and exclude them
bad = [];
if ~isempty(noise),
	% Square and pseudo-normalize (divide by signal stdev) noise
	squaredNoise = noise(:,2).^2;
	window = ones(windowLength,1)/windowLength;
	normalizedSquaredNoise = unity(Filter0(window,sum(squaredNoise,2)),sd,[]);
	excluded = logical(zeros(size(spindles,1),1));
	% Exclude ripples when concomittent noise crosses high detection threshold
	previous = 1;
	for i = 1:size(spindles,1),
		j = FindInInterval(noise,[spindles(i,1),spindles(i,3)],previous);
		previous = j(2);
		if any(normalizedSquaredNoise(j(1):j(2))>highThresholdFactor),
			excluded(i) = 1;
		end
	end
	bad = spindles(excluded,:);
	spindles = spindles(~excluded,:);
% 	disp(['After noise removal: ' num2str(size(spindles,1)) ' events.']);
end


%% BW: Extend to a lower second threshold
% zenv = zscore(abs(hilbert(filtered)));
% zenv = zenv(:,2);
% for i = 1:size(ripples,1)
%     tstart = find(time==ripples(i,1));
%     tstop = find(time==ripples(i,3));
%     if zenv(tstart)>1;
%         newstart = find(zenv(1:tstart)<1,1,'last');
%         if newstart>0
%             ripples(i,1) = time(min(newstart,tstart));
%         end
%     end
%     if zenv(tstop)>1;
%         newstop = find(zenv(tstop:end)<1,1,'first');
%         newstop = tstop+newstop;
%         if newstop<length(filtered)
%             ripples(i,3) = time(max(newstop,tstop));
%         end
%     end
%     
% end



% Optionally, plot results
if strcmp(show,'on'),
	figure;
	if ~isempty(noise),
		MultiPlotXY([time signal],[time squaredSignal],[time normalizedSquaredSignal],[time noise(:,2)],[time squaredNoise],[time normalizedSquaredNoise]);
		nPlots = 6;
		subplot(nPlots,1,3);
 		ylim([0 highThresholdFactor*1.1]);
		subplot(nPlots,1,6);
  		ylim([0 highThresholdFactor*1.1]);
	else
		MultiPlotXY([time signal],[time squaredSignal],[time normalizedSquaredSignal]);
%  		MultiPlotXY(time,signal,time,squaredSignal,time,normalizedSquaredSignal);
		nPlots = 3;
		subplot(nPlots,1,3);
  		ylim([0 highThresholdFactor*1.1]);
	end
	for i = 1:nPlots,
		subplot(nPlots,1,i);
		hold on;
  		yLim = ylim;
		for j=1:size(spindles,1),
			plot([spindles(j,1) spindles(j,1)],yLim,'g-');
			plot([spindles(j,2) spindles(j,2)],yLim,'k-');
			plot([spindles(j,3) spindles(j,3)],yLim,'r-');
			if i == 3,
				plot([spindles(j,1) spindles(j,3)],[spindles(j,4) spindles(j,4)],'k-');
			end
		end
		for j=1:size(bad,1),
			plot([bad(j,1) bad(j,1)],yLim,'k-');
			plot([bad(j,2) bad(j,2)],yLim,'k-');
			plot([bad(j,3) bad(j,3)],yLim,'k-');
			if i == 3,
				plot([bad(j,1) bad(j,3)],[bad(j,4) bad(j,4)],'k-');
			end
		end
		if mod(i,3) == 0,
			plot(xlim,[lowThresholdFactor lowThresholdFactor],'k','linestyle','--');
			plot(xlim,[highThresholdFactor highThresholdFactor],'k-');
		end
	end
end


function [spindles,sd,bad] = FindSpindlesBW(filteredlfp,varargin)
% Based on Zugaro's FindRipples (below)
%FindRipples - Find hippocampal ripples (100~200Hz oscillations).
%
%  USAGE
%
%    [ripples,stdev,noise] = FindRipples(filtered,<options>)
%
%    Ripples are detected using the normalized squared signal (NSS) by
%    thresholding the baseline, merging neighboring significant waves, 
%    thresholding the peaks, and discarding events with excessive duration.
%    Thresholds are computed as multiples of the standard deviation of
%    the NSS. Alternatively, one can use explicit values, typically obtained
%    from a previous call.
%
%    filteredsig    ripple-band filtered LFP (one channel, no timestamps).
%    <options>      optional list of property-value pairs (see table below)
%
%    =========================================================================
%     Properties    Values
%    -------------------------------------------------------------------------
%     'thresholds'  thresholds for ripple beginning/end and peak, in multiples
%                   of the stdev (default = [2 5])
%     'durations'   min inter-wave interval, max ripple duration and min total ripple duration, in ms
%                   (default = [30 100 20])
%     'baseline'    interval used to compute normalization (default = all)
%     'restrict'    same as 'baseline' (for backwards compatibility)
%     'sampFreq'    sampling rate (in Hz) (default = 1250Hz)
%     'stdev'       reuse previously computed stdev
%     'show'        plot results (default = 'off')
%     'noise'       noisy ripple-band filtered channel used to exclude ripple-
%                   like noise (events also present on this channel are
%                   discarded)
%     'timestamps'  vector of times corresponding with each data point
%                   given in filteredlfp.  Default is linear using sampfreq
%    =========================================================================
%
%  OUTPUT
%
%    ripples        for each ripple, [start_t peak_t end_t peakNormalizedPower]
%    stdev          standard deviation of the NSS (can be reused subsequently)
%    noise          ripple-like activity recorded simultaneously on the noise
%                   channel (for debugging info)
%
%  SEE
%
%    See also FilterLFP, RippleStats, SaveRippleEvents, PlotRippleStats.

% Copyright (C) 2004-2011 by Michaël Zugaro, initial algorithm by Hajime Hirase
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.

% Default values
sampFreq = 1250;
show = 'off';
restrict = [];
sd = [];
lowThresholdFactor = 2; % Ripple envoloppe must exceed lowThresholdFactor*stdev
highThresholdFactor = 3; % Ripple peak must exceed highThresholdFactor*stdev
minInterWaveInterval = 30; % in ms
maxRippleDuration = 100; % in ms
minRippleDuration = 20; % in ms
noise = [];
timestamps =  1/sampFreq * 1:length(filteredlfp);

% Check number of parameters
if nargin < 1 | mod(length(varargin),2) ~= 0,
  error('Incorrect number of parameters (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).');
end

% % Check parameter sizes
% if ~ismatrix(filteredsig) | 
% 	error('Parameter ''filtered'' is not a Nx2 matrix (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).');
% end

% Parse parameter list
for i = 1:2:length(varargin),
	if ~ischar(varargin{i}),
		error(['Parameter ' num2str(i+2) ' is not a property (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).']);
	end
	switch(lower(varargin{i})),
		case 'thresholds',
			thresholds = varargin{i+1};
% 			if ~isivector(thresholds,'#2','>0'),
% 				error('Incorrect value for property ''thresholds'' (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).');
% 			end
			lowThresholdFactor = thresholds(1);
			highThresholdFactor = thresholds(2);
		case 'durations',
			durations = varargin{i+1};
% 			if ~isivector(durations,'#3','>0'),
% 				error('Incorrect value for property ''durations'' (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).');
% 			end
			minInterWaveInterval = durations(1);
			maxRippleDuration = durations(2);
			minRippleDuration = durations(3);
		case 'frequency',
			sampFreq = varargin{i+1};
			if ~isdscalar(sampFreq,'>0'),
				error('Incorrect value for property ''frequency'' (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).');
			end
		case 'show',
			show = varargin{i+1};
			if ~isstring(show,'on','off'),
				error('Incorrect value for property ''show'' (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).');
			end
		case {'baseline','restrict'},
			restrict = varargin{i+1};
			if ~isempty(restrict) & ~isdvector(restrict,'#2','<'),
				error('Incorrect value for property ''restrict'' (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).');
			end
		case 'stdev',
			sd = varargin{i+1};
			if ~isdscalar(sd,'>0'),
				error('Incorrect value for property ''stdev'' (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).');
			end
		case 'noise',
			noise = varargin{i+1};
			if ~isdmatrix(noise) | size(noise,1) ~= size(filteredlfp,1) | size(noise,2) ~= 2,
				error('Incorrect value for property ''noise'' (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).');
			end
		case 'timestamps',
			s = varargin{i+1}(:);
			if ~isdmatrix(timestamps) | length(timestamps,1) ~= length(filteredlfp,1) 
				error('Incorrect value for property ''timepoints.');
			end
		otherwise,
			error(['Unknown property ''' num2str(varargin{i}) ''' (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).']);
	end
end

timestamps = timestamps(:);

% Parameters
windowLength = round(sampFreq/1250*11);%11 is arbitrary
window = ones(windowLength,1)/windowLength;

% Square and normalize signal
squaredSignal = filteredlfp.^2;
window = ones(windowLength,1)/windowLength;
keep = [];
if ~isempty(restrict)
	keep = filteredlfp(:,1)>=restrict(1)&filteredlfp(:,1)<=restrict(2);
end

[normalizedSquaredSignal,~] = unity(Filter0(window,sum(squaredSignal,2)),sd,keep);
% disp(sd)

%find and get rid of artifacts... >10SD above mean when smoothed
denoisewindow = sampFreq/5;
smoothed = smooth(normalizedSquaredSignal,denoisewindow);
toohigh = continuousabove2(smoothed,10,1,inf);%find times where it was too high
spans = FindSettleBack(toohigh,smoothed,lowThresholdFactor);%find full span where above theshold of 2SD
for a = 1:size(spans,1);
    normalizedSquaredSignal(spans(a,1):spans(a,2)) = 0;
end
[normalizedSquaredSignal,sd] = unity(normalizedSquaredSignal,sd,[]);

% Detect ripple periods by thresholding normalized squared signal
thresholded = normalizedSquaredSignal > lowThresholdFactor;
start = find(diff(thresholded)>0);
stop = find(diff(thresholded)<0);
% Exclude last ripple if it is incomplete
if length(stop) == length(start)-1,
	start = start(1:end-1);
end
% Exclude first ripple if it is incomplete
if length(stop)-1 == length(start),
    stop = stop(2:end);
end
% Correct special case when both first and last ripples are incomplete
if start(1) > stop(1),
	stop(1) = [];
	start(end) = [];
end
firstPass = [start,stop];
if isempty(firstPass),
	disp('Detection by thresholding failed');
	return
% else
% 	disp(['After detection by thresholding: ' num2str(length(firstPass)) ' events.']);
end

% Merge waves if inter-wave period is too short
minInterWaveSamples = minInterWaveInterval/1000*sampFreq;
secondPass = [];
wave = firstPass(1,:);
for i = 2:size(firstPass,1)
	if firstPass(i,1) - wave(2) < minInterWaveSamples,
		% Merge
		wave = [wave(1) firstPass(i,2)];
	else
		secondPass = [secondPass ; wave];
		wave = firstPass(i,:);
	end
end
secondPass = [secondPass ; wave];
if isempty(secondPass),
	disp('Spindle wave merge failed');
	return
% else
% 	disp(['After spindle wave merge: ' num2str(length(secondPass)) ' events.']);
end

% Discard ripples with a peak power < highThresholdFactor
thirdPass = [];
peakNormalizedPower = [];
for i = 1:size(secondPass,1)
	[maxValue,maxIndex] = max(normalizedSquaredSignal([secondPass(i,1):secondPass(i,2)]));
	if maxValue > highThresholdFactor,
		thirdPass = [thirdPass ; secondPass(i,:)];
		peakNormalizedPower = [peakNormalizedPower ; maxValue];
	end
end
if isempty(thirdPass),
	disp('Peak thresholding failed.');
	return
% else
% 	disp(['After peak thresholding: ' num2str(length(thirdPass)) ' events.']);
end


% Detect negative peak position for each spindle
peakPosition = zeros(size(thirdPass,1),1);
for i=1:size(thirdPass,1),
	[minValue,minIndex] = min(filteredlfp(thirdPass(i,1):thirdPass(i,2)));
	peakPosition(i) = minIndex + thirdPass(i,1) - 1;
end

% Discard spindles that are way too long
% time = filtered(:,1);
spindles = [timestamps(thirdPass(:,1)) timestamps(peakPosition) timestamps(thirdPass(:,2)) peakNormalizedPower];
duration = spindles(:,3)-spindles(:,1);
spindles(duration>maxRippleDuration/1000,:) = [];
% disp(['After max duration test: ' num2str(size(spindles,1)) ' events.']);

%Discard ripples that are way too short
duration = spindles(:,3)-spindles(:,1);
spindles(duration<minRippleDuration/1000,:) = [];
% disp(['After min duration test: ' num2str(size(spindles,1)) ' events.']);


% If a noisy channel was provided, find ripple-like events and exclude them
bad = [];
if ~isempty(noise),
	% Square and pseudo-normalize (divide by signal stdev) noise
	squaredNoise = noise(:,2).^2;
	window = ones(windowLength,1)/windowLength;
	normalizedSquaredNoise = unity(Filter0(window,sum(squaredNoise,2)),sd,[]);
	excluded = logical(zeros(size(spindles,1),1));
	% Exclude ripples when concomittent noise crosses high detection threshold
	previous = 1;
	for i = 1:size(spindles,1)
		j = FindInInterval(noise,[spindles(i,1),spindles(i,3)],previous);
		previous = j(2);
		if any(normalizedSquaredNoise(j(1):j(2))>highThresholdFactor)
			excluded(i) = 1;
		end
	end
	bad = spindles(excluded,:);
	spindles = spindles(~excluded,:);
% 	disp(['After noise removal: ' num2str(size(spindles,1)) ' events.']);
end


%% BW: Extend to a lower second threshold
% zenv = zscore(abs(hilbert(filtered)));
% zenv = zenv(:,2);
% for i = 1:size(ripples,1)
%     tstart = find(time==ripples(i,1));
%     tstop = find(time==ripples(i,3));
%     if zenv(tstart)>1;
%         newstart = find(zenv(1:tstart)<1,1,'last');
%         if newstart>0
%             ripples(i,1) = time(min(newstart,tstart));
%         end
%     end
%     if zenv(tstop)>1;
%         newstop = find(zenv(tstop:end)<1,1,'first');
%         newstop = tstop+newstop;
%         if newstop<length(filtered)
%             ripples(i,3) = time(max(newstop,tstop));
%         end
%     end
%     
% end



% Optionally, plot results
if strcmp(show,'on')
	figure;
	if ~isempty(noise)
		MultiPlotXY([timestamps filteredlfp],[timestamps squaredSignal],[timestamps normalizedSquaredSignal],[timestamps noise(:,2)],[timestamps squaredNoise],[timestamps normalizedSquaredNoise]);
		nPlots = 6;
		subplot(nPlots,1,3);
 		ylim([0 highThresholdFactor*1.1]);
		subplot(nPlots,1,6);
  		ylim([0 highThresholdFactor*1.1]);
	else
		MultiPlotXY([timestamps filteredlfp],[timestamps squaredSignal],[timestamps normalizedSquaredSignal]);
%  		MultiPlotXY(time,signal,time,squaredSignal,time,normalizedSquaredSignal);
		nPlots = 3;
		subplot(nPlots,1,3);
  		ylim([0 highThresholdFactor*1.1]);
	end
	for i = 1:nPlots
		subplot(nPlots,1,i);
		hold on;
  		yLim = ylim;
		for j=1:size(spindles,1)
			plot([spindles(j,1) spindles(j,1)],yLim,'g-');
			plot([spindles(j,2) spindles(j,2)],yLim,'k-');
			plot([spindles(j,3) spindles(j,3)],yLim,'r-');
			if i == 3
				plot([spindles(j,1) spindles(j,3)],[spindles(j,4) spindles(j,4)],'k-');
			end
		end
		for j=1:size(bad,1)
			plot([bad(j,1) bad(j,1)],yLim,'k-');
			plot([bad(j,2) bad(j,2)],yLim,'k-');
			plot([bad(j,3) bad(j,3)],yLim,'k-');
			if i == 3
				plot([bad(j,1) bad(j,3)],[bad(j,4) bad(j,4)],'k-');
			end
		end
		if mod(i,3) == 0
			plot(xlim,[lowThresholdFactor lowThresholdFactor],'k','linestyle','--');
			plot(xlim,[highThresholdFactor highThresholdFactor],'k-');
		end
	end
end


function y = Filter0(b,x)

if size(x,1) == 1,
	x = x(:);
end

if mod(length(b),2) ~= 1,
	error('filter order should be odd');
end

shift = (length(b)-1)/2;

[y0 z] = filter(b,1,x);

y = [y0(shift+1:end,:) ; z(1:shift,:)];


function [U,stdA] = unity(A,sd,restrict)

if ~isempty(restrict),
	meanA = mean(A(restrict));
	stdA = std(A(restrict));
else
	meanA = mean(A);
	stdA = std(A);
end
if ~isempty(sd),
	stdA = sd;
end

U = (A - meanA)/stdA;


function SaveSpindleEvents(filename,ripples,channelID)

%SaveRippleEvents - Save hippocampal ripple (~200Hz oscillations) events.
%
%  USAGE
%
%    SaveRippleEvents(filename,ripples,channelID)
%
%    filename       file to save to
%    ripples        ripple info as provided by <a href="matlab:help FindRipples">FindRipples</a>
%    channelID      channel ID (appended to the event description)
%
%  SEE
%
%    See also FindRipples, RippleStats, PlotRippleStats, SaveEvents.

% Copyright (C) 2004-2011 by Michaël Zugaro
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.

if nargin < 3,
  error('Incorrect number of parameters (type ''help <a href="matlab:help SaveRippleEvents">SaveRippleEvents</a>'' for details).');
end

n = size(ripples,1);
r = ripples(:,1:3)';
events.time = r(:);
for i = 1:3:3*n,
	events.description{i,1} = ['Spindle start ' int2str(channelID)];
	events.description{i+1,1} = ['Spindle peak ' int2str(channelID)];
	events.description{i+2,1} = ['Spindle stop ' int2str(channelID)];
end

SaveEvents(filename,events);


function channelData = notch60(channelData)
%60Hz filters a 1250hz file, such as a .eeg file.  The data should be in
%the vector input vect
% Notch60HzFor1250Hz made using fdatool

hd = Notch60HzFor1250Hz;
channelData = filter(hd,channelData);        


function Hd = Notch60HzFor1250Hz
%NOTCH60HZFOR1250HZ Returns a discrete-time filter object.

% MATLAB Code
% Generated by MATLAB(R) 8.2 and the Signal Processing Toolbox 6.20.
% Generated on: 20-Feb-2015 14:27:35 using fdatool

% Chebyshev Type II Bandstop filter designed using FDESIGN.BANDSTOP.

% All frequency values are in Hz.
Fs = 1250;  % Sampling Frequency

N      = 14;  % Order
Fstop1 = 59;  % First Stopband Frequency
Fstop2 = 61;  % Second Stopband Frequency
Astop  = 80;  % Stopband Attenuation (dB)

% Construct an FDESIGN object and call its CHEBY2 method.
h  = fdesign.bandstop('N,Fst1,Fst2,Ast', N, Fstop1, Fstop2, Astop, Fs);
Hd = design(h, 'cheby2');

% [EOF]

