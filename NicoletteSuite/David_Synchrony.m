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

% Hot takes: most threads look dumb. 
% Threads are the quickest way to make a beginner bboy look stupid
% Wristbreaker moves and lotuses pretty much always look terrible
% Bent leg flares look good
% headspins are underrated
% Menno's wack
% Buddha spins look like shit

%% First let's access some spikes! Decide which animal to look at by modifying the 'rat' string
% If you're using buzcode format, instead of using GetSpikes to make
% allspikecells, use the line:
% allspikecells = spikes.times
% after loading in the spikes file of choice
if ~exist('rat','var')
    rat  = 'Cyclops';
end
DavidGetSpikes;
FiringRateCurve;


%% Now let's create a simple spikemat!
% Let's first create a binsize :)
binsize = 1;
if ~exist('spikemat','var')
%     spikemat = dv_SpktToSpkmat(allspikecells, binsize);
end

%% So this next part might be a little hodgepodgy/confusing
% Next, I'm going to normalize the spikematrix by each individual
% spiketrain. The reason why I'm doing this is so that the high firing
% neurons simply don't dominate over the low firing rate neurons. 
for i = 1:size(spikemat,1)
    hasbeendisp = 0;
    curtrage = [0];
    indperhour = 3600/binsize;
    for j = 1:length(spikemat(i,:))
        try
            spikesinhour = sum(spikemat(i,(floor(j/(indperhour+.00001))*indperhour +1):(ceil(j/indperhour)*indperhour) ));           
        catch
            assert(ceil(j/indperhour)*indperhour > length(spikemat(i,:)));
            spikesinhour = sum(spikemat(i,(floor(j/(indperhour+.00001))*indperhour +1):end ));
        end
            if ~hasbeendisp
                disp(num2str(spikesinhour));
                hasbeendisp = 1;
            end
            if curtrage(end) ~= spikesinhour && length(curtrage) > 1
            hasbeendisp = 0;
            end
            curtrage(j) = spikesinhour;
            newspikemat(j) = spikemat(i,j) / spikesinhour;
    end
    
    disp(' ');
    
    for k = 1:length(newspikemat)
        if isnan(newspikemat(k))
            newspikemat(k) = 0;
        end
    end
    
    spikemat(i,:) = newspikemat;
end
combedSpikemat = sum(spikemat,1);

reclength = length(combedSpikemat);
THEcurve = zeros(1,reclength);
f = waitbar(0,'Letz get dis boi');
for i = 1:reclength
    thisguy = NewGaussBursts(reclength,i,combedSpikemat(i),100);
    THEcurve = THEcurve + thisguy;
    waitbar(i/reclength,f);
end
delete(f);


%% SMALL PATCH
cd('/analysis/Dayvihd/Synchrony/HrlyNormedSynchrony')
lol = load([rat 'RawCurve.mat']);
THEcurve = lol.THEcurve;
%% Finally, for this method, let's plot the results compared to the FR :)

yay=figure;
if ~exist('ints','var')
    ints = makeints(rat);
end
hypno = MakeHypno(ints);
subplot(3,1,1)
%plot(movmean(THEcurve,ceil(600/binsize)));
plot(movmean(THEcurve,600));
axis tight;
ylabel('Synchrony');

subplot(3,1,2)
imagesc(hypno);
colorMap = [255/256 255/256 0; 102/256 178/256 255/256; 255/256 102/256 178/256];
colormap(colorMap);
ylabel('Hypnogram')

subplot(3,1,3)
plot(movmean(overallfr,60));
axis tight;
ylabel('Firing Rate');
sgtitle(['Synchrony vs Firing Rate over Time for ',rat])

cd('/analysis/Dayvihd/Synchrony/HrlyNormedSynchrony/AlsoNiceFigures')
savefig(yay, [rat, '.fig'])
saveas(yay,[rat,'.png'])

% cd('/analysis/Dayvihd/Synchrony/HrlyNormedSynchrony')
% save([rat, 'RawCurve.mat'],'THEcurve')

%% I decided midway through that we're gonna do some sleep state analysis!
% So let's access a variable called 'ints'. This basically hold all the
% windows for all the sleepstates. 
% For Nicolette's rats they would be found in /analysis/Dayvihd. Use
% MakeSleepStates. It should be a variable called ints that you can pretty
% readily use. 
if ~exist('ints','var')
    ints = makeints(rat);
end

%% Now let's combine all the spikes into a single 'train'
% combedSpikes = combSpikes(allspikecells);

%% Did it work so far? Good! Now let's sum all the spikes per selected bin and store that in a nice vector called spbin
% binlength = .1; % in seconds!
% recordingLength = max(combedSpikes);
% spbin = binSpikes(combedSpikes, binlength, recordingLength);

%% This is just for sliding bin stuff... Don't worry about this...
% slides = 7;
% chacha = binSpikes(combedSpikes + 1 * (binlength / slides),binlength, recordingLength);
% real = binSpikes(combedSpikes + 2 * (binlength / slides),binlength, recordingLength);
% smooth = binSpikes(combedSpikes + 3 * (binlength / slides),binlength, recordingLength);
% doo = binSpikes(combedSpikes + 4 * (binlength / slides),binlength, recordingLength);
% dudum = binSpikes(combedSpikes + 5 * (binlength / slides),binlength, recordingLength);
% dum = binSpikes(combedSpikes + 6 * (binlength / slides),binlength, recordingLength);

%% Testing some shit out. Don't worry about this here code below
% find(spbin >= 5)
% find(chacha >= 5)
% find(real >= 5)
% find(smooth >= 5)
% find(doo >= 5)
% find(dudum >= 5)
% find(dum >= 5)
% 
% scatter(find(spbin >= 5), ones(length(find(spbin >= 5)),1))
% hold on;
% scatter(find(chacha >= 5), 2* ones(length(find(chacha >= 5)),1))
% scatter(find(real >= 5), 3*ones(length(find(real >= 5)),1))
% scatter(find(smooth >= 5), 4*ones(length(find(smooth >= 5)),1))
% scatter(find(doo >= 5), 5*ones(length(find(doo >= 5)),1))
% scatter(find(dudum >= 5), 6*ones(length(find(dudum >= 5)),1))
% scatter(find(dum >= 5), 7*ones(length(find(dum >= 5)),1))
% hold off;

%% Okay, I'm gonna just try something else out. Hang tight.
% My plan is to look at the different synchrony events differently... For
% instance, I'll visualize 3 same-time firings and then visualize 4
% same-time firings and so on and so forth I'll probably do this in scatter
% plots

% compareDiffFig(spbin)
% compareDiffFig(chacha)
% compareDiffFig(real)
% compareDiffFig(smooth)

%% Okay, whatever. Now that that's done, let's move onto the next step yeah?
% Let's plot this out on a histogram yeah? Let's go. We're just going to go
% through the vector and slap gaussians over every timepoint

% minthrumax = PlotSynchsFrom(spbin,3,recordingLength,binlength,allspikecells,overallfr,MakeHypno(ints));
% 
% cd('/analysis/Dayvihd/Synchrony');
% lol = zeros(24,size(minthrumax,1));
% for i = 1:size(minthrumax,1)
%     lol(:,i) = curveaveragebin(minthrumax(i,:),24);
% end

% save([rat,'.mat'],'lol');

% loltest = zeros(1,ceil(recordingLength)/binlength);
%     for i = 3:length(allspikecells)
%         thething = GaussBursts(recordingLength,find(spbin == i)*binlength,i,100,binlength); %find is used to produce a vector of all the synchrony event timestamps!
%         loltest = loltest + thething;
%     end
% 
% figure;
% hypno = MakeHypno(ints);
% subplot(3,1,1);
% plot(movmean(loltest,600));
% axis tight
% ylabel('Synchrony')
% subplot(3,1,3);
% imagesc(hypno);
% colorMap = [255/256 255/256 0; 102/256 178/256 255/256; 255/256 102/256 178/256];
% colormap(colorMap);
% ylabel('Hypnogram')
% subplot(3,1,2);
% plot(movmean(overallfr,20));
% axis tight
% ylabel('Firing Rate')

% MakeSynchronyCurve;


%Different versino of MakeSynchronyCurve meant for normalized matrices, nam
%sayin?
function [loltest] = NewMakeSynchronyCurve(combMat,recordingLength,binlength,allspikecells,minSynch)
    
    loltest = zeros(1,ceil(recordingLength)/binlength);
    for i = minSynch:length(allspikecells)
        thething = GaussBursts(recordingLength,find(combMat == i)*binlength,i,100,binlength); %find is used to produce a vector of all the synchrony event timestamps!
        loltest = loltest + thething;
    end
end

%New version of GaussBursts
function [curvewewant] = NewGaussBursts(recordingLength,index,weight,gausswidth)
    curcurvex = (-1*gausswidth):(ceil(recordingLength)+gausswidth); %It is .5 appended on both sides because of just how the algorithm works...
    curcurve = zeros(1,length(curcurvex)); % curcurvex only has the timestamps! This has the actual values :)
    ex = (-gausswidth):gausswidth;
    why = weight*exp(-(5/gausswidth)*ex.^2); %don't ask how I got this... Arbitrary...
    
    %index = find(abs(curcurvex - round(index(i),2)) < .005);
    index = index + 1;
    curcurve(index:(index+(2*gausswidth))) = curcurve(index:(index+(2*gausswidth))) + why;
    
    curvewewant = curcurve(curcurvex > 0 & curcurvex <= ceil(recordingLength));
    
end





% You already KNOW what this does
function [spikemat] = dv_SpktToSpkmat(allspikecells,bin)
    reclength = makeReclength(allspikecells);
    spikemat = [];
    
    for i = 1:length(allspikecells)
        spikemat = [spikemat; binSpikes(allspikecells{i},bin,reclength)];
    end
    
    
end

function [reclength] = makeReclength(allspikecells)
    rex = {};
    for i = 1:length(allspikecells)
        rex{i} = max(allspikecells{i});
    end
    
    reclength = max(cell2mat(rex));
end

% Takes the average of the curve in 'bins' number of bins
function [binned] = curveaveragebin(curve,bins)
    recLength = length(curve);
    binned = zeros(1,bins);
    bindexsize = recLength / bins;
    for i = 1:bins
        binned(i) = nanmean(curve((ceil((i-1)*bindexsize)+1):round(i*bindexsize)));
    end

end

function [allguys] = PlotSynchsFrom(spbin,minSynch,recordingLength,binlength,allspikecells,overallfr,hypno)
    figure;
    subplot(max(spbin)-minSynch + 2,1,1)
    plot(movmean(overallfr,20));
    axis tight
    ylabel('Firing Rate')
    allguys = zeros(max(spbin)-minSynch+1,ceil(recordingLength)/binlength);
    for i = minSynch:max(spbin)
        subplot(max(spbin)-minSynch + 2,1,i-1)
        thisguy = MakeSynchronyCurve(spbin,recordingLength,binlength,allspikecells,i);
        plot(movmean(thisguy,6000))
        axis tight;
        ylabel(['Synch ', num2str(i),'U'])
        allguys(i-minSynch + 1,:) = thisguy;
    end
    subplot(max(spbin)-minSynch + 2,1,i-1)
    imagesc(hypno);
    colorMap = [255/256 255/256 0; 102/256 178/256 255/256; 255/256 102/256 178/256];
    colormap(colorMap);
    ylabel('Hypnogram')
    sgtitle('FR and Synchrony Based on Minimum Synchronous Spikes');
end

function [loltest] = MakeSynchronyCurve(spbin,recordingLength,binlength,allspikecells,minSynch)
    loltest = zeros(1,ceil(recordingLength)/binlength);
    for i = minSynch:length(allspikecells)
        thething = GaussBursts(recordingLength,find(spbin == i)*binlength,i,100,binlength); %find is used to produce a vector of all the synchrony event timestamps!
        loltest = loltest + thething;
    end
end


function compareDiffFig(spbin)
    figure;
    for i = 3:max(spbin)
        this = find(spbin == i);
        scatter(this,i*ones(length(this),1))
        hold on;
    end
    hold off;
end

% This makes the sleepstate window struct called ints! In this program
% it'll be used for making a hypnogram
function [ints] = makeints(ratname)
    cd(['/analysis/Dayvihd/',ratname]);
    wakeints = table2array(readtable([cd '/' ratname ' Wake Windows.csv']));
    nremints = table2array(readtable([cd '/' ratname ' NREM Windows.csv']));
    remints = table2array(readtable([cd '/' ratname ' REM Windows.csv']));

    ints = struct('WAKEstate',wakeints,'NREMstate',nremints,'REMstate',remints);
end

% This guy is ripped from SpikeFieldCoherence. It needs a variable called
% ints, which I'll put above this
function [hypno] = MakeHypno(ints)
    maxtime = max([max(ints.WAKEstate) max(ints.NREMstate) max(ints.REMstate)]);

    hypno = zeros(1,round(maxtime));
    for i = 1:length(hypno)
        for j = 1:length(ints.WAKEstate(:,1))
            if (i > ints.WAKEstate(j,1) && i < ints.WAKEstate(j,2))
                hypno(i) = .9;
            end
        end
        for j = 1:length(ints.NREMstate(:,1))
            if (i > ints.NREMstate(j,1) && i < ints.NREMstate(j,2))
                hypno(i) = 1.5;
            end
        end
        for j = 1:length(ints.REMstate(:,1))
            if (i > ints.REMstate(j,1) && i < ints.REMstate(j,2))
                hypno(i) = 2.9;
            end
        end    
    end
end


% Okay, so this function is a little weird. I actually ripped this from the 
% burstiness code. It basically takes in all the timepoints and burst weights, 
% and creates  a curve where all the bursts are represented as a gaussian 
% (based on the weight...)
function [curvewewant] = GaussBursts(recordingLength,timepoints,weight,gausswidth,binlength)
    curcurvex = (-1*gausswidth):binlength:(ceil(recordingLength)+gausswidth); %It is .5 appended on both sides because of just how the algorithm works...
    curcurve = zeros(1,length(curcurvex));% curcurvex only has the timestamps! This has the actual values :)
    ex = (-gausswidth):binlength:gausswidth;
    why = weight*exp(-(5/gausswidth)*ex.^2); %don't ask how I got this... Arbitrary...
    
    for i = 1:length(timepoints(~isnan(timepoints)))
        timeind = find(abs(curcurvex - round(timepoints(i),2)) < .005);
        curcurve((timeind-(gausswidth/binlength)):(timeind+(gausswidth/binlength))) = curcurve((timeind-(gausswidth/binlength)):(timeind+(gausswidth/binlength))) + why;
    end
    
    curvewewant = curcurve(curcurvex > 0 & curcurvex <= ceil(recordingLength));
    
end


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