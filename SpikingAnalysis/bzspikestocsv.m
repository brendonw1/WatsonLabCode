%bzspikes to csv...
%requires a spikes file to be loaded already... for now at least...
%Along with that, it requires the times variable to be loaded... lol...

filtered = 1;
nicvar = 1;
timeslice = 1;
[parentpath,basename] = fileparts(cd);
basepath = [parentpath,'/', basename];

if filtered 
   load([basepath, '/goodUnitsCurated.mat']);
   load([basepath, '/goodUnitsDaviolin.mat']); 
   load([basepath, '/', basename, '_InjectionComparisionIntervals.mat']);
   [lol,hah,goodUnitsBoth] = UnitsCompare(goodUnits,goodUnitsDaviolin);
   allUnits = 1:length(spikes.UID);
   sieve = {allUnits,goodUnits,goodUnitsDaviolin,goodUnitsBoth};
   sievenames = {'All Units','Max Choices', 'David Choices', 'Collab Choices'};
end


for s = 1:length(sieve)
    if filtered
        subsieve = sieve{s};
        conservedSpikes = spikes;
        for p = flip(1:length(spikes.UID))
            if ~ismember(p,subsieve)
               spikes.times(p) = [];
            end
        end
    end
    
    for i = 1:length(spikes.times)
        sizes(i) = length(spikes.times{i});
    end

    csv = array2table(NaN(max(sizes),length(spikes.times))); %creating NaN table that will be csv

    for j = 1:length(spikes.times)
        csv(1:length(spikes.times{1,j}),j) = array2table(spikes.times{1,j}); %transferring spike data into csv
    end
    
    if timeslice %if we're gonna pick and choose csvs based on timeframes
        newcsv = csv;
        
    end
    
    
    %this is just for the Reformatting function that Nicolette's data uses
    if nicvar
        allfilestartcol = array2table(NaN(max(sizes),1));
        allfilestartcol.Properties.VariableNames = {'AllFile_start'};
        csv = [csv allfilestartcol];
    end

    writetable(csv, [basename,'_',sievenames{s},'.csv']);
    spikes = conservedSpikes;
end