function ReferenceEEGFile(basepath,basename)

if ~exist('basepath','var')
    basepath = cd;
    [~,basename] = fileparts(cd);
end

par = LoadXml(fullfile(basepath,[basename '.xml']));
eegchannelnums = 2:23;

load(fullfile(basepath,[basename '_EDFHeader']))

data = LoadBinary_FMA(fullfile(basepath,[basename '.lfp']),'nchannels',par.nChannels);

% simple mean of mastoids version
a1channum = strmatch('A1',header.label);
a2channum = strmatch('A2',header.label);
ref = mean(data(:,[a1channum a2channum]),2);
data(:,eegchannelnums) = data(:,eegchannelnums) - repmat(ref,1,length(eegchannelnums));

movefile(fullfile(basepath,[basename '.lfp']),fullfile(basepath,[basename '_FpzRefd.lfp']))
data = data';
data = data(:);

oid = fopen(fullfile(basepath,[basename '.lfp']),'w');
fwrite(oid,data,'int16');
fclose(oid);

