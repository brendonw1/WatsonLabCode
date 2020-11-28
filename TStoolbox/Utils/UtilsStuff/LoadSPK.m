%LoadSpikeWaveforms - Read spike waveforms from file.
%
%  USAGE
%
%    waveforms = LoadSpikeWaveforms(filename,nChannels,nSamples)
%
%    filename            spike waveform file name
%    nChannels           number of channels in electrode group
%    nSamples            number of samples per waveform

% Copyright (C) 2004-2006 by Michaël Zugaro
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.

function waveforms = LoadSpikeWaveforms(filename,nChannels,nSamples)

if nargin < 3,
  error('Incorrect number of parameters (type ''help LoadSpikeWaveforms'' for details).');
end

% Default values
start = 0;
precision = 'int16';
skip = 0;
duration = Inf;
frequency = 20000;
channels = 1;

f = fopen(filename,'r');

% Position file index for reading
start = floor(start*frequency)*nChannels*sizeInBytes;
status = fseek(f,start,'bof');
if status ~= 0,
	fclose(f);
	error('Could not start reading (possible reasons include trying to read past the end of the file).');
end

% Determine number of samples when duration is 'inf'
if isinf(duration),
	fileStart = ftell(f);
	status = fseek(f,0,'eof');
	if status ~= 0,
		fclose(f);
		error('Error reading the data file (possible reasons include trying to read past the end of the file).');
	end
	fileStop = ftell(f);
	nSamplesPerChannel = (fileStop-fileStart)/nChannels/sizeInBytes;
	duration = nSamplesPerChannel/frequency;
	frewind(f);
	status = fseek(f,start,'bof');
	if status ~= 0,
		fclose(f);
		error('Could not start reading (possible reasons include trying to read past the end of the file).');
	end
else
	nSamplesPerChannel = floor(frequency*duration);
	if nSamplesPerChannel ~= frequency*duration,
		disp(['Warning: rounding duration (' num2str(duration) ' -> ' num2str(nSamplesPerChannel/frequency) ')']);
		duration = nSamplesPerChannel/frequency;
	end
end


maxSamplesPerChunk = 100000;
nSamples = nChannels*nSamplesPerChannel;
if nSamples > maxSamplesPerChunk,
	% Determine chunk duration and number of chunks
	nSamplesPerChunk = floor(maxSamplesPerChunk/nChannels)*nChannels;
	durationPerChunk = nSamplesPerChunk/frequency/nChannels;
	nChunks = floor(duration/durationPerChunk);
	% Preallocate memory
	data = zeros(nSamplesPerChannel,length(channels));
	% Read all chunks
	i = 1;
	for j = 1:nChunks,
		d = LoadBinaryChunk(f,'frequency',frequency,'nChannels',nChannels,'channels',channels,'duration',durationPerChunk,'skip',skip);
		[m,n] = size(d);
		if m == 0, break; end

		d = reshape(d,nChannels,nSamples,[]);
		d(:,:,find(clu<2))=[];
		data(i:i+m-1,:) = d;
		i = i+m;
		


%  		h=waitbar(j/nChunks);
	end
%  	close(h)
	% If the data size is not a multiple of the chunk size, read the remainder
	remainder = duration - nChunks*durationPerChunk;
	if remainder ~= 0,
		d = LoadBinaryChunk(f,'frequency',frequency,'nChannels',nChannels,'channels',channels,'duration',remainder,'skip',skip);
		[m,n] = size(d);
		if m ~= 0,
			data(i:i+m-1,:) = d;
		end
	end
else
	if skip ~= 0,
		data = fread(f,[nChannels frequency*duration],precision,skip);
	else
		data = fread(f,[nChannels frequency*duration],precision);
	end
	data=data';
	
	if ~isempty(channels),
		data = data(:,channels);
	end
end
fclose(f);



waveforms = reshape(waveforms,nChannels,nSamples,[]);