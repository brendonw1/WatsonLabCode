function [numspikes,bincenters] = EachCellSpikeHisto(basename, binwidth ,varargin)
% Assuming you are in directory with data from recording of interest, will
% import spike data, make a histogram of spikes from all the cells and
% will make a bar graph of the binned spike train... unless the plotting
% variable is off

if isempty(varargin);
    plotting = 1;
else
    plotting = varargin{1};
end

% try
    Par = LoadPar([basename,'.xml']);
% catch
%     error('is there an .xml in the folder?')
%     return
% end
samplerate = Par.SampleRate;%for spike timing (based on dat file);

d = dir([basename,'.lfp']);
if isempty(d)
    d = dir([basename,'.eeg']);
end

durationinsec = d.bytes*8/16/Par.nChannels/Par.lfpSampleRate;
binspersec = 1000/binwidth;

[spiket, spikeind, numclus, iEleClu, spikeph] = ReadEl4CCG2(basename);

try
    load ([basename,'-states.mat']);
    freezing=find(states==2);
    tempvar = diff(freezing);
    stopinds = find(tempvar>1);
    startinds = stopinds+1;
    freezingstarts = freezing(startinds);
    freezingstarts = cat(2,freezing(1),freezingstarts);

    freezingstops = freezing(stopinds);
    freezingstops = cat(2,freezingstops,freezing(end));
catch
end

for a=1:numclus
    cellspikes{a} = spiket(spikeind==a);
    [numspikes,bincenters]=hist(cellspikes{a},durationinsec*binspersec);
    bincenters = bincenters/samplerate*binspersec;
    figure;
    bar(bincenters,numspikes);
    titletext = ([basename,' cell ',num2str(a)]);
    try
       hold on
       maxspikes = max(numspikes);
       for b = 1:length(freezingstarts)
          plot([freezingstarts(b)*binspersec, freezingstarts(b)*binspersec],[0, maxspikes],'--g')
          plot([freezingstops(b)*binspersec, freezingstops(b)*binspersec],[0, maxspikes],'--r') 
       end 
       titletext = [titletext, ' vs Freezing starts'];
    end
    title(titletext)
end

