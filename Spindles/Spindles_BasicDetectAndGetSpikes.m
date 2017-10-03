function Spindles_BasicDetectAndGetSpikes(basepath,basename)
%Brendon Watson 2015
if ~exist('basepath','var')
    basepath = cd;
    [~,basename,~] = fileparts(cd);
else
    cd (basepath)
end
bmd = load([basename '_BasicMetaData.mat']);
numchans = bmd.Par.nChannels;

%% Setup for Detection
detectionchan = bmd.Spindlechannel;
% prompt={'Which channel should spindles be detected on?'};
% name='Spindle Channel';
% numlines=1;
% defaultanswer={num2str(detectionchan)};
% detectionchan=inputdlg(prompt,name,numlines,defaultanswer);
% detectionchan = str2num(detectionchan{1});
% 
% clear prompt name numlines defaultanswer
% % Detect
thresh1 = 2;
thresh2 = 7;

disp('Starting Spindle Detection')
[normspindles,SpindleData] = SpindleDetectWrapper(numchans, detectionchan, bmd.voltsperunit, thresh1, thresh2);
% % make interval set from spindles

% load(fullfile(basepath,'Spindles','SpindleData.mat'),'SpindleData')
% normspindles = SpindleData.normspindles;

%% Get event-wise spiking data
disp('Detecting Spindle Spikes')
Spindles_GetSpindleIntervalSpiking(basepath,basename);

%% Eliminate DOWN state parts from spindles... get event-wise spiking data
disp('Starting No-DOWN spindles')
FindSpindlesWithDOWNs(basepath,basename);
Spindles_GetNoDOWNSpindleIntervalSpiking(basepath,basename);
