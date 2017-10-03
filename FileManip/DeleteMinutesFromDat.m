filename = 'amplifier.dat';
outfile = 'amplifier_cut.dat';
mins = 11.2; %keep first (this many) minutes of file
numchans = 64; 

samprate = 20000;
filebitsperbyte = 16;

bytes = mins*numchans*60*samprate*filebitsperbyte/8;

%use linux "head" command, it will be faster
eval(['!head -c ' num2str(bytes) ' ' filename ' > ' outfile])