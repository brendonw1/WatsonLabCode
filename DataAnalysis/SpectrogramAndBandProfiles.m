function [spectrograms, frequencyBandTimeProfiles] = SpectrogramAndBandProfiles(FileBase, channelNumber, transientTimes)

if exist ([FileBase,'.eeg'], 'file') 
    channelData = LoadBinary_bw([FileBase,'.eeg'],channelNumber);
elseif exist ([FileBase,'.lfp'], 'file')
    channelData = LoadBinary_bw([FileBase,'.lfp'],channelNumber);
else
    disp('No .lfp or .eeg file exists')
end

[y,f,t]=mtcsglong(channelData,2048,1250,1024,[],[],'linear',[],[0 100]);
spectrograms.raw = y; %save into output
spectrograms.timepointsRaw = t;


%% if there are stimulation artifacts (ie footshocks), use input transientTimes to chop them out
if ~exist('transientTimes','var')
    transientTimes = [];
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

betabins = f>12 & f<=20;
betabins = find(betabins);
betaTimeProfile = mean(y(:,betabins),2);
frequencyBandTimeProfiles.beta = betaTimeProfile;

gammabins = f>30 & f<=90;
gammabins = find(gammabins);
gammaTimeProfile = mean(y(:,gammabins),2);
frequencyBandTimeProfiles.gamma = gammaTimeProfile;

%% Plot data into 2 figs, one w just spectrogram and one w family of freq bands
PlotSpectrogramAndBandProfiles(spectrograms, frequencyBandTimeProfiles, FileBase)

