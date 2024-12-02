% Parameters
%lfpFile = '/data/Jeremy/Canute/Canute_231208/Canute_231208.lfp';
lfpFile = '/Users/noahmuscat/University of Michigan Dropbox/Noah Muscat/StateEditorStuff/Canute_231208.lfp';
channels = [1 7 67 112]; % Example channels to process
nCh = 128; % Total number of channels in the LFP file
fs = 1250; % Sampling frequency
nFFT = 3075; % FFT length for spectrogram
fRange = [0 200]; % Frequency range for the spectrogram
suffix = '.lfp'; % Suffix of the LFP file
%outputpath = '/home/noahmu/Documents/outputdata'; % The directory to save output
outputpath = '/Users/noahmuscat/University of Michigan Dropbox/Noah Muscat/StateEditorStuff';

specs = saveSpectrogramsFromLFP(outputpath, lfpFile, channels, nCh, fs, nFFT, fRange, suffix);
