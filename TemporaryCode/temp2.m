%% Changeable stuff
basepath = cd;
channelsIWant = 1:192;
start = 0;%seconds
duration = inf;%seconds



%% Automated parts 
%setup
basename = bz_BasenameFromBasepath(basepath);
datpath = fullfile(basepath,[basename,'.dat']);

sessionInfo = bz_getSessionInfo(basepath);

%getting parameters
sampfreq = sessionInfo.rates.wideband;
offset = 0;
nchannels = 1:length(sessionInfo.channels);
channels = channelsIWant;
if sessionInfo.nBits == 16
    precision = 'int16';
end
skip = 0;
downsample = 1;

% read in data... watch out this can get huge
data = bz_LoadBinary(datpath,'frequency',sampfreq,'start',start,...
    'duration',duration,'offset',offset,'nChannels',nchannels,...
    'channels',channels,'precision',precision,'skip',skip,...
    'downsample',downsample);

% Find MUA in the gathered data
[discrt,contin] = multiChannelMUA(data);
