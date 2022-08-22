function data = ReadDigitalIn(varargin)

%% parses based on name-value pair -based inputs
p = inputParser;
addParameter(p,'FileName','digitalin.dat',@isstring)
addParameter(p,'SampFreq',20000,@isnumeric)
addParameter(p,'NumChannels',1,@isnumeric)

parse(p, varargin{:});

FileName = p.Results.FileName;
SampFreq = p.Results.SampFreq;
NumChannels = p.Results.NumChannels;

% nchannels = 16;
% filename = 'digitalin.dat';

%%
fid = fopen(FileName);
bits = fread(fid, '*ubit1', 'ieee-le');
bitsArray = reshape(bits,[NumChannels,length(bits)/NumChannels]);
bitsArray = logical(bitsArray);

%% readying for output
data = v2struct(bitsArray,SampFreq,NumChannels);

%%
% bitsArray = double(bitsArray);
