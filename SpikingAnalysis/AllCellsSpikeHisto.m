function [numspikes,bincenters] = AllCellsSpikeHisto(basename, binwidth,varargin)
% Assuming you are in directory with data from recording of interest, will
% import spike data, make a histogram of spikes from all the cells and
% will make a bar graph of the binned spike train... unless the plotting
% variable is off

if isempty(varargin);
    plotting = 1;
else
    plotting = varargin{1};
end


% basename = 'BWRat17_121912';
% binwidth = 100;%ms
% samplerate = 20000;
% durationinsec = 13758;

binspersec = 1000/binwidth;

try
    Par = LoadPar([basename,'.xml']);
catch
    error('is there an .xml in the folder?')
    return
end
samplerate = Par.SampleRate;%for spike timing (based on dat file);

d = dir([basename,'.lfp']);
if isempty(d)
    d = dir([basename,'.eeg']);
end
durationinsec = d.bytes*8/16/Par.nChannels/Par.lfpSampleRate;

[spiket, spikeind, numclus, iEleClu, spikeph] = ReadEl4CCG2(basename);%get the spikes
[numspikes,bincenters]=hist(spiket,durationinsec*binspersec);%bin the spikes
bincenters = bincenters/samplerate*binspersec;%correct so bin centers are in seconds not .dat samples

if plotting %if plotting bit is 1
    figure;
    plot(bincenters,numspikes);
    maxspikes = max(numspikes);

    try %will likely get rid of this, but plot freezing times for reference
        load ([basename,'-states.mat']);
        freezing=find(states==2);
        tempvar = diff(freezing);
        startinds = find(tempvar>1);
        freezingstarts = freezing(startinds+1);
        freezingstarts = cat(2,freezing(1),freezingstarts);

        hold on
        for a = 1:length(freezingstarts)
            plot([freezingstarts(a)*binspersec, freezingstarts(a)*binspersec],[0, maxspikes],'r:')
        end
    end
end
 
% ns = reshape(numspikes,[binspersec,durationinsec]);
% ns = sum(ns,1);
% save ([basename,'_SpikesPerSec.mat'],'ns')
