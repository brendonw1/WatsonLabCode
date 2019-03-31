function waveforms = LoadSpikeWaveforms_BW(filename,nChannels,nSamples,list)
% Totally stolen from FMA toolbox... I just added the proper LoadBinary
% func to the bottom of this - Brendon Watson 2014
%
%LoadSpikeWaveforms - Read spike waveforms from disk.
%
%  USAGE
%
%    waveforms = LoadSpikeWaveforms(filename,nChannels,nSamples,list)
%
%    filename            spike waveform file name
%    nChannels           number of channels in electrode group
%    nSamples            number of samples per waveform
%    list                optional list of spikes (from 1 to N) to load
%
%  OUTPUT
%
%    waveforms           3D array (spike #,channel,sample) of waveforms
%
%  SEE
%
%    See also GetSpikeWaveforms, PlotSpikeWaveforms.

% Copyright (C) 2004-2013 by Michaël Zugaro
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.

if nargin < 3,
  error('Incorrect number of parameters (type ''help <a href="matlab:help LoadSpikeWaveforms">LoadSpikeWaveforms</a>'' for details).');
end

[path,basename,extension] = fileparts(filename);
if isempty(path), path = '.'; end

electrodeGroupStr = extension(2:end);
electrodeGroup = str2num(electrodeGroupStr);
[~,basename] = fileparts(basename);

% Load .spk file
filename = [path '/' basename '.spk.' electrodeGroupStr];
if ~exist(filename),
	error(['File ''' filename ''' not found.']);
end
if nargin < 4,
	waveforms = LoadBinaryLocal(filename,'nChannels',nChannels);
else
	waveforms = LoadBinaryLocal(filename,'nChannels',nChannels,'nRecords',nSamples*ones(size(list)),'offset',nSamples*(list-1));	
end
waveforms = reshape(waveforms',nChannels,nSamples,[]);
waveforms = permute(waveforms,[3 1 2]); % rearrange: spike #, channel, sample
% 
% 
% function [data OrigIndex]= LoadBinaryLocal(FileName, Channels, varargin)
% %function [data OrigIndex]= LoadBinary_bw(FileName, Channels, nChannels, varargin)
% %   Channels - list of channels to load starting from 1
% %   nChannels - number of channels in a file, will be read from par/xml file
% % if present
% %   intype/outtype - data types in the file and in the matrix to load to
% % by default assume input file is eeg/dat = int16 type (short int), and
% % output is single (to save space) unless it is version 6.5 that cannot
% % handle single type
% %   method: (1,2,  3 or 4) differes by the way the loading is done - just for
% % efficiency purposes some are better then others, default =2;
% % method 2 works with buffers-works even for huge files. other methods
% % don't work so far ..
% % NB: method =3 allows to load data from within certain time epochs , give
% % in variable Periods : [beg1 end1; beg2 end2....] (in sampling rate of the
% % file you are loading, so if you are loading eeg - then Periods should be
% % in eeg samples
% % OrigIndex then returns the original samples index that samples in Data correspond
% % to , so that you can use it for future spikes and other point process
% % analysis
% % NB: for method 4 for efficiency and historical reasons output is nCh x nT 
% % complaints to : Anton
% if ~FileExists(FileName)
%     error('File %s does not exist or cannot be open\n',FileName);
% end
% 
% lastdot =strfind(FileName,'.');
% FileBase=FileName(1:lastdot(end)-1);
% if FileExists([FileBase '.xml']) || FileExists([FileBase '.par'])
%     Par = LoadPar([FileBase]);
%     nChannels = Par.nChannels;
% else
%     nChannels = 1;
% end
% 
% [nChannels, method, intype, outtype,Periods,Resample] = DefaultArgs(varargin,{nChannels,2,'int16','double',[],1});
% 
% if ~nChannels error('nChannels is not specified and par/xml file is not present'); end
% 
% ver = version; ver = str2num(ver(1));
% if ver<7 outtype ='double';end
% 
% PrecString =[intype '=>' outtype];
% fileinfo = dir(FileName);
% % get file size, and calculate the number of samples per channel
% nSamples = ceil(fileinfo(1).bytes /datatypesize(intype) / nChannels);
% 
% if method<2 & ~isempty(Periods)
%     error('this method does not perform (yet) selective loading with Periods, use method 3 or 4. Bug me to implement it ! :)');
% end
% if method==3 & isempty(Periods)
%     method=2;
%     fprintf('method 3 is replaced by method 2 which uses buffering');
% end
% 
% %have not fixed the case of method 1 for periods extraction
% if method<5
% 
%     filept = fopen(FileName,'r');
% 
%     if ~isempty(Periods)
%         %        method=3;
%         if Resample>1
%             data = feval( outtype, zeros( length(Channels), sum( ceil((diff(Periods,1,2)+1)/nChannels/Resample) ) ) );
%         else
%             data = feval( outtype, zeros( length(Channels), sum(diff(Periods,1,2)+1) ) );
%         end
%     else
%         Periods = [1 nSamples];
%         if Resample>1
%             data = feval(outtype,zeros(length(Channels), ceil(nSamples/Resample)));
%         else
%             data = feval(outtype,zeros(length(Channels), nSamples));
%         end
%     end
% end
% 
% switch method
%     case 1
% 
%         %compute continuous patches in chselect
%         %lazy to do circular continuity search - maybe have patch [nch 1 2 3]
%         %sort in case somebody didn't
%         [Channels ChanOrd]= sort(Channels(:)');
%         dch = diff([Channels(1) Channels]);
%         PatchInd = cumsum(dch>1)+1;
%         PatchLen = hist(PatchInd,unique(PatchInd));
%         PatchSkip = (nChannels - PatchLen)*datatypesize(intype);
%         nPatch = length(unique(PatchInd));
% 
%         for ii=1:nPatch
%             patchch = find(PatchInd==ii);
%             patchbeg = Channels(patchch(1));6
%             PatchPrecString = [num2str(PatchLen(ii)) '*' PrecString];
%             fseek(filept,(patchbeg-1)*datatypesize(intype),'bof');
%             data(patchch,:) = fread(filept,[PatchLen(ii) nSamples],PatchPrecString,PatchSkip(ii));
% 
%         end
%         % put them back in the order they were in Channels argument
%         data = data(ChanOrd,:);
% 
%         
%     case 2 %old way - buffered, now deals with periods as well
%         OrigIndex = [];
%         nPeriods = size(Periods,1);
%         buffersize = 400000;
%         if Resample>1 buffersize = round(buffersize/Resample)*Resample; end
%         totel=0;
%         for ii=1:nPeriods
%             numel=0;
%             numelm=0;
%             Position = (Periods(ii,1)-1)*nChannels*datatypesize(intype);
%             ReadSamples = diff(Periods(ii,:))+1;
%             fseek(filept, Position, 'bof');
%             while numel<ReadSamples 
%                 if numel==ReadSamples break; end
%                 [tmp,count] = fread(filept,[nChannels,min(buffersize,ReadSamples-numel)],PrecString);
%                 data(:,totel+1:totel+ceil(count/nChannels/Resample)) = tmp(Channels,1:Resample:end);
%                 clear tmp
%                
%                 numel = numel+count/nChannels;
%                 totel = totel+ceil(count/nChannels/Resample);
%             end
%             
%             OrigIndex = [OrigIndex; Periods(ii,1)+[0:Resample:ReadSamples-1]'];
%         end
% 
%     case 3 % for full periods extraction, not buffered, use method 2 if periods are large.
%         % OBSOLETE!!!
%         nPeriods = size(Periods,1);
%         numel=0;
%         OrigIndex = [];
%         for ii=1:nPeriods
%             Position = (Periods(ii,1)-1)*nChannels*datatypesize(intype);
%             ReadSamples = diff(Periods(ii,:))+1;
%             fseek(filept, Position, 'bof');
%             
%             [tmp count]= fread(filept, [nChannels, ReadSamples], PrecString);
%             if count/nChannels ~= ReadSamples
%                 error('something went wrong!');
%             end
%             if Resample>1
%                 numelm = ceil(count/nChannels/Resample);
%             else
%                 numelm = count/nChannels;
%             end
%             data(:,numel+1:numel+numelm) = tmp(Channels,1:Resample:end);
%             numel = numel+count/nChannels;
%             OrigIndex = [OrigIndex; Periods(ii,1)+[0:Resample:ReadSamples-1]'];
%         end
%         
%     case 4 %new way - with memmapfile
% 
%         if isempty(Periods)
%             mmap = memmapfile(FileName, 'format',{intype [nChannels nSamples] 'x'},'offset',0,'repeat',1);
%             data = mmap.Data.x(Channels,1:Resample:end);
%         else
%             %data = feval(outtype,zeros(length(Channels), sum(diff(Periods,1,2)))+size(Periods,1));
%             nPeriods = size(Periods,1);
%             data = [];
%             OrigIndex = [];
%             for ii=1:nPeriods
%                 Position = (Periods(ii,1)-1)*nChannels*datatypesize(intype);
%                 ReadSamples = diff(Periods(ii,:))+1;
%                 mmap = memmapfile(FileName, 'format',{intype [nChannels ReadSamples] 'x'},'offset',Position,'repeat',1);
% %                data = [data mmap.Data.x(Channels,Periods(ii,1):Periods(ii,2))];
%                 data = [data mmap.Data.x(Channels,1:Resample:end)];
%                 OrigIndex = [OrigIndex; Periods(ii,1)+[0:Resample:ReadSamples-1]'];
%             end
%         end
%         data = cast(data,outtype);
% end
% if method<4
%     fclose(filept);
% end
% 
% 



function data = LoadBinaryLocal(filename,varargin)

%LoadBinary - Load data from a multiplexed binary file.
%
%  Reading a subset of the data can be done in two different manners: either
%  by specifying start time and duration (more intuitive), or by indicating
%  the position and size of the subset in terms of number of records (more
%  accurate) - a 'record' is a chunk of data containing one sample for each
%  channel.
%
%  LoadBinary can also deal with lists of start times and durations (or
%  offsets and number of records).
%
%  USAGE
%
%    data = LoadBinary(filename,<options>)
%
%    filename       file to read
%    <options>      optional list of property-value pairs (see table below)
%
%    =========================================================================
%     Properties    Values
%    -------------------------------------------------------------------------
%     'frequency'   sampling rate (in Hz, default = 20kHz)
%     'start'       position to start reading (in s, default = 0)
%     'duration'    duration to read (in s, default = Inf)
%     'offset'      position to start reading (in records, default = 0)
%     'nRecords'    number of records to read (default = Inf)
%     'samples'     same as above (for backward compatibility reasons)
%     'nChannels'   number of data channels in the file (default = 1)
%     'channels'    channels to read (default = all)
%     'precision'   sample precision (default = 'int16')
%     'skip'        number of records to skip after each record is read
%                   (default = 0)
%    =========================================================================

% Copyright (C) 2004-2013 by Michaël Zugaro
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.

% Default values
nChannels = 1;
precision = 'int16';
skip = 0;
frequency = 20000;
channels = [];
start = 0;
duration = Inf;
offset = 0;
nRecords = Inf;
time = false;
records = false;

if nargin < 1 | mod(length(varargin),2) ~= 0,
  error('Incorrect number of parameters (type ''help <a href="matlab:help LoadBinary">LoadBinary</a>'' for details).');
end

% Parse options
for i = 1:2:length(varargin),
	if ~ischar(varargin{i}),
		error(['Parameter ' num2str(i+3) ' is not a property (type ''help <a href="matlab:help LoadBinary">LoadBinary</a>'' for details).']);
	end
	switch(lower(varargin{i})),
		case 'frequency',
			frequency = varargin{i+1};
			if ~isdscalar(frequency,'>0'),
				error('Incorrect value for property ''frequency'' (type ''help <a href="matlab:help LoadBinary">LoadBinary</a>'' for details).');
			end
		case 'start',
			start = varargin{i+1};
			if ~isdvector(start),
				error('Incorrect value for property ''start'' (type ''help <a href="matlab:help LoadBinary">LoadBinary</a>'' for details).');
			end
			if start < 0, start = 0; end
			time = true;
		case 'duration',
			duration = varargin{i+1};
			if ~isdvector(duration,'>=0'),
				error('Incorrect value for property ''duration'' (type ''help <a href="matlab:help LoadBinary">LoadBinary</a>'' for details).');
			end
			time = true;
		case 'offset',
			offset = varargin{i+1};
			if ~isivector(offset),
				error('Incorrect value for property ''offset'' (type ''help <a href="matlab:help LoadBinary">LoadBinary</a>'' for details).');
			end
			if offset < 0, offset = 0; end
			records = true;
		case {'nrecords','samples'},
			nRecords = varargin{i+1};
			if ~isivector(nRecords,'>0'),
				error('Incorrect value for property ''nRecords'' (type ''help <a href="matlab:help LoadBinary">LoadBinary</a>'' for details).');
			end
			if length(nRecords) > 1 && any(isinf(nRecords(1:end-1))),
				error('Incorrect value for property ''nRecords'' (type ''help <a href="matlab:help LoadBinary">LoadBinary</a>'' for details).');
			end
			records = true;
		case 'nchannels',
			nChannels = varargin{i+1};
			if ~isiscalar(nChannels,'>0'),
				error('Incorrect value for property ''nChannels'' (type ''help <a href="matlab:help LoadBinary">LoadBinary</a>'' for details).');
			end
		case 'channels',
			channels = varargin{i+1};
			if ~isivector(channels,'>0'),
				error('Incorrect value for property ''channels'' (type ''help <a href="matlab:help LoadBinary">LoadBinary</a>'' for details).');
			end
		case 'precision',
			precision = varargin{i+1};
			if ~isstring(precision),
				error('Incorrect value for property ''precision'' (type ''help <a href="matlab:help LoadBinary">LoadBinary</a>'' for details).');
			end
		case 'skip',
			skip = varargin{i+1};
			if ~isiscalar(skip,'>0'),
				error('Incorrect value for property ''skip'' (type ''help <a href="matlab:help LoadBinary">LoadBinary</a>'' for details).');
			end
		otherwise,
			error(['Unknown property ''' num2str(varargin{i}) ''' (type ''help <a href="matlab:help LoadBinary">LoadBinary</a>'' for details).']);
	end
end

% Either start+duration, or offset+size
if time && records,
	error(['Data subset can be specified either in time or in records, but not both (type ''help <a href="matlab:help LoadBinary">LoadBinary</a>'' for details).']);
end

% By default, load all channels
if isempty(channels),
	channels = 1:nChannels;
end

% Check consistency between channel IDs and number of channels
if any(channels>nChannels),
	error('Cannot load specified channels (listed channel IDs inconsistent with total number of channels).');
end

% Open file
if ~exist(filename),
	error(['File ''' filename ''' not found.']);
end
f = fopen(filename,'r');
if f == -1,
	error(['Cannot read ' filename ' (insufficient access rights?).']);
end

% Size of one data point (in bytes)
sampleSize = 0;
switch precision,
	case {'uchar','unsigned char','schar','signed char','int8','integer*1','uint8','integer*1'},
		sampleSize = 1;
	case {'int16','integer*2','uint16','integer*2'},
		sampleSize = 2;
	case {'int32','integer*4','uint32','integer*4','single','real*4','float32','real*4'},
		sampleSize = 4;
	case {'int64','integer*8','uint64','integer*8','double','real*8','float64','real*8'},
		sampleSize = 8;
end

% Position and number of records of the data subset
if time,
	if length(duration) == 1,
		duration = repmat(duration,size(start,1),1);
	elseif length(duration) ~= length(start),
		error('Start and duration lists have different lengths (type ''help <a href="matlab:help LoadBinary">LoadBinary</a>'' for details).');
	end
	dataOffset = floor(start*frequency)*nChannels*sampleSize;
	nRecords = floor(duration*frequency);
else
	if length(nRecords) == 1,
		nRecords = repmat(nRecords,size(offset,1),1);
	elseif length(nRecords) ~= length(offset),
		error('Offset and number of records lists have different lengths (type ''help <a href="matlab:help LoadBinary">LoadBinary</a>'' for details).');
	end
	dataOffset = offset*nChannels*sampleSize;
end

% Determine total number of records in file
fileStart = ftell(f);
status = fseek(f,0,'eof');
if status ~= 0,
	fclose(f);
	error('Error reading the data file (possible reasons include trying to read past the end of the file).');
end
fileStop = ftell(f);

% Last number of records may be infinite, compute explicit value
if isinf(nRecords(end)),
	status = fseek(f,dataOffset(end),'bof');
	if status ~= 0,
		fclose(f);
		error('Error reading the data file (possible reasons include trying to read past the end of the file).');
	end
	lastOffset = ftell(f);
	lastNRecords = floor((fileStop-lastOffset)/nChannels/sampleSize);
	nRecords(end) = lastNRecords;
end

% Preallocate memory
data = zeros(sum(nRecords)/(skip+1),length(channels));

% Loop through list of start+duration or offset+nRecords
i = 1;
for k = 1:length(dataOffset),

	% Position file index for reading
	status = fseek(f,dataOffset(k),'bof');
	fileOffset = ftell(f);
	if status ~= 0,
		fclose(f);
		error('Could not start reading (possible reasons include trying to read past the end of the file).');
	end

	% (floor in case all channels do not have the same number of samples)
	maxNRecords = floor((fileStop-fileOffset)/nChannels/sampleSize);
	if nRecords(k) > maxNRecords, nRecords(k) = maxNRecords; end

	% For large amounts of data, read chunk by chunk
	maxSamplesPerChunk = 10000;
	nSamples = nRecords(k)*nChannels;
	if nSamples <= maxSamplesPerChunk,
		d = LoadChunk(f,nChannels,channels,nRecords(k),precision,skip*sampleSize);
		[m,n] = size(d);
		if m == 0, break; end
		data(i:i+m-1,:) = d;
		i = i+m;
	else
		% Determine chunk duration and number of chunks
		nSamplesPerChunk = floor(maxSamplesPerChunk/nChannels)*nChannels;
		nChunks = floor(nSamples/nSamplesPerChunk)/(skip+1);
		% Read all chunks
		for j = 1:nChunks,
			d = LoadChunk(f,nChannels,channels,nSamplesPerChunk/nChannels,precision,skip*sampleSize);
			[m,n] = size(d);
			if m == 0, break; end
			data(i:i+m-1,:) = d;
			i = i+m;
		end
		% If the data size is not a multiple of the chunk size, read the remainder
		remainder = nSamples - nChunks*nSamplesPerChunk;
		if remainder ~= 0,
			d = LoadChunk(f,nChannels,channels,remainder/nChannels,precision,skip*sampleSize);
			[m,n] = size(d);
			if m == 0, break; end
			data(i:i+m-1,:) = d;
			i = i+m;
		end
	end
end

fclose(f);

% ---------------------------------------------------------------------------------------------------------

function data = LoadChunk(fid,nChannels,channels,nSamples,precision,skip)

if skip ~= 0,
	data = fread(fid,[nChannels nSamples],[int2str(nChannels) '*' precision],skip*nChannels);
else
	data = fread(fid,[nChannels nSamples],precision);
end
data = data';

if isempty(data),
	warning('No data read (trying to read past file end?)');
elseif ~isempty(channels),
	data = data(:,channels);
end
