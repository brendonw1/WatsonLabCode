function [spectrograms, frequencyBandTimeProfiles] = SpectrogramAndBandProfiles_pg(channelData, transientTimes, Fs, plotting)
% Computes power in the named frequency bands
% (delta,theta,alpha,beta,gamma) for each second an input dataset.  Assumes
% sampling rate of 1250 (ie eeg/lfp file).  Band definitions: 
% Delta 1-4Hz
% Theta 4-8Hz
% Alpha 8-12Hz
% Beta 12-30Hz
% Gamma 30-70Hz
% High Gamma 70-150Hz
% INPUTS
% OUTPUTS

%% Basic parameter setting
bandspersec = 1;
FreqRange = [0 150];

%% Calculate spectrograms
[y,f,t]=mtcsglong(channelData,2048,Fs,Fs/bandspersec,0,[],'linear',[],FreqRange);
spectrograms.raw = y; %save into output
spectrograms.timepointsRaw = t;

%% if there are stimulation artifacts (ie footshocks), use input transientTimes to chop them out
if ~exist('transientTimes','var')
    transientTimes = [];
end
if ~exist('plotting','var')
    plotting = 1;
end

numtransients = size(transientTimes,1);
transientpoints = [];
for a = 1:numtransients;
    b = numtransients-a+1; %go through backwards to not mess up indices of ones addressed later in time
	transientstartpoint =  find(t<transientTimes(b,1),1,'last');
	transientstoppoint =  find(t>transientTimes(b,2),1,'first');
	transientpoints = [transientstartpoint:transientstoppoint];
	t(transientpoints)=[];
	y(transientpoints,:)=[];
end
spectrogram = log(sq(y'));

%% saving spectrogram data for output
spectrograms.stimTransientsGone = y;
spectrograms.flippedSquaredLogged = spectrogram;
spectrograms.timepointsTransentsGone = t;
spectrograms.frequenciesSampled = f;

%% Get out power profiles of various spectral bands, saving for output
deltabins = f>1 & f<=4;
deltabins = find(deltabins);
deltaTimeProfile = mean(y(:,deltabins),2);
frequencyBandTimeProfiles.delta = deltaTimeProfile;

thetabins = f>4 & f<=8;
thetabins = find(thetabins);
thetaTimeProfile = mean(y(:,thetabins),2);
frequencyBandTimeProfiles.theta = thetaTimeProfile;

alphabins = f>8 & f<=12;
alphaabins = find(alphabins);
alphaTimeProfile = mean(y(:,alphabins),2);
frequencyBandTimeProfiles.alpha = alphaTimeProfile;

betabins = f>12 & f<=30;
betabins = find(betabins);
betaTimeProfile = mean(y(:,betabins),2);
frequencyBandTimeProfiles.beta = betaTimeProfile;

gammabins = f>30 & f<=70;
gammabins = find(gammabins);
gammaTimeProfile = mean(y(:,gammabins),2);
frequencyBandTimeProfiles.gamma = gammaTimeProfile;

higammabins = f>70 & f<=150;
higammabins = find(higammabins);
higammaTimeProfile = mean(y(:,higammabins),2);
frequencyBandTimeProfiles.higamma = higammaTimeProfile;

%% Plot data into 2 figs, one w just spectrogram and one w family of freq bands
if plotting
    PlotSpectrogramAndBandProfiles(spectrograms, frequencyBandTimeProfiles, FileBase)
end
