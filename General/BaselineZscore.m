function output = BaselineZscore(data,b)

% output = BaselineZscore(data,b)
%
% Unlike the built-in zscore, this function normalizes each value against
% a baseline, including baseline values themselves. This baseline can be
% any kind of binned or continuous data collected before an experimental
% manipulation (e.g., drug injection, tetanic stimulation), or
% epoch-locking trigger (e.g., in perievent potentials, histograms), etc.
%
% USAGE ___________________________________________________________________
% data -> any 2D or 3D matrix, provided that repeated measures (e.g. time
% bins, blocks of behavioral trials, voltage samples, etc.) are in the
% second dimension. In 2D matrices, the first dimension can contain, for
% example, subjects, neurons, channels, etc. If present, the third
% dimension may contain subjects, assuming that the first dimension is
% occupied by channels or frequency bins, for example. NaNs are ignored.
%
% b -> a positive integer that delimits the baseline (e.g. the last time
% bin, or block of trials, or voltage sample, etc.).
%
% LSBuenoJr _______________________________________________________________

%%
output  = zeros(size(data));
for i   = 1:size(data,3)
    
    output(:,:,i) = (data(:,:,i)-...
        (repmat(nanmean(data(:,1:b,i),2),   1,size(data,2))))./...
         repmat(nanstd (data(:,1:b,i),[],2),1,size(data,2));
end
end