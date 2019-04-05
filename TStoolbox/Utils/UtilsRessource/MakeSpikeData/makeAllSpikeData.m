%  Parameters
RatNb = 19;
dataPath = '/media/sdb6/Data';
dataset = [];



datasetFile = [dataPath '/datasetRat' num2str(RatNb)];

eval(['!./makeDataset.sh ' dataPath ' ' num2str(RatNb)]);

eval(['load ' datasetFile]);
eval(['dataset = datasetRat' num2str(RatNb) ';']);

for i=20:length(dataset)

	if (dataset(i) ~= 200107) || (dataset(i) ~= 200109)
		fprintf([num2str(dataset(i)) '\n]']);
		run(A,'makeSpikeData',{['Rat' num2str(RatNb) filesep num2str(dataset(i))]});
	end
end
