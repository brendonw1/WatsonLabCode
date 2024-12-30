%% this folder is used to test logic that will be implemented into SpectralFreqInator.m
% Parameters
lfpFile = '/Users/noahmuscat/University of Michigan Dropbox/Noah Muscat/SleepStuff/SleepScoringFilesScatha/Canute_231208_101235/Canute_231208.lfp';
channels = [1 7]; % Example channels to process
nCh = 128; % Total number of channels in the LFP file
fs = 1250; % Sampling frequency, 1250 Hz default for lfp
nFFT = 3075; % FFT length for spectrogram
fRange = [0 200]; % Frequency range for the spectrogram
%outputpath = '/home/noahmu/Documents/outputdata'; % The directory to save output
outputpath = '/Users/noahmuscat/Desktop';

[specs, baseName] = saveSpectrogramsFromLFP(outputpath, lfpFile, channels, nCh, fs, nFFT, fRange);
%% testing
[bands, epochs] = PowerFreqFromSpecFreqInator(specs, 1);
