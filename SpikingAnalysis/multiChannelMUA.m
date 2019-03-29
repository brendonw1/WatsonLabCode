function [discrt,contin] = multiChannelMUA(data)

% Gets multi-channel MUA for later alignment to stimuli or
% behavioral/neurophysiological events. Useful for pre-SUA analyses.
%
%
%
% INPUT ___________________________________________________________________
% - data: vector or 2D matrix from bz_LoadBinary, with voltage samples
%   and channels in dimensions 1 and 2 respectively.
%
%
%
% OUTPUTS _________________________________________________________________
% - discrt: column of cells containing timestamp vectors at the original
%   sampling rate (one cell per channel).
%
% - contin: binary version of data (same dimensions of the input), with
%   timestamps marked as "1".
%
%
%
% LSBuenoJr with inputs from BWatson ______________________________________



%% Sets parameters.
filtBand   = [250 4000];           % Bandpass
samplFreq  = 20000;                % Digitization rate
Nyquist    = samplFreq/2;
thrshd     = 4;                    % Standard deviation threshold
spikeWidth = 0.5*(samplFreq/1000); % To rule out spike widths >0.5 ms



%% Filters, then subtracts the average signal from each channel.
tic;disp('Filtering, re-referencing data')

[b,a]      = butter(4,[filtBand(1)/Nyquist filtBand(2)/Nyquist],'bandpass');
filtered   = reshape(filtfilt(b,a,double(reshape(data,numel(data),1))),...
    size(data,1),size(data,2));

referenced = zeros(size(filtered));
for i      = 1:size(filtered,2)
    referenced(:,i) = filtered(:,i)-mean(filtered,2);
end;toc



%% Eliminates noise and small spikes using standard deviation.
tic;disp('Thresholding filtered data')

thresholded = zeros(size(referenced));
for i       = 1:size(referenced,2)
    currLap = referenced(:,i);
    currLap(currLap > (mean(currLap)-(thrshd*std(currLap)))) = 0;
    currLap(currLap ~= 0) = 1;
    thresholded(:,i)      = currLap;
end;toc



%% Filters out suspect large spikes based on width criterion.
tic;disp('Validating spike widths')

delimited = reshape([0;diff(reshape(thresholded,numel(thresholded),1))],...
    size(thresholded,1),size(thresholded,2));

validated          = cell(size(delimited,2),2);k = 0;
for i              = 1:length(validated)
    
    % Onsets and offsets of thresholded signals into cell columns 1 and 2,
    % respectively.
    validated{i,1} = find(delimited(:,i) ==  1);
    validated{i,2} = find(delimited(:,i) == -1);
    
    % Makes sure onset-offset pairs are consistent.
    if validated{i,2}(1) < validated{i,1}(1)
        validated{i,2}   = validated{i,2}(2:end);
    else
    end
    validated{i,1} = validated{i,1}(1:length(validated{i,2}));
    validated{i,1} = [validated{i,1} (validated{i,2} - validated{i,1})];
    
    % Sorts out rejected onsets from cell column 1. This ends up providing
    % spike timestamps, already.
    validated{i,1}(validated{i,1}(:,2) > spikeWidth) = NaN;
    validated{i,1} = validated{i,1}(:,1);
    validated{i,1}(isnan(validated{i,1})) = [];
    
    % This overwritten column 2 consists of spike timestamps +
    % (epoch size * preceding number of channels), as if timestamps were
    % sequenced in a single, long vector. This will be useful for the next
    % section, which binarizes continuous data without a loop.
    validated{i,2} = validated{i,1}+k;k = k+size(delimited,1);
    
end;toc



%% Creates the binary version of the input vector/matrix.
binarized = zeros(numel(delimited),1);

binarized(cell2mat(validated(:,2))) = 1;
binarized = reshape(binarized,size(delimited,1),size(delimited,2));



%% Provides the outputs.
discrt = validated(:,1);contin = binarized;

end