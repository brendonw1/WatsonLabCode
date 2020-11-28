function VectorToText(vect,filename)
%based on matlab help.  Writes each row of the character cell (charcell) to a line of
%text in the filename specified by "filename".  Char should be a cell array 
%with format of a 1 column with many rows, each row with a single string of
%text.


fid = fopen(filename, 'w');

for ix =1:length(vect)
    fprintf(fid, '%s \n', num2str(vect(ix)));
end

fclose(fid);