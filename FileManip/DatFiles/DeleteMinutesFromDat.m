filename = 'LB_04_181206.dat';
outfile = 'LB_04_181206_cut.dat';
mins = 60; %keep first (this many) minutes of file
numchans = 73; 

samprate = 20000;
filebitsperbyte = 16;

bytes = mins*numchans*60*samprate*filebitsperbyte/8;

%use linux "head" command, it will be faster
eval(['!head -c ' num2str(bytes) ' ' filename ' > ' outfile])