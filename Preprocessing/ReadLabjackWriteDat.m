function ReadLabjackWriteDat(filename,nchannels)
% read a csv file written to disk after a labjack .dat file is read in
% excel and savedas .csv.  Labjack files can be simply renamed to .xls and
% read by excel/similar.  Can likely make this read the original .dat or
% .xls.
% Can likely also read date, and figure nchannels from the file just
% fine... didn't bother yet
% Wrote as .lfp to not overwrite original labjack.dat


if ~exist('filename','var')
    filename = 'LabJackEEG_0';
end
if ~exist('nchannels','var')
    nchannels = 4;
end


d = read_mixed_csv([filename '.csv']);

d = d(7:end,:);%get rid of headers and titles
nsamples = size(d,1);

time = zeros(nsamples,1);
channels = zeros(nsamples,nchannels);

for ix = 1:nsamples
    time(ix) = str2num(d{ix,1});
    for nc = 1:nchannels
        channels(ix,nc) = str2num(d{ix,1+nc});
    end
end

%
sampfreq = 1/(time(11)/10);%first value is zero

%shitty filtering
filtersecs = 2;
filterlength = filtersecs*sampfreq;

for nc = 1:nchannels
    filt_channels(:,nc) = channels(:,nc)-smooth(channels(:,nc),filterlength);
end

%% Write to .lfp
ch = int16(filt_channels*1000000);
ch = ch';
ch = ch(:);
fid = fopen([filename '.lfp'],'w');
fwrite(fid,ch,'int16');
fclose(fid);
