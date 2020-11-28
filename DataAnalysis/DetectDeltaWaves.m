function deltas = DetectDeltaWaves(raw)%input is raw lfp data in volts
% deltas = DetectDeltaWaves(totalnumchannels,ChanToUse,basename)

% basename = 'BWRat20_101513';
% 
% if ~strcmp(basename(end-3:end),'.eeg') && ~strcmp(basename(end-3:end),'.lfp')
%     if exist([basename,'.eeg'],'file');
%         filename = [basename,'.eeg'];
%     elseif exist([basename,'.lfp'],'file');
%         filename = [basename,'.lfp'];
%     end
% end
%     
% % totalnumchannels = 72;
% % ChanToUse = 48;
% sampfreq = 1250;
lowpasscutoff = 4;%Hz for lowpass cutoff
% 
% raw = LoadBinary(filename,'frequency',sampfreq,'nchannels',totalnumchannels,'channels',ChanToUse);

% [b,a] = butter(2,(lowpasscutoff/(0.5*sampfreq)),'low'); %generate lowpass butterworth filter
% % raw = lfp(1250*9700:1250*9900);

voltagecutoff = 0.00015;

[b,a] = butter(2,([.5/(0.5*1250)]),'low');%make a low pass signal to subtract low freq stuff from data
filtered = filtfilt(b,a,raw);
raw2 = raw-filtered;

[b,a] = butter(4,([lowpasscutoff/(0.5*1250)]),'low');%now look for ~4hz events
filtered = filtfilt(b,a,raw2);

mindur = 50;%ms
maxdur = 500;%ms

deltas = continuousabove2(filtered,voltagecutoff,mindur,maxdur);
% figure;plot(raw);hold on;plot(deltas',zeros(size(deltas))')

% WriteEventFileFromTwoColumnEvents (deltas/sampfreq*1000,[basename,'.dlt'])






