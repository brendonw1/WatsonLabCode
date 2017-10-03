function out = TextReadToVector(textfilename);

out = [];

fid = fopen(textfilename);
tline = fgetl(fid);
while ischar(tline)
    out(end+1) = str2num(tline);
    tline = fgetl(fid);
end

fclose(fid);


