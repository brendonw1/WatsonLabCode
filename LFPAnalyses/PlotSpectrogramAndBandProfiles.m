function PlotSpectrogramAndBandProfiles(spectrograms, frequencyBandTimeProfiles, FileBase)

%% extracting some data for easier addressing
t = spectrograms.timepointsTransentsGone;
f = spectrograms.frequenciesSampled;
spectrogram = spectrograms.flippedSquaredLogged;

%% make a spectogram-alone figure
figure;imagesc(t,f,spectrogram)
axis xy %puts origin at bottom left
title (FileBase)

%% make a fig with subplots including spectrogram and delta, theta, alpha, beta, gamma
figure;
subplot(4,2,1); imagesc(t,f,spectrogram); axis xy; title (FileBase)

subplot(4,2,2); plot (t,frequencyBandTimeProfiles.delta); title ('delta (1-4Hz)');axis tight
subplot(4,2,3); plot (t,frequencyBandTimeProfiles.theta); title ('theta (4-8Hz)');axis tight
subplot(4,2,4); plot (t,frequencyBandTimeProfiles.alpha); title ('alpha (8-12Hz)');axis tight
subplot(4,2,5); plot (t,frequencyBandTimeProfiles.beta); title ('beta (12-30Hz)');axis tight
subplot(4,2,6); plot (t,frequencyBandTimeProfiles.gamma); title ('gamma (30-70Hz)');axis tight
subplot(4,2,7); plot (t,frequencyBandTimeProfiles.higamma); title ('high gamma (70-150Hz)');axis tight
