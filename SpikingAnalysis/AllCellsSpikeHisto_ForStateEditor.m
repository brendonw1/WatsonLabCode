function AllCellsSpikeHisto_ForStateEditor(basename,cellnum)
% Assuming you are in directory with data from recording of interest, will
% import spike data, make a 1sec

d = dir([basename,'.lfp']);
if isempty(d)
    d = dir([basename,'.eeg']);
end

try
    Par = LoadPar([basename,'.xml']);
catch
    error('is there an .xml in the folder?')
    return
end

durationinsec = round((d.bytes*8/16/Par.nChannels/Par.lfpSampleRate)-1);
% durationinsec = round((length(rawEeg{1}/eegFS) - 1)
binwidth = 1000;%ms
binspersec = 1000/binwidth;
samplerate = Par.SampleRate;%for spike timing (based on dat file);


[spiket, spikeind, numclus, iEleClu, spikeph] = ReadEl4CCG2(basename);
[numspikes,bincenters]=hist(spiket,durationinsec*binspersec);
bincenters = bincenters/samplerate*binspersec;

save ([basename,'_AllCellsSpikesPerSec.mat'],'numspikes')