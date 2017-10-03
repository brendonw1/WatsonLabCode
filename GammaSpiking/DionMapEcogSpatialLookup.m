function DionMapEcogSpatialLookup(basepath,basename)

xspacing = 200;%um
yspacing = 200;%um

if ~exist('basepath','var')
    [~,basename] = fileparts(cd);
    basepath = cd;
end
if exist(fullfile(basepath,'EEGChannelsToUse.txt'))%would be made by DionDataEcogChannelsToUse.m
    chanlist = TextReadToVector(fullfile(basepath,'EEGChannelsToUse.txt'));
else
    disp('Must first run "DionDataEcogChannelsToUse.m" on this recording')
    return
end

par = LoadPar(fullfile(basepath,[basename '.xml']));

% for each channel, get group, look up that group in lookup table
% save that... use that to plot various things in other functions
% ... like coherence to a particular other channel

% go thru spkgroups, count number of channels
channumvect = length(par.SpkGrps);
for a = 1:length(par.SpkGrps);
    channumvect(a) = length(par.SpkGrps(a).Channels);
end

% find start of groups of 4, 30 in a row to match Dion's Ecog
[startend] = continuousabove2_v2(channumvect==4,1,30);

% for each group, make a location lookup: group, location in x, y
goodgrpsvect = startend(1):startend(2);
goodgrpsidxs = goodgrpsvect-startend(1);
% 1 is upperleft
% 2 is right one slot... through 6
% 7 is down one slot
x = rem(goodgrpsidxs,6)* xspacing;
y = floor(goodgrpsidxs/6) * -yspacing;
EcogSpatialLookupBySpkGrp = [goodgrpsvect' x' y'];

% Make Lookup by channel
x = repmat(x,4,1);
x = x(:);
y = repmat(y,4,1);
y = y(:);
goodchansvect = [];
for a = goodgrpsvect;
   goodchansvect = cat(2,goodchansvect,par.SpkGrps(a).Channels);
end
EcogSpatialLookupByChannel = [goodchansvect' x y];

% adjust by 20um spacing
xadj = [-10;10;-10;10];
xadj = repmat(xadj,30,1);
yadj = [-10;-10;10;10];
yadj = repmat(yadj,30,1);
x = x+xadj;
y = y+yadj;
EcogSpatialLookupByChannel_Precise = [goodchansvect' x y];

save(fullfile(basepath,[basename '_EcogSpatialLookup.mat']),'EcogSpatialLookupBySpkGrp','EcogSpatialLookupByChannel','EcogSpatialLookupByChannel_Precise')
1;
