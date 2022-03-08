function [newspikes] = timeframedivy(lowlimit,highlimit,spikes)
%TIMEFRAMEDIVY Summary of this function goes here
%   Detailed explanation goes here
    for k = 1:length(spikes.times)
        newspikes = spikes.times{1,k}(spikes.times{1,k} >= lowlimit & spikes.times{1,k}<= highlimit);
    end
       
end

