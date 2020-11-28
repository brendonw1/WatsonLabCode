function [] = UPSpindleNearestTimings(basepath,basename)

if ~exist('basepath','var')
    [basepath,basename,~] = fileparts(cd);
    basepath = fullfile(basepath,basename);
end

try
    bmd = load([basename '_BasicMetaData.mat']);
catch
    error('must be in a session basefolder')
end
numchans = bmd.Par.nChannels;

%% Load Spindles and UPs
load(fullfile(basepath,'Spindles','SpindleData.mat'),'SpindleData')
normspindles = SpindleData.normspindles;

t = load([basename, '_UPDOWNIntervals']);
UPInts = t.UPInts;

%%
spindleups=[];
nonspindleups=[];
intermedspindleups=[];

%% Assess whether each UP state is sufficiently overlapped by a spindle

ustarts = Start(UPInts);
ustop = End(UPInts);
sstarts = normspindles(:,1);
sstops = normspindles(:,3);

sstartsgrid = repmat(sstarts,1,size(ustarts,1));
sstopsgrid = repmat(sstarts,1,size(ustarts,1));
ustartsgrid = repmat(ustarts,size(sstarts,1),1);
ustopsgrid = repmat(ustops,size(sstarts,1),1);


% For non-overlapping
% find nearest up to each spindle
% find nearest spindle to each up
% ... subtract repmats, then do min(abs(columns))

UStartgridA = repmat(UStartWindows(:,1),1,size(sstarts,1))';
UStartgridB = repmat(UStartWindows(:,2),1,size(sstarts,1))';




startsaboveboolA = (sstartsgrid-UStartgridA)>0;
startsaboveboolB = (sstartsgrid-UStartgridB)<0;

startbool = startsaboveboolA.*startsaboveboolB;
goodstartspindles = find(sum(startbool,2));%this should never be greater than 1, and I haven't seen that it has been 
EarlyStartUps = find(sum(startbool,1));%this should never be greater than 1, and I haven't seen that it has been 


%% Find overlap for each up
maxend = max([normspindles(end,3) End(subset(UPInts,length(length(UPInts))))/10000]);
SpindleMilliseconds = zeros(1,round(maxend*1000));%1ms resolution of whether spindle in each ms
for a=1:size(normspindles,1)% set 1s where spindle ms's are found
   SpindleMilliseconds(round(normspindles(a,1)*1000):round(normspindles(a,3)*1000)) = 1; 
end

UpPercents = zeros(1,length(length(UPInts)));
for a = 1:length(length(UPInts))
    % for a = 1:length(goodstartups)
%     tuidx = goodstartups(a);
    tu = subset(UPInts,a);
    %find the matching spindle(s)
    %look for at least 50% coverage
    thisspanstart = round(Start(tu)/10000*1000);
    thisspanend = round(End(tu)/10000*1000);
    thisspan = SpindleMilliseconds(thisspanstart:thisspanend);

    UpSpindleMsCounts(a) = sum(thisspan);
    UpPercents(a) = mean(thisspan);
%     if uppercents(a)>=percentoverlap
%         spindleups(end+1) = a;
%     elseif uppercents(a)>0
%         intermedspindleups(end+1) = a;
%     else)
%         nonspindleups(end+1) = a;
%     end
end

SpindleUps = intersect(EarlyStartUps,find(UpPercents>=percentoverlap));%good start and >percentoverlap
NoSpindleUps = find(UpPercents==0);
PartialSpindleUps = intersect(1:length(length(UPInts)),find(UpPercents>partialUpPercentOverlap));
PartialSpindleUps = setdiff(PartialSpindleUps,SpindleUps);
LateStartUps = setdiff(find(UpPercents>0),EarlyStartUps);

%Expo


% if at least 50% of up
% 
% starts of spindle no more than 150ms of up
% and no more than 200ms after