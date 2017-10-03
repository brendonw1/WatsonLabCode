function header = EDFtoLFP(filename)

if ~exist('filename','var')
    d = dir('*.edf');
    filename = d(1).name;
end

if strcmp(filename(end-3:end),'.edf')
    filename = filename(1:end-4);
end

inname = [filename '.edf'];
outname = [filename '.lfp'];

[header,recording] = edfread16(inname);

recording = recording(:);

oid = fopen(outname,'w');
fwrite(oid,recording,'int16');
fclose(oid);

save([filename '_EDFHeader'],'header')