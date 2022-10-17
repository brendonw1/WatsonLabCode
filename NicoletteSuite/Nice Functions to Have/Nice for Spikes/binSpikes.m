% Counts how many spikes there are per bin throughout the whole
% combedSpikes train!
function [spbin] = binSpikes(combedSpikes, binlength, recordingLength)
    spbin = zeros(1,ceil(recordingLength/binlength));
    for i = 1:length(spbin)
        spbin(i) = framesum((i-1) * binlength,i * binlength,combedSpikes);
    end
end

%This guy is used in binSpikes. It is the summer/counter for a spiketrain
function [summed] = framesum(low,high,train)
    subtrain = train < high & train >= low;
    summed = sum(subtrain);
end