function resamples = resampledataset(dataset,numresamples)
% function resamples = resampledataset(dataset,numresamples)
% Redraw from initial sample randomly... allowing each value to be taken an
% uncontrolled number of times to contribute to a duplicate dataset with
% the same total number as the original.  Repeat this many times.  
% Input "dataset" must be a vector, output "resamples" will be a matrix of
% resampled versions of the dataset.  Will be (datasetlength)x(numresamples)
NumSamplesInDataset = length(dataset);%number of original samples
indices = ceil(NumSamplesInDataset*rand(NumSamplesInDataset,numresamples));
resamples = dataset(indices);
