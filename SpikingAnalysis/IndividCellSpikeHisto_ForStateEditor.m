function IndividCellSpikeHisto_ForStateEditor(basename, cellnum)
% Will import spike data, make a 1 second-per-bin histogram of spikes from 
% chosen cells and will save in a .mat which is ready to be read by
% StateEditor as an overlay display.  StateEditor can handle (at the
% moment) up to 3 cells (streams of data).

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

for a = 1:length(cellnum)
    cellspikes{cellnum(a)} = spiket(spikeind==cellnum(a));
    [numspikes,bincenters]=hist(cellspikes{cellnum(a)},durationinsec*binspersec);
    bincenters = bincenters/samplerate*binspersec;
    exportbins(a,:) = numspikes;
end

save ([basename,'_Cell',num2str(cellnum),'_SpikesPerSec.mat'],'exportbins')