function badout = ReadBadChannels(basepath)
% Reads bad_channels.txt files in basepaths.  Format must be a vertical set
% of text lines, all numbers after the last blank line will be assumed to
% be bad channels.  Output is a vector of numbers of bad channels.
%
% Brendon Watson 2016

if ~exist('badbath','var')
    basepath = cd;
end
if ~exist(fullfile(basepath,'bad_channels.txt'),'file')
    disp('No "bad_channels.txt" found in this folder')
    badout = [];
    return
end
%% Read in and note places of empty lines
empties = [];
fid = fopen(fullfile(basepath,'bad_channels.txt'));
tline = fgetl(fid);
if isempty(tline)
    empties = 1;
end
t = {tline};
counter = 2;
while ischar(tline)
%     disp(tline)
    tline = fgetl(fid);
    if isempty(tline)
        empties = counter;
    end
    t{end+1} = tline;
    counter = counter+1;
end
fclose(fid);
t(end) = [];

%% Read any numbers after last empty spot
if ~isempty(empties)% in case a carrage return at the end
    if empties(end) == length(t)
        empties(end) = [];
    end
end

if ~isempty(empties)
    start = empties(end)+1;
else
    start = 1;
end

counter = 1;
for a = start:length(t)
    if ~isempty(str2num(t{a}))
       badout(counter) = str2num(t{a});
       counter = counter+1;
    end
end
