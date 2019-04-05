function out = textreadsimple(textfilename);

fid = fopen(textfilename);
out = fscanf(fid,'%s');
fclose(fid);