function CellStringToTextFile(c,name)
% takes in a 1xN cell array of strings and outputs each element to an ascii
% file called name

fid = fopen(name,'w');

for a = 1:length(c)
    fprintf(fid,[c{a},'\n']);
end

fclose(fid);