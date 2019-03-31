function out = ReadMetaAspects(fname,desired)

if ~strcmp(fname(end-4:end),'.meta')
    fname = [fname, '.meta'];
end

switch lower(desired)
    case 'endms'
        searchstring = 'TimeStamp of the end';
        startextractchar = 59;
    case 'startms'
        searchstring = 'TimeStamp of the start';
        startextractchar = 61;
    case 'numchans'
        searchstring = 'Number of';
        startextractchar = 31;
    case 'filebytes'
        searchstring = 'File size';
        startextractchar = 21;
    case 'starttime'
        searchstring = 'Recording start time';
        startextractchar = 24;
    case 'startdate'
        searchstring = 'Recording start date';
        startextractchar = 28;
end

endsearchchar = length(searchstring);  
        
fid = fopen(fname);
tline = fgetl(fid);
while ischar(tline)
%     disp(tline);
    try
        if strcmp(tline(1:endsearchchar),searchstring)
            out = tline(startextractchar:end);
            break
        end
    end
    tline= fgetl(fid);
end
fclose(fid);
