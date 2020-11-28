function [maps,data,stats] = SpindleStatsWrapper (num_CH, spi_CH, spindles,varargin)
% Gets and plots basic stats for spindles detected by Detect_spi_bw.m
% Takes whatever .eeg or .lfp is in the folder, filters it and extracts
% stats from the previously-detected spindles


%% Replicate what happened in Detect_spi_bw to load and filter lfp data
%% Parameter defaults
% spi_thresholds = [2 3];
spi_lowThresholdFactor = 2;
spi_highThresholdFactor = 3;
% hvspi_thresholds = [7 12];
hvspi_lowThresholdFactor = 7;
hvspi_highThresholdFactor = 12;
state = 'ALLSTATES';
state_name = state;

spindleband = [10 20];

%% Parse parameter list
for i = 1:2:length(varargin),
	if ~ischar(varargin{i}),
		error(['Parameter ' num2str(i+2) ' is not a property (type ''help <a href="matlab:help FindSpindles">FindSpindles</a>'' for details).']);
	end
	switch(lower(varargin{i})),
        case 'state',
			state = varargin{i+1};
            state_name = state;
			if ~isstring(state,'NREM','REM', 'WAKE','ALLSTATES'),
				error('Incorrect value for property ''state'' (type ''help <a href="matlab:help FindSpindles">FindSpindles</a>'' for details).');
            end
    end
end
            
%% Open lfp file 
pathstr = cd;
filename = dir('*.lfp');
if isempty(filename)
    filename = dir('*.eeg');
end
if isempty(filename)
    slashes = strfind(pathstr,'/');
    pathstr = pathstr(1:slashes(end)-1);
    filename = dir('../*.eeg');
    if isempty(filename)
        filename = dir('../*.lfp');
        if isempty(filename)
            error('No .lfp or .eeg file found.  Aborting')
            return
        end
    end
end
[~, fbasename, fileSuffix] = fileparts(filename.name);
% nchannels = num_CH;
% spindle_channel = spi_CH;  
% spi_CH = spi_CH-1;
lfp = LoadLfp(fullfile(pathstr,[fbasename fileSuffix]),num_CH,spi_CH);    

%% States handling
if ~strcmp(state,'ALLSTATES')%if a specified state is entered, load state and restrict to that state... uses states from StateEditor
    state_mat = dir('*-states.mat*');
    load (state_mat.name);
    StateIntervals = ConvertStatesVectorToIntervalSets(states);                 % 6 Intervalsets representing sleep states
    REM = StateIntervals{5};
    NREM = or(StateIntervals{2}, StateIntervals{3});
    WAKE = StateIntervals{1};

    if strcmp(state,'NREM'),
        state = NREM;
    elseif strcmp(state, 'REM'),
            state = REM;
    else strcmp(state, 'WAKE'),
        state = WAKE;
    end
    datatimes = Range(Restrict(lfp, state), 's');
    datavalues = Data(Restrict(lfp, state));
else % if no state restriction specfied
    datatimes = Range(lfp, 's');
    datavalues = double(Data(lfp));
end

%% Filter
% fil_sleep = FilterLFP([Range(Restrict(lfp, state), 's') Data(Restrict(lfp, state))], 'passband', spindleband);
filtered = FilterLFP([datatimes datavalues], 'passband', spindleband);

%% Get Cycles
h = hilbert(filtered(:,2));
phase(:,1) = filtered(:,1);
phase(:,2) = angle(h);
unwrapped(:,1) = filtered(:,1);
unwrapped(:,2) = unwrap(phase(:,2));



%% Finally really get stats (per FMAToolbox)
[maps,data,stats] = SpindleStats(filtered,spindles,'durations',[-.5 .5]);

%% Plot (per FMAToolbox)
PlotSpindleStats(spindles,maps,data,stats,'durations',[-.25 .25])







function [maps,data,stats] = SpindleStats(filtered,spindles,varargin)

%SpindleStats - Compute descriptive stats for ripples (100~200Hz oscillations).
%
%  USAGE
%
%    [maps,data,stats] = SpindleStats(filtered,ripples,<options>)
%
%    filtered       ripple-band filtered samples (one channel)
%    ripples        ripple timing information (obtained using <a href="matlab:help FindSpindles">FindSpindles</a>)
%    <options>      optional list of property-value pairs (see table below)
%
%    =========================================================================
%     Properties    Values
%    -------------------------------------------------------------------------
%     'frequency'   sampling rate (in Hz) (default = 1250Hz)
%     'durations'   durations before and after ripple peak (in s)
%                   (default = [-0.5 0.5])
%    =========================================================================
%
%  OUTPUT
%
%    maps.ripples               instantaneous amplitude (one ripple per row)
%    maps.frequency             instantaneous frequency
%    maps.phase                 instantaneous phase
%    maps.amplitude             enveloppe amplitude
%    data.peakFrequency         frequency at peak
%    data.peakAmplitude         amplitude at peak
%    data.duration              durations
%    stats.durationAmplitude    correlation between duration and amplitude (rho, p)
%    stats.durationFrequency    correlation between duration and frequency (rho, p)
%    stats.amplitudeFrequency   correlation between amplitude and frequency (rho, p)
%    stats.acg.data             autocorrelogram data
%    stats.acg.t                autocorrelogram time bins
%
%  SEE
%
%    See also FindSpindles, SaveSpindleEvents, PlotSpindleStats.

% Copyright (C) 2004-2011 by Michaël Zugaro
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.

% Default values
samplingRate = 1250;
durations = [-50 50]/1000;
nCorrBins = 50;
%  corrBinSize = 400;
corrDuration = 20;
corrBinSize = 0.1;

% Check number of parameters
if nargin < 2,
  error('Incorrect number of parameters (type ''help <a href="matlab:help SpindleStats">SpindleStats</a>'' for details).');
end

% Check parameter sizes
if size(filtered,2) ~= 2,
	error('Parameter ''filtered'' is not a Nx2 matrix (type ''help <a href="matlab:help SpindleStats">SpindleStats</a>'' for details).');
end
if size(spindles,2) ~= 4,
	error('Parameter ''ripples'' is not a Nx4 matrix (type ''help <a href="matlab:help SpindleStats">SpindleStats</a>'' for details).');
end

% Parse parameter list
for i = 1:2:length(varargin),
	if ~ischar(varargin{i}),
		error(['Parameter ' num2str(i+2) ' is not a property (type ''help <a href="matlab:help SpindleStats">SpindleStats</a>'' for details).']);
	end
	switch(lower(varargin{i})),
		case 'frequency',
			samplingRate = varargin{i+1};
			if ~isdscalar(samplingRate,'>0'),
				error('Incorrect value for property ''frequency'' (type ''help <a href="matlab:help SpindleStats">SpindleStats</a>'' for details).');
			end
		case 'durations',
			durations = varargin{i+1};
			if ~isdvector(durations,'#2','<'),
				error('Incorrect value for property ''durations'' (type ''help <a href="matlab:help SpindleStats">SpindleStats</a>'' for details).');
			end
		otherwise,
			error(['Unknown property ''' num2str(varargin{i}) ''' (type ''help <a href="matlab:help SpindleStats">SpindleStats</a>'' for details).']);
	end
end

nBins = floor(samplingRate*diff(durations)/2)*2+1; % must be odd
nHalfCenterBins = 3;
centerBin = ceil(nBins/2);
centerBins = centerBin-nHalfCenterBins:centerBin+nHalfCenterBins;

% Compute instantaneous phase and amplitude
h = hilbert(filtered(:,2));
phase(:,1) = filtered(:,1);
phase(:,2) = angle(h);
amplitude(:,1) = filtered(:,1);
amplitude(:,2) = abs(h);
unwrapped(:,1) = filtered(:,1);
unwrapped(:,2) = unwrap(phase(:,2));
% Compute instantaneous frequency
frequency = Diff(unwrapped,'smooth',0);
frequency(:,2) = frequency(:,2)/(2*pi);

% Compute ripple map
[r,i] = Sync(filtered,spindles(:,2),'durations',durations);
maps.spindles = SyncMap(r,i,'durations',durations,'nbins',nBins,'smooth',0);

% Compute frequency Map
[f,i] = Sync(frequency,spindles(:,2),'durations',durations);
maps.frequency = SyncMap(f,i,'durations',durations,'nbins',nBins,'smooth',0);

% Compute phase map
[p,i] = Sync(phase,spindles(:,2),'durations',durations);
maps.phase = SyncMap(p,i,'durations',durations,'nbins',nBins,'smooth',0);

% Compute amplitude map
[a,i] = Sync(amplitude,spindles(:,2),'durations',durations);
maps.amplitude = SyncMap(a,i,'durations',durations,'nbins',nBins,'smooth',0);

% Spindle frequency and amplitude at peak
data.peakFrequency = maps.frequency(:,centerBin);
data.peakAmplitude = maps.amplitude(:,centerBin);

% Spindle durations
data.duration = spindles(:,3)-spindles(:,1);

% Autocorrelogram and correlations
%  [stats.acg.data,stats.acg.t] = CCG(spindles(:,2)*1000,1,corrBinSize,nCorrBins/2,1000);stats.acg.t = stats.acg.t/1000;
sampfreq = 20000;
[stats.acg.data,stats.acg.t] = CCG(spindles(:,2)*sampfreq,1,sampfreq*corrBinSize,nCorrBins/2,sampfreq);stats.acg.t = stats.acg.t/1000;
% [stats.acg.data,stats.acg.t] = CCG_FMA(spindles(:,2),1,'binSize',1,'duration',10);
[stats.amplitudeFrequency.rho,stats.amplitudeFrequency.p] = corrcoef(data.peakAmplitude,data.peakFrequency);
[stats.durationFrequency.rho,stats.durationFrequency.p] = corrcoef(data.duration,data.peakFrequency);
[stats.durationAmplitude.rho,stats.durationAmplitude.p] = corrcoef(data.duration,data.peakAmplitude);


function PlotSpindleStats(r,m,d,s,varargin)

%PlotSpindleStats - Plot descriptive stats for spindles (100~200Hz oscillations).
%
%  USAGE
%
%    PlotSpindleStats(spindles,maps,data,stats,<options>)
%
%    Use the ouputs of <a href="matlab:help SpindleStats">SpindleStats</a> as input parameters. Using cell arrays of
%    repeated measures will yield pairwise statistics.
%
%    spindles        ripple timing info (provided by <a href="matlab:help FindSpindles">FindSpindles</a>)
%    maps           ripple instantaneous amplitude, frequency, and phase maps
%    data           frequency and amplitude at peak, durations
%    stats          autocorrelogram and correlations
%    <options>      optional list of property-value pairs (see table below)
%
%    =========================================================================
%     Properties    Values
%    -------------------------------------------------------------------------
%     'frequency'   sampling rate (in Hz) (default = 1250Hz)
%     'durations'   durations before and after ripple peak (in s)
%                   (default = [-0.05 0.05])
%    =========================================================================
%
%  SEE
%
%    See also FindSpindles, SpindleStats, SaveSpindleEvents.

% Copyright (C) 2004-2011 by Michaël Zugaro
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.

% Default values
samplingRate = 1250;
durations = [-500 500]/1000;
nCorrBins = 1000;

% Check number of parameters
if nargin < 3,
  error('Incorrect number of parameters (type ''help <a href="matlab:help PlotSpindleStats">PlotSpindleStats</a>'' for details).');
end

% Parse parameter list
for i = 1:2:length(varargin),
	if ~ischar(varargin{i}),
		error(['Parameter ' num2str(i+2) ' is not a property (type ''help <a href="matlab:help PlotSpindleStats">PlotSpindleStats</a>'' for details).']);
	end
	switch(lower(varargin{i})),
		case 'frequency',
			samplingRate = varargin{i+1};
			if ~isdscalar(samplingRate,'>0'),
				error('Incorrect value for property ''frequency'' (type ''help <a href="matlab:help PlotSpindleStats">PlotSpindleStats</a>'' for details).');
			end
		case 'durations',
			durations = varargin{i+1};
			if ~isdvector(durations,'#2','<'),
				error('Incorrect value for property ''durations'' (type ''help <a href="matlab:help PlotSpindleStats">PlotSpindleStats</a>'' for details).');
			end
		otherwise,
			error(['Unknown property ''' num2str(varargin{i}) ''' (type ''help <a href="matlab:help PlotSpindleStats">PlotSpindleStats</a>'' for details).']);
	end
end

if isa(m,'cell'),
	spindles = r;
	maps = m;
	data = d;
	stats = s;
else
	spindles{1} = r;
	maps{1} = m;
	data{1} = d;
	stats{1} = s;
end
nElectrodes = length(maps);

%  nBins = floor(samplingRate*diff(durations)/2)*2+1; % must be odd
nBins = 	length(maps{1}.spindles);
nHalfCenterBins = 3;
%  centerBin = durations(1)/sum(durations)*(nBins-1)+1;
centerBin = ceil(nBins/2);
centerBins = centerBin-nHalfCenterBins:centerBin+nHalfCenterBins;

% Stats for individual electrodes

for electrode = 1:nElectrodes,

	% Unsorted color plots
	f = figure;
	set(f,'name',['Spindles (unsorted) - ' int2str(electrode)]);
	dx = diff(durations);
	x = durations(1):dx/size(maps{electrode}.spindles,2):durations(2);
	subplot(2,2,1);PlotColorMap(maps{electrode}.spindles,1,'bar','on','cutoffs',[-300 300],'x',x);xlabel('Spindles');
	subplot(2,2,2);PlotColorMap(maps{electrode}.phase,1,'bar','on','type','circular','x',x);xlabel('Spindle Phase');
	subplot(2,2,3);PlotColorMap(maps{electrode}.frequency,1,'bar','on','cutoffs',[8 22],'x',x);xlabel('Spindle Frequency');
	subplot(2,2,4);PlotColorMap(maps{electrode}.amplitude,1,'bar','on','x',x);xlabel('Spindle Amplitude'); %,'cutoffs',[0 3500]

	% Sorted color plots (sort by ripple frequency)
	%  f = figure;
	%  set(f,'name',['Spindles (sorted by frequency) - ' int2str(electrode)]);
	%  subplot(2,2,1);PlotColorMap(maps.spindles{electrode}(order,:),1,'bar','on');xlabel('Spindles');
	%  subplot(2,2,2);PlotColorMap(maps.phase{electrode}(order,:),1,'bar','on','type','circular');xlabel('Spindle Phase');
	%  subplot(2,2,3);PlotColorMap(maps.frequency{electrode}(order,:),1,'bar','on','cutoffs',[100 250]);xlabel('Spindle Frequency');
	%  subplot(2,2,4);PlotColorMap(maps.amplitude{electrode}(order,:),1,'bar','on','cutoffs',[0 3500]);xlabel('Spindle Amplitude');

	% Spindles stats: spindles, peak frequency vs amplitude, autocorrelogram, peak frequency vs duration, peak amplitude vs duration
	f = figure;set(f,'name',['Spindle Stats - ' int2str(electrode)]);

	subplot(2,2,1);a = gca;hold on;
    plot(mean(maps{electrode}.spindles))
% 	plot(((1:nBins)'-ceil(nBins/2))/nBins*diff(durations),maps{electrode}.spindles,'b');
    axis('tight')
    
	subplot(2,2,2);
	b = bar(stats{electrode}.acg.t,stats{electrode}.acg.data);set(b,'FaceColor',[0 0 0]);xlabel('Autocorrelogram');
%  	b = bar(((0:nCorrBins)-nCorrBins/2)/1000,stats{electrode}.acg.data);xlim([-nCorrBins nCorrBins]/2000);set(b,'FaceColor',[0 0 0]);xlabel('Autocorrelogram');
    axis('tight')

	subplot(2,3,4);a = gca;
	PlotDistribution2(data{electrode}.peakAmplitude,data{electrode}.peakFrequency,'nbins',1000); %,'smooth',5
	axes(a);xlabel(['r=' num2str(stats{electrode}.amplitudeFrequency.rho(1,2)) ' p=' num2str(stats{electrode}.amplitudeFrequency.p(1,2))]);ylabel('Frequency vs Amplitude');

	subplot(2,3,5);a = gca;
	PlotDistribution2(data{electrode}.duration,data{electrode}.peakFrequency,'nbins',1000); %,'smooth',5
	axes(a);xlabel(['r=' num2str(stats{electrode}.durationFrequency.rho(1,2)) ' p=' num2str(stats{electrode}.durationFrequency.p(1,2))]);ylabel('Frequency vs Duration');

	subplot(2,3,6);a = gca;
	PlotDistribution2(data{electrode}.duration,data{electrode}.peakAmplitude,'nbins',1000); %,'smooth',5
	axes(a);xlabel(['r=' num2str(stats{electrode}.durationAmplitude.rho(1,2)) ' p=' num2str(stats{electrode}.durationAmplitude.p(1,2))]);ylabel('Amplitude vs Duration');
end

% Pairwise stats
% 
% if nElectrodes == 2,
% 
% 		% Match ripple pairs
% 		ripplePairs = MatchPairs(spindles{1}(:,2),spindles{2}(:,2),'error',0.01); % within 10 ms
% 		% Spindles on LFP 1 only
% 		only1 = isnan(ripplePairs(:,2));
% 		% Spindles on LFP 2 only
% 		only2 = isnan(ripplePairs(:,1));
% 		% Spindles on both electrodes
% 		both = ~only1 & ~only2;
% 		% Peak time on LFP 1 when there are spindles on both electrodes
% 		ripplePairTimes = ripplePairs(both,1);
% 		% For each ripple on LFP 1, whether there are spindles on both electrodes
% 		spindlesOn1AlsoOn2 = ~isnan(ripplePairs(~only2,2));
% 		% For each ripple on LFP 2, whether there are spindles on both electrodes
% 		spindlesOn2AlsoOn1 = ~isnan(ripplePairs(~only1,1));
% 		% For each ripple on LFP 1, whether there are no spindles on LFP 2
% 		spindlesOn1NotOn2 = isnan(ripplePairs(~only2,2));
% 		% For each ripple on LFP 2, whether there are no spindles on LFP 1
% 		spindlesOn2NotOn1 = isnan(ripplePairs(~only1,1));
% 
% %  		% Compute phase shift map
% %  		size(maps{1}.phase)
% %  		[p1,i1] = Sync(maps{1}.phase,ripplePairTimes,'durations',durations);
% %  		[p2,i2] = Sync(maps{2}.phase,ripplePairTimes,'durations',durations);
% %  		shift(:,1) = p1(:,1);
% %  		shift(:,2) = p1(:,2)-p2(:,2);
% %  		phaseShiftMap = SyncMap(shift,i1,'durations',durations,'nbins',nBins,'smooth',0);
% %  		phaseShiftMap(phaseShiftMap<-pi) = phaseShiftMap(phaseShiftMap<-pi) + 2*pi;
% %  		phaseShiftMap(phaseShiftMap>pi) = phaseShiftMap(phaseShiftMap>pi) - 2*pi;
% %
% %  		% Determine average phase shift using center bins
% %  		meanCenterPhaseShift = mean(phaseShiftMap(:,centerBins),2);
% %  		[~,order] = sortrows(meanCenterPhaseShift);
% 
% 		% Plot phase difference, frequency and amplitude (1 vs 2)
% 		f = figure;set(f,'name','Pairwise Stats');
% 
% %  		subplot(2,2,1);PlotColorMap(phaseShiftMap,1,'bar','on','type','circular');xlabel('Phase Shift');
% %  		hold on;plot([1 1]*size(phaseShiftMap,2)/2,ylim,'w');
% %
% %  		subplot(2,2,2);PlotColorMap(phaseShiftMap(order,:),1,'bar','on','type','circular');xlabel('Phase Shift');
% %  		hold on;plot([1 1]*size(phaseShiftMap,2)/2,ylim,'w');
% 
% 		subplot(2,3,4);a = gca;
% 		[rho,p] = corrcoef(data{1}.peakFrequency(spindlesOn1AlsoOn2),data{2}.peakFrequency(spindlesOn2AlsoOn1));
% 		PlotDistribution2(data{1}.peakFrequency(spindlesOn1AlsoOn2),data{2}.peakFrequency(spindlesOn2AlsoOn1),'nbins',1000,'smooth',50);
% 		axes(a);xlabel(['r=' num2str(rho(1,2)) ' p=' num2str(p(1,2))]);ylabel('Frequency (1 vs 2)');
% 
% 		subplot(2,3,5);a = gca;
% 		[rho,p] = corrcoef(data{1}.peakAmplitude(spindlesOn1AlsoOn2),data{2}.peakAmplitude(spindlesOn2AlsoOn1));
% 		PlotDistribution2(data{1}.peakAmplitude(spindlesOn1AlsoOn2),data{2}.peakAmplitude(spindlesOn2AlsoOn1),'nbins',1000,'smooth',50);
% 		axes(a);xlabel(['r=' num2str(rho(1,2)) ' p=' num2str(p(1,2))]);ylabel('Amplitude (1 vs 2)');
% 
% 		subplot(2,3,6);a = gca;
% 		rippleDurations1 = data{1}.duration(spindlesOn1AlsoOn2);
% 		rippleDurations2 = data{2}.duration(spindlesOn2AlsoOn1);
% 		discard = rippleDurations1>0.05|rippleDurations2>0.05;
% 		rippleDurations1 = rippleDurations1(~discard);
% 		rippleDurations2 = rippleDurations2(~discard);
% 		[rho,p] = corrcoef(rippleDurations1,rippleDurations2);
% 		PlotDistribution2(rippleDurations1,rippleDurations2,'nbins',1000,'smooth',50);
% 		axes(a);xlabel(['r=' num2str(rho(1,2)) ' p=' num2str(p(1,2))]);ylabel('Duration (1 vs 2)');
% 		% Plot info for unilateral vs bilateral spindles
% 		f = figure;set(f,'name','Unilateral vs Bilateral Stats');
% 
% 		subplot(2,2,1);
% 		S_boxplot([data{1}.peakFrequency(spindlesOn1NotOn2);data{1}.peakFrequency(spindlesOn1AlsoOn2);data{2}.peakFrequency(spindlesOn2NotOn1);data{2}.peakFrequency(spindlesOn2AlsoOn1)],[ones(sum(spindlesOn1NotOn2),1);2*ones(sum(spindlesOn1AlsoOn2),1);3*ones(sum(spindlesOn2NotOn1),1);4*ones(sum(spindlesOn2AlsoOn1),1)]);
% 		p1 = S_ranksum(data{1}.peakFrequency(spindlesOn1NotOn2),data{1}.peakFrequency(spindlesOn1AlsoOn2));
% 		p2 = S_ranksum(data{2}.peakFrequency(spindlesOn2NotOn1),data{2}.peakFrequency(spindlesOn2AlsoOn1));
% 		xlabel(['p=' num2str(p1) ' N=' num2str(sum(spindlesOn1NotOn2)) ',' num2str(sum(spindlesOn1AlsoOn2)) ' p=' num2str(p2) ' N=' num2str(sum(spindlesOn2NotOn1)) ',' num2str(sum(spindlesOn2AlsoOn1))]);
% 		ylabel('Frequency (1-2,1+2,2-1,2+1)');
% 
% 		subplot(2,2,2);
% 		S_boxplot([data{1}.peakAmplitude(spindlesOn1NotOn2);data{1}.peakAmplitude(spindlesOn1AlsoOn2);data{2}.peakAmplitude(spindlesOn2NotOn1);data{2}.peakAmplitude(spindlesOn2AlsoOn1)],[ones(sum(spindlesOn1NotOn2),1);2*ones(sum(spindlesOn1AlsoOn2),1);3*ones(sum(spindlesOn2NotOn1),1);4*ones(sum(spindlesOn2AlsoOn1),1)]);
% 		p1 = S_ranksum(data{1}.peakAmplitude(spindlesOn1NotOn2),data{1}.peakAmplitude(spindlesOn1AlsoOn2));
% 		p2 = S_ranksum(data{2}.peakAmplitude(spindlesOn2NotOn1),data{2}.peakAmplitude(spindlesOn2AlsoOn1));
% 		xlabel(['p=' num2str(p1) ' N=' num2str(sum(spindlesOn1NotOn2)) ',' num2str(sum(spindlesOn1AlsoOn2)) ' p=' num2str(p2) ' N=' num2str(sum(spindlesOn2NotOn1)) ',' num2str(sum(spindlesOn2AlsoOn1))]);
% 		ylabel('Amplitude (1-2,1+2,2-1,2+1)');
% 
% 		subplot(2,2,3);
% 		S_boxplot([data{1}.duration(spindlesOn1NotOn2);data{1}.duration(spindlesOn1AlsoOn2);data{2}.duration(spindlesOn2NotOn1);data{2}.duration(spindlesOn2AlsoOn1)],[ones(sum(spindlesOn1NotOn2),1);2*ones(sum(spindlesOn1AlsoOn2),1);3*ones(sum(spindlesOn2NotOn1),1);4*ones(sum(spindlesOn2AlsoOn1),1)]);
% 		p1 = S_ranksum(data{1}.duration(spindlesOn1NotOn2),data{1}.duration(spindlesOn1AlsoOn2));
% 		p2 = S_ranksum(data{2}.duration(spindlesOn2NotOn1),data{2}.duration(spindlesOn2AlsoOn1));
% 		xlabel(['p=' num2str(p1) ' N=' num2str(sum(spindlesOn1NotOn2)) ',' num2str(sum(spindlesOn1AlsoOn2)) ' p=' num2str(p2) ' N=' num2str(sum(spindlesOn2NotOn1)) ',' num2str(sum(spindlesOn2AlsoOn1))]);
% 		ylabel('Duration (1-2,1+2,2-1,2+1)');
% end



function [out, t, Pairs] = CCG(T, G, BinSize, HalfBins, SampleRate, GSubset, Normalization, Epochs)
% constructs multiple cross and Auto correlogram
% usage: [ccg, t, pairs] = CCG(T, G, BinSize, HalfBins, SampleRate, GSubset, Normalization, Epochs)
%
% T gives the time of the events, (events need not be sorted by TIME)-in timepoints
% G says which one is in which group
% BinSize gives the size of a bin in input units (i.e. not scaled by SampleRate)
% HalfBins gives the number of bins on each side of 0 - so the total is 1+2*HalfBins
% SampleRate is for x-axis scaling only.  It defaults to 20000
% GSubset says which groups to plot the CCGS of (defaults to all but group 1)
% Normalization indicates the type of y-axis normalization to be used.  
% 'count' indicates that the y axis should show the raw spike count in each bin.
% 'hz' will normalize to give the conditional intensity of cell 2 given that cell 1 fired a spike (default)
% 'hz2' will give the joint intensity, measured in hz^2.
% 'scale' will scale by both firing rates so the asymptotic value is 1.  This gives you
%   the ratio of the coincidence rate to that expected for uncorrelated spike trains
%
% optional input Epochs allows you to compute from only spikes in certain epochs
% and it will bias-correct so you don't see any triangular shape. 
% Warning: if gaps between epochs are shorter than total CCG length, this will mess
% up the edges.
%
% The output array will be 3d with the first dim being time lag and the second two 
% specifying the 2 cells in question (in the order of GSubset)
% If there is no output specified, it will plot the CCGs
%
% This file calls a C program so your CCG is computed fast.
% to use it, you need to compile mex file from CCGHeart.c
% run : mex -v CCGHeart.c 
% different architectures will produce different extensions of mex file,
% also different versions of matlab link mex file to different libraries
% they are mostly taken into account in the code of CCG.m, but if your
% version or architecture is different from those - modify CCGFun string to
% match the name of the mex file your compiler generated.
% optional output t gives time axis for the bins in ms
% optional output argument pairs gives a nx2 array with the indices of the spikes
% in each train that fall in the CCG.
% written by Ken Harris 
% small editions Anton Sirota
if nargin<5
	SampleRate = 20000;
end
if nargin<6
	GSubset = unique(G);
%	GSubset = setdiff(GSubset, 1);
end
if nargin<7
	Normalization = 'hz';
end;
if nargin<8
    Epochs = [];
end

if length(G)==1
	G = ones(length(T), 1);
	GSubset = 1;
	nGroups = 1;
else
	nGroups = length(GSubset);
end;


% Prepare Res and Clu arrays.
G=G(:);
T=T(:);

if ~isempty(Epochs)
    Included = find(ismember(G,GSubset) & isfinite(T) & WithinRanges(T,Epochs));
    
    % check gaps between epochs are not too short
    GapLen = Epochs(2:end,1) - Epochs(1:(size(Epochs,1)-1),2);
    TooShort = find(GapLen<BinSize*(HalfBins+.5));
    if ~isempty(TooShort)
        fprintf('WARNING: Epochs ');
        fprintf('%d ', TooShort);
        fprintf('are followed by too-short gaps.\n');
    end
 

else
    Included = find(ismember(G,GSubset) & isfinite(T));
    Epochs = [];%[min(T)-1 max(T)+1];
  
end
Res = T(Included);
% if no spikes, return nothing
if length(Res)<=1
    nBins = 1+2*HalfBins;
    out = zeros(nBins, nGroups, nGroups);
    t = 1000*(-HalfBins:HalfBins)*BinSize/SampleRate;
    Pairs = [];
    return
end

% To make the Clu array we need a indexing array, which SUCKS!
G2Clu = full(sparse(GSubset,1,1:nGroups));
Clu = G2Clu(G(Included));


% sort by time
[Res ind] = sort(Res);
Clu = Clu(ind);

% Now call the C program...
ver = version; 
ver = str2num(ver(1:3));
comp = computer;
%check for version and architecture
%LocalName = ['CCGHeart_local.' comp];
%LocalName = ls([matlabroot '/toolbox/local/CCGHeart_local*']);
% LocalName = ls(['/jp03/u12/jagdish/matlab/jp/CCGHeart.mexa64']);
% length(LocalName);
% if LocalName
	CCGFun = 'CCGHeart'; % f$%^ it is the .mex file!~!---jp
% else
%    if ver>=7.2
%        [dd host ] = system('hostname');
%     
%        if strfind(host,'urethane')
%            CCGFun = 'CCGHeart_urethane';
%        else
%            CCGFun = 'CCGHeart7_2';
%        end
%    elseif ver<7.2 & ver>=7 
%             CCGFun = 'CCGHeart7';
%    else
%        CCGFun = 'CCGHeart';
%    end
%    if strcmp(comp,'GLNXA64')  %-------------------- shige commented out
%        CCGFun = [CCGFun '_64'];
%    end                        %----------------------------------------
% end
%fprintf('using %s for version %d\n',CCGFun,ver);
    
    
    
% call the program
nSpikes = length(Res);
if nargout>=3
    % fixing the bug of CCGHeart when no spikes fall withing HalfBins (even
    % for autocorrelogram
    if min(diff(Res))<=BinSize*(HalfBins+1)
        [Counts RawPairs] = feval(CCGFun,Res, uint32(Clu), BinSize, uint32(HalfBins));
        rsRawPairs = reshape(RawPairs, [2 length(RawPairs)/2])';
    else
        warning('pairs cannot be computed - no overlap between spikes withing the range you want');
        rsRawPairs = [];
        Counts = feval(CCGFun,Res, uint32(Clu), BinSize, uint32(HalfBins));
    end
else
    Counts = feval(CCGFun,Res, uint32(Clu), BinSize, uint32(HalfBins));
end
% shape the results
nBins = 1+2*HalfBins;
% if there are no spikes in the top cluster, CCGEngine will produce a output the wrong size
nPresent = max(Clu);
Counts = double(reshape(Counts,[nBins nPresent nPresent]));
if nPresent<nGroups
    % extent array size with zeros
    Counts(nBins, nGroups, nGroups) = 0;
end
    
if nargout>=3
    Pairs = Included(ind(double(rsRawPairs) + 1));
end

% OK so we now have the bin counts.  Now we need to rescale it.

% remove bias due to edge effects - this should be vectorized
if isempty(Epochs)
    Bias = ones(nBins,1);
else
    nTerm = [HalfBins:-1:1 , 0.25 , 1:HalfBins];
	Bias = zeros(nBins,1);
    TotLen = 0;
	for e=1:size(Epochs,1)
        EpochLen = Epochs(e,2)-Epochs(e,1);
        EpochBias = clip(EpochLen - nTerm*BinSize,0,inf)*BinSize;
        Bias = Bias+EpochBias';
        TotLen = TotLen + EpochLen;
	end
    Bias = Bias/TotLen/BinSize;
end

if isempty(Epochs)
      Trange = max(Res) - min(Res); % total time
else
       Trange = sum(diff(Epochs,[],2));
end
t = 1000*(-HalfBins:HalfBins)*BinSize/SampleRate;

% count the number of spikes in each group:
for g=1:nGroups
	nSpikesPerGroup(g) = sum(Clu==g);
end;

% normalize each group
for g1=1:nGroups, for g2=g1:nGroups
	switch Normalization
		case 'hz'
			Factor = SampleRate / (BinSize * nSpikesPerGroup(g1));
			AxisUnit = '(Hz)';
		case 'hz2'
			Factor = SampleRate * SampleRate / (Trange*BinSize);	
			AxisUnit = '(Hz^2)';
		case 'count';
			Factor = 1;
			AxisUnit = '(Spikes)';
		case 'scale'
			Factor = Trange / (BinSize * nSpikesPerGroup(g1) * nSpikesPerGroup(g2));
			AxisUnit = '(Scaled)';
		otherwise
			warning(['Unknown Normalization method ', Normalization]);
	end;
% 	ccg(:,g1,g2) = flipud(Counts(:,g1,g2)) * Factor ./repmat(Bias,[1 nGroups,nGroups]); 
 	ccg(:,g1,g2) = flipud(Counts(:,g1,g2)) * Factor ./Bias; 
	ccg(:,g2,g1) = (Counts(:,g1,g2)) * Factor ./Bias; 
	% now plot, if there is no output argument
	if (nargout==0)
		FigureIndex = g1 + nGroups*(nGroups-g2);
		subplot(nGroups,nGroups,FigureIndex);		
	
		% plot graph
%		bar(1000*(-HalfBins:HalfBins)*BinSize/SampleRate, ccg(:,g1,g2));
		bar(t, ccg(:,g1,g2));

		% label y axis
		if g1==g2
%			ylabel(['ACG ', AxisUnit])	
    		FiringRate = SampleRate * nSpikesPerGroup(g1) / Trange;
%     		Ttitle = sprintf('%d (~%5.2fHz)',GSubset(g1),FiringRate);
% 			title(Ttitle);
    		xlabel('ms');
        else 
        %    set(gca, 'xtick', []);
        end
        if g1==1
            ylabel(sprintf('%d', GSubset(g2)));
%			ylabel(['CCG ', AxisUnit])
% 			Ttitle = sprintf('%d vs %d', GSubset(g1), GSubset(g2));
% 			title(Ttitle);
		end
        if g2==nGroups
    		Ttitle = sprintf('%d (~%5.2fHz)',GSubset(g1),FiringRate);
			title(Ttitle);
        end

		axis tight
	end
end,end;

% only make an output argument if its needed (to prevent command-line spew)
if (nargout>0)
	out = ccg;
end



