function nummovementshapes = ReadVLCMotionTextLog(logname)

fid = fopen(logname);
literal = 'motiondetect debug: Counted ';
nummovementshapes = [];

y = 0;
counter = 0;
tline = fgetl(fid);
while ischar(tline)
   counter = counter+1;
   matches = strfind(tline, literal);
   num = length(matches);
   if num > 0
       nummovementshapes(end+1) = str2num(tline(28:end-14));
   end
   tline = fgetl(fid);
end

fclose(fid);