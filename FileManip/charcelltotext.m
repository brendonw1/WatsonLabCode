function charcelltotext(charcell,filename)
%based on matlab help.  Writes each row of the character cell (charcell) to a line of
%text in the filename specified by "filename".  Char should be a cell array 
%with format of a 1 column with many rows, each row with a single string of
%text.

[nrows,ncols]= size(charcell);

fid = fopen(filename, 'w');

for row=1:nrows
    fprintf(fid, '%s \n', charcell{row,:});
end

fclose(fid);