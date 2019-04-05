function UPSpindleMotionWSSnippets = WSSnippets_GatherSpindlesUPsMotion(ep1,ep2)

if ~exist('basepath','var')
    [~,basename,~] = fileparts(cd);
    basepath = cd;
end

if ~exist('ep1','var')
    ep1 = '13sws';
end
if ~exist('ep2','var')
    ep2 = '[]';
end

if isnumeric(ep1)
    ep1str = inputdlg('Enter string to depict snippet timing');
else
    ep1str = ep1;
end

if ~exist(fullfile(basepath,'WSSnippets'),'dir')
    mkdir(fullfile(basepath,'WSSnippets'))
end
if ~exist(fullfile(basepath,'WSSnippets',ep1str),'dir')
    mkdir(fullfile(basepath,'WSSnippets',ep1str))
end

%% UP state incidence
t = load(fullfile(basepath,[basename '_UPDOWNIntervals.mat']));
upstarts = Start(t.UPInts,'s');
upstartsarr = cat(2,ones(size(upstarts)),upstarts);

[preUPs,postUPs,tep1,tep2] = GatherVectorsFromEpochPairs(upstartsarr,ep1,ep2);
for a = 1:length(tep1)
    tprespan = tot_length(tep1{a},'s');
    medianPreUPIncRate(a) = sum(logical(Data(preUPs{a}{1})))/tprespan;
end
for a = 1:length(tep2)
    tpostspan = tot_length(tep2{a},'s');
    medianPostUPIncRate(a) = sum(logical(Data(preUPs{a}{1})))/tpostspan;
end

% UP state durations
updurations = End(t.UPInts,'s') - Start(t.UPInts,'s');
updurarr = cat(2,updurations,upstarts);
[preUPDur,postUPDur] = GatherVectorsFromEpochPairs(updurarr,ep1,ep2);
for a = 1:length(preUPDur)
    medianPreUPDur(a) = nanmedian(Data(preUPDur{a}{1}));
    medianPostUPDur(a) = nanmedian(Data(postUPDur{a}{1}));
end

% UP state spike rates
t = load(fullfile(basepath,'UPstates',[basename '_UPSpikeStatsE.mat']));
% upspkcounts = t.isse.intspkcounts;
% upcountarr = cat(2,upstarts,updurations);
upspkrates = t.isse.intspkcounts./updurations;
upspkrtarr = cat(2,upspkrates,upstarts);
[preUPSpkRate,postUPSpkRate] = GatherVectorsFromEpochPairs(upspkrtarr,ep1,ep2);% upcountarr = cat(2,upstarts,updurations);
for a = 1:length(preUPSpkRate)
    medianPreUPSpkRate(a) = nanmedian(Data(preUPSpkRate{a}{1}));
    medianPostUPSpkRate(a) = nanmedian(Data(postUPSpkRate{a}{1}));
end

%% Spindle occurrence
t = load(fullfile(basepath,'Spindles','SpindleData.mat'));
spindlestarts = t.SpindleData.normspindles(:,1);
spindlestartsarr = cat(2,ones(size(spindlestarts)),spindlestarts);
[preSpindles,postSpindles,tep1,tep2] = GatherVectorsFromEpochPairs(spindlestartsarr,ep1,ep2);% upcountarr = cat(2,upstarts,updurations);
for a = 1:length(tep1)
    tprespan = tot_length(tep1{a},'s');
    medianPreSpindleIncRate(a) = sum(logical(Data(preSpindles{a}{1})))/tprespan;
end
for a = 1:length(tep2)
    tpostspan = tot_length(tep2{a},'s');
    medianPostSpindleIncRate(a) = sum(logical(Data(postSpindles{a}{1})))/tpostspan;
end

% Spindle duration
spindledur = t.SpindleData.data.duration;
spdurarr = cat(2,spindledur,spindlestarts);
[preSpindleDur,postSpindleDur] = GatherVectorsFromEpochPairs(spdurarr,ep1,ep2);% upcountarr = cat(2,upstarts,updurations);
for a = 1:length(preSpindleDur)
    medianPreSpindleDur(a) = nanmedian(Data(preSpindleDur{a}{1}));
    medianPostSpindleDur(a) = nanmedian(Data(postSpindleDur{a}{1}));
end

% Spindle frequency
spindlefreq = t.SpindleData.data.peakFrequency;
spfreqarr = cat(2,spindlefreq,spindlestarts);
[preSpindleFreq,postSpindleFreq] = GatherVectorsFromEpochPairs(spfreqarr,ep1,ep2);% upcountarr = cat(2,upstarts,updurations);
for a = 1:length(preSpindleFreq)
    medianPreSpindleFreq(a) = nanmedian(Data(preSpindleFreq{a}{1}));
    medianPostSpindleFreq(a) = nanmedian(Data(postSpindleFreq{a}{1}));
end

% Spindle amplitude
spindleamp = t.SpindleData.data.peakAmplitude;
spamparr = cat(2,spindleamp,spindlestarts);
[preSpindleAmp,postSpindleAmp] = GatherVectorsFromEpochPairs(spamparr,ep1,ep2);% upcountarr = cat(2,upstarts,updurations);
for a = 1:length(preSpindleAmp)
    medianPreSpindleAmp(a) = nanmedian(Data(preSpindleAmp{a}{1}));
    medianPostSpindleAmp(a) = nanmedian(Data(postSpindleAmp{a}{1}));
end

% Spindle Spiking
t = load(fullfile(basepath,'Spindles',[basename '_SpindleSpikeStats.mat']));
spindlerates = t.isse.intspkcounts./spindledur;
spspkrtarr = cat(2,spindlerates,spindlestarts);
[preSpindleSpkRate,postSpindleSpkRate] = GatherVectorsFromEpochPairs(spspkrtarr,ep1,ep2);% upcountarr = cat(2,upstarts,updurations);
for a = 1:length(preSpindleSpkRate)
    medianPreSpindleSpkRate(a) = nanmedian(Data(preSpindleSpkRate{a}{1}));
    medianPostSpindleSpkRate(a) = nanmedian(Data(postSpindleSpkRate{a}{1}));
end

%% Motion per sec
t = load(fullfile(basepath,[basename '_Motion.mat']));
motionsecs = t.motiondata.thresholdedsecs;
motionraw = t.motiondata.motion;
% grab ws eps, grab vect and sum of motion secs for each

wsw = load(fullfile(basepath,[basename '_WSWEpisodes2']));
WSEpisodes = wsw.WSEpisodes;
numWSEpisodes = size(WSEpisodes,2);
GoodSleepInterval = wsw.GoodSleepInterval;

tempeps1 = [];
for a = 1:numWSEpisodes;
    t1 = [Start(subset(WSEpisodes{a},1),'s') End(subset(WSEpisodes{a},1),'s')];
    motionRawVect{a} = motionraw(t1(1):t1(2));
    motionSecsVect{a} = motionsecs(t1(1):t1(2));
    motionSecsSums(a) = sum(motionSecsVect{a});
end                    

%% Save
UPSpindleMotionWSSnippets = v2struct(preUPs,postUPs,medianPreUPIncRate,medianPostUPIncRate,...
    preUPDur,postUPDur,medianPreUPDur,medianPostUPDur,...
    preUPSpkRate,postUPSpkRate,medianPreUPSpkRate,medianPostUPSpkRate,...
    preSpindles,postSpindles,medianPreSpindleIncRate,medianPostSpindleIncRate,...
    preSpindleDur,postSpindleDur,medianPreSpindleDur,medianPostSpindleDur,...
    preSpindleFreq,postSpindleFreq,medianPreSpindleFreq,medianPostSpindleFreq,...
    preSpindleAmp,postSpindleAmp,medianPreSpindleAmp,medianPostSpindleAmp,...
    preSpindleSpkRate,postSpindleSpkRate,medianPreSpindleSpkRate,medianPostSpindleSpkRate,...
    motionSecsVect,motionRawVect,motionSecsSums);

savefilename = fullfile(basepath,'WSSnippets',ep1str,[basename '_UPSpindleMotionWSSnippets']);
save(savefilename,'UPSpindleMotionWSSnippets')


