function tspdata = ReadTspByfgetl(tspfilename)
% function tspdata = ReadTspByfgetl(tspfilename)
% gets the timestamps (first datapoint per line) from tsp files.  Outputs an
% n x 1 matrix of timestamps.
%
% Brendon Watson October 2014

tspdata = [];
fid = fopen(tspfilename);

tline = fgetl(fid);
while ischar(tline)
    sp = strfind(tline,' ');
    if ~isempty(sp)
        tspdata(end+1) = str2num(tline(1:sp(1)-1));
    else
        tspdata(end+1) = str2num(tline);
    end
    
    tline = fgetl(fid);
end

tspdata = tspdata';
