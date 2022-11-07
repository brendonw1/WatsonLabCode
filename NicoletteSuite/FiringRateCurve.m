%% Alright. This is gonna be a script that spits out a curve that plots overall 
% Firing rate over time...

% Let's choose this rat first!
if ~exist('rat','var')
    rat = 'Beast';
end

% First let's load in these spikes, yeah?
if ~exist('allspikecells','var')
    DavidGetSpikes;
end

% Now let's choose the size of the bin! In seconds!
bin = 10; 

reclength = GetRecordingLength(allspikecells);
binnedvector = [];

%figure;
for i = 1:length(allspikecells)
    binnedvector(i,:) = binSpikes(allspikecells{i},bin,reclength) / bin;
    %plot(binnedvector(i,:))
    %hold on
end

overallfr = mean(binnedvector,1);





% Grabs the last spike time in the recording and basically labels it as the
% recording length
function [reclength] = GetRecordingLength(allspikecells)
    reclength = 0;
    for i = 1:length(allspikecells)
        if max(allspikecells{i}) > reclength
            reclength = max(allspikecells{i});
        end
    end
    reclength = ceil(reclength);
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