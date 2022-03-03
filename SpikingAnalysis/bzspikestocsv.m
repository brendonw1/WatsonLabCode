%bzspikes to csv...
for i = 1:length(spikes.times)
    sizes(i) = length(spikes.times{i});
end

csv = array2table(NaN(max(sizes),length(spikes.times)));

for j = 1:length(spikes.times)
    csv(1:length(spikes.times{1,j}),j) = array2table(spikes.times{1,j});
end

%this is just for the Reformatting function that Nicolette's data uses
allfilestartcol = array2table(NaN(max(sizes),1));
allfilestartcol.Properties.VariableNames = {'AllFile_start'};
csv = [csv allfilestartcol];

writetable(csv, 'Dino_080114.csv');