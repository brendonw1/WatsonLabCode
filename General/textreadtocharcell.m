function out = textreadtocharcell(textfilename)

out = {};

fid = fopen(textfilename);
t = fgetl(fid);
while ischar(t)
    out{end+1} = t;
    t = fgetl(fid);
end
fclose(fid);