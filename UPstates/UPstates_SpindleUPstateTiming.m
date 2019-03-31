function UPstates_SpindleUPstateTiming(basename,basepath)

if ~exist('basename','var') || ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

%% Load ups, get starts, stops
t = load([basename, '_UPDOWNIntervals']);
UPints = t.UPInts;
UPstarts = Start(UPints)/10000;
UPstops = End(UPints)/10000;

%% Load Spindles, get starts, stops
load(fullfile(basepath,'Spindles','SpindleData.mat'),'SpindleData')
normspindles = SpindleData.normspindles;
sp_starts = normspindles(:,1);
sp_stops = normspindles(:,3);

%% Generate histogram for starts
binwidth = 0.01;
mintime = -2;
maxtime = 2;

[startcounts,startbincenters] = ...
    CrossCorrelateByMesh(sp_starts,UPstarts,binwidth,mintime,maxtime);

%% Generate histogram for stops
binwidth = 0.01;
mintime = -2;
maxtime = 2;

[stopcounts,stopbincenters] = ...
    CrossCorrelateByMesh(sp_stops,UPstops,binwidth,mintime,maxtime);

%% plot
f = figure;
subplot(2,1,1)
bar(startbincenters,startcounts);
yl = get(gca,'ylim');
hold on;plot([0 0],yl,'r')
title('Spindle Starts relative to UP starts')

subplot(2,1,2)
bar(stopbincenters,stopcounts);
yl = get(gca,'ylim');
hold on;plot([0 0],yl,'r')
title('Spindle Stops relative to UP stops')

AboveTitle([basename 'Spindle vs UP state timing'],f)

