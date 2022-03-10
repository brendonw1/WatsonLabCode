function [newspikes] = timeframedivy(lowlimit,highlimit,spikes)
%TIMEFRAMEDIVY Summary of this function goes here
%   Detailed explanation goes here
newspikes = {};
    for k = 1:length(spikes.times)
        newspikes{1,k} = spikes.times{1,k}(spikes.times{1,k} >= lowlimit & spikes.times{1,k}<= highlimit);
    end
       
end

