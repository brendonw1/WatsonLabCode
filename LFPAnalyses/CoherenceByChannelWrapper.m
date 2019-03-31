function [corrmat,sites,h] = CoherenceByChannelWrapper(basepath,freqrange,metric)
% Uses Dan Levenstein's LFPPairMat to do channel-wise comparisons of
% coherence in arbitrary frequency range using one of various measures.
% See LFPPairMat documentation for more info.  This can be downloaded from
% github at https://github.com/dlevenstein/DLevenstein-Code.
% Options for freqrange and metric
%       'freqrange'    frequency range to calculate coherence/correlation,
%           default is "gamma" (30-80Hz).
%           Can also input startstop pairs to denote frequency
%           Named band options are
%                delta      [0 4]
%                theta      [4 10]
%                spindles   [10 20]
%                gamma      [30 80]
%                ripples    [130 170]
%                bbhigamma  [50 180]
%       'metric'    pairwise metric to use
%           'corr'  correlation between raw signal
%           'powercorr' correlation between power of filtered signal
%           'ISPC'  (default) (functional) AKA phase coherence
%           'filtcorr'  correlation between filtered signal
%
% Brendon Watson 2016

%% Constants and Parameters
if ~exist('basepath','var')
    [~,basename] = fileparts(cd);
end
basename = bz_BasenameFromBasepath(basepath);
if ~exist('freqrange','var')
    freqrange = 'bbhigamma';
end
if ~exist('metric','var')
    metric = 'filtcorr';
end


Par = LoadParameters(fullfile(basepath,[basename '.xml']));

%% Get channel list... all channels in .xml spike groups
if exist(fullfile(basepath,'EEGChannelsToUse.txt'))%would be made by DionDataEcogChannelsToUse.m
    chanlist = TextReadToVector(fullfile(basepath,'EEGChannelsToUse.txt'));
else    
    chanlist = [];
    for a = 1:length(Par.SpkGrps);
        chanlist = cat(2,chanlist,Par.SpkGrps(a).Channels);
    end
    badchannels = ReadBadChannels(basepath);
    chanlist = setdiff(chanlist,badchannels);
end

%% find times of high power
% load all channels
% filter by power
% record/save powers per 

%% Call base function
[corrmat,sites,h] = LFPPairMat('basepath',basepath,'basename',basename,...
    'frange',freqrange,'metric',metric,'channels',chanlist);


%% Save results
if isnumeric(freqrange)
    freqrangestr = [num2str(freqrange) 'Hz'];
else
    freqrangestr = freqrange;
end
outputnamestr = ([basename '_CoherenceBy' metric '_In' freqrangestr 'Range']);

save(fullfile(basepath,outputnamestr),'corrmat','sites')

%% Figure Making and Saving


title(['Channel-to-channel coherence in ' freqrangestr ' range.  Metric:' metric '. ' basename])
set(h,'name',outputnamestr)

MakeDirSaveFigsThereAs(fullfile(basepath,'CoherenceFigs'),h,'fig')
MakeDirSaveFigsThereAs(fullfile(basepath,'CoherenceFigs'),h,'png')

1;