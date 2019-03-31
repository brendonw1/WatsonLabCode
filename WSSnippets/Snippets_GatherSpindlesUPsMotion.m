function Snippets_GatherSpindlesUPsMotion(ep1,ep2)

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

if ~exist(fullfile(basepath,'Snippets'),'dir')
    mkdir(fullfile(basepath,'Snippets'))
end
if ~exist(fullfile(basepath,'Snippets',ep1str),'dir')
    mkdir(fullfile(basepath,'Snippets',ep1str))
end

%% UP state incidence
t = load(fullfile(basepath,[basename '_UPDOWNIntervals.mat']));
upstarts = Start(t.UPInts,'s');
upstartsarr = cat(2,ones(size(upstarts)),upstarts);

[preWakeUPs,postWakeUPs,tep1,tep2] = GatherVectorsFromEpochPairs(upstartsarr,ep1,ep2);
for a = 1:length(tep1)
    tprespan = tot_length(tep1{a},'s');
    meanPreWakeUPIncRate(a) = sum(logical(Data(preWakeUPs{a}{1})))/tprespan;
end
for a = 1:length(tep2)
    tpostspan = tot_length(tep2{a},'s');
    meanPostWakeUPIncRate(a) = sum(logical(Data(preWakeUPs{a}{1})))/tpostspan;
end

% UP state durations
updurations = End(t.UPInts,'s') - Start(t.UPInts,'s');
updurarr = cat(2,updurations,upstarts);
[preWakeUPdur,postWakeUPdur] = GatherVectorsFromEpochPairs(updurarr,ep1,ep2);
for a = 1:length(preWakeUPdur)
    meanPreWakeUPdur(a) = nanmean(Data(preWakeUPdur{a}{1}));
    meanPostWakeUPdur(a) = nanmean(Data(postWakeUPdur{a}{1}));
end

% UP state spike rates
t = load(fullfile(basepath,'UPstates',[basename '_UPSpikeStatsE.mat']));
% upspkcounts = t.isse.intspkcounts;
% upcountarr = cat(2,upstarts,updurations);
upspkrates = t.isse.intspkcounts./updurations;
upspkrtarr = cat(2,upspkrates,upstarts);
[preWakeUPrate,postWakeUPrate] = GatherVectorsFromEpochPairs(upspkrtarr,ep1,ep2);% upcountarr = cat(2,upstarts,updurations);
for a = 1:length(preWakeUPrate)
    meanPreWakeUPrate(a) = nanmean(Data(preWakeUPrate{a}{1}));
    meanPostWakeUPrate(a) = nanmean(Data(postWakeUPrate{a}{1}));
end

%% Spindle occurrence
t = load(fullfile(basepath,'Spindles','SpindleData.mat'));
spindlestarts = t.SpindleData.normspindles(:,1);
spindlestartsarr = cat(2,ones(size(spindlestarts)),spindlestarts);
[preWakeSpindles,postWakeSpindles,tep1,tep2] = GatherVectorsFromEpochPairs(spindlestartsarr,ep1,ep2);% upcountarr = cat(2,upstarts,updurations);
for a = 1:length(tep1)
    tprespan = tot_length(tep1{a},'s');
    meanPreWakeSpindleIncRate(a) = sum(logical(Data(preWakeSpindles{a}{1})))/tprespan;
end
for a = 1:length(tep2)
    tpostspan = tot_length(tep2{a},'s');
    meanPostWakeSpindleIncRate(a) = sum(logical(Data(postWakeSpindles{a}{1})))/tpostspan;
end

% Spindle duration
spindledur = t.SpindleData.data.duration;
spdurarr = cat(2,spindledur,spindlestarts);
[preWakeSpindleDur,postWakeSpindleDur] = GatherVectorsFromEpochPairs(spdurarr,ep1,ep2);% upcountarr = cat(2,upstarts,updurations);
for a = 1:length(preWakeSpindleDur)
    meanPreWakeSpindleDur(a) = nanmean(Data(preWakeSpindleDur{a}{1}));
    meanPostWakeSpindleDur(a) = nanmean(Data(postWakeSpindleDur{a}{1}));
end

% Spindle frequency
spindlefreq = t.SpindleData.data.peakFrequency;
spfreqarr = cat(2,spindlefreq,spindlestarts);
[preWakeSpindleFreq,postWakeSpindleFreq] = GatherVectorsFromEpochPairs(spfreqarr,ep1,ep2);% upcountarr = cat(2,upstarts,updurations);
for a = 1:length(preWakeSpindleFreq)
    meanPreWakeSpindleFreq(a) = nanmean(Data(preWakeSpindleFreq{a}{1}));
    meanPostWakeSpindleFreq(a) = nanmean(Data(postWakeSpindleFreq{a}{1}));
end

% Spindle amplitude
spindleamp = t.SpindleData.data.peakAmplitude;
spamparr = cat(2,spindleamp,spindlestarts);
[preWakeSpindleAmp,postWakeSpindleAmp] = GatherVectorsFromEpochPairs(spamparr,ep1,ep2);% upcountarr = cat(2,upstarts,updurations);
for a = 1:length(preWakeSpindleAmp)
    meanPreWakeSpindleAmp(a) = nanmean(Data(preWakeSpindleAmp{a}{1}));
    meanPostWakeSpindleAmp(a) = nanmean(Data(postWakeSpindleAmp{a}{1}));
end

% Spindle Spiking
t = load(fullfile(basepath,'Spindles',[basename '_SpindleSpikeStats.mat']));
spindlerates = t.isse.intspkcounts./spindledur;
spspkrtarr = cat(2,spindlerates,spindlestarts);
[preWakeSpindleRate,postWakeSpindleRate] = GatherVectorsFromEpochPairs(spspkrtarr,ep1,ep2);% upcountarr = cat(2,upstarts,updurations);
for a = 1:length(preWakeSpindleRate)
    meanPreWakeSpindleRate(a) = nanmean(Data(preWakeSpindleRate{a}{1}));
    meanPostWakeSpindleRate(a) = nanmean(Data(postWakeSpindleRate{a}{1}));
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
UPSpindleMotionSnippets = v2struct(preWakeUPs,postWakeUPs,meanPreWakeUPIncRate,meanPostWakeUPIncRate,...
    preWakeUPdur,postWakeUPdur,meanPreWakeUPdur,meanPostWakeUPdur,...
    preWakeUPrate,postWakeUPrate,meanPreWakeUPrate,meanPostWakeUPrate,...
    preWakeSpindles,postWakeSpindles,meanPreWakeSpindleIncRate,meanPostWakeSpindleIncRate,...
    preWakeSpindleDur,postWakeSpindleDur,meanPreWakeSpindleDur,meanPostWakeSpindleDur,...
    preWakeSpindleFreq,postWakeSpindleFreq,meanPreWakeSpindleFreq,meanPostWakeSpindleFreq,...
    preWakeSpindleAmp,postWakeSpindleAmp,meanPreWakeSpindleAmp,meanPostWakeSpindleAmp,...
    preWakeSpindleRate,postWakeSpindleRate,meanPreWakeSpindleRate,meanPostWakeSpindleRate,...
    motionSecsVect,motionRawVect,motionSecsSums);

savefilename = fullfile(basepath,'Snippets',ep1str,[basename '_UPSpindleMotionSnippets']);
save(savefilename,'UPSpindleMotionSnippets')


