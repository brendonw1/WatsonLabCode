function [normspindles,SpindleData] = SpindleDetectWrapper(numchans, detectionchan, voltsperunit, thresh1, thresh2)
% numchans - total number of channels in recording
% detectionchan - channel to detect on, base 1 (+1 compared to neuroscope)

if ~exist('thresh1','var')
    thresh1 = 2;
end
if ~exist('thresh2','var')
    thresh2 = 7;
end
statename = 'nrem';

[spindles, hv_spindles, normspindles, DetectionParams] = Detect_spi_bw(numchans, detectionchan, 'spi_thresholds',[thresh1 thresh2],'durations',[200 3000 300],'state',statename);

%% Move output files to new Spindles folder
thispath = cd;
% newfolder = fullfile(thispath,'Spindles');
newfolder = fullfile(thispath);
if ~exist(newfolder,'dir')
    mkdir(newfolder)
end
d1 = dir('*spindles.mat');
d2 = dir('*spi.evt');
d3 = dir('*hvs.evt');
d4 = dir('*nsp.evt');
d = cat(1,d1,d2,d3,d4);
for a=1:length(d);
    movefile(d(a).name,newfolder);
end

%% write file for state editor
ev = [normspindles(:,1) normspindles(:,3)];
filename = fullfile(newfolder,'SpindlesForStateEditor.mat');
WriteStateEditorEventsFromTwoColumnEvents(ev,filename)

%% Get Zugaro stats
if exist('varargin','var')
    [maps,data,stats] = SpindleStatsWrapper(numchans, detectionchan, normspindles,varargin);
else
    [maps,data,stats] = SpindleStatsWrapper(numchans, detectionchan, normspindles);
end
data.peakAmplitude = data.peakAmplitude * voltsperunit;
maps.amplitude = maps.amplitude * voltsperunit;


% %% Basic metrics
% SpindleStartTsd = tsd(ev(:,1),ev(:,1));
% % SpindleI = intervalSet(ev(:,1)/10000,ev(:,2)/10000);
% SpindleLengths = Data(length(SpindleI));
% SpindlePowers = normspindles(:,4);
% 
% figure;hist(SpindleLengths,100)
% figure;hist(SpindlePowers,100)

% %% BW summary stats
% totalspindles = length(normspindles);
% meanamp = mean(data.peakAmplitude);
% sdamp = std(data.peakAmplitude);
% meanfreq = mean(data.peakFrequency);
% sdfreq = std(data.peakFrequency);
% meanduration = mean(data.duration);
% sdduration = std(data.duration);
% 
% % States handling
% state_mat = dir('*-states.mat*');
% t = load (state_mat.name);
% StateIntervals = ConvertStatesVectorToIntervalSets(t.states);                 % 6 Intervalsets representing sleep states
% if strcmp(lower(statename),'allstates')
%     stateduration = size(t.states,2);
% elseif strcmp(lower(statename),'nrem') | strcmp(lower(statename),'sws')
%     stateints = or(StateIntervals{2}, StateIntervals{3});
%     stateduration = tot_length(stateints,'s');
% elseif strcmp(lower(statename), 'rem'),
%     stateints = StateIntervals{5};
%     stateduration = tot_length(stateints,'s');
% else strcmp(lower(statename), 'wake'),
%     stateints = StateIntervals{1};
%     stateduration = tot_length(stateints,'s');
% end
% clear t StateIntervals stateints
% 
% occurrencerate = totalspindles/stateduration;
% 
% figure;title({['Total Spindles = ' num2str(totalspindles)],...
%     ['Occurrence Rate = ' num2str(occurrencerate) 'Hz'],...
%     ['Peak Amplitudes: ' num2str(1000000*meanamp) ' +- ' num2str(1000000*sdamp) 'uV']...
%     ['Freq at Peak: ' num2str(meanfreq) ' +- ' num2str(sdfreq) 'Hz']...
%     ['Durations: ' num2str(1000*meanduration) ' +- ' num2str(1000*sdduration) 'ms']...    
%     })
% 
% 
% %%
% 
% % save to a larger struct
% [~,basename,~] = fileparts(cd);
% anat = GetChannelAnatomy(basename,detectionchan);
% 
% SpindleDetectionEval = assignout('base','SpindleDetectionEval');
% 
% SpindleDetectionEval.TotalSpindles(end+1) = totalspindles;
% SpindleDetectionEval.OccurrenceRates(end+1) = occurrencerate;
% SpindleDetectionEval.PeakAmplitudeMeans(end+1) = 1000000*meanamp;
% SpindleDetectionEval.PeakAmplitudeSDs(end+1) = 1000000*sdamp;
% SpindleDetectionEval.PeakDurationMeans(end+1) = 1000*meanduration;
% SpindleDetectionEval.PeakDurationSDs(end+1) = 1000*sdduration;
% SpindleDetectionEval.PeakFrequencyMeans(end+1) = meanfreq;
% SpindleDetectionEval.PeakFrequencySDs(end+1) = sdfreq;
% SpindleDetectionEval.Names{end+1} = basename;
% SpindleDetectionEval.Anatomies{end+1} = anat;
% 
% assignin('base','SpindleDetectionEval',SpindleDetectionEval)


SpindleData = v2struct(normspindles,...
    maps,data,stats,detectionchan,DetectionParams);
save(fullfile(basepath,[basename '_Spindles.mat']),SpindleData)
% MakeDirSaveVarThere(newfolder,SpindleData);
% save(fullfile(newfolder,'SpindleData.mat'),'SpindleData')
