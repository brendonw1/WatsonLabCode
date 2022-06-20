function NewDivy(begin,finish,spikes,stringnum,basename,sievenames,s)

baselinespikes = timeframedivy(begin,finish,spikes);
baselinesizes = [];
for i = 1:length(baselinespikes)
baselinesizes(i) = length(baselinespikes{i});
end
baselinecsv = array2table(NaN(max(baselinesizes),length(spikes.times))); %creating NaN table that will be csv

for j = 1:length(spikes.times)
    baselinecsv(1:length(baselinespikes{1,j}),j) = array2table(baselinespikes{1,j}); %transferring spike data into csv
end

baselinecsv = addAllFilecol(true,baselinecsv,baselinesizes);
disp(['lol'])
writetable(baselinecsv, [basename,'_',sievenames{s},stringnum,'.csv']);
disp(['done with', stringnum])