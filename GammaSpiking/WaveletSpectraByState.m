function WaveletSpectraByState(basepath)
% Individual cells correlated against various frequency bands.  Each cell
% vs each band.  Also population and broadband data used too.
% Brendon Watson 2017

%% Constants

%% Input handling
if ~exist('basepath','var')
    basepath = cd;
end
basename = bz_BasenameFromBasepath(basepath);

if ~exist('plotting','var')
    plotting = 0;
end

%% Loading up
load(fullfile(basepath,[basename '_WaveletForGamma.mat']),'amp')
load(fullfile(basepath,[basename '_WaveletForGamma.mat']),'bandmeans')
load(fullfile(basepath,[basename '_WaveletForGamma.mat']),'sampfreq')
load(fullfile(basepath,[basename '-states.mat']))
load(fullfile(basepath,[basename '_Motion']),'motiondata')

%restrict to good sleep interval, always thus far has been a single
%start-stop interval
load(fullfile(basepath,[basename '_GoodSleepInterval.mat']))
states((1:length(states))>GoodSleepInterval.timePairFormat(2)) = [];
states((1:length(states))<GoodSleepInterval.timePairFormat(1)) = [];


%extract intervals of states
ss = IDXtoINT(states);
AllTINTS = [1 length(states)];
WakeINTS = ss{1};
MaINTS = ss{2};
NremINTS = ss{3};
if length(ss)<5 
    RemINTS = [];
else
    RemINTS = ss{5};
end
MinMoveSecs = 5;
MinNonmoveSecs = 5;
WakeMove5INTS = continuousabove2_v2(motiondata.thresholdedsecs,0.5,MinMoveSecs,Inf);
%     WakeMove5IS = intervalSet(WakeMove5IN(:,1),WakeMove5IN(:,2));
%     WakeMove5IS = intersect(WakeMove5IS,WakeSecsIS);
%     WakeMove5IN = [Start(WakeMove5IS) End(WakeMove5IS)];
WakeMove5INTS = IntersectEpochs(WakeMove5INTS,WakeINTS);

WakeNonmove5INTS = continuousbelow2(motiondata.thresholdedsecs,0.5,MinNonmoveSecs,Inf);
%     WakeNonmove5IS = intervalSet(WakeNonmove5IN(:,1),WakeNonmove5IN(:,2));
%     WakeNonmove5IS = intersect(WakeNonmove5IS,WakeSecsIS);
%     WakeNonmove5IN = [Start(WakeNonmove5IS) End(WakeNonmove5IS)];
WakeNonmove5INTS = IntersectEpochs(WakeNonmove5INTS,WakeINTS);

1;

stateslist = {'AllT','Wake','WakeMove5','WakeNonmove5','Nrem','Rem','Ma'};
WaveletSpectrumByState.stateslist = stateslist;

for stidx = 1:length(stateslist)
    tst = stateslist{stidx};

    thisstatespectrum = nan(1,length(bandmeans));

    eval(['x = isempty(' tst 'INTS);'])
    if x
        continue
    end
    
    eval(['tstarts = ' tst 'INTS(:,1);'])
    eval(['tends = ' tst 'INTS(:,2);'])
    tamp = [];
    if length(tstarts)==1
        if tstarts==1 && tends*sampfreq == size(amp,1)
            thisstatespectrum = mean(amp,1);
        else
            tstartsamp = tstarts*sampfreq;
            tendsamp = tends*sampfreq;
            thisstatespectrum = mean(amp(tstartsamp:tendsamp,:),1);
        end             
    else
        for eidx = 1:length(tstarts) %for each episode
            tstartsamp = tstarts(eidx)*sampfreq;
            tendsamp = tends(eidx)*sampfreq;
            tamp = cat(1,tamp,amp(tstartsamp:tendsamp,:));
        end
        thisstatespectrum = mean(tamp,1);
    end
    clear tamp
    %save
    eval(['WaveletSpectrumByState.SpectrumFor' tst ' = thisstatespectrum;'])
    eval(['WaveletSpectrumByState.' tst 'INTS = ' tst 'INTS;'])
end

%% save
WaveletSpectrumByState.bandmeans = bandmeans;
WaveletSpectrumByState.sampfreq = sampfreq;

save(fullfile(basepath,[basename '_WaveletSpectrumByState']),'WaveletSpectrumByState','-v7.3')
1;
%% plot