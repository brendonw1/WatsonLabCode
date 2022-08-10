%% Synchrony 
% Brendon's Notes:
% 1) combine the timestamps of spikes from all neurons into one spike train.  they'd look like "one neuron"
% 2) Bin the spike trains to some bin width (maybe start with 50 or 100ms)
% 3) Summate spikes in each bin.   I think there's a buzcode thing for this, I forget the new name (old one sticking in my head)
% 4) Gather a distribution of the values in those bins and look at it in histogram form to check if it's super interesting or something
% 5) If nothing special and the distribution looks roughly gaussian, just use a z-score cut off of 2 SD's beyond the mean
% 6) To do this, use the zscore() matlab function and just find only data above 2 (which means 2 SD's above mean) - each of these is a synchrony event
% 7) then you'd count the number of these per hour or whatever around the cicadian clock
% 8) whatever you get, compare against basic firing rate. I assume firing rate going up by x would increase the chances of this super linearly
% 9) I'd plot this across the different times of day
% 10) I'd repeat this for different bin sizes to see if synchrony at different timescales are more or less modulated by circadian/ultradian rhythms.   I'd use 2ms 5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000 bins and then plot these on top of each other

%% First let's access some spikes! Decide which animal to look at by modifying the 'rat' string
% If you're using buzcode format, instead of using GetSpikes to make
% allspikecells, use the line:
% allspikecells = spikes.times
% after loading in the spikes file of choice
rat  = 'Professor X';
GetSpikes;

%% Now let's combine all the spikes into a single 'train'
combedSpikes = combSpikes(allspikecells);

%% Did it work so far? Good! Now let's sum all the spikes per selected bin and store that in a nice vector called spbin
binlength = .1; % in seconds!
recordingLength = max(combedSpikes);
spbin = binSpikes(combedSpikes, binlength, recordingLength);

%% This is just for sliding bin stuff... Don't worry about this...
chacha = binSpikes(combedSpikes + 1 * (binlength / 4),binlength, recordingLength);
real = binSpikes(combedSpikes + 2 * (binlength / 4),binlength, recordingLength);
smooth = binSpikes(combedSpikes + 3 * (binlength / 4),binlength, recordingLength);

%% Testing some shit out. Don't worry about this here code below
find(spbin >= 5)
find(chacha >= 5)
find(real >= 5)
find(smooth >= 5)

scatter(find(spbin >= 5), ones(length(find(spbin >= 5)),1))
hold on;
scatter(find(chacha >= 5), 1.2* ones(length(find(chacha >= 5)),1))
scatter(find(real >= 5), 1.4*ones(length(find(real >= 5)),1))
scatter(find(smooth >= 5), 1.6*ones(length(find(smooth >= 5)),1))
hold off;

% Function used to combine allspikecells into a single train
function [combedSpikes] = combSpikes(allspikecells) 
    combedSpikes = [];
    try
        for i = 1:length(allspikecells)
            combedSpikes = [combedSpikes; allspikecells{i}];
        end
    catch
        disp('oof. Perhaps make sure that all your spikes are columns not rows?')
    end
    combedSpikes = sort(combedSpikes);
end

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