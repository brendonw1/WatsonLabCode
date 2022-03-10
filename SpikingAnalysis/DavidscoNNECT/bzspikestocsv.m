%bzspikes to csv...
%requires a spikes file to be loaded already... for now at least...
%Along with that, it requires the times variable to be loaded... lol...
% Z:\BWRatKetamineDataset\Achilles_120413
% C:\Users\duck7\Documents\Lab Shit\WatsonLabCode

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
    
    csv = addAllFilecol(nicvar,csv,sizes);
    disp(['writing table to ',basename,sievenames{s}]);
    writetable(csv, [basename,'_',sievenames{s},'.csv']);
    disp(['done motherfucker']);
    





    if timeslice %if we're gonna pick and choose csvs based on timeframes
        %use find to find the indices of anything outside of conditions,
        %and make them NaN.I think that'll work... I mean... I hope... I'm
        %guessing that find won't work on tables... maybe just convert
        %spikes.times into a findable structure FIRST and THEN do line 40
        %to copy it over to newcsv.

        baselinespikes = timeframedivy(InjectionComparisionIntervals.BaselineStartRecordingSeconds,InjectionComparisionIntervals.BaselineEndRecordingSeconds,spikes);
        for i = 1:length(baselinespikes)
        baselinesizes(i) = length(baselinespikes{i});
        end
        baselinecsv = array2table(NaN(max(baselinesizes),length(spikes.times))); %creating NaN table that will be csv

        for j = 1:length(spikes.times)
            baselinecsv(1:length(baselinespikes{1,j}),j) = array2table(baselinespikes{1,j}); %transferring spike data into csv
        end
        
        baselinecsv = addAllFilecol(nicvar,baselinecsv,baselinesizes);
        disp(['lol'])
        writetable(baselinecsv, [basename,'_',sievenames{s},'baseline','.csv']);
        disp(['done with lol'])


        P24spikes = timeframedivy(InjectionComparisionIntervals.BaselineP24StartRecordingSeconds,InjectionComparisionIntervals.BaselineP24EndRecordingSeconds,spikes);
        for i = 1:length(P24spikes)
        P24sizes(i) = length(P24spikes{i});
        end
        P24csv = array2table(NaN(max(P24sizes),length(spikes.times))); %creating NaN table that will be csv

        for j = 1:length(spikes.times)
            P24csv(1:length(P24spikes{1,j}),j) = array2table(P24spikes{1,j}); %transferring spike data into csv
        end

        P24csv = addAllFilecol(nicvar,P24csv,P24sizes);
        disp(['hah'])
        writetable(P24csv, [basename,'_',sievenames{s},'circadian','.csv']);
        disp('hah done')
    end

spikes = conservedSpikes;
end