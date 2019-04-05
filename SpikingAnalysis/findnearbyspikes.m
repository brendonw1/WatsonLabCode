function syncspikesoutput = findnearbyspikes(sortedspikes,sortedspikeids,synccutoff)
% Finds all spikes in a spike train within synccutoff samples of each other
% 
% A somewhat inefficient but relatively size-tolerant technique to find all
% spikes ocurring within some time window of each other.  Takes chunks of
% 1000 spikes at a time, does all to all subtraction in one step then finds
% diffs less than the specified cutoff.  Then takes some pain to manage the
% problem of juctions between chunks to make sure spike synchronizations
% don't get lost at these junctions.
%
% INPUTS: sortedspikes - 1xn vector of spiketimes from all cells in a given 
%                        recording, sorted with the earliest spikes first.  
%         sortedspikeids - 1xn vector of cell/cluster numbers of origin of 
%                          each correspoing spike in sortedspikes.   [syncspikestimes4ms, syncspikescells4ms] = findnearbyspikes(allspikessorted,allspikesidssorted,40);
%         synccutoff - single number signifying the number of samples
%                      within which spikes should be to be detected (and 
%                      output from this function)
% OUTPUTS: syncspikestimes - 2 column vector of pairs of spikes within 
%                            synccutoff samples of each other (regardless 
%                            of cell of origin)
%          syncspikescells - 2 column vector of cell IDs of each spike,
%                            same dimensions as syncspikestimes, each ID 
%                            corresponds to the spike in the same position as syncspikecells

syncspikestimes = [];
syncspikescells = [];
lastspike = 0;
numspikes = length(sortedspikes);
chunksz = 500;
% chunknum = 0;
numbufferedspikes=0;
% numsyncspikesfromthisloop=0;

dispcounter = round((numspikes-1)/10);
dispmultiplier = 1;

while lastspike<numspikes
%     chunknum = chunknum+1;
    if lastspike+chunksz<numspikes
        spikestotake = (lastspike+1):(lastspike+chunksz);
    else
        spikestotake = (lastspike+1):numspikes;
    end
    
    spikeschunk = sortedspikes(spikestotake);%take a chunk of spiking data
    spikesidschunk = sortedspikeids(spikestotake);%corresponding chunk of cell id data

    %setting up for 2d matrix subtraction of all elements from all elements
    spikesmtx1 = repmat(spikeschunk,[size(spikeschunk,2),1]);
    spikesmtx2 = spikesmtx1';

    diffsmtx = spikesmtx1-spikesmtx2;%subtract to get inter-spike diffs
    diffsmtx(logical(tril(diffsmtx))) = -1;%eliminate the lower half of mtx
    diffsmtx(logical(eye(size(diffsmtx)))) = -1;%elimiate identity (same spike to itself)

    [i,j]=find(diffsmtx<=synccutoff & diffsmtx>0);%find small enough diffs

% getting rid of spike>0 matches equal to those in prior chunk (necessary to make sure junctions don't create missed spikes)
    if numbufferedspikes>0;%ie from last junction
        lastoverlapspiketime = sortedspikes(lastspike+numbufferedspikes);
        overhangmatches = find(spikeschunk(i)<=lastoverlapspiketime & spikeschunk(j)<=lastoverlapspiketime);
            %above finds pairs composed only of pairs from pairs of spikes
            %both in the prior loop to be thrown away (but not from spike
            %pairs crossing the junction, catching which is the entire
            %piont of this whole junction business).
        i(overhangmatches)=[];
        j(overhangmatches)=[];
    end

% saving output
    syncspikestimes = cat(1,syncspikestimes,[spikeschunk(i)' spikeschunk(j)']);%store spike times
    syncspikescells = cat(1,syncspikescells,[spikesidschunk(i)' spikesidschunk(j)']);%store cell ids of spikes
    
%     numsyncspikesfrompriorloop = numsyncspikesfromthisloop;
%     numsyncspikesfromthisloop = length(i);
        
%% handling chunk junctions, want to make sure sync'd spikes at junctions are not missed
    if numspikes>spikestotake(end);%if this is not the end of the entire file and more chunks will be taken

%         nextspiketime = sortedspikes(spikestotake(end)+1);%grab timing of next spike that will be analyze
%         bufferspike = find(spikeschunk >= (nextspiketime-synccutoff),1,'first');%find the earliest spike in finished chunk to include with next
        bufferspike = find(spikeschunk >= (sortedspikes(spikestotake(end))-synccutoff),1,'first');%find all spikes within synccutoff of end
        if ~isempty(bufferspike)%if any to be buffered
            numbufferedspikes = (chunksz-bufferspike) + 1;
            lastspike = spikestotake(end)-(chunksz-bufferspike)-1;%this (together with start of loop) will allow to grab right spikes
        else %if no need to buffer
            lastspike = spikestotake(end);
            numbufferedspikes = 0;
        end
    else %if this is the end of the file... 
        lastspike = numspikes; %will not allow next iteration of loop to execute
    end
    
    if lastspike>(dispcounter*dispmultiplier);%just for feedback
        disp([num2str(lastspike) ' out of ' num2str(numspikes) ' done'])
        dispmultiplier = dispmultiplier+1;
    end
end
% 
% disp(['Chunk size = ',num2str(chunksz)])
% disp(['Sync cutoff = ',num2str(synccutoff)])

%% Separate spikes coming from pairs of cell vs pairs of spikes from one cell
i = find(diff(syncspikescells,1,2)==0);

%make list of all spikes by same cells
samecellssyncspiketimes = syncspikestimes(i,:);
samecellssyncspikecells = syncspikescells(i,:);
%make lists of pairs of spikes from each invidual cell
for a = 1:max(samecellssyncspikecells(:))
    samecellssyncspiketimesbycell{a} = samecellssyncspiketimes((samecellssyncspikecells(:,1)==a),:);
end

%keep a bit list of all spike pairs from different cells
diffcellssyncspiketimes = syncspikestimes;
diffcellssyncspikecells = syncspikescells;
diffcellssyncspiketimes(i,:) = [];
diffcellssyncspikecells(i,:) = [];

%save to output structure
syncspikesoutput.samecellssyncspiketimesbycell = samecellssyncspiketimesbycell;
syncspikesoutput.samecellssyncspiketimes = samecellssyncspiketimes;
syncspikesoutput.samecellssyncspikecells = samecellssyncspikecells;
syncspikesoutput.diffcellssyncspiketimes = diffcellssyncspiketimes;
syncspikesoutput.diffcellssyncspikecells = diffcellssyncspikecells;
syncspikesoutput.allcellssyncspiketimes = syncspikestimes;
syncspikesoutput.allcellssyncspikecells = syncspikescells;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % OLD METHOD
% % An inefficient but relatively size-tolerant technique to find all spikes
% % ocurring within some time window of each other.  Loops through one spike
% % at a time and finds other spikes within the given window of that
% % reference, then goes on to the next.  (Uses serial subtractions of
% % neighboring spikes rather than diff'ing all spikes against this one).
% % Consider making more efficient if computationally feasible
% % 
% % synccutoff = 40;%4ms
% % burstcutoff = 40;%4ms
% syncspikescells = [];
% syncspikestimes = [];
% numspikes = length(sortedspikes);
% dispcounter = round((numspikes-1)/20);
% for a = 1:numspikes-1
%     thisspk = sortedspikes(a);
%     numplus = 1;
%     plusdiff = 0;
%     while plusdiff<=synccutoff
%         plusdiff = sortedspikes(a+numplus)-thisspk;
%         if plusdiff <= synccutoff
%             syncspikestimes(end+1,:)=[thisspk sortedspikes(a+numplus)];
%             syncspikescells(end+1,:)=[sortedspikeids(a) sortedspikeids(a+numplus)];
%             numplus = numplus + 1;
%         end
%     end
%     
%     if rem(a,dispcounter)==0;%just for feedback
%         disp([num2str(a) ' out of ' num2str(numspikes) ' done'])
%     end
% end